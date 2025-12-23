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
        ContinueButton.layer.masksToBounds = true
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.clipsToBounds = true
        ind.layer.cornerRadius = 10
        ind.layer.masksToBounds = true
    }
    
    
    @IBAction func termsConditionAction(_ sender: Any) {
        openURL("https://gruppie.in/terms.html")
    }
    
    @IBAction func privacyPolicyAction(_ sender: Any) {
        openURL("https://gruppie.in/privacy.html")
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count == 10 else {
            showAlert(message: "Please enter a valid 10-digit phone number.")
            return
        }

        let phoneData = PhoneData(phone: phoneNumber, countryCode: "IN")
        savePhoneNumberToCoreData(phoneData: phoneData)

        
        
        // ✅ Use central API manager
        checkUserExist(phoneNumber: phoneNumber) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):

                if response.isUserExist && response.isValid {
                    // ✅ Case 1: Registered & Active
                    navigateToPasswordViewController(
                        with: PhoneData(phone: phoneNumber, countryCode: phoneData.countryCode)
                    )

                } else if !response.isUserExist {
                    // ❌ Case 2: User not registered
                    self.showAlert(message: "This user is not registered. Not allowed to access this app.")

                } else if response.isUserExist && !response.isValid {
                    // 🔐 Case 3: User exists but not valid → OTP
                    navigateToOtpViewController(
                        with: PhoneData(phone: phoneNumber, countryCode: phoneData.countryCode)
                    )
                }

            case .failure(let error):
                self.showAlert(message: "Something went wrong: \(error.localizedDescription)")
            }

        }
    }
    
    func checkUserExist(phoneNumber: String,
                        completion: @escaping (Result<UserExistResponse, APIManager.APIError>) -> Void) {
        
        let params = ["phoneNumber": phoneNumber] // Query param
        
        APIManager.shared.request(
            endpoint: "user-exist?",
            method: .get,
            queryParams: params,
            headers: nil,
            completion: completion
        )
    }
    
    func openURL(_ urlString: String) {
           if let url = URL(string: urlString) {
               UIApplication.shared.open(url)
           }
       }

    func navigateToOtpViewController(with phoneData: PhoneData) {
        print("➡️ Navigating to PasswordViewController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController else {
            print("❌ ViewController with identifier 'passwordViewController' not found.")
            return
        }
        vc.phoneData = phoneData
        vc.phoneNumber = phoneData.phone
        vc.countryCode = phoneData.countryCode

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

    func navigateToPasswordViewController(with phoneData: PhoneData) {
        print("➡️ Navigating to PasswordViewController")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "passwordViewController") as? passwordViewController else {
            print("❌ PasswordViewController not found")
            return
        }
        vc.phoneData = phoneData
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
