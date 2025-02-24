
import UIKit
import SDWebImage

class GrpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var images: [ImageData] = []
    var schools: [School] = [] // Received from SetPINViewController
    var groupDatas: [GroupData] = []
    @IBOutlet var teamCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received schools data: \(schools)")
        teamCollectionView.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupCollectionViewCell")
        teamCollectionView.reloadData()
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
        // Configure the image icon
        if let imageUrl = getImageURL(from: school.image), !imageUrl.absoluteString.isEmpty {
            cell.anImageIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"), options: .refreshCached) { image, error, _, _ in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            }
        } else {
            cell.anImageIcon.image = UIImage(named: "new_banner.png") // Default image if no URL
        }
        
        // Configure other cell elements
        cell.configure(with: school)
    }
    
    
    // Helper to get URL from image string (either direct URL or Base64 encoded)
    private func getImageURL(from imageString: String) -> URL? {
        // Check if the string is a valid URL
        if let url = URL(string: imageString), UIApplication.shared.canOpenURL(url) {
            return url
        }
        
        // Decode Base64 to URL
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
        let schoolData = schools[indexPath.item]
        print("Selected school: \(schoolData.shortName) with ID: \(schoolData.id)")
        
        // Instantiate storyboard and HomeVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
            print("Successfully instantiated HomeVC")
            
            // Pass the school data
            homeVC.school = schoolData
            
            // Create a DispatchGroup to manage multiple API calls
            let dispatchGroup = DispatchGroup()
            var imageUrls: [String]?
            
            // Fetch Banner Image
            dispatchGroup.enter()
            fetchBannerImage(groupId: schoolData.id) { urls in
                imageUrls = urls
                dispatchGroup.leave()
            }
            
            // Fetch User Profile
            dispatchGroup.enter()
            fetchUserProfile(groupId: schoolData.id) { profile in
                homeVC.name = profile
                dispatchGroup.leave()
             }
          
            dispatchGroup.enter()
            fetchHomeData(groupId: schoolData.id) { groupData in
                if let groupData = groupData {
                    // Pass the fetched group data to homeVC
                    DispatchQueue.main.async {
                        homeVC.groupDatas = groupData  // Store the fetched data in groupDatas
                       // homeVC.tableView.reloadData()  // Reload the table view to display the new data
                    }

                    // Debugging output
                    for group in groupData {
                        print("Fetched Activity: \(group.activity)")
                        for icon in group.featureIcons {
                            print("Feature Type: \(icon.type), Image: \(icon.image)")
                        }
                    }
                }
                dispatchGroup.leave()
            }

            
            dispatchGroup.notify(queue: .main) {
                if let imageUrls = imageUrls {
                    // Pass the image URLs to HomeVC
                    homeVC.imageUrls = imageUrls
                }
                print("All API calls have finished!")
                
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
            
            DispatchQueue.main.async {
                self.teamCollectionView.reloadData()
            }
            
        }
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
                    
                    // If there is no image or fileName is null, use the default image
                    if let item = dataArray.first, let fileNames = item["fileName"] as? [String?], fileNames.first == nil {
                        imageUrls = ["new_banner.png"] // Use default image
                    } else {
                        // Loop through the file names and append valid image URLs
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
                    
                    completion(imageUrls.isEmpty ? ["new_banner.png"] : imageUrls) // Ensure default image is passed
                } else {
                    completion(["new_banner.png"]) // Default image if no data found
                }
            } catch {
                print("Error parsing API response: \(error.localizedDescription)")
                completion(["new_banner.png"]) // Default image in case of parsing error
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
        
        print("Sending request to Profile: \(urlString)")
        print("Using token: \(token)")
        
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
            
            // Print the raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data of profile: \(responseString)") // Log raw response
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Parsed JSON Response: \(json)") // Print parsed JSON response
                    
                    // Check if the 'data' key exists in the JSON response
                    if let dataArray = json["data"] as? [[String: Any]] {
                        print("Data Array: \(dataArray)") // Log the entire data array to inspect its contents
                        
                        if let name = dataArray.first?["name"] as? String {
                            print("Fetched name: \(name)") // Print the fetched name
                            completion(name) // Return the name of the user
                        } else {
                            print("Name not found in response")
                            completion(nil)
                        }
                    } else {
                        print("Invalid 'data' format in response")
                        completion(nil)
                    }
                } else {
                    print("Failed to parse JSON response")
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

            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response of Home API: \(rawResponse)")
            }

            do {
                // Parse JSON using JSONSerialization
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = jsonResponse["data"] as? [[String: Any]] {
                    // Map data array to GroupData model
                    let groups = dataArray.compactMap { groupDict -> GroupData? in
                        guard let activity = groupDict["activity"] as? String,
                              let featureIconsArray = groupDict["featureIcons"] as? [[String: Any]] else {
                            return nil
                        }

                        // Map featureIcons to FeatureIcon model
                        let featureIcons = featureIconsArray.compactMap { iconDict -> FeatureIcon? in
                            guard let type = iconDict["type"] as? String,
                                  let image = iconDict["image"] as? String else {
                                return nil
                            }
                            return FeatureIcon(type: type, image: image)
                        }

                        return GroupData(activity: activity, featureIcons: featureIcons)
                    }
                    // Print fetched data for debugging
                                    print("Fetched Group Data:")
                                    for group in groups {
                                        print("Activity: \(group.activity)")
                                        for icon in group.featureIcons {
                                            print("Type H: \(icon.type), Image H: \(icon.image)")
                                        }
                                    }

                    // Pass the parsed data to completion
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
