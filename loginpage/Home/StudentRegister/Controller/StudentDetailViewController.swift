import UIKit

class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var EditButton: UIButton! // Connect this in Interface Builder


    @IBAction func whatsappButtonTapped(_ sender: UIButton) {
        guard let phoneNumber = student?.phone, !phoneNumber.isEmpty else {
            print("Error: Phone number is missing")
            return
        }
        
        let formattedPhoneNumber = "+\(phoneNumber)"
        let whatsappURL = "whatsapp://send?phone=\(formattedPhoneNumber)"
        
        if let url = URL(string: whatsappURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Error: WhatsApp is not installed or URL is malformed")
        }
    }
    @IBAction func callButtonTapped(_ sender: UIButton) {
        guard let phoneNumber = student?.phone, !phoneNumber.isEmpty else {
            print("Error: Phone number is missing")
            return
        }

        let formattedNumber = "tel://\(phoneNumber)"
        if let url = URL(string: formattedNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Error: Cannot open dialer")
        }
    }

    @IBAction func DeleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Student", message: "Are you sure you want to delete this student?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteStudent()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func deleteStudent() {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/\(userId)/delete"
        print("API URL: \(urlString)") // ✅ Print API URL

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)") // ✅ Print status code
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)") // ✅ Print API response
            }

            // ✅ Check if deletion was successful
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("✅ Student deleted successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                print("❌ Error: Failed to delete student")
            }
        }

        task.resume()
    }
    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var name: UILabel!
    var student: StudentData?
        var isEditingEnabled = false
        var token: String = "" // Add this line
        var groupId: String = "" // If needed
        var teamId: String = "" // If needed
        var userId: String = "" // If needed
        var studentDbId: String = ""



    override func viewDidLoad() {
        super.viewDidLoad()
        // Apply rounded corners to EditButton
        EditButton.layer.cornerRadius = 10 // Adjust the radius as needed
            EditButton.clipsToBounds = true

        print("StudentDetailViewController Loaded")
        if let student = student {
                name.text = student.name
            designation.text = student.rollNumber ?? ""
            } else {
                print("Error: Student data is nil")
            }
        // Register TableView Cells
        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
        TableView.register(UINib(nibName: "EducationInfoCell", bundle: nil), forCellReuseIdentifier: "EducationInfoCell")
        TableView.register(UINib(nibName: "AccountInfoCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")

        TableView.delegate = self
        TableView.dataSource = self
        TableView.reloadData()
    }

 

    // MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3  // Three sections: Basic, Education, Account
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Each section contains a single row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let student = student else {
            print("Error: Student data is nil")
            return UITableViewCell()
        }

        switch indexPath.section {
        case 0: // Basic Info
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as! BasicInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell
            
        case 1: // Education Info
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationInfoCell", for: indexPath) as! EducationInfoCell
            cell.populate(with: student.educationInfo, isEditingEnabled: isEditingEnabled)
            return cell
            
        case 2: // Account Info
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as! AccountInfoCell
            cell.populate(with: student.accountInfo, isEditingEnabled: isEditingEnabled)
            return cell

        default:
            return UITableViewCell()
        }
    }

    // MARK: - TableView Delegate Methods

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Basic Info"
        case 1: return "Other Info"
        case 2: return "Family Info"
        default: return nil
        }
    }
    @IBAction func EditButton(_ sender: Any) {
            if isEditingEnabled {
                // Collect updated data from text fields
                let updatedStudentData = collectUpdatedData()
                updateStudentProfile(with: updatedStudentData)
            } else {
                isEditingEnabled = true
                TableView.reloadData()
            }
        }

    func collectUpdatedData() -> [String: Any] {
        var updatedData: [String: Any] = [:]

        // Get visible cells and extract data from text fields
        for cell in TableView.visibleCells {
            if let basicInfoCell = cell as? BasicInfoCell {
                updatedData["name"] = basicInfoCell.name.text ?? ""
                updatedData["gender"] = basicInfoCell.gender.text ?? ""
                updatedData["className"] = basicInfoCell.studentClass.text ?? ""
                updatedData["section"] = basicInfoCell.section.text ?? ""
                updatedData["rollNumber"] = basicInfoCell.rollNo.text ?? ""
                updatedData["email"] = basicInfoCell.email.text ?? ""
                updatedData["phone"] = basicInfoCell.phone.text ?? ""
                updatedData["dateOfJoining"] = basicInfoCell.doj.text ?? ""
            } else if let educationInfoCell = cell as? EducationInfoCell {
                updatedData["nationality"] = educationInfoCell.nationality.text ?? ""
                updatedData["bloodGroup"] = educationInfoCell.bloodGroup.text ?? ""
                updatedData["religion"] = educationInfoCell.religion.text ?? ""
                updatedData["caste"] = educationInfoCell.caste.text ?? ""
                updatedData["category"] = educationInfoCell.category.text ?? ""
                updatedData["disability"] = educationInfoCell.disability.text ?? ""
                updatedData["dateOfBirth"] = educationInfoCell.dob.text ?? ""
                updatedData["admissionNumber"] = educationInfoCell.admissionNo.text ?? ""
                updatedData["satsNumber"] = educationInfoCell.satsNumber.text ?? ""
                updatedData["address"] = educationInfoCell.address.text ?? ""
                updatedData["aadharNumber"] = educationInfoCell.aadharNo.text ?? ""
            } else if let accountInfoCell = cell as? AccountInfoCell {
                updatedData["fatherName"] = accountInfoCell.fatherName.text ?? ""
                updatedData["motherName"] = accountInfoCell.motherName.text ?? ""
                updatedData["fatherPhone"] = accountInfoCell.fatherPhone.text ?? ""
                updatedData["motherPhone"] = accountInfoCell.motherPhone.text ?? ""
                updatedData["fatherEmail"] = accountInfoCell.fatherEmail.text ?? ""
                updatedData["motherEmail"] = accountInfoCell.motherEmail.text ?? ""
                updatedData["fatherQualification"] = accountInfoCell.fatherQualification.text ?? ""
                updatedData["motherQualification"] = accountInfoCell.motherQualification.text ?? ""
                updatedData["fatherOccupation"] = accountInfoCell.fatherOccupation.text ?? ""
                updatedData["motherOccupation"] = accountInfoCell.motherOccupation.text ?? ""
                updatedData["fatherAadharNo"] = accountInfoCell.fatherAadharNo.text ?? ""
                updatedData["motherAadharNo"] = accountInfoCell.motherAadharNo.text ?? ""
                updatedData["fatherIncome"] = accountInfoCell.fatherIncome.text ?? ""
                updatedData["motherIncome"] = accountInfoCell.motherIncome.text ?? ""
            }
        }

        return updatedData
    }
    
    func updateStudentProfile(with updatedData: [String: Any]) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/edit/profile?user_id=\(userId)"
        print("API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = TokenManager.shared.getToken() ?? "" // Fetching the token
        print("🔑 Token Used: Bearer \(token)") // ✅ Debugging the token
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedData, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("🚀 Request Body Sent: \(jsonString)") // ✅ Debugging Request Data
            }
            
            request.httpBody = jsonData
        } catch {
            print("❌ Error: Failed to serialize JSON")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }

            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Student profile updated successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

        task.resume()
    }

}

