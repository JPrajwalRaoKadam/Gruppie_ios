import UIKit
struct PhoneData: Codable {
    var phone: String
    var countryCode: String
}

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ind: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var ContinueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        butttonStyles()
        phoneNumberTextField.delegate = self
        phoneNumberTextField.keyboardType = .numberPad
    }
    
    func butttonStyles(){
        ContinueButton.layer.cornerRadius = 10
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.clipsToBounds = true
        ind.layer.cornerRadius = 10
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        // Reduce opacity when button is clicked
        if let button = sender as? UIButton {
            button.alpha = 0.5 // Set to 50% opacity
        }

        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count == 10 else {
            showAlert(message: "Please enter a valid 10-digit phone number.")
            return
        }

        let phoneData = PhoneData(phone: phoneNumber, countryCode: "IN")
        checkUserExistence(with: phoneData)
    }

    func checkUserExistence(with phoneData: PhoneData) {
        guard let url = URL(string: APIManager.shared.baseURL + "user/exist/category/app?category=school&appName=GC2") else {
            showAlert(message: "Invalid API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(phoneData)
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

            // Print raw data for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response Data: \(rawResponse)")
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responseData = jsonResponse["data"] as? [String: Any] {
                    DispatchQueue.main.async {
                        self.handleResponseData(responseData, phoneNumber: phoneData.phone, countryCode: phoneData.countryCode)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Invalid response format.")
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

    func handleResponseData(_ responseData: [String: Any], phoneNumber: String, countryCode: String) {
        print("Response Data: \(responseData)")
        guard let isUserExist = responseData["isUserExist"] as? Bool,
              let isAllowedToAccessApp = responseData["isAllowedToAccessApp"] as? Bool else {
            showAlert(message: "Invalid response data.")
            return
        }

        if isUserExist && isAllowedToAccessApp {
            // Navigate directly to PasswordViewController
            navigateToPasswordViewController(with: PhoneData(phone: phoneNumber, countryCode: countryCode))
        } else if !isUserExist && isAllowedToAccessApp {
            // Navigate to CreateAccountViewController
            navigateToCreateAccountScreen(with: phoneNumber)
        } else {
            // Show alert for access denial
            showAlert(message: "User not allowed to access this app.")
        }
    }

    func navigateToPasswordViewController(with phoneData: PhoneData) {
        print("Navigating to password page")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "passwordViewController") as? passwordViewController else {
            print("ViewController with identifier 'passwordViewController' not found.")
            return
        }
        vc.phoneData = phoneData // Pass the phone data, including country code
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func navigateToCreateAccountScreen(with phoneNumber: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController else {
            print("ViewController with identifier 'CreateAccountViewController' not found.")
            return
        }
        vc.phoneNumber = phoneNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if textField == phoneNumberTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) && updatedText.count <= 10
        }
        return true
    }
}
