import UIKit

class rolesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var rolesLabel: UILabel!
    @IBOutlet weak var rolesCollectionView: UICollectionView!

    // MARK: - Properties
    private var roles: [UserRole] = []
    var homeData: [HomeResponse] = []  // ✅ Stored here
    var groupToken: String?
    var groupName: String?
    var roleName: String?

    private var hasConfiguredSheet = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        registerCollectionView()
        fetchUserRoles()
    }

    // MARK: - UI Setup
    private func setupUI() {
        rolesCollectionView.layer.cornerRadius = 10
        rolesCollectionView.layer.masksToBounds = true
        rolesLabel.text = groupName != nil ? "Roles for \(groupName!)" : "Select Role"
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

    // MARK: - API: Fetch User Roles
    private func fetchUserRoles() {
        guard let token = groupToken else {
            showAlert(message: "Group token missing")
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.request(
            endpoint: "user-role",
            method: .get,
            headers: headers
        ) { (result: Result<UserRoleResponse, APIManager.APIError>) in

            switch result {
            case .success(let response):
                self.roles = response.data
                self.rolesCollectionView.reloadData()
//                self.configureSheetHeight()

                // Save first role token (optional default)
                if let firstToken = response.data.first?.token {
                    UserDefaults.standard.set(firstToken, forKey: "user_role_Token")
                }

            case .failure(let error):
                print("❌ User-role error:", error)
                self.showAlert(message: "Unable to fetch roles")
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
        case 1...4: height = screenHeight * 0.16
        case 5...8: height = screenHeight * 0.23
        case 9...12: height = screenHeight * 0.40
        default: height = screenHeight * 0.50
        }

        let detent = UISheetPresentationController.Detent.custom(
            identifier: .init("dynamic")
        ) { _ in height }

        sheet.detents = count >= 16 ? [detent, .medium()] : [detent]
        sheet.selectedDetentIdentifier = .init("dynamic")
        sheet.prefersGrabberVisible = true
    }

    // MARK: - Alert
    private func showAlert(title: String = "Alert", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CollectionView Delegate & DataSource
extension rolesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        roles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupCollectionViewCell",
            for: indexPath
        ) as! GroupCollectionViewCell

        cell.configure(with: roles[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let selectedRole = roles[indexPath.row]

        // Save role token
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
