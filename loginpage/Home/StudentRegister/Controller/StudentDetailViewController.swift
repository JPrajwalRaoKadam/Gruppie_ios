import UIKit

class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var EditButton: UIButton!
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
        token = TokenManager.shared.getToken() ?? ""

        EditButton.layer.cornerRadius = 10
        EditButton.clipsToBounds = true

        if let student = student {
            name.text = student.name
            designation.text = student.rollNumber ?? ""
        }

        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
        TableView.register(UINib(nibName: "EducationInfoCell", bundle: nil), forCellReuseIdentifier: "EducationInfoCell")
        TableView.register(UINib(nibName: "AccountInfoCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")

        TableView.delegate = self
        TableView.dataSource = self
        TableView.reloadData()
        
        enableKeyboardDismissOnTap()
    }

    @IBAction func whatsappButtonTapped(_ sender: UIButton) {
        guard let phoneNumber = student?.phone, !phoneNumber.isEmpty else {
            print("Error: Phone number is missing")
            return
        }

        let formattedPhoneNumber = "+\(phoneNumber)"
        let whatsappURL = "whatsapp://send?phone=\(formattedPhoneNumber)"

        if let url = URL(string: whatsappURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Error: WhatsApp is not installed")
        }
    }

    @IBAction func callButtonTapped(_ sender: UIButton) {
        guard let phoneNumber = student?.phone, !phoneNumber.isEmpty else {
            print("Error: Phone number is missing")
            return
        }

        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Error: Cannot open dialer")
        }
    }

    @IBAction func DeleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Student", message: "Are you sure you want to delete this student?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteStudent()
        })

        present(alert, animated: true)
    }

    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func EditButton(_ sender: Any) {
        if isEditingEnabled {
            view.endEditing(true)
            let updatedStudentData = collectUpdatedData()
            self.student = updatedStudentData

            do {
                let jsonData = try JSONEncoder().encode(updatedStudentData)
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    updateStudentProfile(with: dictionary)
                }
            } catch {
                print("❌ Failed to convert StudentData to dictionary: \(error)")
            }
        }

        isEditingEnabled.toggle()
        EditButton.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)

        if isEditingEnabled {
            TableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int { return 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let student = student else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as! BasicInfoCell
            cell.delegate = self
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationInfoCell", for: indexPath) as! EducationInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as! AccountInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
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
        case 0: titleLabel.text = "Basic Info"
        case 1: titleLabel.text = "Other Info"
        case 2: titleLabel.text = "Family Info"
        default: break
        }

        headerView.addSubview(titleLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func collectUpdatedData() -> StudentData {
        var profile = StudentData()

        for section in 0..<TableView.numberOfSections {
            let indexPath = IndexPath(row: 0, section: section)
            guard let cell = TableView.cellForRow(at: indexPath) else { continue }

            switch cell {
            case let basic as BasicInfoCell:
                profile.name = basic.name.text ?? ""
                profile.gender = basic.gender.text ?? ""
                profile.className = basic.studentClass.text ?? ""
                profile.section = basic.section.text ?? ""
                profile.rollNumber = basic.rollNo.text ?? ""
                profile.email = basic.email.text ?? ""
                profile.phone = basic.phone.text ?? ""
                profile.doj = basic.doj.text ?? ""

            case let edu as EducationInfoCell:
                profile.nationality = edu.nationality.text ?? ""
                profile.bloodGroup = edu.bloodGroup.text ?? ""
                profile.religion = edu.religion.text ?? ""
                profile.caste = edu.caste.text ?? ""
                profile.category = edu.category.text ?? ""
                profile.disability = edu.disability.text ?? ""
                profile.dob = edu.dob.text ?? ""
                profile.admissionNumber = edu.admissionNo.text ?? ""
                profile.satsNumber = edu.satsNumber.text ?? ""
                profile.address = edu.address.text ?? ""
                profile.aadharNumber = edu.aadharNo.text ?? ""

            case let acc as AccountInfoCell:
                profile.fatherName = acc.fatherName.text
                profile.motherName = acc.motherName.text
                profile.fatherPhone = acc.fatherPhone.text
                profile.motherPhone = acc.motherPhone.text
                profile.fatherEmail = acc.fatherEmail.text
                profile.motherEmail = acc.motherEmail.text
                profile.fatherEducation = acc.fatherQualification.text
                profile.motherEducation = acc.motherQualification.text
                profile.fatherOccupation = acc.fatherOccupation.text
                profile.motherOccupation = acc.motherOccupation.text
                profile.fatherAadharNumber = acc.fatherAadharNo.text
                profile.motherAadharNumber = acc.motherAadharNo.text
                profile.familyIncome = acc.fatherIncome.text

            default:
                break
            }
        }

        return profile
    }

    func updateStudentProfile(with StudentData: [String: Any]) {
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
                let jsonData = try JSONSerialization.data(withJSONObject: StudentData, options: .prettyPrinted)
                
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

    func deleteStudent() {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/\(userId)/delete"
        print("🗑️ Delete API: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Delete Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🧾 Delete Status Code: \(httpResponse.statusCode)")
            }

            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Student deleted successfully.")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("❌ Failed to delete student.")
                }
            }
        }.resume()
    }
}

extension StudentDetailViewController: BasicInfoCellDelegate {
    func didUpdateField(field: String, value: String) {
        switch field {
        case "name": student?.name = value
        case "gender": student?.gender = value
        case "className": student?.className = value
        case "section": student?.section = value
        case "rollNumber": student?.rollNumber = value
        case "email": student?.email = value
        case "phone": student?.phone = value
        case "dateOfJoining": student?.dateOfJoining = value
        default: break
        }
    }
}
