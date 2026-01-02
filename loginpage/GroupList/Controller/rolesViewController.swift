import UIKit


class rolesViewController: UIViewController {

    @IBOutlet weak var rolesLabel: UILabel!
    @IBOutlet weak var rolesCollectionView: UICollectionView!
//    @IBOutlet weak var backButton: UIButton!

    private var roles: [UserRole] = []
    var groupToken: String?
    var groupName: String?
    var roleName: String?
    private var hasConfiguredSheet = false


    override func viewDidLoad() {
        super.viewDidLoad()
        rolesCollectionView.layer.cornerRadius = 10
        rolesCollectionView.layer.masksToBounds = true
        rolesLabel.text = "Select Role"
        if let name = groupName {
            rolesLabel.text = "Roles for \(name)"
        }

        registerCollectionView()
        fetchUserRoles()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
           print("Removed group token and role token!!!!!!")
        SessionManager.removeUserRoleToken()
       }
    

    // MARK: - CollectionView Setup
    private func registerCollectionView() {
        rolesCollectionView.delegate = self
        rolesCollectionView.dataSource = self

        rolesCollectionView.register(
            UINib(nibName: "GroupCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GroupCollectionViewCell"
        )
    }
    
    
    
    // MARK: - API Call (GET user-role)
    private func fetchUserRoles() {
        guard let token = groupToken else {
            showAlert(message: "Token missing")
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.request(
            endpoint: "user-role",
            method: .get,
            headers: headers
        ) { (result: Result<UserRoleResponse, APIManager.APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("response......", response)
                    self.roles = response.data
                    self.rolesCollectionView.reloadData()
                    
                    DispatchQueue.main.async {
                           self.configureSheetHeight()
                       }
                    
                    // ✅ Save the first role's token in UserDefaults (if exists)
                    if let firstToken = response.data.first?.token {
                        UserDefaults.standard.set(firstToken, forKey: "user_role_Token")
                        print("🔑 Token saved in UserDefaults:", firstToken)
                    }

                case .failure(let error):
                    print("❌ User Role API Error:", error)
                    self.showAlert(message: "Unable to fetch roles")
                }
            }
        }
    }

    private func configureSheetHeight() {
        guard let sheet = sheetPresentationController,
              !hasConfiguredSheet else { return }

        hasConfiguredSheet = true

        let count = roles.count
        let screenHeight = UIScreen.main.bounds.height
        let height: CGFloat

        switch count {
        case 1...4:
            height = screenHeight * 0.16
        case 5...8:
            height = screenHeight * 0.23
        case 9...12:
            height = screenHeight * 0.40
        default:
            height = screenHeight * 0.5
        }

        let detent = UISheetPresentationController.Detent.custom(
            identifier: .init("dynamic")
        ) { _ in height }

        sheet.detents = count >= 16 ? [detent, .medium()] : [detent]
        sheet.selectedDetentIdentifier = .init("dynamic")
        sheet.prefersGrabberVisible = true
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }



    // MARK: - Alert Helper
    func showAlert(title: String = "Alert", message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)

        present(alert, animated: true)
    }

//    @IBAction func backButtonTapped(_ sender: UIButton) {
//        dismiss(animated: true)
//    }
    
}

// MARK: - CollectionView Delegate & DataSource
extension rolesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return roles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupCollectionViewCell",
            for: indexPath
        ) as! GroupCollectionViewCell

        let role = roles[indexPath.row]
//        cell.aLabelTeamNameIcon.text = self.roleName
        cell.configure(with: role) // Make sure configure supports UserRole

        return cell
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//
//        let selectedRole = roles[indexPath.row]
//        print("✅ Selected Role:", selectedRole.roleName)
//        print("Token:", selectedRole.token)
//
//        // You can handle role selection here, e.g., dismiss or navigate
//    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let selectedRole = roles[indexPath.row]
        print("✅ Selected Role:", selectedRole.roleName)
        print("Token:", selectedRole.token)

        // Save selected role token
        UserDefaults.standard.set(selectedRole.token, forKey: "user_role_Token")

        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(
                withIdentifier: "HomeVC"
            ) as! HomeVC

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let nav = UINavigationController(rootViewController: homeVC)
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }

}
