import UIKit

class AssignStudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    var subject: ClassSubject?
    var classId: Int? // Add this property to receive class ID
    var groupAcademicYearId: String? // Add this property

    // ✅ Store full student objects
    var students: [StudentSubjectStudent] = []

    // ✅ Store currently selected student IDs
    var selectedStudentIds: Set<String> = []
    
    // ✅ Store originally assigned student IDs
    var originallyAssignedStudentIds: Set<String> = []
    
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

        fetchStudentsFromAPI()
    }
    
    func fetchStudentsFromAPI() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ No token found")
            return
        }

        guard let subject = subject else {
            print("❌ No subject found")
            return
        }

        guard let classId = classId else {
            print("❌ No class ID found")
            return
        }

        // Convert Int to String for URL
        let subjectIdString = String(subject.subjectId)
        let classIdString = String(classId)
        
        // Use classId in the path and subjectId as the last component
        let urlString = "https://dev.gruppie.in/api/v1/subject-register/class/\(classIdString)/student-mapping/subject/\(subjectIdString)"
        
        print("🌐 Fetching students from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
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
            
            // Print the raw JSON to see the structure
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Students API JSON: \(jsonString)")
            }

            do {
                // First check if the response indicates an error
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = errorResponse["success"] as? Bool, !success {
                    print("❌ API returned error: \(errorResponse["message"] ?? "Unknown error")")
                    DispatchQueue.main.async {
                        self.students = []
                        self.tableView.reloadData()
                        // Still try to fetch assigned students
                        self.fetchAssignedStudents()
                    }
                    return
                }
                
                // Decode the response using the updated model
                let studentsResponse = try JSONDecoder().decode(StudentSubjectResponse.self, from: data)
                
                // Find the data for this specific subject - compare as Int
                if let subjectData = studentsResponse.data.first(where: { Int($0.subjectId) == subject.subjectId }) {
                    DispatchQueue.main.async {
                        self.students = subjectData.students
                        print("✅ Loaded \(self.students.count) students for subject: \(subjectData.subjectName)")
                        
                        // Debug: Print all student IDs to see what we have
                        for student in self.students {
                            print("👨‍🎓 Student: \(student.studentName), ID: \(student.studentId)")
                        }
                        
                        // After loading students, fetch assigned students
                        self.fetchAssignedStudents()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("❌ No data found for subject ID: \(subject.subjectId)")
                        self.students = []
                        self.tableView.reloadData()
                        // Still try to fetch assigned students
                        self.fetchAssignedStudents()
                    }
                }

            } catch {
                print("Decoding error:", error)
                DispatchQueue.main.async {
                    self.students = []
                    self.tableView.reloadData()
                    self.fetchAssignedStudents()
                }
            }
        }.resume()
    }
    
    // ✅ Fetch students using the minimal-list API
    func fetchAssignedStudents() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ No token found")
            DispatchQueue.main.async {
                self.originallyAssignedStudentIds = []
                self.selectedStudentIds = []
                self.tableView.reloadData()
            }
            return
        }
        
        guard let classId = classId else {
            print("❌ No class ID found")
            DispatchQueue.main.async {
                self.originallyAssignedStudentIds = []
                self.selectedStudentIds = []
                self.tableView.reloadData()
            }
            return
        }
        
        // Use the passed groupAcademicYearId
        guard let groupAcademicYearId = groupAcademicYearId else {
            print("❌ No groupAcademicYearId found")
            DispatchQueue.main.async {
                self.originallyAssignedStudentIds = []
                self.selectedStudentIds = []
                self.tableView.reloadData()
            }
            return
        }
        
        // Construct URL with query parameters
        var urlComponents = URLComponents(string: "https://dev.gruppie.in/api/v1/student/minimal-list")
        urlComponents?.queryItems = [
            URLQueryItem(name: "classId", value: "\(classId)"),
            URLQueryItem(name: "groupAcademicYearId", value: groupAcademicYearId)
        ]
        
        guard let url = urlComponents?.url else {
            print("❌ Invalid URL")
            DispatchQueue.main.async {
                self.originallyAssignedStudentIds = []
                self.selectedStudentIds = []
                self.tableView.reloadData()
            }
            return
        }
        
        print("🌐 Fetching students from: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.originallyAssignedStudentIds = []
                    self.selectedStudentIds = []
                    self.tableView.reloadData()
                }
                return
            }

            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized - Token may be invalid or expired")
                    DispatchQueue.main.async {
                        self.originallyAssignedStudentIds = []
                        self.selectedStudentIds = []
                        self.tableView.reloadData()
                    }
                    return
                }
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.originallyAssignedStudentIds = []
                    self.selectedStudentIds = []
                    self.tableView.reloadData()
                }
                return
            }
            
            // Print JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Minimal-list API JSON: \(jsonString)")
            }

            do {
                // First check if the response is an error
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = errorResponse["success"] as? Bool, !success {
                    print("❌ API returned error: \(errorResponse["message"] ?? "Unknown error")")
                    DispatchQueue.main.async {
                        self.originallyAssignedStudentIds = []
                        self.selectedStudentIds = []
                        self.tableView.reloadData()
                    }
                    return
                }
                
                // Try to decode based on common response patterns
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // Check if response has a "data" array (common pattern)
                    if let dataArray = json["data"] as? [[String: Any]] {
                        let studentIds = dataArray.compactMap { item -> String? in
                            // Try different possible ID field names
                            return item["studentId"] as? String ??
                                   item["id"] as? String ??
                                   item["userId"] as? String
                        }
                        
                        DispatchQueue.main.async {
                            self.originallyAssignedStudentIds = Set(studentIds)
                            self.selectedStudentIds = self.originallyAssignedStudentIds
                            print("✅ Loaded \(studentIds.count) students from minimal-list API")
                            self.tableView.reloadData()
                        }
                    }
                    // Check if response is directly an array
                    else if let dataArray = json as? [[String: Any]] {
                        let studentIds = dataArray.compactMap { item -> String? in
                            return item["studentId"] as? String ??
                                   item["id"] as? String ??
                                   item["userId"] as? String
                        }
                        
                        DispatchQueue.main.async {
                            self.originallyAssignedStudentIds = Set(studentIds)
                            self.selectedStudentIds = self.originallyAssignedStudentIds
                            print("✅ Loaded \(studentIds.count) students from minimal-list API")
                            self.tableView.reloadData()
                        }
                    }
                    // No students found
                    else {
                        print("ℹ️ No students array found in response")
                        DispatchQueue.main.async {
                            self.originallyAssignedStudentIds = []
                            self.selectedStudentIds = []
                            self.tableView.reloadData()
                        }
                    }
                }
            } catch {
                print("❌ JSON Decoding error:", error)
                DispatchQueue.main.async {
                    self.originallyAssignedStudentIds = []
                    self.selectedStudentIds = []
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }
    
    // ✅ POST API – Save selected student assignments
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let subject = subject else {
            print("❌ No subject found")
            showAlert(message: "Subject not found")
            return
        }
        
        // Debug: Print current state
        print("📊 Current State:")
        print("   originallyAssignedStudentIds: \(originallyAssignedStudentIds)")
        print("   selectedStudentIds: \(selectedStudentIds)")
        
        // Find which student IDs were added (in selected but not in originally assigned)
        let addedStudentIds = selectedStudentIds.subtracting(originallyAssignedStudentIds)
        
        // Find which student IDs were removed (in originally assigned but not in selected)
        let removedStudentIds = originallyAssignedStudentIds.subtracting(selectedStudentIds)
        
        print("➕ Added student IDs: \(addedStudentIds)")
        print("➖ Removed student IDs: \(removedStudentIds)")
        
        // If there are no changes, show message and return
        if addedStudentIds.isEmpty && removedStudentIds.isEmpty {
            print("⚠️ No changes to student assignments")
            self.showAlert(message: "No changes to save") {
                self.dismiss(animated: true)
            }
            return
        }
        
        // For this API, we need to send the ADDED student IDs
        let studentIdStrings = Array(addedStudentIds)
        
        print("📤 Sending added student IDs: \(studentIdStrings)")
        
        guard !studentIdStrings.isEmpty else {
            print("⚠️ No students to add")
            self.showAlert(message: "No new students to assign")
            return
        }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
        
        saveStudentAssignments(subjectId: subject.subjectId, studentIds: studentIdStrings) { success, message in
            DispatchQueue.main.async {
                // Remove loading indicator
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                
                if success {
                    self.showAlert(message: "Student assignments saved successfully!") {
                        // Update the originally assigned IDs to match the new selection
                        self.originallyAssignedStudentIds = self.selectedStudentIds
                        self.dismiss(animated: true)
                    }
                } else {
                    self.showAlert(message: message ?? "Failed to save assignments")
                }
            }
        }
    }
    
    // ✅ UPDATED API Call to save student assignments with new endpoint
    func saveStudentAssignments(subjectId: Int, studentIds: [String], completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            completion(false, "No token found")
            return
        }
        
        guard let classId = classId else {
            completion(false, "No class ID found")
            return
        }
        
        // UPDATED: New URL with classId in the path
        let urlString = "https://dev.gruppie.in/api/v1/subject-register/class/\(classId)/student-mapping"
        
        guard let url = URL(string: urlString) else {
            completion(false, "Invalid URL")
            return
        }
        
        // Convert String IDs to Int for the API
        let studentIdInts = studentIds.compactMap { Int($0) }
        
        // UPDATED: New request body structure - removed classId, subjectId as String
        let requestBody: [String: Any] = [
            "studentIds": studentIdInts,
            "subjectId": "\(subjectId)" // Send subjectId as String
        ]
        
        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
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
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let message = json["message"] as? String {
                                completion(false, message)
                            } else if let error = json["error"] as? String {
                                completion(false, error)
                            } else {
                                completion(false, "Server error with status code: \(httpResponse.statusCode)")
                            }
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

    // MARK: - TableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignTeacherTableViewCell", for: indexPath) as? AssignTeacherTableViewCell else {
            return UITableViewCell()
        }
        
        let student = students[indexPath.row]
        
        // Display student name
        cell.name.text = student.studentName
        
        // Configure the cell's button action
        cell.enableButton.tag = indexPath.row
        cell.enableButton.removeTarget(self, action: nil, for: .allEvents)
        cell.enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: .touchUpInside)
        
        // Show green tick if selected - using studentId
        cell.isSelectedForAssignment = selectedStudentIds.contains(student.studentId)
        
        return cell
    }

    // MARK: - Toggle Selection
    @objc func enableButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < students.count else { return }
        
        let student = students[index]
        let studentId = student.studentId
        
        print("🔘 Button tapped for student: \(student.studentName) with ID: \(studentId)")
        print("   Before - selectedStudentIds: \(selectedStudentIds)")
        
        if selectedStudentIds.contains(studentId) {
            selectedStudentIds.remove(studentId)
            print("❌ Removed student ID: \(studentId) from selection")
        } else {
            selectedStudentIds.insert(studentId)
            print("✅ Added student ID: \(studentId) to selection")
        }
        
        print("   After - selectedStudentIds: \(selectedStudentIds)")
        
        // Reload just this row to update the button appearance
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
