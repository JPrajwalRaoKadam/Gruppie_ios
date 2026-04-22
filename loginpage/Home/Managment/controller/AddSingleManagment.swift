import UIKit

class AddSingleManagement: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dob: UITextField!

    var token: String?
    var groupIds = ""
    
    // Picker views
    private let genderPicker = UIPickerView()
    private let datePicker = UIDatePicker()
    
    // Gender options - Display values
    let genderOptions = ["Male", "Female", "Other"]
    
    // Gender values mapping for API (UPPERCASE)
    let genderAPIMapping = [
        "Male": "MALE",
        "Female": "FEMALE",
        "Other": "OTHER"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Received Token:", token ?? "nil")

        number.delegate = self
        addUserButton.isEnabled = false

        name.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        number.addTarget(self, action: #selector(validateForm), for: .editingChanged)

        setupKeyboardDismiss()

        addUserButton.layer.cornerRadius = 10
        customView.layer.cornerRadius = 10
        backButton.layer.cornerRadius = backButton.frame.size.height / 2

        setupGenderPicker()
        setupDatePicker()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    // MARK: - Keyboard Dismiss
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismiss))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapToDismiss() {
        view.endEditing(true)
    }
    
    // MARK: - Setup Pickers
    func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        gender.inputView = genderPicker
        gender.inputAccessoryView = createToolbar(selector: #selector(doneTapped))
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        datePicker.maximumDate = Date()
        dob.inputView = datePicker
        dob.inputAccessoryView = createToolbar(selector: #selector(doneTapped))
    }
    
    // MARK: - Toolbar
    func createToolbar(selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: selector)
        
        toolbar.setItems([flex, done], animated: true)
        return toolbar
    }
    
    // MARK: - Done Action
    @objc func doneTapped() {
        if gender.isFirstResponder {
            let selectedRow = genderPicker.selectedRow(inComponent: 0)
            if selectedRow >= 0 && selectedRow < genderOptions.count {
                gender.text = genderOptions[selectedRow]
            }
        }
        
        if dob.isFirstResponder {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dob.text = formatter.string(from: datePicker.date)
        }
        
        view.endEditing(true)
        validateForm()
    }
    
    // MARK: - Picker Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = genderOptions[row]
    }

    // MARK: - Validation (Only name and number are mandatory)
    @objc func validateForm() {
        addUserButton.isEnabled = !(
            name.text?.isEmpty ?? true ||
            number.text?.isEmpty ?? true
        )
    }

    // MARK: - Alerts
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

    // MARK: - API Call with Form Data
    func callAddManagementAPI() {
        guard let nameText = name.text, !nameText.isEmpty,
              let numberText = number.text, !numberText.isEmpty,
              let token = token else {
            showError("Name and Mobile Number are required")
            return
        }

        // Create form data body
        var formData: [String: String] = [
            "fullName": nameText,
            "mobileNumber": numberText
        ]
        
        // Add optional fields if they have values
        if let emailText = email.text, !emailText.isEmpty {
            formData["email"] = emailText
        }
        
        // Convert gender to uppercase for API (MALE, FEMALE, OTHER)
        if let genderText = gender.text, !genderText.isEmpty {
            if let apiGender = genderAPIMapping[genderText] {
                formData["gender"] = apiGender
            } else {
                formData["gender"] = genderText.uppercased()
            }
        }
        
        if let dobText = dob.text, !dobText.isEmpty {
            formData["dateOfBirth"] = dobText
        }
        
        print("📤 Sending Form Data:", formData)

        // Create the request
        guard let url = URL(string: "https://backend.gc2.co.in/api/v1/management") else {
            showError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Convert form data to URL encoded string
        var components = URLComponents()
        components.queryItems = formData.map { URLQueryItem(name: $0.key, value: $0.value) }
        let bodyString = components.percentEncodedQuery ?? ""
        request.httpBody = bodyString.data(using: .utf8)
        
        print("📤 Request Body:", bodyString)
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network Error:", error)
                    self.showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.showError("No data received")
                    return
                }
                
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Response:", responseString)
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("📥 JSON Response:", jsonResponse)
                    
                    // Try to parse success status
                    if let json = jsonResponse as? [String: Any],
                       let success = json["success"] as? Bool,
                       success == true {
                        let message = json["message"] as? String ?? "Management added successfully"
                        self.showAlert(message: message, success: true)
                    } else if let json = jsonResponse as? [String: Any],
                              let message = json["message"] as? String {
                        self.showError(message)
                    } else {
                        self.showAlert(message: "Management added successfully", success: true)
                    }
                } catch {
                    print("❌ JSON Parsing Error:", error)
                    // If response is not JSON but request succeeded
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        self.showAlert(message: "Management added successfully", success: true)
                    } else {
                        self.showError("Failed to add management")
                    }
                }
            }
        }
        
        task.resume()
    }

    // MARK: - Button Actions
    @IBAction func addUser(_ sender: UIButton) {
        // Only validate mandatory fields (name and number)
        guard let nameText = name.text, !nameText.isEmpty,
              let numberText = number.text, !numberText.isEmpty else {
            showError("Name and Mobile Number are required fields")
            return
        }
        
        // Print all entered data (including optional)
        print("📝 Name:", nameText)
        print("📝 Email:", email.text ?? "")
        print("📝 Phone:", numberText)
        print("📝 Gender:", gender.text ?? "")
        print("📝 Date of Birth:", dob.text ?? "")

        callAddManagementAPI()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        goBackToPreviousViewController()
    }

    // MARK: - Helpers
    func clearTextFields() {
        email.text = ""
        name.text = ""
        number.text = ""
        gender.text = ""
        dob.text = ""
        addUserButton.isEnabled = false
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == number {
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
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
