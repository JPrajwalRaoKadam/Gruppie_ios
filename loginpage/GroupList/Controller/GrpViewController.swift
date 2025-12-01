import UIKit
import SDWebImage

class GrpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet var teamCollectionView: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    
    var images: [ImageData] = []
    var schools: [School] = [] // Received from SetPINViewController
    var filteredSchools: [School] = [] // For search results
    var groupDatas: [GroupData] = []
    var currentRole: String?
    private var isProcessingSelection = false
    var logoutDropdownView: UIView?
    var searchTextField: UITextField?
    
    // Track search state
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAPIAndNavigate { [weak self] in
            guard let self = self else { return }
            print("API call finished, reloading collection view...")
            
            searchView.layer.cornerRadius = 10
            teamCollectionView.layer.cornerRadius = 10
            
            // Initialize filtered schools with all schools
            self.filteredSchools = self.schools
            
            // 🔹 Directly show search text field (no tap required)
            setupSearchTextField()
            
            // Prefetch all images to cache
            let urls = self.schools.compactMap { self.getImageURL(from: $0.image) }
            SDWebImagePrefetcher.shared.prefetchURLs(urls)
            
            let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissLogoutDropdown(_:)))
            tapOutside.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapOutside)
            
            self.teamCollectionView.reloadData()
        }
        teamCollectionView.register(
            SchoolsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SchoolsHeaderView.identifier
        )
        
        print("Received schools data: \(schools)")
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
        searchTextField?.layer.cornerRadius = searchView.layer.cornerRadius
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
        guard let searchText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if searchText.isEmpty {
            // Show all schools when search is empty
            isSearching = false
            filteredSchools = schools
        } else {
            // Filter schools based on search text
            isSearching = true
            filteredSchools = schools.filter { school in
                // Search in multiple fields - adjust based on your School model properties
                let nameMatch = school.name.range(of: searchText, options: .caseInsensitive) != nil
                let shortNameMatch = school.shortName.range(of: searchText, options: .caseInsensitive) != nil
                let descriptionMatch = school.name.range(of: searchText, options: .caseInsensitive) != nil
                
                // Add any other fields you want to search in
                return nameMatch || shortNameMatch || descriptionMatch
            }
        }
        
        // Reload collection view with filtered results
        teamCollectionView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // Clear search and show all schools
        isSearching = false
        filteredSchools = schools
        teamCollectionView.reloadData()
        
        // Let the text field clear its text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.teamCollectionView.reloadData()
        }
        
        return true
    }
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSchools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionViewCell", for: indexPath) as? GroupCollectionViewCell else {
            fatalError("Unable to dequeue GroupCollectionViewCell.")
        }
        
        let school = filteredSchools[indexPath.row]
        configureCell(cell, with: school)
        
        return cell
    }
    
    private func configureCell(_ cell: GroupCollectionViewCell, with school: School) {
        if let imageUrl = getImageURL(from: school.image), !imageUrl.absoluteString.isEmpty {
            cell.anImageIcon.sd_setImage(
                with: imageUrl,
                placeholderImage: UIImage(named: "placeholder"),
                options: [.retryFailed, .continueInBackground]
            ) { image, error, _, _ in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        } else {
            cell.anImageIcon.image = UIImage(named: "new_banner.png") // Default image if no URL
        }
        
        cell.configure(with: school)
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
        
        let schoolData = filteredSchools[indexPath.item]
        print("Selected school: \(schoolData.shortName) with ID: \(schoolData.id)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
            homeVC.school = schoolData
            let dispatchGroup = DispatchGroup()
            var imageUrls: [String]?
            
            dispatchGroup.enter()
            fetchBannerImage(groupId: schoolData.id) { urls in
                imageUrls = urls
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            fetchUserProfile(groupId: schoolData.id) { profile in
                homeVC.name = profile
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            fetchHomeData(groupId: schoolData.id) { groupData in
                DispatchQueue.main.async {
                    if let groupData = groupData {
                        homeVC.groupDatas = groupData
                        homeVC.currentRole = self.currentRole
                        print("✅ Loaded \(groupData.count) groups")
                    } else {
                        print("⚠️ No group data received")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                homeVC.imageUrls = imageUrls ?? []
                self.navigationController?.pushViewController(homeVC, animated: true)
                self.isProcessingSelection = false
            }
            
            DispatchQueue.main.async {
                self.teamCollectionView.reloadData()
            }
        } else {
            self.isProcessingSelection = false
        }
    }
    
    
    private func filterSchools(with searchText: String) {
        if searchText.isEmpty {
            filteredSchools = schools
        } else {
            filteredSchools = schools.filter { school in
                // Customize this based on what properties you want to search
                let nameMatch = school.name.localizedCaseInsensitiveContains(searchText) ?? false
                let shortNameMatch = school.shortName.localizedCaseInsensitiveContains(searchText)
                let descriptionMatch = school.name.localizedCaseInsensitiveContains(searchText) ?? false
                
                return nameMatch || shortNameMatch || descriptionMatch
            }
        }
        teamCollectionView.reloadData()
    }
    
    // MARK: - API Methods
    private func callAPIAndNavigate(completion: @escaping () -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token is nil. Cannot proceed with API call.")
            completion()
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups?category=school"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API call failed with error: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("API call failed with response: \(response.debugDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let schoolResponse = try decoder.decode(SchoolResponse.self, from: data)
                
                guard let schoolsData = schoolResponse.data else {
                    print("No schools data found.")
                    completion()
                    return
                }
                
                self.schools = schoolsData.compactMap { School(from: $0) }
                self.filteredSchools = self.schools // Initialize filtered schools
                print("Fetched Schools: \(self.schools.map { $0.shortName })")
                
                DispatchQueue.main.async {
                    completion()
                }
                
            } catch {
                print("Failed to decode API response: \(error.localizedDescription)")
                completion()
            }
        }
        
        task.resume()
    }
    
    func fetchBannerImage(groupId: String, completion: @escaping ([String]?) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            completion(nil)
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/banner/get/new"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    var imageUrls: [String] = []
                    
                    if let item = dataArray.first, let fileNames = item["fileName"] as? [String?], fileNames.first == nil {
                        imageUrls = ["new_banner.png"]
                    } else {
                        for item in dataArray {
                            if let fileNames = item["fileName"] as? [[String: Any]] {
                                for file in fileNames {
                                    if let imageUrl = file["name"] as? String {
                                        imageUrls.append(imageUrl)
                                    }
                                }
                            }
                        }
                    }
                    
                    completion(imageUrls.isEmpty ? ["new_banner.png"] : imageUrls)
                } else {
                    completion(["new_banner.png"])
                }
            } catch {
                print("Error parsing API response: \(error.localizedDescription)")
                completion(["new_banner.png"])
            }
        }
        
        task.resume()
    }
    
    func fetchUserProfile(groupId: String, completion: @escaping (String?) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            completion(nil)
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/my/kids/profile"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data of profile: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]],
                   let name = dataArray.first?["name"] as? String {
                    completion(name)
                } else {
                    print("Name not found or data format invalid")
                    completion(nil)
                }
            } catch {
                print("Error parsing API response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private func fetchHomeData(groupId: String, completion: @escaping ([GroupData]?) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            completion(nil)
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/home"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }
            
            // 🪶 Print raw response for verification
            if let raw = String(data: data, encoding: .utf8) {
                print("\n🔹 Raw Response of Home API:\n\(raw)\n")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // ✅ Decode using wrapper object
                let response = try decoder.decode(HomeResponse.self, from: data)
                let groups = response.data
                
                // ✅ Debug print
                print("✅ Successfully decoded groups:")
                for group in groups {
                    print("→ Activity: \(group.activity)")
                    for icon in group.featureIcons {
                        print("   - \(icon.name) (\(icon.role ?? "no role"))")
                        self.currentRole = icon.role
                    }
                }
                
                completion(groups)
            } catch {
                print("❌ Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
