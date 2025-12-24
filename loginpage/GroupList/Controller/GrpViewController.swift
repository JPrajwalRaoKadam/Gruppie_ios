import UIKit
import SDWebImage

class GrpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet var teamCollectionView: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    
//    var images: [ImageData] = []
//    var schools: [School] = [] // Received from SetPINViewController
//    var filteredSchools: [School] = [] // For search results
    var filteredGroups: [GroupItem] = []
    var groupDatas: [GroupData] = []
    var currentRole: String?
    private var isProcessingSelection = false
    var logoutDropdownView: UIView?
    var searchTextField: UITextField?
    var groupDataResponse: [GroupItem] = []
    
    // Track search state
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let token = UserDefaults.standard.string(forKey: "login_token") else {
            print("❌ Login token missing, redirecting to login")
            navigateToLogin()
            return
        }
        
        print("✅ Login token found:", token)
        
        callAPIAndNavigate { [weak self] data in
            guard let self = self else { return }

            self.groupDataResponse = data
            self.filteredGroups = data   // initialize

            DispatchQueue.main.async {
                self.teamCollectionView.reloadData()
            }
        }

        
        func navigateToLogin() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
            
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
      setupSearchTextField()
      searchView.layer.cornerRadius = 10
      teamCollectionView.layer.cornerRadius = 10

        teamCollectionView.register(
            SchoolsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SchoolsHeaderView.identifier
        )
        
        teamCollectionView.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "GroupCollectionViewCell")
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        // Remove previous dropdown if visible
        //        logoutDropdownView?.removeFromSuperview()
        //
        //        // Get the button's position in the view's coordinate space
        //        guard let buttonSuperview = sender.superview else { return }
        //        let buttonFrameInView = buttonSuperview.convert(sender.frame, to: self.view)
        //
        //        // Define size of logout overlay
        //        let overlayWidth = 100.0
        //        let overlayHeight: CGFloat = 40
        //
        //        // Place overlay **exactly over the button**
        //        let overlayFrame = CGRect(x: buttonFrameInView.origin.x - 60,
        //                                  y: buttonFrameInView.origin.y - 10,
        //                                  width: overlayWidth,
        //                                  height: overlayHeight)
        //
        //        // Create view
        //        let dropdownView = UIView(frame: overlayFrame)
        //        dropdownView.backgroundColor = .white
        //        dropdownView.layer.cornerRadius = 8
        //        dropdownView.layer.borderWidth = 1
        //        dropdownView.layer.borderColor = UIColor.lightGray.cgColor
        //        dropdownView.clipsToBounds = true
        //
        //        // Add "Logout" label or button
        //        let label = UILabel(frame: dropdownView.bounds)
        //        label.text = "Logout"
        //        label.textAlignment = .center
        //        label.textColor = .red
        //        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        //        label.isUserInteractionEnabled = true
        //        dropdownView.addSubview(label)
        //
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLogoutTap))
        //        label.addGestureRecognizer(tap)
        //
        //        // Add to main view
        //        self.view.addSubview(dropdownView)
        //        self.logoutDropdownView = dropdownView
    }
    
    func setupSearchTextField() {
        // Avoid re-adding if already exists
        guard searchTextField == nil else { return }
        
        searchTextField = UITextField(frame: searchView.bounds)
        searchTextField?.placeholder = "Search schools..."
        searchTextField?.delegate = self
        searchTextField?.backgroundColor = .white
        searchTextField?.borderStyle = .none
        searchTextField?.layer.cornerRadius = 10
        searchTextField?.clipsToBounds = true
        searchTextField?.font = UIFont.systemFont(ofSize: 16)
        searchTextField?.clearButtonMode = .whileEditing
        searchTextField?.autocorrectionType = .no
        searchTextField?.returnKeyType = .search
        searchTextField?.autocapitalizationType = .none
        
        // Add target for text changes
        searchTextField?.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
        // ✅ Add right-side search icon
        let rightIconView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: searchTextField!.frame.height))
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .gray
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 5, y: 10, width: 20, height: 20)
        rightIconView.addSubview(icon)
        searchTextField?.rightView = rightIconView
        searchTextField?.rightViewMode = .always
        
        // Optional left padding
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: searchTextField!.frame.height))
        searchTextField?.leftView = leftPaddingView
        searchTextField?.leftViewMode = .always
        
        if let searchTextField = searchTextField {
            searchView.addSubview(searchTextField)
        }
    }
    
    @objc func handleLogoutTap() {
        logoutDropdownView?.removeFromSuperview()
        
        // Perform logout
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "loggedInPhone")
        
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: loginVC)
        }
    }
    
    @objc func dismissLogoutDropdown(_ sender: UITapGestureRecognizer) {
        logoutDropdownView?.removeFromSuperview()
    }
    
    // MARK: - Search TextField Methods
    @objc func searchTextChanged(_ textField: UITextField) {
        filterGroups(with: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearching = false
        filteredGroups = groupDataResponse
        teamCollectionView.reloadData()
        return true
    }

    
    // MARK: - API Methods
    private func callAPIAndNavigate(
        completion: @escaping ([GroupItem]) -> Void
    ) {
        
        guard let authToken = UserDefaults.standard.string(forKey: "login_token") else {
            print("❌ groups_token not found")
            completion([])
            return
        }
        
        let headers = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        APIManager.shared.request(
            endpoint: "groups",
            method: .get,
            headers: headers
        ) { (result: Result<GroupsResponsee, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                print("✅ API Status:", response.status)
                print("Response123  \(response)")
                
                // ✅ Save token
                if let firstGroup = response.data.first {
                    UserDefaults.standard.set(firstGroup.token, forKey: "groups_token")
                    print("✅ Group token stored")
                }
                
                completion(response.data)
                
            case .failure(let error):
                print("❌ API failed:", error)
                completion([])
            }
        }
    }
    
    
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredGroups.count : groupDataResponse.count
    }

    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GroupCollectionViewCell",
            for: indexPath
        ) as? GroupCollectionViewCell else {
            fatalError("Cell not found")
        }

        let group = isSearching
            ? filteredGroups[indexPath.item]
            : groupDataResponse[indexPath.item]

        cell.configure(with: group)
        return cell
    }
    private func filterGroups(with searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            isSearching = false
            filteredGroups = groupDataResponse
            teamCollectionView.reloadData()
            return
        }

        isSearching = true

        filteredGroups = groupDataResponse.filter {
            $0.groupName.localizedCaseInsensitiveContains(text)
        }

        teamCollectionView.reloadData()
    }

    
    private func getImageURL(from imageString: String) -> URL? {
        if let url = URL(string: imageString), UIApplication.shared.canOpenURL(url) {
            return url
        }
        return decodeBase64ToURL(from: imageString)
    }
    
    private func decodeBase64ToURL(from base64String: String) -> URL? {
        let cleanedString = base64String.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let decodedData = Data(base64Encoded: cleanedString),
              let decodedString = String(data: decodedData, encoding: .utf8),
              let url = URL(string: decodedString) else {
            return nil
        }
        return url
    }
    
    // MARK: - Collection View Layout
    
    // MARK: - Header View
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SchoolsHeaderView.identifier,
                for: indexPath
            ) as! SchoolsHeaderView
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 4 columns with small gaps
        let itemsPerRow: CGFloat = 4
        let padding: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * padding
        let availableWidth = collectionView.frame.width - totalSpacing - 20 // 10 left + 10 right inset
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        // slightly taller for image + label
        return CGSize(width: itemWidth, height: itemWidth + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // vertical gap between rows
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // horizontal gap between items
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard !isProcessingSelection else {
            print("Tap ignored – already processing.")
            return
        }
        
        isProcessingSelection = true
        
        // ✅ Get selected group
        let selectedGroup = groupDataResponse[indexPath.item]
        
        print("✅ Selected Group:")
        print("Group Name:", selectedGroup.groupName)
        print("Role:", selectedGroup.roleName)
        print("Category:", selectedGroup.gruppieCategory)
        
        // ✅ Store selected group token if needed
        UserDefaults.standard.set(selectedGroup.token, forKey: "groups_token")
        
        // 👉 Navigate to next screen (example: HomeVC)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
            
            // Pass basic group info
            homeVC.Role = selectedGroup.roleName
            homeVC.groupName = selectedGroup.groupName   // create this var in HomeVC if needed
            
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        
        isProcessingSelection = false
    }
}
