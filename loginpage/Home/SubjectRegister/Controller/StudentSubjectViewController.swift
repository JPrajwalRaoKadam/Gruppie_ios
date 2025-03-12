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

    var students: [Staffs] = []  // ✅ Store API response here

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Received Data in StudentSubjectViewController:")
        print("📌 Token: \(token)")
        print("📌 Group ID: \(groupId)")
        print("📌 Team ID: \(teamId)")
        print("📌 Subject ID: \(subjectId ?? "N/A")")
        print("📌 Subject Priority: \(subjectPriority ?? -1)")
        print("📌 Subject Name: \(selectedSubject?.subjectName ?? "N/A")")

        // ✅ Bind the subject name from the previous screen
        SubjectName.text = selectedSubject?.subjectName ?? "N/A"
        
        // ✅ Bind the subject priority from the previous screen
        if let priority = subjectPriority {
            SubjectPriority.text = "\(priority)"
        } else {
            SubjectPriority.text = "N/A"
        }

        // ✅ Ensure TableView is visible

        // ✅ Register TableViewCell
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "StudentSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentSubjectTableViewCell")

        // ✅ Check if delegate & dataSource are set correctly
        if TableView.delegate == nil || TableView.dataSource == nil {
            print("❌ Error: TableView delegate or dataSource is not set")
        } else {
            print("✅ TableView delegate & dataSource set successfully")
        }

        configureUI()

        // ✅ Call API to fetch student data
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
    


    // MARK: - API Call
    func fetchStudentSubjects() {
        guard let subjectId = subjectId, let subjectPriority = subjectPriority else {
            print("❌ Error: Missing subjectId or subjectPriority")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/students/get?subjectPriority=\(subjectPriority)"
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

            // ✅ Print Raw API Response (for debugging)
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📌 Raw API Response StudentSubject:\n\(rawResponse)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(StaffListResponse.self, from: data)
                
                // ✅ Print Decoded Data (for debugging)
                print("✅ Decoded API Response:")
                print("📌 Total Pages: \(decodedResponse.totalNumberOfPages)")
                print("📌 Staff List:")
                for staff in decodedResponse.data {
                    print(" - Name: \(staff.name ?? "N/A"), ID: \(staff.staffId ?? "N/A"), Designation: \(staff.designation ?? "N/A")")
                }

                DispatchQueue.main.async {
                    self.students = decodedResponse.data  // ✅ Store response in variable
                    print("📌 Total students fetched: \(self.students.count)") // ✅ Debugging

                    self.TableView.reloadData()  // ✅ Reload TableView

                    // ✅ Force reload after a slight delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.TableView.reloadData()
                    }
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        task.resume()
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📌 numberOfRowsInSection called - Students count: \(students.count)")
        return students.count  // ✅ Update dynamically based on API response
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("📌 cellForRowAt called for indexPath: \(indexPath.row)")

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentSubjectTableViewCell", for: indexPath) as? StudentSubjectTableViewCell else {
            print("❌ Cell Dequeue Failed")
            return UITableViewCell()
        }

        let student = students[indexPath.row]
        
        // ✅ Bind subjectName from API response to the label in the cell
        cell.SubjectName.text = student.subjectName ?? "N/A"
        
        return cell
    }
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
