import UIKit

class DetailViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
        @IBOutlet weak var bcbutton: UIButton!
        @IBOutlet weak var TableView: UITableView!
        @IBOutlet weak var name: UILabel!
        @IBOutlet weak var searchButton: UIButton!
        @IBOutlet weak var searchView: UIView!
        @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
        
        var studentDbId: String?
        var token: String = ""
        var groupId: String?
        var teamId: String = ""
        var userId: String = ""
        var studentDetails: [StudentData] = []
        var filteredStudentDetails: [StudentData] = []
        var studentName: String?
        var newStudent: StudentData?
        var searchTextField: UITextField?

        override func viewDidLoad() {
            super.viewDidLoad()
            TableView.layer.cornerRadius = 10

            if let studentName = studentName {
                name.text = studentName
            }
            heightConstraintOfSearchView.constant = 0
            bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
            bcbutton.clipsToBounds = true

            searchView.isHidden = true
            print("DetailViewController loaded")
            print("groupIds: \(groupId), teamId: \(teamId), token: \(token), studentDbId: \(studentDbId ?? "N/A")")
            
            TableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
            
            TableView.dataSource = self
            TableView.delegate = self
            
            TableView.layer.cornerRadius = 15
            TableView.layer.masksToBounds = true
            
            searchView.isHidden = true
            searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
            filteredStudentDetails = studentDetails

            print("Student details count: \(studentDetails.count)")
            enableKeyboardDismissOnTap()
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
        
        func filterMembers(textField: String) {
            let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if searchText.isEmpty {
                filteredStudentDetails = studentDetails
                TableView.reloadData()
                return
            }

            filteredStudentDetails = studentDetails.filter {
                ($0.name ?? "").lowercased().contains(searchText.lowercased())
            }

            TableView.reloadData()
        }

       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterMembers(textField: searchText)
        return true
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredStudentDetails.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else {
                fatalError("Cell could not be dequeued")
            }

            let student = filteredStudentDetails[indexPath.row]
            self.newStudent = student
            cell.nameLabel.text = student.name
            cell.designationLabel.text = student.fatherName

            return cell
        }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = filteredStudentDetails[indexPath.row]

        let studentInfo: [String: Any] = [
            "name": selectedStudent.name ?? "",
            "groupId": selectedStudent.groupId ?? ""
        ]

        NotificationCenter.default.post(name: Notification.Name("SelectedStudentNotification"), object: nil, userInfo: studentInfo)

        if let navController = self.navigationController {
            let viewControllers = navController.viewControllers
            if viewControllers.count >= 3 {
                navController.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            } else {
                navController.popViewController(animated: true)
            }
        }
    }

    @IBAction func backButton(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
        }

    }

