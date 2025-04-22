import UIKit

class StudentSubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var OptionalButton: UIButton!
    @IBOutlet weak var SubjectPriority: UITextField!
    @IBOutlet weak var SubjectName: UITextField!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var searchLabel: UILabel!

    var token: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var subjectId: String?
    var subjectPriority: Int?
    var selectedSubject: SubjectDetail?
    var selectedStudentIds: [String] = []

    var students: [StudentSubjectStudent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Received Data in StudentSubjectViewController:")
        print("📌 Token: \(token)")
        print("📌 Group ID: \(groupId)")
        print("📌 Team ID: \(teamId)")
        print("📌 Subject ID: \(subjectId ?? "N/A")")
        print("📌 Subject Priority: \(subjectPriority ?? -1)")
        print("📌 Subject Name: \(selectedSubject?.subjectName ?? "N/A")")

        SubjectName.text = selectedSubject?.subjectName ?? "N/A"
        if let priority = subjectPriority {
            SubjectPriority.text = "\(priority)"
        } else {
            SubjectPriority.text = "N/A"
        }

        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "StudentSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentSubjectTableViewCell")

        if TableView.delegate == nil || TableView.dataSource == nil {
            print("❌ Error: TableView delegate or dataSource is not set")
        } else {
            print("✅ TableView delegate & dataSource set successfully")
        }

        configureUI()
        fetchStudentSubjects()
    }

    func configureUI() {
        searchLabel.layer.cornerRadius = 8
        searchLabel.layer.borderWidth = 1
        searchLabel.layer.borderColor = UIColor.black.cgColor
        searchLabel.layer.masksToBounds = true
        save.layer.cornerRadius = 10
        save.clipsToBounds = true
    }

    func fetchStudentSubjects() {
        guard let subjectId = subjectId, let subjectPriority = subjectPriority else {
            print("❌ Error: Missing subjectId or subjectPriority")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/students/get?subjectPriority=\(subjectPriority)"
        print("🌐 API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No Data Received")
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📌 Raw API Response StudentSubject:\n\(rawResponse)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(StudentSubjectResponse.self, from: data)

                DispatchQueue.main.async {
                    // 🔁 Collect all students from all subject entries
                    self.students = decodedResponse.data.flatMap { $0.studentsList }

                    print("📌 Total students fetched: \(self.students.count)")
                    for (index, student) in self.students.enumerated() {
                        print("👤 Student \(index + 1): \(student.studentName ?? "N/A") - ID: \(student.userId ?? "N/A")")
                    }

                    self.TableView.reloadData()
                }

            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        task.resume()
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentSubjectTableViewCell", for: indexPath) as? StudentSubjectTableViewCell else {
            return UITableViewCell()
        }

        let student = students[indexPath.row]
        cell.StudentName.text = student.studentName ?? "No Name"

        // Set checkbox state
        let isSelected = selectedStudentIds.contains(student.userId ?? "")
        cell.checkBoxButton.setImage(UIImage(systemName: isSelected ? "checkmark.square.fill" : "square"), for: .normal)

        // Closure for checkbox tapped
        cell.checkBoxTappedAction = { [weak self] in
            guard let self = self else { return }
            let userId = student.userId

            if let index = self.selectedStudentIds.firstIndex(of: userId ?? "") {
                self.selectedStudentIds.remove(at: index)
            } else {
                self.selectedStudentIds.append(userId ?? "")
            }

            print("📌 Current selectedStudentIds: \(self.selectedStudentIds)")
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let subjectId = subjectId,
              let subjectPriority = subjectPriority else {
            print("❌ Missing subject ID or priority")
            return
        }

        let urlString = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/students/add?subjectPriority=\(subjectPriority)"
        print("🌐 API POST URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid API URL")
            return
        }

        let requestBody: [String: Any] = [
            "userIds": selectedStudentIds
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📩 Raw API Response:\n\(rawResponse)")
            }

            // Optional: Parse the response to confirm success
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Students successfully added to subject!")
                } else {
                    print("❌ Failed to add students. Status Code: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
