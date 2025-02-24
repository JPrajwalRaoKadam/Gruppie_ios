
import UIKit

class AddSingleManagement: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var addUserButton: UIButton!

    var token: String?
    var groupIds = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the number field delegate for validation
        number.delegate = self

        // Initially disable the Add User button and add observers
        addUserButton.isEnabled = false

        // Add observers to enable Add User button only when all fields are filled
        name.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        designation.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        number.addTarget(self, action: #selector(validateForm), for: .editingChanged)
    }

    // MARK: - Validation and Form Handling
    @objc func validateForm() {
        addUserButton.isEnabled = !(name.text?.isEmpty ?? true || designation.text?.isEmpty ?? true || number.text?.isEmpty ?? true)
    }

    // MARK: - API Call
    func callAddManagementAPIi() {
        // Validate fields before API call
        guard let nameText = name.text, !nameText.isEmpty,
              let designationText = designation.text, !designationText.isEmpty,
              let numberText = number.text, !numberText.isEmpty else {
            print("Error: Fields cannot be empty")
            return
        }

        // Add the country code to the phone number
        let countryCode = "+91"  // Update this if needed for other countries
        let fullPhoneNumber = countryCode + numberText

        // Prepare the URL for the API call
        guard let url = URL(string: APIManager.shared.baseURL + "groups/62b32f1197d24b31c4fa7a1a/management/add") else {
            print("Invalid URL")
            return
        }

        // Create the HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set Authorization Token (if required)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Create MemberDetailsData object
        let memberDetails = MemberDetailsData(name: nameText, phone: fullPhoneNumber, designation: designationText)
        
        // Prepare the request body (using model structure)
        let managementData = [memberDetails] // Wrap the model in an array
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

        // Perform the network request
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

                // Successfully added user, decode the response
                if let data = data {
                    self.handleAPIResponse(data: data)
                }
            }
        }
        task.resume()
    }


    // MARK: - Handle API Response
    func handleAPIResponse(data: Data) {
        do {
            // Decode the response data into the MemberDetailsData model
            let decoder = JSONDecoder()
            let response = try decoder.decode([String: MemberDetailsData].self, from: data)
            
            // Print the decoded response to console
            if let member = response["managementData"] {
                print("API Response: \(member.name), \(member.phone), \(member.designation)")
            }
            
            // Show success alert
            self.showAlert(message: "User Added Successfully!", success: true)
        } catch {
            print("Error decoding response: \(error)")
            self.showError("Failed to decode API response.")
        }
    }

    // Show error message in an alert
    func showError(_ message: String) {
        showAlert(message: "Error: \(message)", success: false)
    }

    // MARK: - Show Alert
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

    // MARK: - Actions

    @IBAction func addUser(_ sender: UIButton) {
        // Check if all fields are filled
        if let designationText = designation.text, !designationText.isEmpty,
           let nameText = name.text, !nameText.isEmpty,
           let numberText = number.text, !numberText.isEmpty {

            // Print the input data to the console
            print("Name: \(nameText)")
            print("Designation: \(designationText)")
            print("Phone: \(numberText)")
            
            // Call the API to add the management data
            callAddManagementAPIi()
        } else {
            print("Please fill all fields before saving.")
        }
    }

    @IBAction func addMore(_ sender: UIButton) {
        clearTextFields()
    }

    func clearTextFields() {
        designation.text = ""
        name.text = ""
        number.text = ""
        addUserButton.isEnabled = false
    }

    // MARK: - UITextFieldDelegate Methods

    // Limit the number of digits to exactly 10 and allow only numeric input
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numeric characters
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)

        if !allowedCharacters.isSuperset(of: characterSet) {
            return false  // Reject non-numeric characters
        }

        // Limit the number of digits to exactly 10
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        // Only allow 10 digits (no more, no less)
        return newText.count <= 10
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Extension to convert MemberDetailsData to Dictionary for JSON serialization
extension MemberDetailsData {
    func toDictionary() -> [String: String] {
        return [
            "name": self.name,
            "phone": self.phone,
            "designation": self.designation
        ]
    }
}
