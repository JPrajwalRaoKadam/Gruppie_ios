import UIKit

class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func AddButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Add Class", message: "Choose an option", preferredStyle: .actionSheet)
        
        let addRegularClassAction = UIAlertAction(title: "Add Regular class", style: .default) { _ in
            self.fetchClassDataForRegularClass()
        }
        
        let addCombinedClassAction = UIAlertAction(title: "Add Combined class", style: .default) { _ in
            self.addCombinedClass()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(addRegularClassAction)
        actionSheet.addAction(addCombinedClassAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func fetchClassDataForRegularClass() {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/get/class/list") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("🔍 Requesting: \(url)")
        print("🔑 Auth Token: \(token)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response from server")
                return
            }

            print("📡 Response Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ClassListResponse.self, from: data)

                // Extract classTypeId and className from the first available ClassType
                guard let firstClassData = response.data.first?.classes.first else {
                    print("❌ No class data found")
                    return
                }

                let classData = response.data.first?.classes ?? []
                let classTypeId = firstClassData.classTypeId
                let className = firstClassData.classList.first?.className ?? "Unknown" // You can modify this based on your requirement

                DispatchQueue.main.async {
                    self.navigateToAddRegularClass(
                        withClassData: classData,
                        classTypeId: classTypeId,
                        className: className
                    )
                }
            } catch {
                print("❌ Error decoding JSON: \(error)")
            }
        }

        task.resume()
    }
    func navigateToAddRegularClass(withClassData classData: [ClassType], classTypeId: String, className: String) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass") as? AddRegularClass else {
            print("❌ Failed to instantiate AddRegularClass from Student.storyboard")
            return
        }

        // Pass data to the view controller
        addRegularClassVC.classData = classData
        addRegularClassVC.classTypeId = classTypeId
        addRegularClassVC.className = className
        addRegularClassVC.groupId = groupIds
        addRegularClassVC.token = token

        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
    }
    func addCombinedClass() {
        print("✅ Adding Combined class")
        
        // Instantiate AddCombineClass from storyboard
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addCombineClassVC = storyboard.instantiateViewController(withIdentifier: "AddCombineClass") as? AddCombineClass else {
            print("❌ Failed to instantiate AddCombineClass from Student.storyboard")
            return
        }

        // Pass data to the AddCombineClass view controller
        addCombineClassVC.token = self.token
        addCombineClassVC.groupIds = self.groupIds
        
        // Optionally, pass any other data needed for AddCombineClass
        addCombineClassVC.studentTeams = self.studentTeams
        addCombineClassVC.filteredStudentTeams = self.filteredStudentTeams
        addCombineClassVC.combinedStudentTeams = self.combinedStudentTeams
        
        // Navigate to AddCombineClass view controller
        self.navigationController?.pushViewController(addCombineClassVC, animated: true)
    }
    var studentTeams: [StudentTeam] = []
    var filteredStudentTeams: [StudentTeam] = []
    var combinedStudentTeams: [CombinedStudentTeam] = []
    var token: String = ""
    var groupIds: String = ""
    var teamId: String = ""
    
    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SearchClass: UITextField!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        SearchClass.delegate = self
        SearchClass.addTarget(self, action: #selector(searchStudents), for: .editingChanged)
        
        filteredStudentTeams = studentTeams
        
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        segmentChanged()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SegmentController.selectedSegmentIndex == 0 {
            return filteredStudentTeams.count
        } else {
            return combinedStudentTeams.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentIndex = SegmentController.selectedSegmentIndex
        
        if segmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTableViewCell", for: indexPath) as? RegularTableViewCell else {
                return UITableViewCell()
            }
            
            let studentTeam = filteredStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = studentTeam.phone.isEmpty ? "N/A" : studentTeam.phone

            cell.configure(name: studentTeam.name, designation: studentTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CombineTableViewCell", for: indexPath) as? CombineTableViewCell else {
                return UITableViewCell()
            }

            let combinedTeam = combinedStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = combinedTeam.phone.isEmpty ? "N/A" : combinedTeam.phone
            
            cell.configure(name: combinedTeam.name, designation: combinedTeam.teacherName ?? "Unknown", icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        }
    }

    @objc func searchStudents() {
        guard let searchText = SearchClass.text, !searchText.isEmpty else {
            filteredStudentTeams = studentTeams
            StudentList.reloadData()
            return
        }
        
        if SegmentController.selectedSegmentIndex == 0 {
            filteredStudentTeams = studentTeams.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        StudentList.reloadData()
    }

    @objc func segmentChanged() {
        let selectedIndex = SegmentController.selectedSegmentIndex
        print("Segment changed to index: \(selectedIndex)")

        if selectedIndex == 1 {
            fetchCombinedStudentTeams()
        }
        
        StudentList.reloadData()
    }

    func fetchCombinedStudentTeams() {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/class/get?type=combined") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CombinedStudentTeamResponse.self, from: data)
                DispatchQueue.main.async {
                    self.combinedStudentTeams = response.data
                    self.StudentList.reloadData()
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        
        task.resume()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = SegmentController.selectedSegmentIndex
        
        if selectedIndex == 0 {
            let selectedStudentTeam = filteredStudentTeams[indexPath.row]
            navigateToDetailViewController(withTeamId: selectedStudentTeam.teamId, name: selectedStudentTeam.name)
        } else {
            let selectedCombinedTeam = combinedStudentTeams[indexPath.row]
            navigateToDetailViewController(withTeamId: selectedCombinedTeam.teamId, name: selectedCombinedTeam.name)
        }
    }

    func navigateToDetailViewController(withTeamId teamId: String, name: String) {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/team/\(teamId)/students/get") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print raw API response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response to detailView: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(StudentDataResponse.self, from: data)

                DispatchQueue.main.async {
                    if let firstStudent = response.data.first {
                        let studentDbId = firstStudent.studentDbId ?? "N/A"
                        print("Student Database ID: \(studentDbId)")

                        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                            detailVC.token = self.token
                            detailVC.groupIds = self.groupIds
                            detailVC.teamId = teamId
                            detailVC.studentName = name
                            detailVC.studentDbId = studentDbId
                            detailVC.studentDetails = response.data
                            self.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    } else {
                        print("No student data found")
                    }
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }

        task.resume()
    }
}
