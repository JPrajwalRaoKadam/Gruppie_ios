import UIKit

class passwordViewController: UIViewController {
    
    // Property to hold phone data
    var phoneData: PhoneData?
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var continueOutlet: UIButton!
    @IBOutlet weak var backOutlet: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var phonenumber: UILabel!
    
    let device = UIDevice.current
    let bundle = Bundle.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        butttonStyles()
        enableKeyboardDismissOnTap()
        // Log phone data for debugging
        if let phoneData = phoneData {
               print("Phone: \(phoneData.phone), Country Code: \(phoneData.countryCode)")
               // Safely unwrap and format the phone number without Optional() or quotes
               phonenumber.text = "Enter the password set by you for \(phoneData.phone)"
           }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "forgotPassword", attributes: underlineAttribute)
        forgotPassword.setAttributedTitle(underlineAttributedString, for: .normal)
    }
  
    
    func butttonStyles() {
        continueOutlet.layer.cornerRadius = 10
        backOutlet.layer.cornerRadius = 10
        password.layer.cornerRadius = 10
        password.clipsToBounds = true
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func forgotPassword(_ sender: UIButton) {
        guard let phoneData = phoneData else {
            print("Phone data missing")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let otpVC = storyboard.instantiateViewController(
            withIdentifier: "OTPViewController"
        ) as? OTPViewController else {
            return
        }

        otpVC.phoneData = phoneData
        otpVC.phoneNumber = phoneData.phone
        otpVC.countryCode = phoneData.countryCode
        otpVC.shouldAutoResendOTP = true   // ✅ KEY LINE
        navigationController?.pushViewController(otpVC, animated: true)
    }

    
    @IBAction func continueButton(_ sender: UIButton) {
        guard let passwordText = password.text, !passwordText.isEmpty,
              let phoneData = phoneData else {
            print("Password or phone data is missing")
            return
        }

        savePasswordToKeychain(password: passwordText)

        let payload: [String: Any] = [
            "userName": [
                "phone": phoneData.phone,
                "countryCode": phoneData.countryCode
            ],
            "password": passwordText
        ]
        
//        callLoginAPI(with: payload)
        loginUser()
    }
    
    func savePasswordToKeychain(password: String) {
        let passwordData = Data(password.utf8)
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecValueData as String: passwordData
        ]

        SecItemDelete(keychainQuery as CFDictionary)
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Password saved to Keychain")
        } else {
            print("Failed to save password to Keychain")
        }
    }
    
    func loginUser() {
        let device = UIDevice.current
        let bundle = Bundle.main
        
        let requestBody = LoginRequest(
            phoneNumber: phoneData?.phone ?? "",
            password: password.text ?? "",
            deviceToken: "fcm_token_123456789abcdef",
            countryCode: "IN",
            deviceId: device.identifierForVendor?.uuidString ?? "",
            deviceType: "ios",                 // Correct iOS value
            deviceModel: device.model,
            osVersion: device.systemVersion,
            appVersion: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            appName: bundle.infoDictionary?["CFBundleName"] as? String ?? "Gruppie Premium"
        )
        
        // Set proper headers
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        APIManager.shared.request(
            endpoint: "auth/login",       // Use correct login endpoint
            method: .post,
            body: requestBody,
            headers: headers
        ) { (result: Result<LoginResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                if response.success == true, let token = response.token {

                    UserDefaults.standard.set(token, forKey: "login_token")
                    UserDefaults.standard.set(self.phoneData?.phone, forKey: "loggedInPhone")

                    // ✅ THIS LINE FIXES YOUR ISSUE
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")

                    UserDefaults.standard.synchronize()

                    self.switchToHome()
                } else {
                    print("⚠️ Login failed:", response.message ?? "Unknown error")
                }
                
            case .failure(let error):
                // Print error
                print("❌ Login API Error:", error)
            }
        }
    }
    
    func switchToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController")

        let nav = UINavigationController(rootViewController: homeVC)
        nav.navigationBar.isHidden = true

        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {

            sceneDelegate.window?.rootViewController = nav
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }


    
    func navigateToSetPIN() {
        if let setPINVC = storyboard?.instantiateViewController(withIdentifier: "SetPINViewController") as? SetPINViewController {
            navigationController?.pushViewController(setPINVC, animated: true)
        } else {
            print("Error: Unable to instantiate SetPINViewController.")
        }
    }
    
    
    // MARK: - Alert for invalid password or other API errors
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
