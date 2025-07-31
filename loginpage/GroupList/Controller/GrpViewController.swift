
import UIKit
import SDWebImage

class GrpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var teamCollectionView: UICollectionView!
    
    var images: [ImageData] = []
    var schools: [School] = [] // Received from SetPINViewController
    var groupDatas: [GroupData] = []
    var currentRole: String?
    private var isProcessingSelection = false
    var logoutDropdownView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        callAPIAndNavigate { [weak self] in
            guard let self = self else { return }
            print("API call finished, reloading collection view...")

            // Prefetch all images to cache
            let urls = self.schools.compactMap { self.getImageURL(from: $0.image) }
            SDWebImagePrefetcher.shared.prefetchURLs(urls)
            let tapOutside = UITapGestureRecognizer(target: self, action: #selector(dismissLogoutDropdown))
            tapOutside.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapOutside)
            self.teamCollectionView.reloadData()
        }

        print("Received schools data: \(schools)")
        teamCollectionView.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupCollectionViewCell")
        enableKeyboardDismissOnTap()
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        // Remove previous dropdown if visible
        logoutDropdownView?.removeFromSuperview()

        // Get the button’s position in the view's coordinate space
        guard let buttonSuperview = sender.superview else { return }
        let buttonFrameInView = buttonSuperview.convert(sender.frame, to: self.view)

        // Define size of logout overlay
        let overlayWidth = 100.0
        let overlayHeight: CGFloat = 40

        // Place overlay **exactly over the button**
        let overlayFrame = CGRect(x: buttonFrameInView.origin.x - 60,
                                  y: buttonFrameInView.origin.y - 10,
                                  width: overlayWidth,
                                  height: overlayHeight)

        // Create view
        let dropdownView = UIView(frame: overlayFrame)
        dropdownView.backgroundColor = .white
        dropdownView.layer.cornerRadius = 8
        dropdownView.layer.borderWidth = 1
        dropdownView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownView.clipsToBounds = true

        // Add "Logout" label or button
        let label = UILabel(frame: dropdownView.bounds)
        label.text = "Logout"
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isUserInteractionEnabled = true
        dropdownView.addSubview(label)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLogoutTap))
        label.addGestureRecognizer(tap)

        // Add to main view
        self.view.addSubview(dropdownView)
        self.logoutDropdownView = dropdownView
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

    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schools.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionViewCell", for: indexPath) as? GroupCollectionViewCell else {
            fatalError("Unable to dequeue GroupCollectionViewCell.")
        }

        let school = schools[indexPath.row]
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 4
        let spacing: CGFloat = 5
        let totalSpacing = (2 * spacing) + ((numberOfItemsPerRow - 1) * spacing)
        let itemWidth = (collectionView.frame.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: itemWidth, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingSelection else {
            print("Tap ignored – already processing.")
            return
        }

        isProcessingSelection = true

        let schoolData = schools[indexPath.item]
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
                if let groupData = groupData {
                    DispatchQueue.main.async {
                        homeVC.groupDatas = groupData
                        homeVC.currentRole = self.currentRole
                    }
                }
                dispatchGroup.leave()
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

    func fetchHomeData(groupId: String, completion: @escaping ([GroupData]?) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            completion(nil)
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/home"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
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

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response of Home API: \(rawResponse)")
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = jsonResponse["data"] as? [[String: Any]] {
                    let groups = dataArray.compactMap { groupDict -> GroupData? in
                        guard let activity = groupDict["activity"] as? String,
                              let featureIconsArray = groupDict["featureIcons"] as? [[String: Any]] else {
                            return nil
                        }

                        let featureIcons = featureIconsArray.compactMap { iconDict -> FeatureIcon? in
                            guard let name = iconDict["name"] as? String,
                                  let image = iconDict["image"] as? String,
                                  let role = iconDict["role"] as? String else {
                                return nil
                            }
                            self.currentRole = role
                            return FeatureIcon(name: name, image: image, role: role)
                        }

                        return GroupData(activity: activity, featureIcons: featureIcons)
                    }
                    completion(groups)
                } else {
                    print("Unexpected response format or missing data key")
                    completion(nil)
                }
            } catch {
                print("Error parsing API response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }


}

