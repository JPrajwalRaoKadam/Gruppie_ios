import UIKit

// MARK: - API Models


// MARK: - LanguageViewController
class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var classId: String?
    var groupAcademicYearId: String?
    
    // Row labels
    let languages = [
        "Language 1",
        "Language 2",
        "Language 3",
        "Optional - 1",
        "Optional - 2",
        "Optional - 3",
        "Optional - 4",
        "Others"
    ]
    
    // Store fetched API data
    var subjectGroups: [ClassSubjectGroup] = []
    
    // Map table rows to API 'type'
    let languageTypeMapping: [String: String] = [
        "Language 1": "L-I",
        "Language 2": "L-II",
        "Language 3": "L-III",
        "Optional - 1": "O-1",
        "Optional - 2": "O-2",
        "Optional - 3": "O-3",
        "Optional - 4": "O-4",
        "Others": "OTHERS"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Fetch subjects from API
        fetchSubjects()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.height / 2
    }
    
    private func setupUI() {
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.clipsToBounds = true
    }
    
    // MARK: - API Call
    private func fetchSubjects() {
        
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ No token found")
            return
        }
        
        guard let classId = classId,
              let groupAcademicYearId = groupAcademicYearId else {
            print("❌ Missing classId or groupAcademicYearId")
            return
        }
        
        let urlString = "https://dev.gruppie.in/api/v1/subject-register?groupAcademicYearId=\(groupAcademicYearId)&classId=\(classId)&page=1&limit=20"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ClassSubjectsAPIResponse.self, from: data)
                
                // ✅ Print detailed API response
                print("📌 Full API Response:")
                for group in decodedResponse.data.subjectGroups {
                    print("---- Subject Group Type: \(group.type) ----")
                    for subject in group.subjects {
                        print("Subject Name: \(subject.subjectName), Subject ID: \(subject.subjectId), Code: \(subject.code)")
                        print("Assigned Students Count: \(subject.assignedStudentsCount), Assigned Staff Count: \(subject.assignedStaffCount)")
                        for staff in subject.assignedStaff {
                            print("  Staff Name: \(staff.staffName), Staff ID: \(staff.staffId), Profile Photo: \(staff.profilePhoto ?? "nil")")
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.subjectGroups = decodedResponse.data.subjectGroups
                    self.tableView.reloadData()
                }
                
            } catch {
                print("❌ Decoding Error:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Response:", jsonString)
                }
            }
        }.resume()
    }
    
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") ??
                   UITableViewCell(style: .default, reuseIdentifier: "LanguageCell")
        
        cell.textLabel?.text = languages[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.row]
        print("📌 Selected Row: \(selectedLanguage)")
        
        guard let type = languageTypeMapping[selectedLanguage] else { return }
        
        // Filter subjects for the selected type
        let filteredSubjects = subjectGroups.first { $0.type == type }?.subjects ?? []
        
        // ✅ Print filtered data being passed
        print("📌 Passing \(filteredSubjects.count) subjects to LanguageSubViewController:")
        for subject in filteredSubjects {
            print("Subject Name: \(subject.subjectName), Subject ID: \(subject.subjectId), Code: \(subject.code)")
            for staff in subject.assignedStaff {
                print("  Staff Name: \(staff.staffName), Staff ID: \(staff.staffId)")
            }
        }
        
        // Navigate to LanguageSubViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LanguageSubViewController") as? LanguageSubViewController {
            vc.subjects = filteredSubjects
            vc.title = selectedLanguage
            
            // ✅ Pass the classId to LanguageSubViewController
            if let classId = self.classId {
                vc.classId = Int(classId)
                print("📌 Passing classId: \(classId) to LanguageSubViewController")
            } else {
                print("⚠️ Warning: classId is nil")
            }
            
            // ✅ Pass the groupAcademicYearId
            if let groupAcademicYearId = self.groupAcademicYearId {
                vc.groupAcademicYearId = groupAcademicYearId
                print("📌 Passing groupAcademicYearId: \(groupAcademicYearId) to LanguageSubViewController")
            } else {
                print("⚠️ Warning: groupAcademicYearId is nil")
                
                // Optionally set a default value if needed
                // vc.groupAcademicYearId = "142" // Default value
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
