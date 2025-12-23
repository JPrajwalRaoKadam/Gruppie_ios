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
            print("Phone data is missing")
            return
        }
//        requestForgotPassword(for: phoneData)
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

//    func callLoginAPI(with payload: [String: Any]) {
//        let urlString = APIManager.shared.baseURL + "login/category/app?category=school&appName=GC2&addSchool=true"
//        guard let url = URL(string: urlString) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
//        } catch {
//            print("Error serializing JSON: \(error)")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error making API call: \(error)")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("Status code: \(httpResponse.statusCode)")
//
//                if httpResponse.statusCode == 200 {
//                    if let data = data {
//                        do {
//                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                               let token = json["token"] as? String {
//                                print("Authentication Token: \(token)")
//
//                                TokenManager.shared.setToken(token)
//                                UserDefaults.standard.setValue(self.phoneData?.phone, forKey: "loggedInPhone")
//                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
//
//                                DispatchQueue.main.async {
//                                    self.navigateToSetPIN()
//                                }
//                            } else {
//                                print("No token found in response")
//                            }
//                        } catch {
//                            print("Error parsing JSON: \(error)")
//                        }
//                    }
//                } else {
//                    if let data = data {
//                        do {
//                            if let errorResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                               let title = errorResponse["title"] as? String,
//                               let message = errorResponse["message"] as? String {
//                                print("Error: \(title) - \(message)")
//                                DispatchQueue.main.async {
//                                    self.showAlert(title: title, message: message)
//                                }
//                            }
//                        } catch {
//                            print("Error parsing error response: \(error)")
//                        }
//                    }
//                }
//            }
//        }
//
//        task.resume()
//    }

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
                // Safe optional handling
                if response.success == true, let token = response.token {
                    
                    // Store token
                    UserDefaults.standard.set(token, forKey: "login_token")
                    print("✅ Login Token:", token)
                    
                    // Navigate to OTP / next screen
                    self.navigateToHomeVC()
                    
                } else {
                    print("⚠️ Login failed:", response.message ?? "Unknown error")
                }
                
            case .failure(let error):
                // Print error
                print("❌ Login API Error:", error)
            }
        }
    }

    
    func navigateToSetPIN() {
        if let setPINVC = storyboard?.instantiateViewController(withIdentifier: "SetPINViewController") as? SetPINViewController {
            navigationController?.pushViewController(setPINVC, animated: true)
        } else {
            print("Error: Unable to instantiate SetPINViewController.")
        }
    }

//    func requestForgotPassword(for phoneData: PhoneData) {
//        guard let url = URL(string: APIManager.shared.baseURL + "forgot/password/category/app?category=school&appName=GC2") else {
//            print("Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let payload: [String: Any] = [
//            "phone": phoneData.phone,
//            "countryCode": phoneData.countryCode
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
//        } catch {
//            print("Error serializing JSON: \(error)")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error making API call: \(error)")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("Status code: \(httpResponse.statusCode)")
//
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    print("Response Data: \(responseString)")
//                }
//
//                if httpResponse.statusCode == 200 {
//                    DispatchQueue.main.async {
//                        self.navigateToOTPViewController(with: phoneData)
//                    }
//                } else {
//                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                        print("Error Response Data: \(responseString)")
//                    }
//                    print("Failed to request forgot password. Status code: \(httpResponse.statusCode)")
//                }
//            }
//        }
//
//        task.resume()
//    }

//    func navigateToOTPViewController(with phoneData: PhoneData) {
//        if let otpVC = storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
//            otpVC.phoneNumber = phoneData.phone
//            otpVC.countryCode = phoneData.countryCode
//            navigationController?.pushViewController(otpVC, animated: true)
//        }
//    }
    
    func navigateToHomeVC() {
        if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    // MARK: - Alert for invalid password or other API errors
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
