import UIKit

class StudentViewController1: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    var currentRole: String?
    var studentTeams: [StudentTeam] = []
    var filteredStudentTeams: [StudentTeam] = []
    var combinedStudentTeams: [CombinedStudentTeam] = []
    var token: String = ""
    var groupIds: String = ""
    var teamId: String = ""
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let regularNib = UINib(nibName: "RegularTableViewCell1", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell1", bundle: nil)
        heightConstraintOfSearchView.constant = 0
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell1")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell1")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        searchView.isHidden = true
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
        filteredStudentTeams = studentTeams
        
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        segmentChanged()
    }
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
        if shouldShow {
            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
            searchTextField?.placeholder = "Search..."
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchTextField?.backgroundColor = .white
            searchTextField?.layer.cornerRadius = 5
            searchTextField?.layer.borderWidth = 1
            searchTextField?.layer.borderColor = UIColor.gray.cgColor
            if let searchTextField = searchTextField {
                searchView.addSubview(searchTextField)
            }
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
        }
    }
    
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

                guard let firstClassData = response.data.first?.classes.first else {
                    print("❌ No class data found")
                    return
                }

                let classData = response.data.first?.classes ?? []
                let classTypeId = firstClassData.classTypeId
                let className = firstClassData.classList.first?.className ?? "Unknown"
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
        let storyboard = UIStoryboard(name: "Student1", bundle: nil)
        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass1") as? AddRegularClass1 else {
            print("❌ Failed to instantiate AddRegularClass from Student1.storyboard")
            return
        }

        addRegularClassVC.classData = classData
        addRegularClassVC.classTypeId = classTypeId
        addRegularClassVC.className = className
        addRegularClassVC.groupId = groupIds
        addRegularClassVC.token = token

        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
    }
    
    func addCombinedClass() {
        print("✅ Adding Combined class")
        
        let storyboard = UIStoryboard(name: "Student1", bundle: nil)
        guard let addCombineClassVC = storyboard.instantiateViewController(withIdentifier: "AddCombineClass1") as? AddCombineClass1 else {
            print("❌ Failed to instantiate AddCombineClass1 from Student.storyboard")
            return
        }

        addCombineClassVC.token = self.token
        addCombineClassVC.groupIds = self.groupIds
        
        addCombineClassVC.studentTeams = self.studentTeams
        addCombineClassVC.filteredStudentTeams = self.filteredStudentTeams
        addCombineClassVC.combinedStudentTeams = self.combinedStudentTeams
        
        self.navigationController?.pushViewController(addCombineClassVC, animated: true)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTableViewCell1", for: indexPath) as? RegularTableViewCell1 else {
                return UITableViewCell()
            }
            
            let studentTeam = filteredStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = studentTeam.phone.isEmpty ? "N/A" : studentTeam.phone
            
            cell.configure(name: studentTeam.name, designation: studentTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CombineTableViewCell1", for: indexPath) as? CombineTableViewCell1 else {
                return UITableViewCell()
            }

            let combinedTeam = combinedStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = combinedTeam.phone.isEmpty ? "N/A" : combinedTeam.phone
            
            cell.configure(name: combinedTeam.name, designation: combinedTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        }
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
        print("API URL: \(url.absoluteString)")

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

                        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController1") as? DetailViewController1 {
                            detailVC.token = self.token
                            detailVC.groupIds = self.groupIds
                            detailVC.teamId = teamId
                            detailVC.studentName = name
                            detailVC.studentDbId = studentDbId
                            detailVC.studentDetails = response.data
                            detailVC.currentRole = self.currentRole

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
    
    func filterMembers(textField: String) {
        let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText.isEmpty {
            filteredStudentTeams = studentTeams
            StudentList.reloadData()
            return
        }
        
        if SegmentController.selectedSegmentIndex == 0 {
            filteredStudentTeams = studentTeams.filter {
            
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        StudentList.reloadData()
    }
    
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    filterMembers(textField: searchText)
    return true
}
}
