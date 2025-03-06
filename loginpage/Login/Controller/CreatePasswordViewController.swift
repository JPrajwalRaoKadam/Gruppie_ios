import UIKit

class CreatePasswordViewController: UIViewController {
    
    @IBOutlet weak var enterNewPassword: UITextField!
    @IBOutlet weak var enterConfirmPassword: UITextField!
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    var phoneNumber: String?
    var otp: String?
    var countryCode: String?
    var receivedToken: String? // Variable to hold the token

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        butttonStyles()
        if let number = phoneNumber {
            print("Received phone number: \(number)")
        }
    }
    func butttonStyles(){
        nextOutlet.layer.cornerRadius = 10
        cancelOutlet.layer.cornerRadius = 10
        enterNewPassword.layer.cornerRadius = 10
        enterNewPassword.clipsToBounds = true
        cancelOutlet.layer.cornerRadius = 10
        cancelOutlet.clipsToBounds = true
    }

    @IBAction func nextButton(_ sender: UIButton) {
        guard let password = enterNewPassword.text, !password.isEmpty,
              let confirmPassword = enterConfirmPassword.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please enter both password fields.")
            return
        }

        if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }

        createPassword(password: password)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createPassword(password: String) {
        guard let url = URL(string:  APIManager.shared.baseURL + "create/password/category/app?category=school&appName=GC2") else {
            showAlert(message: "Invalid API URL.")
            return
        }

        let payload: [String: Any] = [
            "userName": [
                "phone": phoneNumber ?? "",
                "countryCode": countryCode ?? "IN"
            ],
            "otp": otp ?? "",
            "confirmPassword": password,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            showAlert(message: "Failed to prepare request. Please try again.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received.")
                }
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("Parsed JSON Response: \(jsonResponse ?? [:])")

                if let token = jsonResponse?["token"] as? String {
                    print("Storing token: \(token)")
                    self.storeToken(token: token)
                    self.receivedToken = token // Store the token

                    DispatchQueue.main.async {
                        self.navigateToSetPIN()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Failed to create password. No token received.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Error processing response. Please try again.")
                }
            }
        }
        task.resume()
    }

    func storeToken(token: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userToken",
            kSecValueData as String: token.data(using: .utf8)!
        ]
        
        SecItemDelete(keychainQuery as CFDictionary)
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error storing token: \(status)")
        }
    }

    func navigateToSetPIN() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let setPINVC = storyboard.instantiateViewController(withIdentifier: "SetPINViewController") as? SetPINViewController else {
            print("ViewController with identifier 'SetPINViewController' not found.")
            return
        }
        
        // Pass the token to SetPINViewController
       // setPINVC.token = receivedToken

        self.navigationController?.pushViewController(setPINVC, animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
