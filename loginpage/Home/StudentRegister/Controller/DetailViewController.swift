import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    var classId: String = ""
    var groupAcademicYearId: String = ""
    var className: String = ""
    var studentName: String = ""
    var students: [StudentRegistration] = []
    var filteredStudents: [StudentRegistration] = []


    var studentDbId: String?
    var teamId: String = ""
    var userId: String = ""
    var studentDetails: [StudentData] = []
    var filteredStudentDetails: [StudentData] = []
    var newStudent: StudentData?
    var searchTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        heightConstraintOfSearchView.constant = 0
        name.text = className

        searchView.isHidden = true
        print("DetailViewController loaded")

        print(" className: \(className),classId: \(classId), token: \(SessionManager.useRoleToken), groupAcademicYearId: \(groupAcademicYearId ?? "N/A")")
        
        TableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        TableView.dataSource = self
        TableView.delegate = self
        
        TableView.layer.cornerRadius = 15
        TableView.layer.masksToBounds = true
        
        searchView.isHidden = true
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
        filteredStudents = students

        //filteredStudentDetails = studentDetails
        
        TableView.layer.cornerRadius = 10
        TableView.layer.masksToBounds = true
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        

        print("Student details count: \(studentDetails.count)")
        
        enableKeyboardDismissOnTap()
        fetchStudentList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
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
    
    
//    func filterMembers(textField: String) {
//        let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if searchText.isEmpty {
//            filteredStudentDetails = studentDetails
//            TableView.reloadData()
//            return
//        }
//
//        filteredStudentDetails = studentDetails.filter {
//            ($0.name ?? "").lowercased().contains(searchText.lowercased())
//        }
//
//        TableView.reloadData()
//    }
    func filterMembers(textField: String) {
        let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)

        if searchText.isEmpty {
            filteredStudents = students
            TableView.reloadData()
            return
        }

        filteredStudents = students.filter {
            $0.firstName.lowercased().contains(searchText.lowercased())
        }

        TableView.reloadData()
    }

    

   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    filterMembers(textField: searchText)
    return true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStudents.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DetailTableViewCell",
            for: indexPath
        ) as? DetailTableViewCell else {
            fatalError("Cell could not be dequeued")
        }

        let student = filteredStudents[indexPath.row]
        cell.configure(with: student)

        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedStudent = filteredStudents[indexPath.row]
//
//        guard let userId = selectedStudent.userId, !userId.isEmpty else {
//            print("User ID is missing or empty for selected student")
//            return
//        }
//
//        let selectedStudentDbId = selectedStudent.studentDbId ?? "N/A"
//        
//        print("Navigating with userId: \(userId), studentDbId: \(selectedStudentDbId), teamId: \(teamId), groupId: \(groupIds)")
//
//        DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Student", bundle: nil)
//            if let studentDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentDetailViewController") as? StudentDetailViewController {
//                
//                studentDetailVC.student = selectedStudent
//                studentDetailVC.groupId = self.groupIds
//                studentDetailVC.teamId = self.teamId
//                studentDetailVC.userId = userId
//                studentDetailVC.studentDbId = selectedStudentDbId
//
//                self.navigationController?.pushViewController(studentDetailVC, animated: true)
//            }
//        }
//    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select Option", message: "Choose an action", preferredStyle: .actionSheet)

        let addStudentAction = UIAlertAction(title: "Add Student", style: .default) { _ in
            self.navigateToAddStudentViewController()
        }

        let addStaffAction = UIAlertAction(title: "Add Staff", style: .default) { _ in
            self.navigateToAddStaffViewController()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addStudentAction)
        alertController.addAction(addStaffAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func navigateToAddStudentViewController() {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        if let addStudentVC = storyboard.instantiateViewController(withIdentifier: "AddStudentViewController") as? AddStudentViewController {
            addStudentVC.classId = self.classId
            addStudentVC.newStudentDetails = self.studentDetails
            self.navigationController?.pushViewController(addStudentVC, animated: true)
        }
    }
    
    private func navigateToAddStaffStudent(with staffList: [StaffMember]) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        if let addStaffVC = storyboard.instantiateViewController(withIdentifier: "AddStaffStudent") as? AddStaffStudent {
            //addStaffVC.token = self.token
           // addStaffVC.groupId = self.groupIds
            addStaffVC.userId = self.userId
            addStaffVC.staffList = staffList
            self.navigationController?.pushViewController(addStaffVC, animated: true)
        }
    }

    private func navigateToAddStaffViewController() {
        print("Fetching staff data before navigation...")

        guard let url = URL(string: APIManager.shared.baseURL + "/staff/get?type=teaching") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching staff data:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                
                let decodedResponse = try JSONDecoder().decode(StaffDataResponse.self, from: data)

                if let staffList = decodedResponse.data, !staffList.isEmpty {
                    if let firstUser = staffList.first {
                        self.userId = firstUser.userId ?? ""
                        print("Fetched User ID: \(self.userId)")
                    }

                    DispatchQueue.main.async {
                        self.navigateToAddStaffStudent(with: staffList)
                    }
                } else {
                    print("No staff data available.")
                }
            } catch {
                print("Error decoding JSON:", error)
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found:", context.debugDescription)
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch:", context.debugDescription)
                    case .valueNotFound(let type, let context):
                        print("Value '\(type)' not found:", context.debugDescription)
                    case .dataCorrupted(let context):
                        print("Data corrupted:", context.debugDescription)
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
            }
        }

        task.resume()
    }

    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchStudentList() {

        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        let headers = [
            "Authorization": "Bearer \(roleToken)"
        ]

        let queryParams: [String: String] = [
            "classId": classId,
            "groupAcademicYearId": groupAcademicYearId,
            "page": "1",
            "limit": "50"
        ]

        APIManager.shared.request(
            endpoint: "student/full-registration",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { [weak self] (result: Result<StudentFullRegistrationResponse, APIManager.APIError>) in

            guard let self = self else { return }

            switch result {

            case .success(let response):
                print("✅ API SUCCESS")
                print("Message:", response.message)
                print("Total students:", response.data.count)

                // 🔍 Pretty print each student
                response.data.forEach {
                    print("👤 Student:", $0.fullName, "| Mobile:", $0.studentMobileNumber ?? "N/A")
                }

                // 🔄 Save & reload UI
                DispatchQueue.main.async {
                    self.students = response.data
                    self.filteredStudents = response.data
                    self.TableView.reloadData()
                }


            case .failure(let error):
                print("❌ API FAILED:", error.localizedDescription)
            }
        }
    }



}
