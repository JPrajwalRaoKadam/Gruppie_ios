import UIKit

class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var EditButton: UIButton!


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
        print("API URL: \(urlString)")

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
                print("Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }

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
        var token: String = ""
        var groupId: String = ""
        var teamId: String = ""
        var userId: String = ""
        var studentDbId: String = ""



    override func viewDidLoad() {
        super.viewDidLoad()
        EditButton.layer.cornerRadius = 10
            EditButton.clipsToBounds = true

        print("StudentDetailViewController Loaded")
         if let student = student {
            print("Student Data: \(student)")
            name.text = student.name
            designation.text = student.rollNumber ?? ""
        } else {
            print("Error: Student data is nil")
        }

        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
        TableView.register(UINib(nibName: "EducationInfoCell", bundle: nil), forCellReuseIdentifier: "EducationInfoCell")
        TableView.register(UINib(nibName: "AccountInfoCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")

        TableView.delegate = self
        TableView.dataSource = self
        TableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let student = student else {
            print("Error: Student data is nil")
            return UITableViewCell()
        }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as! BasicInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationInfoCell", for: indexPath) as! EducationInfoCell
            cell.populate(with: student.educationInfo, isEditingEnabled: isEditingEnabled)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as! AccountInfoCell
            cell.populate(with: student.accountInfo, isEditingEnabled: isEditingEnabled)
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor.white

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 5, width: tableView.frame.width - 32, height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.black

        switch section {
        case 0:
            titleLabel.text = "Basic Info"
        case 1:
            titleLabel.text = "Other Info"
        case 2:
            titleLabel.text = "Family Info"
        default:
            return nil
        }

        headerView.addSubview(titleLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    @IBAction func EditButton(_ sender: Any) {
            if isEditingEnabled {
                let updatedStudentData = collectUpdatedData()
                updateStudentProfile(with: updatedStudentData)
            } else {
                isEditingEnabled = true
                TableView.reloadData()
            }
        }

    func collectUpdatedData() -> [String: Any] {
        var updatedData: [String: Any] = [:]

        for section in 0..<TableView.numberOfSections {
            let indexPath = IndexPath(row: 0, section: section)
            
            if let cell = TableView.cellForRow(at: indexPath) {
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
                    func getValidValue(_ text: String?) -> Any {
                        return (text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) ? NSNull() : text!
                    }
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
                    func getValidValue(_ text: String?) -> Any {
                        return (text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) ? NSNull() : text!
                    }

                    updatedData["fatherName"] = getValidValue(accountInfoCell.fatherName.text ?? "")
                    updatedData["motherName"] = getValidValue(accountInfoCell.motherName.text ?? "")
                    updatedData["fatherPhone"] = getValidValue(accountInfoCell.fatherPhone.text ?? "")
                    updatedData["motherPhone"] = getValidValue(accountInfoCell.motherPhone.text ?? "")
                    updatedData["fatherEmail"] = getValidValue(accountInfoCell.fatherEmail.text ?? "")
                    updatedData["motherEmail"] = getValidValue(accountInfoCell.motherEmail.text ?? "")
                    updatedData["fatherQualification"] = getValidValue(accountInfoCell.fatherQualification.text ?? "")
                    updatedData["motherQualification"] = getValidValue(accountInfoCell.motherQualification.text ?? "")
                    updatedData["fatherOccupation"] = getValidValue(accountInfoCell.fatherOccupation.text ?? "")
                    updatedData["motherOccupation"] = getValidValue(accountInfoCell.motherOccupation.text ?? "")
                    updatedData["fatherAadharNo"] = getValidValue(accountInfoCell.fatherAadharNo.text ?? "")
                    updatedData["motherAadharNo"] = getValidValue(accountInfoCell.motherAadharNo.text ?? "")
                    updatedData["fatherIncome"] = getValidValue(accountInfoCell.fatherIncome.text ?? "")
                    updatedData["motherIncome"] = getValidValue(accountInfoCell.motherIncome.text ?? "")
                }

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
        
        let token = TokenManager.shared.getToken() ?? ""
        print("🔑 Token Used: Bearer \(token)")
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedData, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("🚀 Request Body Sent: \(jsonString)")
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

