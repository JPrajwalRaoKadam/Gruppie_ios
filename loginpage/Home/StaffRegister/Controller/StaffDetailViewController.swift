import UIKit

class StaffDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var staffDetailTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var staffId: UILabel!
    @IBOutlet weak var name: UILabel!

    var staffDetails: StaffDetailsData?
    var token: String?
    var groupId: String? = ""

    var staffBasicInfo: StaffBasicInfoModel?
    var staffAccountInfo: StaffAccountInfoModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = staffDetails?.name
        staffId.text = staffDetails?.staffId
        editButton.layer.cornerRadius = 10
        editButton.clipsToBounds = true

        print("staffDetails received: \(staffDetails)")
        print ("token staffVc:\(token)")
        guard staffDetailTableView != nil else {
            print("Error: staffDetailTableView is nil")
            return
        }

        staffDetailTableView.delegate = self
        staffDetailTableView.dataSource = self

        staffDetailTableView.register(UINib(nibName: "StaffBasicInfo", bundle: nil), forCellReuseIdentifier: "StaffBasicInfoCell")
        staffDetailTableView.register(UINib(nibName: "StaffAccountInfo", bundle: nil), forCellReuseIdentifier: "StaffAccountInfoCell")

        staffDetailTableView.estimatedRowHeight = 100
        staffDetailTableView.rowHeight = UITableView.automaticDimension

        fetchStaffDetails()
        enableKeyboardDismissOnTap()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this staff?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteStaff()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    private func deleteStaff() {
        guard let staffId = staffDetails?.staffId else {
            print("Error: Staff ID is missing")
            return
        }

        guard let groupId = groupId, !groupId.isEmpty else {
            print("Error: groupId is missing")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/\(staffId)/delete?type=staff"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ Error: token is nil when setting Authorization header")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during DELETE request: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("✅ Staff successfully deleted.")

                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("❌ Failed to delete staff. Status code: \(httpResponse.statusCode)")
                }
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
        }

        task.resume()
    }

    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        updateStaffDetails()
    }
    @IBAction func Admin(_ sender: UIButton) {
            showAdminConfirmationAlert()
        }
    private func showAdminConfirmationAlert() {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to make this staff an admin?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.makeStaffAdmin()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(yesAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func makeStaffAdmin() {
        guard let staffId = staffDetails?.staffId else {
            print("Error: No staff ID found")
            return
        }

        guard let groupId = groupId, !groupId.isEmpty else {
            print("Error: groupId is missing")
            return
        }

        let apiUrl = APIManager.shared.baseURL + "admin/groups/\(groupId)/users/\(staffId)/allow/post"
        print("API URL make admin: \(apiUrl)")  // <--- This line prints the API URL to the console


        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = token, !token.isEmpty else {
            print("Error: Missing authentication token")
            return
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("Staff successfully made admin.")

                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }

                } else {
                    print("Failed to make staff admin. Status code: \(httpResponse.statusCode)")
                }
            }

            guard let data = data else {
                print("No data received from server")
                return
            }

            if let jsonResponse = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonResponse)")
            }

            do {
                let responseObject = try JSONDecoder().decode(AdminStaffResponse.self, from: data)
                print("Decoded Response: \(responseObject)")

                if let success = responseObject.success, success {
                    print("Staff successfully made admin.")

                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Failed to make staff admin: \(responseObject.message ?? "No message")")
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }

        task.resume()
    }


    private func updateStaffDetails() {
        guard let staffDetails = staffDetails else { return }
        guard let groupId = groupId else {
            print("Error: groupId is nil")
            return
        }

        let updatedData: [String: Any] = [
            "aadharNumber": staffBasicInfo?.aadharNo ?? "",
            "address": staffBasicInfo?.address ?? "",
            "bankAccountNumber": staffAccountInfo?.bankAccount ?? "",
            "bankIfscCode": staffAccountInfo?.bankIfsc ?? "",
            "bloodGroup": staffBasicInfo?.bloodGroup ?? "Blood Group",
            "caste": staffBasicInfo?.caste ?? "",
            "designation": staffDetails.designation,
            "disability": "Select Disability",
            "dob": staffBasicInfo?.dob ?? "",
            "doj": staffBasicInfo?.doj ?? "",
            "email": staffBasicInfo?.emailId ?? "",
            "gender": staffBasicInfo?.gender ?? "Select Gender",
            "image": "",
            "name": staffBasicInfo?.name ?? "",
            "panNumber": staffAccountInfo?.panNumber ?? "",
            "phone": staffBasicInfo?.phone ?? "",
            "qualification": staffBasicInfo?.qualification ?? "",
            "religion": staffBasicInfo?.religion ?? "Select Religion",
            "staffCategory": staffBasicInfo?.type ?? "Category",
            "type": "Teaching",
            "uanNumber": staffAccountInfo?.uanNumber ?? ""
        ]

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/\(staffDetails.staffId)/edit"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL with groupId: \(groupId)")
            return
        }

        print("PUT API URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updatedData, options: [])
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Successfully updated staff details")
                } else {
                    print("Failed to update staff details with status code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }

    private func fetchStaffDetails() {
        guard let details = staffDetails else { return }

        staffBasicInfo = StaffBasicInfoModel(
            name: details.name,
            country: "India",
            phone: details.phone,
            staffId: details.staffId,
            doj: details.doj.isEmpty ? "Not Available" : details.doj,
            className: details.classType ?? "",
            gender: details.gender,
            qualification: details.qualification,
            dob: details.dob,
            address: details.address,
            religion: details.religion,
            caste: details.caste,
            bloodGroup: details.bloodGroup,
            emailId: details.email,
            aadharNo: details.aadharNumber,
            type: details.staffCategory
//            emergencyContact: details.emergencyContactNumber ?? "",
//            fatherName: details.fatherName ?? "",
//            motherName: details.motherName ?? "",
//            profession: details.profession ?? ""
        )

        staffAccountInfo = StaffAccountInfoModel(
            uanNumber: details.uanNumber ?? "Not Available",
            panNumber: details.panNumber ?? "Not Available",
            bankAccount: details.bankAccountNumber ?? "Not Available",
            bankIfsc: details.bankIfscCode ?? "Not Available"
        )

        staffDetailTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Basic Info" : "Account Info"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffBasicInfoCell", for: indexPath) as? StaffBasicInfo else {
                return UITableViewCell()
            }
            if let basicInfo = staffBasicInfo {
                cell.populate(with: basicInfo, isEditingEnabled: true)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAccountInfoCell", for: indexPath) as? StaffAccountInfo else {
                return UITableViewCell()
            }
            if let accountInfo = staffAccountInfo {
                cell.populate(with: accountInfo, isEditingEnabled: true)
            }
            return cell
        }
    }
}
