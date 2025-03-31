import UIKit

class StaffDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func Edit(_ sender: UIButton) {
        updateStaffDetails()
    }

    @IBAction func Admin(_ sender: UIButton) {
        showAdminConfirmationAlert()
    }

    private func showAdminConfirmationAlert() {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to make this staff an admin?", preferredStyle: .alert)
        
        // "Yes" action to proceed with making the staff admin
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.makeStaffAdmin()
        }
        
        // "Cancel" action to dismiss the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        // Present the alert
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
        
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/users/\(staffId)/allow/post"
        
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

    @IBAction func DeleteButton(_ sender: UIButton) {
        deleteStaff()
    }

    private func deleteStaff() {
        guard let staffId = staffDetails?.staffId else {
            print("Error: No staff ID found")
            return
        }
        
        guard let groupId = groupId, !groupId.isEmpty else {
            print("Error: groupId is missing")
            return
        }
        
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/staff/\(staffId)/delete?type=staff"
        
        // Create URL request
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Ensure token is valid
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
                
                // Check if the response status code indicates success (2xx range)
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("Staff successfully deleted from the API.")
                    
                    // Navigate back to the previous screen after deletion
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Failed to delete staff from the API. Status code: \(httpResponse.statusCode)")
                }
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debug: Print raw API response
            if let jsonResponse = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonResponse)")
            }
            
            // Decode JSON response (if applicable)
            do {
                let responseObject = try JSONDecoder().decode(DeleteStaffResponse.self, from: data)
                print("Decoded Response: \(responseObject)")
                
                if let success = responseObject.success, success {
                    print("Staff deleted successfully.")
                } else {
                    print("Failed to delete staff: \(responseObject.message ?? "No message")")
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }


    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)

    }
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var staffDetailTableView: UITableView!
    var staffDetails: StaffDetailsData? // This will hold the staff details passed from StaffRegister

    var token: String?
    var groupId: String? = "62b4265f97d24b15e8123155"
    
    var staffBasicInfo: StaffBasicInfoModel? // Model for Staff Basic Info
    var staffAccountInfo: StaffAccountInfoModel? // Model for Staff Account Info
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure staffDetailTableView is properly initialized
        guard staffDetailTableView != nil else {
            print("Error: staffDetailTableView is nil")
            return
        }

        // Set table view delegate and data source
        staffDetailTableView.delegate = self
        staffDetailTableView.dataSource = self

        // Register custom cells for both StaffBasicInfo and StaffAccountInfo
        staffDetailTableView.register(UINib(nibName: "StaffBasicInfo", bundle: nil), forCellReuseIdentifier: "StaffBasicInfoCell")
        staffDetailTableView.register(UINib(nibName: "StaffAccountInfo", bundle: nil), forCellReuseIdentifier: "StaffAccountInfoCell")

        // Automatically adjust cell height
        staffDetailTableView.estimatedRowHeight = 100
        staffDetailTableView.rowHeight = UITableView.automaticDimension

        fetchStaffDetails()
    }

    private func fetchStaffDetails() {
        guard let details = staffDetails else { return }

        // Create basic info model
        self.staffBasicInfo = StaffBasicInfoModel(
            name: details.name,
            country: "India", // Assuming country is India
            phone: details.phone,
            staffId: details.staffId,
            doj: details.doj.isEmpty ? "Not Available" : details.doj,
            className: details.classType ?? "", // Use empty string if nil
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
        )

        // Create account info model
        self.staffAccountInfo = StaffAccountInfoModel(
            uanNumber: details.uanNumber ?? "Not Available",
            panNumber: details.panNumber ?? "Not Available",
            bankAccount: details.bankAccountNumber ?? "Not Available",
            bankIfsc: details.bankIfscCode ?? "Not Available"
        )

        // Reload the table view
        staffDetailTableView.reloadData()
    }


    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        // Reload table view on segment change
        staffDetailTableView.reloadData()
    }

    // MARK: - TableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Only 1 row will be displayed based on the selected segment
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentController.selectedSegmentIndex == 0 {
            // Staff Basic Info Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffBasicInfoCell", for: indexPath) as? StaffBasicInfo else {
                return UITableViewCell()
            }
            if let basicInfo = staffBasicInfo {
                cell.populate(with: basicInfo, isEditingEnabled: true) // Populate StaffBasicInfo cell
            }
            return cell
        } else {
            // Staff Account Info Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAccountInfoCell", for: indexPath) as? StaffAccountInfo else {
                return UITableViewCell()
            }
            if let accountInfo = staffAccountInfo {
                cell.populate(with: accountInfo, isEditingEnabled: true) // Populate StaffAccountInfo cell
            }
            return cell
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func updateStaffDetails() {
        guard let staffId = staffDetails?.staffId else {
            print("Error: No staff ID found")
            return
        }
        
        guard let groupId = groupId, !groupId.isEmpty else {
            print("Error: groupId is missing")
            return
        }
        
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/staff/\(staffId)/edit"
        
        // Capture user input from the text fields
        let updatedStaff = EditStaffRequestModel(
            aadharNumber: staffBasicInfo?.aadharNo ?? "",
            address: staffBasicInfo?.address ?? "",
            bankAccountNumber: staffAccountInfo?.bankAccount ?? "",
            bankIfscCode: staffAccountInfo?.bankIfsc ?? "",
            bloodGroup: staffBasicInfo?.bloodGroup ?? "",
            caste: staffBasicInfo?.caste ?? "",
            designation: staffBasicInfo?.type ?? "",
            disability: "Yes",
            dob: staffBasicInfo?.dob ?? "",
            doj: staffBasicInfo?.doj ?? "",
            email: staffBasicInfo?.emailId ?? "",
            emergencyContactNumber: "",
            fatherName: "",
            gender: staffBasicInfo?.gender ?? "",
            image: "",
            motherName: "",
            name: staffBasicInfo?.name ?? "",
            panNumber: staffAccountInfo?.panNumber ?? "",
            phone: staffBasicInfo?.phone ?? "",
            profession: "",
            qualification: staffBasicInfo?.qualification ?? "",
            religion: staffBasicInfo?.religion ?? "",
            staffCategory: staffBasicInfo?.type ?? "",
            type: "Teaching",
            uanNumber: staffAccountInfo?.uanNumber ?? ""
        )
        
        // Encode request model
        guard let jsonData = try? JSONEncoder().encode(updatedStaff) else {
            print("Error encoding request body")
            return
        }
        
        // Debug: Print JSON payload
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Payload: \(jsonString)")
        }
        
        // Create URL request
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Ensure token is valid
        guard let token = token, !token.isEmpty else {
            print("Error: Missing authentication token")
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                // Check if the response status code indicates success (2xx range)
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    print("Data successfully saved to the API.")
                } else {
                    print("Failed to save data to the API. Status code: \(httpResponse.statusCode)")
                }
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debug: Print raw API response
            if let jsonResponse = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonResponse)")
            }
            
            // Check if response is empty
            if data.isEmpty {
                print("API returned an empty response.")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            // Decode JSON response
            do {
                let responseObject = try JSONDecoder().decode(EditStaffResponse.self, from: data)
                print("Decoded Response: \(responseObject)")
                
                if let success = responseObject.success, success {
                    print("Data successfully updated in the API.")
                } else {
                    print("Failed to update data in the API: \(responseObject.message ?? "No message")")
                }
                
                // Navigate back to the previous screen on success
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
