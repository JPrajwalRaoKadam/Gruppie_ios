import UIKit

class AddStaffViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var selectTypeTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var token: String?
    var groupId: String? = ""
    
    let typeOptions = ["Teaching", "Non-Teaching"]
    let dropdownTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFields = [
            firstNameTextField,
            middleNameTextField,
            lastNameTextField,
            contactNumberTextField,
            selectTypeTextField
        ]
        
        textFields.forEach { tf in
            tf?.layer.cornerRadius = 10
            tf?.layer.masksToBounds = true
            tf?.layer.borderWidth = 1
            tf?.layer.borderColor = UIColor.lightGray.cgColor
            tf?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            tf?.leftViewMode = .always
            tf?.delegate = self
        }
        
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.isHidden = true
        dropdownTableView.layer.borderWidth = 1
        dropdownTableView.layer.borderColor = UIColor.lightGray.cgColor
        dropdownTableView.layer.cornerRadius = 8
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(dropdownTableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard textField == contactNumberTextField else {
            return true
        }
        
        // Allow only digits
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // Limit to 10 digits
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 10
    }

    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
        
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let contactNumber = contactNumberTextField.text, !contactNumber.isEmpty,
              let staffType = selectTypeTextField.text, !staffType.isEmpty else {
            showError("First Name, Last Name, Mobile Number and Staff Type are required")
            return
        }
        
        guard contactNumber.count == 10 else {
            showError("Contact number must be exactly 10 digits")
            return
        }
        
        print("👤 First Name:", firstName)
        print("👤 Last Name:", lastName)
        print("📞 Phone:", contactNumber)
        print("🧑‍💼 Staff Type:", staffType)
        
        callAddStaffAPI(
            firstName: firstName,
            middleName: middleNameTextField.text,
            lastName: lastName,
            contactNumber: contactNumber,
            
            staffType: staffType
        )
    }
        
    func callAddStaffAPI(firstName: String, middleName: String?, lastName: String?, contactNumber: String, staffType: String) {
        guard let token = SessionManager.useRoleToken else {
            showError("Token missing")
            return
        }
        
        print("🔑 Token used for API:", token)
        
        let staffTypeFormatted = staffType.uppercased()
        var parameters: [String: String] = [
            "firstName": firstName,
            "contactNumber": contactNumber,
            "staffType": staffTypeFormatted
        ]
        
        if let middleName = middleName, !middleName.isEmpty { parameters["middleName"] = middleName }
        if let lastName = lastName, !lastName.isEmpty { parameters["lastName"] = lastName }
        
        let url = URL(string: "https://dev.gruppie.in/api/v1/staff/full-registration")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createMultipartBody(parameters: parameters, boundary: boundary)
        
        print("🚀 Sending Add Staff Request")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ API Error:", error.localizedDescription)
                    self.showError("Failed to add staff")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showError("Invalid server response")
                    return
                }
                
                print("🚀 HTTP Status Code:", httpResponse.statusCode)
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("✅ Response Body:", responseString)
                } else {
                    print("✅ Response Body is empty")
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    self.showAlert(message: "Staff added successfully", success: true)
                } else {
                    self.showError("Failed to add staff. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func createMultipartBody(parameters: [String: String], boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        for (key, value) in parameters {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            body.append("\(value + lineBreak)")
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        if textField == selectTypeTextField { showDropdown() } else { hideDropdown() }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { hideDropdown() }
    
    func showDropdown() {
        let textFieldFrameInView = selectTypeTextField.superview?.convert(selectTypeTextField.frame, to: self.view) ?? selectTypeTextField.frame
        dropdownTableView.frame = CGRect(
            x: textFieldFrameInView.origin.x,
            y: textFieldFrameInView.origin.y + textFieldFrameInView.height,
            width: textFieldFrameInView.width,
            height: CGFloat(typeOptions.count * 44)
        )
        dropdownTableView.reloadData()
        dropdownTableView.isHidden = false
        self.view.bringSubviewToFront(dropdownTableView)
    }
    
    func hideDropdown() { dropdownTableView.isHidden = true }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { typeOptions.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = typeOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTypeTextField.text = typeOptions[indexPath.row]
        hideDropdown()
        selectTypeTextField.resignFirstResponder()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
         
    func showAlert(message: String, success: Bool) {
        let alert = UIAlertController(title: success ? "Success" : "Alert", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        self.present(alert, animated: true)
    }

  }

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
