import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var name: UILabel!
    
    var token: String = ""
    var groupIds: String = ""
    var teamId: String = ""
    var studentDetails: [StudentData] = []
    var studentName: String?
    var newStudent: StudentData?

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select Option", message: "Choose an action", preferredStyle: .actionSheet)

        let addStudentAction = UIAlertAction(title: "Add Student", style: .default) { _ in
            print("Add Student tapped")
            
            if self.teamId.isEmpty {
                self.teamId = ""
            }
            
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

        let addStaffAction = UIAlertAction(title: "Add Staff", style: .default) { _ in
            print("Add Staff tapped")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addStudentAction)
        alertController.addAction(addStaffAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
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
        print("groupIds: \(groupIds), teamId: \(teamId), token: \(token)")
        
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
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = studentDetails[indexPath.row]
        
        guard let userId = selectedStudent.userId, !userId.isEmpty else {
            print("User ID is missing or empty for selected student")
            return
        }

        print("Navigating with userId: \(userId), teamId: \(teamId), groupId: \(groupIds), token: \(token)")

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Student", bundle: nil)
            if let studentDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentDetailViewController") as? StudentDetailViewController {
                
                studentDetailVC.student = selectedStudent
                studentDetailVC.token = self.token
                studentDetailVC.groupId = self.groupIds
                studentDetailVC.teamId = self.teamId
                studentDetailVC.userId = userId // Pass userId here
                
                self.navigationController?.pushViewController(studentDetailVC, animated: true)
            }
        }
    }
}
