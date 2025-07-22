import UIKit
import CoreData

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
        self.navigationController?.isNavigationBarHidden = true
        styleUI()
        phoneNumberTextField.delegate = self
        phoneNumberTextField.keyboardType = .numberPad
        
        // ✅ Use global extension if already defined
        enableKeyboardDismissOnTap()
    }
    
    func styleUI() {
        ContinueButton.layer.cornerRadius = 10
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.clipsToBounds = true
        ind.layer.cornerRadius = 10
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count == 10 else {
            showAlert(message: "Please enter a valid 10-digit phone number.")
            return
        }

        let phoneData = PhoneData(phone: phoneNumber, countryCode: "IN")
        savePhoneNumberToCoreData(phoneData: phoneData)

        // ✅ Use central API manager
        APIManager.shared.checkUserAcrossServers(phoneData: phoneData) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let (response, server)):
                    print("✅ Using server: \(server.rawValue)")
                    self.handleResponseData(response, phoneNumber: phoneData.phone, countryCode: phoneData.countryCode)

                case .failure(let error):
                    print("❌ All servers failed: \(error.localizedDescription)")
                    self.showAlert(message: "Unable to connect to any server. Please try again later.")
                }
            }
        }
    }

    func handleResponseData(_ responseData: [String: Any], phoneNumber: String, countryCode: String) {
        print("📦 Response Data: \(responseData)")
        guard let isUserExist = responseData["isUserExist"] as? Bool,
              let isAllowedToAccessApp = responseData["isAllowedToAccessApp"] as? Bool else {
            showAlert(message: "Invalid response data.")
            return
        }

        if isUserExist && isAllowedToAccessApp {
            navigateToPasswordViewController(with: PhoneData(phone: phoneNumber, countryCode: countryCode))
        } else if !isUserExist && isAllowedToAccessApp {
            navigateToCreateAccountScreen(with: phoneNumber)
        } else {
            showAlert(message: "User not allowed to access this app.")
        }
    }

    func navigateToPasswordViewController(with phoneData: PhoneData) {
        print("➡️ Navigating to PasswordViewController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "passwordViewController") as? passwordViewController else {
            print("❌ ViewController with identifier 'passwordViewController' not found.")
            return
        }
        vc.phoneData = phoneData
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func navigateToCreateAccountScreen(with phoneNumber: String) {
        print("➡️ Navigating to CreateAccountViewController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController else {
            print("❌ ViewController with identifier 'CreateAccountViewController' not found.")
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

    func savePhoneNumberToCoreData(phoneData: PhoneData) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        let user = NSManagedObject(entity: entity, insertInto: context)
        user.setValue(phoneData.phone, forKey: "phone")
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to save phone number: \(error)")
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
