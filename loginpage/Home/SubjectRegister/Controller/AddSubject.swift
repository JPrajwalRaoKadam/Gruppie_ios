import UIKit

class AddSubject: UIViewController {
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Save: UIButton!
    
    var token: String?
    var groupId: String?
    var teamId: String?
    var subjects: [SubjectDetail] = []
    var selectedSubjects: Set<SubjectDetail> = []
    var subjectDetail: SubjectDetail?
    var sectionIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Token: \(token ?? "N/A")")
        print("Group ID: \(groupId ?? "N/A")")
        print("Team ID: \(teamId ?? "N/A")")
        
        styleButton(Save)
        
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "AddSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "AddSubjectTableViewCell")
        
        fetchSubjects()
    }
    
    func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
    }
    
    func fetchSubjects() {
        guard let groupId = groupId, let teamId = teamId, let token = token else {
            print("❌ Missing required parameters")
            return
        }
        
        let apiURL = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/gruppie/subject/get?subjectPriority=1"
        guard let url = URL(string: apiURL) else {
            print("❌ Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Server returned error")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SubjectRegisterResponse.self, from: data)
                self.subjects = decodedResponse.data
                
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
                
                print("✅ Subjects Loaded: \(self.subjects.count)")
            } catch {
                print("❌ JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    @IBAction func saveSelectedSubjects(_ sender: UIButton) {
        guard let groupId = groupId, let teamId = teamId, let token = token else {
            print("❌ Missing required parameters")
            return
        }
        
        guard !selectedSubjects.isEmpty else {
            print("⚠️ No subjects selected")
            return
        }
        
        let apiURL = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/add"
        print("📌 API URL: \(apiURL)")
        
        guard let url = URL(string: apiURL) else {
            print("❌ Invalid API URL")
            return
        }
        
        let newSubjects = selectedSubjects.map { subject in
            return SubjectDetail(
                universityCode: subject.universityCode,
                totalNoOfStudents: subject.totalNoOfStudents,
                subjectPriority: determineSubjectPriority(for: subject, sectionIndex: sectionIndex ?? 0),
                subjectName: subject.subjectName,
                subjectId: subject.subjectId ?? "",
                staffName: subject.staffName,
                partSubject: subject.partSubject,
                parentSubject: subject.parentSubject,
                optional: subject.optional,
                noOfStudentsUnAssigned: subject.noOfStudentsUnAssigned,
                noOfStudentsAssigned: subject.noOfStudentsAssigned,
                manual: subject.manual,
                isLanguage: subject.isLanguage,
                canPost: subject.canPost
            )
        }
        let subjectDataArray: [[String: Any]] = newSubjects.map { subject in
            var subjectDict: [String: Any] = [
                "isLanguage": subject.isLanguage,
                "manual": subject.manual ?? false,
                "optional": subject.optional,
                "subjectName": subject.subjectName,
                "universityCode": subject.universityCode ?? ""
            ]
            
            if subject.isLanguage {
                subjectDict["subjectPriority"] = subject.subjectPriority
            }
            
            return subjectDict
        }
        
        let requestBody: [String: Any] = ["subjectData": subjectDataArray]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("❌ JSON Encoding Failed")
            return
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📜 Request Body:\n\(jsonString)")        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid server response")
                return
            }
            
            print("🌍 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data, httpResponse.statusCode == 200 else {
                print("❌ Failed to save subjects")
                return
            }
            
            print("✅ Subjects saved successfully!")
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        task.resume()
    }
    
    func determineSubjectPriority(for subject: SubjectDetail, sectionIndex: Int) -> Int {
        switch sectionIndex {
        case 0: return 1 // Language-1
        case 1: return 2 // Language-2
        case 2: return 3 // Language-3
        case 3: return 0 // Other Subjects
        default: return 0
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AddSubject: UITableViewDataSource, UITableViewDelegate, AddSubjectTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubjectTableViewCell", for: indexPath) as? AddSubjectTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = subjects[indexPath.row]
        let isSelected = selectedSubjects.contains(subject)
        
        cell.configure(with: subject, isSelected: isSelected)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Checkbox Selection
    func didTapCheckBox(for subject: SubjectDetail) {
        print("Toggled Subject: \(subject.subjectName) - ID: \(subject.subjectId ?? "N/A")")
        
        if selectedSubjects.contains(subject) {
            selectedSubjects.remove(subject)
        } else {
            selectedSubjects.insert(subject)
        }
        
        if let index = subjects.firstIndex(where: { $0.subjectId == subject.subjectId }) {
            DispatchQueue.main.async {
                self.TableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none) // ✅ Reload only selected row
            }
        }
        
        func BackButton(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
