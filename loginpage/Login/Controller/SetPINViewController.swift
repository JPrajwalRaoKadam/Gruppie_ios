import UIKit

class SetPINViewController: UIViewController, UITextFieldDelegate {
    // UI Outlets
    @IBOutlet weak var spinBox1: UITextField!
    @IBOutlet weak var spinBox2: UITextField!
    @IBOutlet weak var spinBox3: UITextField!
    @IBOutlet weak var spinBox4: UITextField!
    @IBOutlet weak var cpinBox1: UITextField!
    @IBOutlet weak var cpinBox2: UITextField!
    @IBOutlet weak var cpinBox3: UITextField!
    @IBOutlet weak var cpinBox4: UITextField!
    @IBOutlet weak var skipOutlet: UIButton!
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var backButton1: UIButton!
    @IBOutlet weak var skip: UIButton!
    
    var images: [ImageData] = []
    var schools: [School] = [] // Received from SetPINViewController
    var groupDatas: [GroupData] = []
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        butttonStyles()
        enableKeyboardDismissOnTap()
        
        [spinBox1, spinBox2, spinBox3, spinBox4,
         cpinBox1, cpinBox2, cpinBox3, cpinBox4].forEach { $0?.applyRoundedStyle() }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "skip", attributes: underlineAttribute)
        skip.setAttributedTitle(underlineAttributedString, for: .normal)
        callAPIAndNavigate { [weak self] in
            print("API call finished, reloading collection view...")
        }
        print("Received schools data: \(schools)")
    }
    
    func butttonStyles(){
        skipOutlet.layer.cornerRadius = 10
        nextOutlet.layer.cornerRadius = 10
        backButton1.layer.cornerRadius = 10
    }
   
    
    private func setupTextFields() {
        let textFields = [spinBox1, spinBox2, spinBox3, spinBox4, cpinBox1, cpinBox2, cpinBox3, cpinBox4]
        textFields.forEach { textField in
            textField?.delegate = self
            textField?.keyboardType = .numberPad
            textField?.isSecureTextEntry = true
            textField?.borderStyle = .roundedRect
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 1 {
            textField.text = String(text.last!)
        }
        if textField.text?.count == 1 {
            switch textField {
            case spinBox1: spinBox2.becomeFirstResponder()
            case spinBox2: spinBox3.becomeFirstResponder()
            case spinBox3: spinBox4.becomeFirstResponder()
            case spinBox4: cpinBox1.becomeFirstResponder()
            case cpinBox1: cpinBox2.becomeFirstResponder()
            case cpinBox2: cpinBox3.becomeFirstResponder()
            case cpinBox3: cpinBox4.becomeFirstResponder()
            case cpinBox4: cpinBox4.resignFirstResponder()
            default: break
            }
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        if validatePIN() && validatePIN2() {
            //        callAPIAndNavigate()
            if schools.count > 1 {
                self.navigateToGroupViewController()
            } else {
                handleSchoolSelection(schoolDataArray: schools)
            }
        }
    }
    
    @IBAction func skip(_ sender: UIButton) {
        //        callAPIAndNavigate()
        if schools.count > 1 {
            self.navigateToGroupViewController()
        } else {
            handleSchoolSelection(schoolDataArray: schools)
        }
        
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
    
    private func decodeBase64Image(from base64String: String) -> UIImage? {
        if let decodedData = Data(base64Encoded: base64String),
           let image = UIImage(data: decodedData) {
            return image
        }
        return nil
    }
    //validation
    private func validatePIN() -> Bool {
        let pinFields = [spinBox1, spinBox2, spinBox3, spinBox4, cpinBox1, cpinBox2, cpinBox3, cpinBox4]
        
        for textField in pinFields {
            if textField?.text?.isEmpty ?? true {
                showAlert(message: "Please enter PIN")
                return false
            }
        }
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    private func validatePIN2() -> Bool {
        let pinFields = [spinBox1, spinBox2, spinBox3, spinBox4]
        let confirmPinFields = [cpinBox1, cpinBox2, cpinBox3, cpinBox4]
        
        // Check if all PIN fields are filled
        for textField in pinFields + confirmPinFields {
            if textField?.text?.isEmpty ?? true {
                showAlert2(message: "Please enter PIN")
                return false
            }
        }
        
        // Retrieve PIN and Confirm PIN values
        let setPin = pinFields.compactMap { $0?.text }.joined()
        let confirmPin = confirmPinFields.compactMap { $0?.text }.joined()
        
        // Compare Set PIN and Confirm PIN
        if setPin != confirmPin {
            showAlert2(message: "PIN and Confirm PIN do not match")
            return false
        }
        
        return true
    }
    private func showAlert2(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleSchoolSelection(schoolDataArray: [School]) {
        guard let schoolData = schoolDataArray.first else {
            print("No school data available")
            return
        }
        
        print("Selected school: \(schoolData.shortName) with ID: \(schoolData.id)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
            print("Successfully instantiated HomeVC")
            
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
                if let imageUrls = imageUrls {
                    homeVC.imageUrls = imageUrls
                    homeVC.currentRole = self.currentRole
                }
                print("All API calls have finished!")
                self.navigationController?.pushViewController(homeVC, animated: true)
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
    private func callAPIAndNavigate(completion: @escaping () -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token is nil. Cannot proceed with API call.")
            completion()  // Ensure completion is called even on failure
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
                    completion()  // Notify when data is ready
                }
                
            } catch {
                print("Failed to decode API response: \(error.localizedDescription)")
                completion()
            }
        }
        
        task.resume()
    }
    
    private func navigateToGroupViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let groupVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController") as? GrpViewController {
            groupVC.schools = self.schools
            groupVC.currentRole = currentRole
            groupVC.groupDatas = self.groupDatas
            groupVC.images = self.images
            groupVC.currentRole = self.currentRole
            self.navigationController?.pushViewController(groupVC, animated: true)
        }
    }
    
}
extension UITextField {
    func applyRoundedStyle(radius: CGFloat = 10) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1        // optional
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.backgroundColor = .white
    }
}
