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
    
    var schools: [School] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        butttonStyles()
    }
    func butttonStyles(){
        skipOutlet.layer.cornerRadius = 10
        nextOutlet.layer.cornerRadius = 10
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
            self.navigateToGroupViewController()
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        //        callAPIAndNavigate()
//        HomeAPIService.shared.callAPIAndNavigate { [weak self] in
//            guard let self = self else { return }
//            
//            print("API call finished, reloading collection view...")
//            
//            // Ensure there's at least one school to pass
//            if let selectedSchool = self.schools.first  {
//                print("Received schools data: \(self.schools)")
//                if HomeAPIService.shared.CurrentRole == "student" && HomeAPIService.shared.grpCount == 1 {
//                    self.navigateToHomeVC(schoolData: selectedSchool)
//                } else {
                    self.navigateToGroupViewController()
//                }
//            }
//            
//        }
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

    private func navigateToGroupViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let groupVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController") as? GrpViewController {
            self.navigationController?.pushViewController(groupVC, animated: true)
        }
    }
    
//    func navigateToHomeVC(schoolData: School) {
//        // Instantiate storyboard and HomeVC
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
//            print("Successfully instantiated HomeVC")
//            
//            // Pass the school data
//            homeVC.school = schoolData
//            
//            // Create a DispatchGroup to manage multiple API calls
//            let dispatchGroup = DispatchGroup()
//            var imageUrls: [String]?
//            
//            // Fetch Banner Image
//            dispatchGroup.enter()
//            HomeAPIService.shared.fetchBannerImage(groupId: schoolData.id) { urls in
//                imageUrls = urls
//                dispatchGroup.leave()
//            }
//            
//            // Fetch User Profile
//            dispatchGroup.enter()
//            HomeAPIService.shared.fetchUserProfile(groupId: schoolData.id) { profile in
//                homeVC.name = profile
//                dispatchGroup.leave()
//             }
//          
//            dispatchGroup.enter()
//            HomeAPIService.shared.fetchHomeData(groupId: schoolData.id) { groupData in
//                if let groupData = groupData {
//                    // Pass the fetched group data to homeVC
//                    DispatchQueue.main.async {
//                        homeVC.groupDatas = groupData  // Store the fetched data in groupDatas
//                       // homeVC.tableView.reloadData()  // Reload the table view to display the new data
//                    }
//
//                    // Debugging output
//                    for group in groupData {
//                        print("Fetched Activity: \(group.activity)")
//                        for icon in group.featureIcons {
//                            print("Feature Type: \(icon.type), Image: \(icon.image)")
//                        }
//                    }
//                }
//                dispatchGroup.leave()
//            }
//
//            
//            dispatchGroup.notify(queue: .main) {
//                if let imageUrls = imageUrls {
//                    // Pass the image URLs to HomeVC
//                    homeVC.imageUrls = imageUrls
//                }
//                print("All API calls have finished!")
//                
//                self.navigationController?.pushViewController(homeVC, animated: true)
//            }
//            
//        }
//    }
}
