import UIKit

class AssignStudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    var subject: ClassSubject?
    var classId: Int?
    var groupAcademicYearId: String?

    // ✅ Store full student objects
    var students: [StudentSubjectStudent] = []

    // ✅ Store currently selected student IDs
    var selectedStudentIds: Set<String> = []
    
    // ✅ Store originally assigned student IDs
    var originallyAssignedStudentIds: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = backButton.frame.height / 2
        
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
    
    // ✅ FIRST API – Fetch All Students for this Subject
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

        let subjectIdString = String(subject.subjectId)
        let classIdString = String(classId)
        
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Students API JSON: \(jsonString)")
            }

            do {
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = errorResponse["success"] as? Bool, !success {
                    print("❌ API returned error: \(errorResponse["message"] ?? "Unknown error")")
                    DispatchQueue.main.async {
                        self.students = []
                        self.tableView.reloadData()
                        self.fetchAssignedStudents()
                    }
                    return
                }
                
                let studentsResponse = try JSONDecoder().decode(StudentSubjectResponse.self, from: data)
                
                if let subjectData = studentsResponse.data.first(where: { Int($0.subjectId) == subject.subjectId }) {
                    DispatchQueue.main.async {
                        self.students = subjectData.students
                        print("✅ Loaded \(self.students.count) students for subject: \(subjectData.subjectName)")
                        
                        for student in self.students {
                            print("👨‍🎓 Student: \(student.studentName), ID: \(student.studentId)")
                        }
                        
                        // ⭐ After loading students, call second API to get assigned students
                        self.fetchAssignedStudents()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("❌ No data found for subject ID: \(subject.subjectId)")
                        self.students = []
                        self.tableView.reloadData()
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
    
    // ✅ SECOND API – Fetch Assigned Students (to mark them as selected)
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
        
        guard let subject = subject else {
            print("❌ No subject found")
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
        
        // ✅ Use student-mapping endpoint
        let subjectIdString = String(subject.subjectId)
        let classIdString = String(classId)
        let urlString = "https://dev.gruppie.in/api/v1/subject-register/class/\(classIdString)/student-mapping/subject/\(subjectIdString)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            DispatchQueue.main.async {
                self.originallyAssignedStudentIds = []
                self.selectedStudentIds = []
                self.tableView.reloadData()
            }
            return
        }
        
        print("🌐 Fetching assigned students from: \(urlString)")
        
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

            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Assigned Students JSON: \(jsonString)")
            }

            do {
                let studentsResponse = try JSONDecoder().decode(StudentSubjectResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if let subjectData = studentsResponse.data.first(where: { Int($0.subjectId) == self.subject?.subjectId }) {
                        let assignedStudentIds = subjectData.students.map { $0.studentId }
                        self.originallyAssignedStudentIds = Set(assignedStudentIds)
                        self.selectedStudentIds = self.originallyAssignedStudentIds
                        
                        print("✅ Originally assigned students loaded: \(self.originallyAssignedStudentIds.count) students")
                        print("🔢 Originally Assigned Student IDs: \(self.originallyAssignedStudentIds)")
                        print("🔢 Selected Student IDs: \(self.selectedStudentIds)")
                    } else {
                        print("ℹ️ No assigned students found for this subject")
                        self.originallyAssignedStudentIds = []
                        self.selectedStudentIds = []
                    }
                    
                    self.tableView.reloadData()
                }

            } catch {
                print("❌ Assigned Decoding error:", error)
                DispatchQueue.main.async {
                    self.originallyAssignedStudentIds = []
                    self.selectedStudentIds = []
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }
    
    // ✅ POST API – Save selected student assignments (Add new and Remove existing)
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let subject = subject else {
            print("❌ No subject found")
            showAlert(message: "Subject not found")
            return
        }
        
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
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
        
        // Handle both add and remove operations
        var hasError = false
        let group = DispatchGroup()
        
        // Add new students
        if !addedStudentIds.isEmpty {
            group.enter()
            let addedStudentIdStrings = Array(addedStudentIds)
            print("📤 Adding student IDs: \(addedStudentIdStrings)")
            
            saveStudentAssignments(subjectId: subject.subjectId, studentIds: addedStudentIdStrings, action: "add") { success, message in
                if !success {
                    print("❌ Failed to add students: \(message ?? "Unknown error")")
                    hasError = true
                }
                group.leave()
            }
        }
        
        // Remove students
        if !removedStudentIds.isEmpty {
            group.enter()
            let removedStudentIdStrings = Array(removedStudentIds)
            print("📤 Removing student IDs: \(removedStudentIdStrings)")
            
            saveStudentAssignments(subjectId: subject.subjectId, studentIds: removedStudentIdStrings, action: "remove") { success, message in
                if !success {
                    print("❌ Failed to remove students: \(message ?? "Unknown error")")
                    hasError = true
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            if hasError {
                self.showAlert(message: "Some changes could not be saved. Please try again.")
            } else {
                self.showAlert(message: "Student assignments updated successfully!") {
                    self.originallyAssignedStudentIds = self.selectedStudentIds
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // ✅ Unified API Call to handle both add and remove operations
    func saveStudentAssignments(subjectId: Int, studentIds: [String], action: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            completion(false, "No token found")
            return
        }
        
        guard let classId = classId else {
            completion(false, "No class ID found")
            return
        }
        
        // Use different endpoints for add and remove
        let urlString: String
        if action == "add" {
            urlString = "https://dev.gruppie.in/api/v1/subject-register/class/\(classId)/student-mapping"
        } else {
            // For remove, try using POST with a different path
            urlString = "https://dev.gruppie.in/api/v1/subject-register/class/\(classId)/student-mapping/remove"
        }
        
        guard let url = URL(string: urlString) else {
            completion(false, "Invalid URL")
            return
        }
        
        let studentIdInts = studentIds.compactMap { Int($0) }
        
        let requestBody: [String: Any] = [
            "studentIds": studentIdInts,
            "subjectId": "\(subjectId)"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            completion(false, "Failed to create request body")
            return
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📦 \(action.uppercased()) Request Body: \(jsonString)")
        }
        
        var request = URLRequest(url: url)
        // Use POST for both add and remove since DELETE is not supported
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ \(action.uppercased()) API Error:", error.localizedDescription)
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(false, "No data received from server")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 \(action.uppercased()) Response: \(jsonString)")
            }
            
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
        
        cell.name.text = student.studentName
        
        cell.enableButton.tag = indexPath.row
        cell.enableButton.removeTarget(self, action: nil, for: .allEvents)
        cell.enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: .touchUpInside)
        
        // ✅ Show green tick if selected - this will mark already assigned students
        let isSelected = selectedStudentIds.contains(student.studentId)
        cell.isSelectedForAssignment = isSelected
        print("🎨 Cell for student: \(student.studentName), ID: \(student.studentId), Selected: \(isSelected)")
        
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
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
