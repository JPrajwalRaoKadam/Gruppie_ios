import UIKit

class StaffSujectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var OptionalButton: UIButton!
    @IBOutlet weak var SubjectPriority: UITextField!
    @IBOutlet weak var SubjectName: UITextField!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    
    var subjectId: String?
    var selectedSubject: SubjectDetail?
    var staffList: [Staffs] = []
    var teamId: String?
    var groupId: String?
    var token: String?
    var selectedSubjects: Set<String> = []
    var subjectPriority: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        if let priority = subjectPriority {
                SubjectPriority.text = "\(priority)"
            } else {
                SubjectPriority.text = "No Priority Assigned"
            }
        TableView.layer.cornerRadius = 10
        TableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "StaffSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "StaffSubjectTableViewCell")

        configureUI()
        
        fetchTeachingStaff()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    func configureUI() {
        searchLabel.layer.cornerRadius = 8
        searchLabel.layer.borderWidth = 1
        searchLabel.layer.borderColor = UIColor.black.cgColor
        searchLabel.layer.masksToBounds = true
        save.layer.cornerRadius = 10
        save.clipsToBounds = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("✅ Number of Rows: \(staffList.count)")
        return staffList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffSubjectTableViewCell", for: indexPath) as? StaffSubjectTableViewCell else {
            print("❌ Cell Dequeue Failed")
            return UITableViewCell()
        }
        
        let staff = staffList[indexPath.row]
        let isSelected = selectedSubjects.contains(staff.staffId!)
        
        
        cell.configure(with: staff, isSelected: isSelected)
        cell.delegate = self
        
        return cell
    }

    func fetchTeachingStaff() {
            guard let groupId = groupId,
                  let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching") else {
                print("❌ Invalid groupId or URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Error fetching staff: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📌 Raw API Response StaffSubject: \(jsonString)")
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(StaffListResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.staffList = decodedResponse.data
                        self.TableView.reloadData()
                        
                        if let subjectName = self.selectedSubject?.subjectName {
                            self.SubjectName.text = subjectName
                        } else {
                            self.SubjectName.text = "No Subject Name"
                        }
                        if let priority = self.subjectPriority {
                            self.SubjectPriority.text = "\(priority)"
                        } else {
                            self.SubjectPriority.text = "No Priority Assigned"
                        }
                    }
                } catch {
                    print("❌ Decoding error: \(error.localizedDescription)")
                }
            }.resume()
        }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension StaffSujectViewController: StaffSubjectTableViewCellDelegate {
    func didTapCheckBox(for staff: Staffs) {
        if selectedSubjects.contains(staff.staffId!) {
            selectedSubjects.remove(staff.staffId!)
        } else {
            selectedSubjects.insert(staff.staffId!)
        }
        
        if let index = staffList.firstIndex(where: { $0.staffId == staff.staffId }) {
            let indexPath = IndexPath(row: index, section: 0)
            TableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        print("✅ Selected: \(staff.name ?? "Unknown")")
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let groupId = groupId, let teamId = teamId, let selectedSubject = selectedSubject else {
            print("❌ Missing required parameters")
            return
        }

        guard let subjectName = SubjectName.text, !subjectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("❌ Error: Subject name cannot be empty")
            return
        }

        print("📌 groupId StaffSubject: \(groupId)")
        print("📌 teamId StaffSubject: \(teamId)")
        print("📌 subjectId StaffSubject: \(subjectId ?? "nil")")

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId ?? "")/staff/update"
        print("🌐 API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        let selectedStaffIds = Array(selectedSubjects)

        let parameters: [String: Any] = [
            "isLanguage": false,
            "optional": false,
            "staffId": selectedStaffIds,
            "subjectName": subjectName,
            "subjectPriority": Int(SubjectPriority.text ?? "0") ?? 0
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData

            print("📩 API Request Body: \(parameters)")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ API Request Failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid Response")
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Staff successfully updated for subject")

                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📌 API Response: \(responseString)")
                    }

                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    print("❌ Failed with Status Code: \(httpResponse.statusCode)")
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        print("❌ API Error Message: \(errorMessage)")
                    }
                }
            }.resume()
        } catch {
            print("❌ JSON Serialization Error: \(error.localizedDescription)")
        }
    }
}
