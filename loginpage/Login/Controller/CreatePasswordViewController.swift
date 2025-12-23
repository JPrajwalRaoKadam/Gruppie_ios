import UIKit

class CreatePasswordViewController: UIViewController {
    
    @IBOutlet weak var enterNewPassword: UITextField!
    @IBOutlet weak var enterConfirmPassword: UITextField!
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!

    // MARK: - Data from previous VC
    var otp: String?
    var phoneNumber: String?

    // ✅ Fixed values
    let countryCode: String = "IN"
    let token: String = "fcm_token_123456789abcdef"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        buttonStyles()
        enableKeyboardDismissOnTap()
        
        enterNewPassword.autocapitalizationType = .none
        enterNewPassword.autocorrectionType = .no
        enterNewPassword.isSecureTextEntry = true
        enterConfirmPassword.autocapitalizationType = .none
        enterConfirmPassword.autocorrectionType = .no
        enterConfirmPassword.isSecureTextEntry = true
           

        print("========== CREATE PASSWORD VC LOADED ==========")
        print("📲 Phone Number:", phoneNumber ?? "nil")
        print("🌍 Country Code:", countryCode)
        print("🔐 OTP:", otp ?? "nil")
        print("🪙 Token:", token)
        print("==============================================")
    }

    func buttonStyles() {
        nextOutlet.layer.cornerRadius = 10
        cancelOutlet.layer.cornerRadius = 10
        enterNewPassword.layer.cornerRadius = 10
        enterConfirmPassword.layer.cornerRadius = 10
    }

   
    @IBAction func nextButton(_ sender: UIButton) {

        print("👉 NEXT BUTTON TAPPED")

        guard var password = enterNewPassword.text,
              var confirmPassword = enterConfirmPassword.text else {
            print("❌ Password fields nil")
            showAlert(message: "Please enter password")
            return
        }

        // ✅ Force first letter to uppercase
        if let firstChar = password.first {
            password = String(firstChar).uppercased() + password.dropFirst()
        }
        if let firstCharConfirm = confirmPassword.first {
            confirmPassword = String(firstCharConfirm).uppercased() + confirmPassword.dropFirst()
        }

        print("🔑 Entered Password (capitalized first letter):", password)
        print("🔑 Confirm Password (capitalized first letter):", confirmPassword)

        if password != confirmPassword {
            print("❌ Password mismatch")
            showAlert(message: "Passwords do not match")
            return
        }

        if !isValidPassword(password) {
            print("❌ Password validation failed")
            showAlert(message: "Password must include uppercase, lowercase, number & special character")
            return
        }

        print("✅ Password validation passed")
        createPassword(password: password)
    }


    @IBAction func cancelButton(_ sender: UIButton) {
        print("👈 Cancel tapped")
        navigationController?.popViewController(animated: true)
    }

    func createPassword(password: String) {

        guard let phone = phoneNumber,
              let otp = otp else {
            showAlert(message: "Required data missing")
            return
        }

        let requestBody = CreatePasswordRequest(
            phoneNumber: phone,
            password: password,
            otp: otp,
            deviceToken: token,
            countryCode: countryCode,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            deviceType: "ios",
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            appName: Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        )

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        APIManager.shared.request(
            endpoint: "set-password",
            method: .put,
            body: requestBody,
            headers: headers
        ) { (result: Result<CreatePasswordResponse, APIManager.APIError >) in

            switch result {

            case .success(let response):
                if response.success, let token = response.token {

                    UserDefaults.standard.set(token, forKey: "login_token")
                    UserDefaults.standard.set(self.phoneNumber, forKey: "loggedInPhone")

                    // ✅ THIS WAS MISSING
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")

                    UserDefaults.standard.synchronize()

                    self.navigateToSetPIN()
                } else {
                    self.showAlert(message: response.message ?? "Something went wrong")
                }

            case .failure(let error):
                print("❌ API Error:", error)
                self.showAlert(message: "Failed to create password")
            }
        }
    }


    // MARK: - Helpers
    func saveLoginData(token: String) {
        UserDefaults.standard.set(token, forKey: "login_token")
        UserDefaults.standard.set(phoneNumber, forKey: "login_username")
        print("💾 Saved login_token & login_username")
    }

    func navigateToSetPIN() {
        print("➡️ Navigating to SetPINViewController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SetPINViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    func isValidPassword(_ password: String) -> Bool {
        let isValid = password.count >= 6
        print("🔎 Password length:", password.count)
        print("🔎 Password validation result:", isValid)
        return isValid
    }

    func showAlert(message: String) {
        print("🚨 ALERT:", message)
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
