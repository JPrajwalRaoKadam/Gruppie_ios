
import UIKit

class AddSingleManagement: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var addUserButton: UIButton!

    @IBOutlet weak var backButton: UIButton!
    var token: String?
    var groupIds = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        number.delegate = self

        addUserButton.isEnabled = false

        name.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        designation.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        number.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        enableKeyboardDismissOnTap()
    }
    @objc func validateForm() {
        addUserButton.isEnabled = !(name.text?.isEmpty ?? true || designation.text?.isEmpty ?? true || number.text?.isEmpty ?? true)
    }
    func callAddManagementAPIi() {
        guard let nameText = name.text, !nameText.isEmpty,
              let designationText = designation.text, !designationText.isEmpty,
              let numberText = number.text, !numberText.isEmpty else {
            print("Error: Fields cannot be empty")
            return
        }
        
        let countryCode = "+91"
        let fullPhoneNumber = countryCode + numberText
        
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupIds)/management/add"
            print("API URL: \(apiUrl)")

            guard let url = URL(string: apiUrl) else {
                print("Invalid URL")
                return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let memberDetails = MemberDetailsData(name: nameText, phone: fullPhoneNumber, designation: designationText)
        
        let managementData = [memberDetails]
        let body: [String: Any] = [
            "managementData": managementData.map { $0.toDictionary() }
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showError("Invalid response")
                    return
                }

                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                    print("API Error: \(httpResponse.statusCode)")
                    if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                        print("Error Response: \(errorResponse)")
                    }
                    self.showError("API Error: \(httpResponse.statusCode)")
                    return
                }

                if let data = data {
                    self.handleAPIResponse(data: data)
                }
            }
        }
        task.resume()
    }


    func handleAPIResponse(data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode([String: MemberDetailsData].self, from: data)
            
            if let member = response["managementData"] {
                print("API Response: \(member.name), \(member.phone), \(member.designation)")
            }
            
            self.showAlert(message: "User Added Successfully!", success: true)
        } catch {
            print("Error decoding response: \(error)")
            self.showError("Failed to decode API response.")
        }
    }

    func showError(_ message: String) {
        showAlert(message: "Error: \(message)", success: false)
    }

    func showAlert(message: String, success: Bool) {
        let alert = UIAlertController(title: success ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if success {
                self.goBackToPreviousViewController()
            }
        }))
        self.present(alert, animated: true)
    }

    func goBackToPreviousViewController() {
        navigationController?.popViewController(animated: true)
    }


    @IBAction func addUser(_ sender: UIButton) {
        if let designationText = designation.text, !designationText.isEmpty,
           let nameText = name.text, !nameText.isEmpty,
           let numberText = number.text, !numberText.isEmpty {

            print("Name: \(nameText)")
            print("Designation: \(designationText)")
            print("Phone: \(numberText)")
            
            callAddManagementAPIi()
        } else {
            print("Please fill all fields before saving.")
        }
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


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)

        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }

        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        return newText.count <= 10
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MemberDetailsData {
    func toDictionary() -> [String: String] {
        return [
            "name": self.name,
            "phone": self.phone,
            "designation": self.designation
        ]
    }
}
