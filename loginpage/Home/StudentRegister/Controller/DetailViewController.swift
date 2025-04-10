import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var name: UILabel!
    
    var studentDbId: String?
    var token: String = ""
    var groupIds: String = ""
    var teamId: String = ""
    var userId: String = ""
    var studentDetails: [StudentData] = []
    var studentName: String?
    var newStudent: StudentData?

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
        print("Navigating with teamId: \(self.teamId), groupId: \(self.groupIds), token: \(self.token)")

        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        if let addStudentVC = storyboard.instantiateViewController(withIdentifier: "AddStudentViewController") as? AddStudentViewController {
            addStudentVC.token = self.token
            addStudentVC.groupId = self.groupIds
            addStudentVC.teamId = self.teamId
            addStudentVC.newStudentDetails = self.studentDetails
            self.navigationController?.pushViewController(addStudentVC, animated: true)
        }
    }
    
    private func navigateToAddStaffStudent(with staffList: [StaffMember]) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        if let addStaffVC = storyboard.instantiateViewController(withIdentifier: "AddStaffStudent") as? AddStaffStudent {
            addStaffVC.token = self.token
            addStaffVC.groupId = self.groupIds
            addStaffVC.userId = self.userId
            addStaffVC.staffList = staffList // Pass fetched staff data
            self.navigationController?.pushViewController(addStaffVC, animated: true)
        }
    }

    private func navigateToAddStaffViewController() {
        print("Fetching staff data before navigation...")

        guard let url = URL(string: "https://api.gruppie.in/api/v1/groups/\(groupIds)/staff/get?type=teaching") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

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
                    // Fetch and store userId from the first staff member
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

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let studentName = studentName {
            name.text = studentName
        }

        print("DetailViewController loaded")
        print("groupIds: \(groupIds), teamId: \(teamId), token: \(token), studentDbId: \(studentDbId ?? "N/A")")
        
        TableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        TableView.dataSource = self
        TableView.delegate = self
        
        TableView.layer.cornerRadius = 15
        TableView.layer.masksToBounds = true
        
        print("Student details count: \(studentDetails.count)")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {
            fatalError("Cell could not be dequeued")
        }
        
        let student = studentDetails[indexPath.row]
        self.newStudent = student
        cell.nameLabel.text = student.name
        cell.designationLabel.text = student.fatherName 

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = studentDetails[indexPath.row]
        
        guard let userId = selectedStudent.userId, !userId.isEmpty else {
            print("User ID is missing or empty for selected student")
            return
        }

        let selectedStudentDbId = selectedStudent.studentDbId ?? "N/A"
        
        print("Navigating with userId: \(userId), studentDbId: \(selectedStudentDbId), teamId: \(teamId), groupId: \(groupIds), token: \(token)")

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Student", bundle: nil)
            if let studentDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentDetailViewController") as? StudentDetailViewController {
                
                studentDetailVC.student = selectedStudent
                studentDetailVC.token = self.token
                studentDetailVC.groupId = self.groupIds
                studentDetailVC.teamId = self.teamId
                studentDetailVC.userId = userId
                studentDetailVC.studentDbId = selectedStudentDbId

                self.navigationController?.pushViewController(studentDetailVC, animated: true)
            }
        }
    }
}
