import UIKit

class passwordViewController: UIViewController {
    
    // Property to hold phone data
    var phoneData: PhoneData?
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var continueOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        butttonStyles()
        // Log phone data for debugging
        if let phoneData = phoneData {
            print("Phone: \(phoneData.phone), Country Code: \(phoneData.countryCode)")
            
        }
    }
    func butttonStyles(){
        continueOutlet.layer.cornerRadius = 10
        password.layer.cornerRadius = 10
        password.clipsToBounds = true
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
        // Ensure phone data is available
        guard let phoneData = phoneData else {
            print("Phone data is missing")
            return
        }
        
        // Call the API to request a password reset
        requestForgotPassword(for: phoneData)
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        // Ensure the password text field is not empty
        guard let passwordText = password.text, !passwordText.isEmpty,
              let phoneData = phoneData else {
            print("Password or phone data is missing")
            return
        }

        savePasswordToKeychain(password: passwordText)
        // Constructing the payload
        let payload: [String: Any] = [
            "userName": [
                "phone": phoneData.phone,
                "countryCode": phoneData.countryCode
            ],
            "password": passwordText
        ]
        
        // Call the API
        callLoginAPI(with: payload)
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

    func callLoginAPI(with payload: [String: Any]) {
        // API URL
        let urlString = APIManager.shared.baseURL + "login/category/app?category=school&appName=GC2&addSchool=true"
        guard let url = URL(string: urlString) else { return }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert payload to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                print("Error making API call: \(error)")
                return
            }

            // Check for HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")

                // Handle response based on status code
                if httpResponse.statusCode == 200 {
                    // Successful response, parse data
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                // Handle successful login and check for a token
                                if let token = json["token"] as? String {
                                    print("Authentication Token: \(token)")

                                    // Save the token using the Singleton
                                    TokenManager.shared.setToken(token)

                                    UserDefaults.standard.setValue(self.phoneData?.phone, forKey: "loggedInPhone")
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                    
                                    // Proceed to SetPINViewController
                                    DispatchQueue.main.async {
                                        self.navigateToSetPIN()
                                    }
                                } else {
                                    print("No token found in response")
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                } else {
                    // Handle authentication error (e.g., invalid credentials)
                    if let data = data {
                        do {
                            if let errorResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let title = errorResponse["title"] as? String,
                                   let message = errorResponse["message"] as? String {
                                    print("Error: \(title) - \(message)")
                                }
                            }
                        } catch {
                            print("Error parsing error response: \(error)")
                        }
                    }
                }
            }
        }

        // Start the task
        task.resume()
    }

    func navigateToSetPIN() {
        if let setPINVC = storyboard?.instantiateViewController(withIdentifier: "SetPINViewController") as? SetPINViewController {
            navigationController?.pushViewController(setPINVC, animated: true)
        } else {
            print("Error: Unable to instantiate SetPINViewController.")
        }
    }

    // Function to request forgot password
    func requestForgotPassword(for phoneData: PhoneData) {
        // Define the API URL
        guard let url = URL(string: APIManager.shared.baseURL + "forgot/password/category/app?category=school&appName=GC2") else {
            print("Invalid URL")
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Changed to PUT as per your requirement
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the payload for the forgot password request
        let payload: [String: Any] = [
            "phone": phoneData.phone,
            "countryCode": phoneData.countryCode
        ]

        // Serialize the payload to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                print("Error making API call: \(error)")
                return
            }

            // Check for HTTP response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")

                // Print the response data for debugging
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                }

                // Handle the response based on status code
                if httpResponse.statusCode == 200 {
                    // Successfully requested forgot password, navigate to OTPViewController
                    DispatchQueue.main.async {
                        self.navigateToOTPViewController(with: phoneData)
                    }
                } else {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Error Response Data: \(responseString)")
                    }
                    print("Failed to request forgot password. Status code: \(httpResponse.statusCode)")
                }
            }
        }

        // Start the task
        task.resume()
    }

    // Function to navigate to OTPViewController
    func navigateToOTPViewController(with phoneData: PhoneData) {
        if let otpVC = storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
            otpVC.phoneNumber = phoneData.phone
            otpVC.countryCode = phoneData.countryCode // Pass the country code to OTPViewController
            navigationController?.pushViewController(otpVC, animated: true)
        }
    }
}
