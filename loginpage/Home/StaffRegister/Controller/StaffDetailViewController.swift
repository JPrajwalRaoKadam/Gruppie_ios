import UIKit

class StaffDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var staffDetailTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var staffId: UILabel!
    @IBOutlet weak var name: UILabel!

    var staffDetails: StaffDetailsData?
    var token: String?
    var groupId: String? = ""
    var isEditingStaffInfo = false

    var staffBasicInfo: StaffDetailsData?
    var staffAccountInfo: StaffDetailsData?

    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = staffDetails?.name
        staffId.text = staffDetails?.type
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

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if isEditingStaffInfo {
            // ✅ Saving mode
            isEditingStaffInfo = false
            enableEditing(false)
            
            // ✅ 1. Save updated cell values into the model
            saveEditedValuesToModel()

            // ✅ 2. Now call API
            updateStaffDetails()
            
            sender.setTitle("Edit", for: .normal)
            
            // ✅ 3. Reload with latest saved model values
            staffDetailTableView.reloadData()
        } else {
            // ✏️ Entering edit mode
            isEditingStaffInfo = true
            enableEditing(true)
            sender.setTitle("Save", for: .normal)
        }
    }
    func saveEditedValuesToModel() {
        guard var currentDetails = staffDetails else { return }

        // 🔹 Update values from Basic Info Cell
        if let basicCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StaffBasicInfo {
            let updatedBasic = basicCell.collectUpdatedData()
            currentDetails.name = updatedBasic.name
            currentDetails.phone = updatedBasic.phone
            currentDetails.email = updatedBasic.email
            currentDetails.gender = updatedBasic.gender
            currentDetails.dob = updatedBasic.dob
            currentDetails.address = updatedBasic.address
            currentDetails.staffCategory = updatedBasic.staffCategory
            currentDetails.designation = updatedBasic.designation
            currentDetails.religion = updatedBasic.religion
            currentDetails.aadharNumber = updatedBasic.aadharNumber
            currentDetails.qualification = updatedBasic.qualification
            currentDetails.className = updatedBasic.className
            currentDetails.classType = updatedBasic.classType
            currentDetails.country = updatedBasic.country
            currentDetails.emailId = updatedBasic.emailId
            currentDetails.aadharNo = updatedBasic.aadharNo
            currentDetails.type = updatedBasic.type
            currentDetails.disability = updatedBasic.disability
            currentDetails.bloodGroup = updatedBasic.bloodGroup
            currentDetails.caste = updatedBasic.caste

            print("📝 Updated Basic Info: \(updatedBasic)")
        }

        // 🔹 Update values from Account Info Cell
        if let accountCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? StaffAccountInfo {
            let updatedAccount = accountCell.collectUpdatedData()
            currentDetails.uanNumber = updatedAccount.uanNumber
            currentDetails.panNumber = updatedAccount.panNumber
            currentDetails.bankAccountNumber = updatedAccount.bankAccountNumber
            currentDetails.bankIfscCode = updatedAccount.bankIfscCode
            currentDetails.bankAccount = updatedAccount.bankAccount
            currentDetails.bankIfsc = updatedAccount.bankIfsc

            print("🏦 Updated Account Info: \(updatedAccount)")
        }

        // 🔄 Save updated model
        self.staffDetails = currentDetails
    }

    func enableEditing(_ enable: Bool) {
        if let basicInfoCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StaffBasicInfo {
            basicInfoCell.setEditingEnabled(enable)
        }

        if let accountInfoCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? StaffAccountInfo {
            accountInfoCell.setEditingEnabled(enable)
        }
    }

//    func updateStaffDetails() {
//        // ✅ Ensure all required data is present
//        guard
//            let groupId = groupId,
//            let staffId = staffDetails?.staffId,
//            let details = staffDetails,
//            let url = URL(string: "https://api.gruppie.in/api/v1/groups/\(groupId)/staff/\(staffId)/edit")
//        else {
//            print("❌ Invalid data or malformed URL.")
//            return
//        }
//
//        print("🌐 Request URL: \(url.absoluteString)")
//        
//        // ✅ Use token passed from previous VC
//        guard let token = token, !token.isEmpty else {
//            print("❌ Token is missing from previous VC")
//            return
//        }
//
//        print("🔐 Token being sent: Bearer \(token.prefix(12))...")
//
//        // ✅ Optional: Validate critical fields before request
//        if details.name?.isEmpty ?? true || details.phone?.isEmpty ?? true {
//            print("⚠️ Warning: Name or phone is missing, server may reject request.")
//        }
//
//        // ✅ Prepare the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        // ✅ Encode updated details
//        do {
//            let encodedData = try JSONEncoder().encode(details)
//            request.httpBody = encodedData
//
//            if let json = String(data: encodedData, encoding: .utf8) {
//                print("📦 Request JSON:", json)
//            }
//        } catch {
//            print("❌ Encoding error:", error)
//            return
//        }
//
//        // ✅ Send the request
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ API error:", error.localizedDescription)
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 Status Code:", httpResponse.statusCode)
//
//                if httpResponse.statusCode == 401 {
//                    print("🚫 Unauthorized. The token may be invalid or user lacks permission for this action.")
//                }
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print("📥 Response JSON:", json)
//                } catch {
//                    print("⚠️ Failed to parse response: \(error.localizedDescription)")
//                }
//            }
//        }.resume()
//    }

    func updateStaffDetails() {
        guard let groupId = groupId, let staffId = staffDetails?.staffId else {
            print("❌ groupId or staffId is nil")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/\(staffId)/edit"
        print("📡 API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept") // Optional but safe to include

        let token = TokenManager.shared.getToken() ?? ""
        if token.isEmpty {
            print("❌ Token is empty")
            return
        }

        print("🔑 Token Used: Bearer \(token)")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Prepare JSON body manually from staffDetails
        guard let staff = staffDetails else {
            print("❌ Staff details not available")
            return
        }

        let body: [String: Any] = [
            "aadharNumber": staff.aadharNumber ?? "",
            "address": staff.address ?? "",
            "bankAccountNumber": staff.bankAccountNumber ?? "",
            "bankIfscCode": staff.bankIfscCode ?? "",
            "bloodGroup": staff.bloodGroup ?? "Blood Group",
            "caste": staff.caste ?? "Brahmins",
            "designation": staff.designation ?? "",
            "disability": staff.disability ?? "Select Disability",
            "dob": staff.dob ?? "",
            "doj": staff.doj ?? "",
            "email": staff.email ?? "",
            "emergencyContactNumber": "", // Not in model
            "fatherName": "",             // Not in model
            "gender": staff.gender ?? "Select Gender",
            "image": staff.image ?? "",
            "motherName": "",             // Not in model
            "name": staff.name ?? "",
            "panNumber": staff.panNumber ?? "",
            "phone": staff.phone ?? "",
            "profession": "",             // Not in model
            "qualification": staff.qualification ?? "",
            "religion": staff.religion ?? "Select Religion",
            "staffCategory": staff.staffCategory ?? "Category",
            "type": staff.type ?? "teaching",
            "uanNumber": staff.uanNumber ?? ""
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("🚀 Request Body Sent: \(jsonString)")
            }

            request.httpBody = jsonData
        } catch {
            print("❌ JSON serialization error: \(error.localizedDescription)")
            return
        }

        // 🔍 Final debug info
        print("🧾 Final Request Info:")
        print("🔗 URL: \(request.url?.absoluteString ?? "nil")")
        print("🔐 Headers: \(request.allHTTPHeaderFields ?? [:])")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📶 Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ No response data")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 API Response: \(responseString)")
            }

            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Staff profile updated successfully")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("⚠️ Update failed")
                }
            }
        }

        task.resume()
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffBasicInfoCell", for: indexPath) as? StaffBasicInfo else {
                return UITableViewCell()
            }

            let infoToUse = staffDetails ?? staffDetails
            if let info = infoToUse {
                cell.populate(with: info, isEditingEnabled: isEditingStaffInfo)
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAccountInfoCell", for: indexPath) as? StaffAccountInfo else {
                return UITableViewCell()
            }

            let infoToUse = staffDetails ?? staffDetails
            if let info = infoToUse {
                cell.populate(with: info, isEditingEnabled: isEditingStaffInfo)
            }

            return cell
        }
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

        guard let token = token, !token.isEmpty else {
            print("Error: Missing authentication token")
            return
        }

        let apiUrl = APIManager.shared.baseURL + "admin/groups/\(groupId)/users/\(staffId)/allow/post"
        print("API URL make admin: \(apiUrl)")

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    return // ✅ Don't decode empty response
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
                    print("Staff successfully made admin (from decoded response).")

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

    private func fetchStaffDetails() {
        guard let details = staffDetails else { return }

        // You can update or enrich the model, or just reload the table view
        // No need to assign it again unless modifying fields
        
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

    
}
