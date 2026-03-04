import UIKit

class AssignTeacherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    
    var subject: ClassSubject?
    
    // ✅ Store full staff objects instead of just names
    var teachers: [APIStaffMember] = []

    // ✅ Store currently selected staff IDs (includes both existing and newly selected)
    var selectedStaffIds: Set<String> = []
    
    // ✅ Store originally assigned staff IDs (from the API)
    var originallyAssignedStaffIds: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = backButton.frame.height / 2
        
        // ✅ Add this for addButton
        addButton.layer.cornerRadius = 10
        addButton.clipsToBounds = true
        
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        
        let nib = UINib(nibName: "AssignTeacherTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AssignTeacherTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self

        fetchTeachersFromAPI()
    }
    
    // ✅ FIRST API – Fetch All Teaching Staff
    func fetchTeachersFromAPI() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ No token found")
            return
        }

        guard let url = URL(string: "https://dev.gruppie.in/api/v1/staff/registration") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }
            
            // ✅ Print the raw JSON to see the structure
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Teachers API JSON: \(jsonString)")
            }

            do {
                let staffListResponse = try JSONDecoder().decode(APIStaffListResponse.self, from: data)
                
                let teachingStaff = staffListResponse.data.filter { $0.staffType == "TEACHING" }

                DispatchQueue.main.async {
                    self.teachers = teachingStaff
                    print("✅ Loaded \(self.teachers.count) teaching staff")
                    
                    // Debug: Print all teacher IDs to see what we have
                    for teacher in self.teachers {
                        print("👨‍🏫 Teacher: \(teacher.displayName), ID: \(teacher.staffId ?? "0")")
                    }
                    
                    // ⭐ After loading teachers, call second API
                    self.fetchAssignedStaff()
                }

            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    
    func fetchAssignedStaff() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token"),
              let subjectId = subject?.subjectId else {
            print("Missing subjectId")
            return
        }

        let urlString = "https://dev.gruppie.in/api/v1/subject-register/staff-mapping/subject/\(subjectId)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid assigned staff URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Assigned API Error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }
            
            // ✅ Print JSON to see structure
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Assigned Staff JSON: \(jsonString)")
            }

            do {
                // Try to decode as generic dictionary first to see structure
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📋 Assigned Staff Structure: \(json.keys)")
                }
                
                let assignedResponse = try JSONDecoder().decode(AssignedStaffResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Store originally assigned staff IDs
                    self.originallyAssignedStaffIds = Set(assignedResponse.data.compactMap { $0.staffId })
                    // Initialize selectedStaffIds with the originally assigned IDs
                    self.selectedStaffIds = self.originallyAssignedStaffIds
                    
                    print("✅ Originally assigned staff loaded: \(self.originallyAssignedStaffIds.count) staff")
                    print("🔢 Originally Assigned Staff IDs: \(self.originallyAssignedStaffIds)")
                    print("🔢 Selected Staff IDs: \(self.selectedStaffIds)")
                    
                    self.tableView.reloadData()
                }

            } catch {
                print("❌ Assigned Decoding error:", error)
            }
        }.resume()
    }
    
    // ✅ POST API – Save selected staff assignments
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let subjectId = subject?.subjectId else {
            print("❌ No subject ID found")
            showAlert(message: "Subject ID not found")
            return
        }
        
        // Debug: Print current state
        print("📊 Current State:")
        print("   originallyAssignedStaffIds: \(originallyAssignedStaffIds)")
        print("   selectedStaffIds: \(selectedStaffIds)")
        
        // Find which staff IDs were added (in selected but not in originally assigned)
        let addedStaffIds = selectedStaffIds.subtracting(originallyAssignedStaffIds)
        
        // Find which staff IDs were removed (in originally assigned but not in selected)
        let removedStaffIds = originallyAssignedStaffIds.subtracting(selectedStaffIds)
        
        print("➕ Added staff IDs: \(addedStaffIds)")
        print("➖ Removed staff IDs: \(removedStaffIds)")
        
        // If there are no changes, show message and return
        if addedStaffIds.isEmpty && removedStaffIds.isEmpty {
            print("⚠️ No changes to staff assignments")
            self.showAlert(message: "No changes to save") {
                self.dismiss(animated: true)
            }
            return
        }
        
        // For this API, we need to send the ADDED staff IDs
        // Based on the response, it seems the API only adds new mappings
        let staffIdStrings = Array(addedStaffIds)
        
        print("📤 Sending added staff IDs: \(staffIdStrings)")
        
        guard !staffIdStrings.isEmpty else {
            print("⚠️ No staff to add")
            self.showAlert(message: "No new staff to assign")
            return
        }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
        
        // Convert subjectId to String if it's an Int
        let subjectIdString = String(describing: subjectId)
        
        saveStaffAssignments(subjectId: subjectIdString, staffIds: staffIdStrings) { success, message in
            DispatchQueue.main.async {
                // Remove loading indicator
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                
                if success {
                    self.showAlert(message: "Staff assignments saved successfully!") {
                        // Update the originally assigned IDs to match the new selection
                        self.originallyAssignedStaffIds = self.selectedStaffIds
                        self.dismiss(animated: true)
                    }
                } else {
                    self.showAlert(message: message ?? "Failed to save assignments")
                }
            }
        }
    }
    
    // ✅ API Call to save staff assignments
    func saveStaffAssignments(subjectId: String, staffIds: [String], completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            completion(false, "No token found")
            return
        }
        
        guard let url = URL(string: "https://dev.gruppie.in/api/v1/subject-register/staff-mapping") else {
            completion(false, "Invalid URL")
            return
        }
        
        // Convert String IDs to Int for the API
        let staffIdInts = staffIds.compactMap { Int($0) }
        
        let requestBody: [String: Any] = [
            "staffIds": staffIdInts,
            "subjectId": subjectId
        ]
        
        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(false, "Failed to create request body")
            return
        }
        
        // Print request body for debugging
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 POST Request Body: \(jsonString)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ POST API Error:", error.localizedDescription)
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(false, "No data received from server")
                return
            }
            
            // Print response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 POST Response: \(jsonString)")
            }
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(true, nil)
                } else {
                    // Try to parse error message from response
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = json["message"] as? String {
                            completion(false, message)
                        } else {
                            completion(false, "Server error with status code: \(httpResponse.statusCode)")
                        }
                    } catch {
                        completion(false, "Server error with status code: \(httpResponse.statusCode)")
                    }
                }
            } else {
                completion(false, "Invalid response from server")
            }
        }.resume()
    }
    
    // ✅ Helper method to show alerts
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignTeacherTableViewCell", for: indexPath) as? AssignTeacherTableViewCell else {
            return UITableViewCell()
        }
        
        let teacher = teachers[indexPath.row]
        cell.name.text = teacher.displayName
        
        // Configure the cell's button action
        cell.enableButton.tag = indexPath.row
        cell.enableButton.removeTarget(self, action: nil, for: .allEvents)
        cell.enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: .touchUpInside)
        
        // ✅ Show green tick if selected - update the cell's state
        if let staffId = teacher.staffId {
            cell.isSelectedForAssignment = selectedStaffIds.contains(staffId)
        } else {
            cell.isSelectedForAssignment = false
        }
        
        return cell
    }

    // MARK: - Toggle Selection

    @objc func enableButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < teachers.count else { return }
        
        let teacher = teachers[index]
        
        guard let staffId = teacher.staffId else {
            print("❌ No staffId for teacher at index \(index)")
            return
        }
        
        print("🔘 Button tapped for teacher: \(teacher.displayName) with ID: \(staffId)")
        print("   Before - selectedStaffIds: \(selectedStaffIds)")
        
        if selectedStaffIds.contains(staffId) {
            selectedStaffIds.remove(staffId)
            print("❌ Removed teacher ID: \(staffId) from selection")
        } else {
            selectedStaffIds.insert(staffId)
            print("✅ Added teacher ID: \(staffId) to selection")
        }
        
        print("   After - selectedStaffIds: \(selectedStaffIds)")
        
        // Reload just this row to update the button appearance
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
