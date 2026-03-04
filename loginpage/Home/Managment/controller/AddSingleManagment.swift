import UIKit

class AddSingleManagement: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var addMoreButton: UIButton!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    var token: String?
    var groupIds = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ Received Token:", token ?? "nil")

        number.delegate = self
        addUserButton.isEnabled = false

        name.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        designation.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        number.addTarget(self, action: #selector(validateForm), for: .editingChanged)

        enableKeyboardDismissOnTap()

        addUserButton.layer.cornerRadius = 10
        addMoreButton.layer.cornerRadius = 10
        addUserButton.clipsToBounds = true
        addMoreButton.clipsToBounds = true

        customView.layer.cornerRadius = 10
        customView.layer.masksToBounds = true

        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    @objc func validateForm() {
        addUserButton.isEnabled = !(
            name.text?.isEmpty ?? true ||
            designation.text?.isEmpty ?? true ||
            number.text?.isEmpty ?? true
        )
    }

    func showError(_ message: String) {
        showAlert(message: message, success: false)
    }

    func showAlert(message: String, success: Bool) {
        let alert = UIAlertController(
            title: success ? "Success" : "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if success {
                self.goBackToPreviousViewController()
            }
        })

        present(alert, animated: true)
    }

    func goBackToPreviousViewController() {
        navigationController?.popViewController(animated: true)
    }

    func callAddManagementAPI() {

        guard let nameText = name.text,
              let dobText = designation.text,
              let numberText = number.text,
              let token = token else {
            showError("Required data missing")
            return
        }

        let requestBody = AddManagementRequest(
            fullName: nameText,
            dateOfBirth: dobText,
            mobileNumber: numberText
        )

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        APIManager.shared.request(
            endpoint: "management",
            method: .post,
            body: requestBody,
            headers: headers
        ) { (result: Result<AddManagementResponse, APIManager.APIError>) in

            DispatchQueue.main.async {
                switch result {

                case .success(let response):
                    if response.success {
                        self.showAlert(
                            message: response.message ?? "User added successfully",
                            success: true
                        )
                    } else {
                        self.showError(response.message ?? "Something went wrong")
                    }

                case .failure(let error):
                    print("❌ API Error:", error)
                    self.showError("Failed to add user")
                }
            }
        }
    }

    @IBAction func addUser(_ sender: UIButton) {

        guard let nameText = name.text, !nameText.isEmpty,
              let designationText = designation.text, !designationText.isEmpty,
              let numberText = number.text, !numberText.isEmpty else {
            showError("Please fill all fields")
            return
        }

        print("Name:", nameText)
        print("DOB:", designationText)
        print("Phone:", numberText)

        callAddManagementAPI()
    }

    @IBAction func addMore(_ sender: UIButton) {
        clearTextFields()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        goBackToPreviousViewController()
    }

    func clearTextFields() {
        designation.text = ""
        name.text = ""
        number.text = ""
        addUserButton.isEnabled = false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)

        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }

        let currentText = textField.text ?? ""
        let newText = (currentText as NSString)
            .replacingCharacters(in: range, with: string)

        return newText.count <= 10
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
