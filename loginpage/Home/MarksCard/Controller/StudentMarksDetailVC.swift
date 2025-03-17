//
//  StudentMarksDetailVC.swift
//  loginpage
//
//  Created by apple on 12/03/25.
//

import UIKit

class StudentMarksDetailVC: UIViewController {
    
    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var subjectsLabel: UILabel!
    @IBOutlet weak var studentMarksTableView: UITableView!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var AllSubTextFeild: UITextField!
    
    var studentMarkExamDataResponse: [StudentMarksData] = []
    var examDataResponse: [ExamData] = []
    var passedExamTitle = ""
    let subjectsHandler = SubjectsTableViewHandler()
    let studentMarksHandler = StudentMarksTableViewHandler()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subjectsView.isHidden = true
        let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell", bundle: nil)
        subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell")
        studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell")
        setupTableViews()
    }
    
    func setupTableViews() {
        let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell", bundle: nil)

        // Register cells
        subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell")
        studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell")

        AllSubTextFeild.isUserInteractionEnabled = false
        AllSubTextFeild.addTarget(self, action: #selector(disableEditing), for: .editingDidBegin)

        
        // Pass data to handlers
        subjectsHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
        studentMarksHandler.studentMarkExamDataResponse = studentMarkExamDataResponse

        subjectsTableView.delegate = subjectsHandler
        subjectsTableView.dataSource = subjectsHandler

        studentMarksTableView.delegate = studentMarksHandler
        studentMarksTableView.dataSource = studentMarksHandler

        // Handle subject selection
        subjectsHandler.didSelectSubject = { [weak self] selectedSubject in
            self?.subjectsLabel.text = selectedSubject
            self?.subjectsView.isHidden = true  // Hide view after selection
        }
    }

    @objc func disableEditing(_ textField: UITextField) {
        textField.resignFirstResponder()  // Immediately dismiss keyboard
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func allSubjectListingButtonAction(_ sender: Any) {
        subjectsView.isHidden.toggle()
        subjectsTableView.reloadData()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
    }
    
    
    
}

class StudentMarksTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {

    var studentMarkExamDataResponse: [StudentMarksData] = []
    
    // Number of sections = Number of students
    func numberOfSections(in tableView: UITableView) -> Int {
        return studentMarkExamDataResponse.count
    }
    
    // Number of rows per section = Number of subjects for that student
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentMarkExamDataResponse[section].subjectMarksDetails?.count ?? 0
    }
    
    // Custom section header = Student's name + icon + total + 1 score label
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let studentData = studentMarkExamDataResponse[section]
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        // Profile Image
        let iconImageView = UIImageView(frame: CGRect(x: 15, y: 5, width: 40, height: 40))
        iconImageView.image = UIImage(systemName: "person.circle")
        iconImageView.tintColor = .black
        iconImageView.contentMode = .scaleAspectFit
        headerView.addSubview(iconImageView)
        
        // Student's Name Label
        let nameLabel = UILabel(frame: CGRect(x: 65, y: 5, width: tableView.frame.width - 80, height: 25))
        nameLabel.text = studentData.studentName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black
        headerView.addSubview(nameLabel)
        
        // Total Label (smaller & bold)
        let totalLabel = UILabel(frame: CGRect(x: 65, y: 30, width: 50, height: 20))
        totalLabel.text = "Total"
        totalLabel.font = UIFont.boldSystemFont(ofSize: 14)
        totalLabel.textColor = .darkGray
        headerView.addSubview(totalLabel)
        
        // Single Score Label (e.g., "100/100")
        let scoreLabel = UILabel(frame: CGRect(x: totalLabel.frame.maxX + 10, y: 30, width: 80, height: 20))
//        let obtainedMarks = studentData.subjectMarksDetails?.reduce(0) { $0 + (Int($1.obtainedMarks ?? "") ?? 0) } ?? 0
//        let maxMarks = studentData.subjectMarksDetails?.count ?? 0
        scoreLabel.text = " 0/0 "
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
        scoreLabel.textColor = .darkGray
        scoreLabel.textAlignment = .left
        headerView.addSubview(scoreLabel)

        // Bottom Labels - Adjusted layout for 60/40 split
        let totalWidth = tableView.frame.width

        // "Subject" takes 60% of the width
        let subjectLabel = UILabel(frame: CGRect(x: 0, y: 55, width: totalWidth * 0.6, height: 20))
        subjectLabel.text = "Subject"
        subjectLabel.font = UIFont.boldSystemFont(ofSize: 14)
        subjectLabel.textAlignment = .center
        subjectLabel.textColor = .black
        headerView.addSubview(subjectLabel)

        // "Min/Max" and "Obtained" share the remaining 40%
        let remainingLabels = ["Min - Max", "Obtained"]
        let remainingWidth = totalWidth * 0.4 / CGFloat(remainingLabels.count)

        for (index, labelText) in remainingLabels.enumerated() {
            let labelX = totalWidth * 0.6 + CGFloat(index) * remainingWidth
            let label = UILabel(frame: CGRect(x: labelX, y: 55, width: remainingWidth, height: 20))
            label.text = labelText
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.textAlignment = .center
            label.textColor = .black
            headerView.addSubview(label)
        }


        return headerView
    }
    
    // Section height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    // Configure each cell with subject name and obtained marks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectNameDetailsTableViewCell", for: indexPath) as? SubjectNameDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        let studentData = studentMarkExamDataResponse[indexPath.section]
        if let subjectMarkDetails = studentData.subjectMarksDetails?[indexPath.row] {
            cell.subName.text = subjectMarkDetails.subjectName
            cell.obtainedMarksTextFeild.text = subjectMarkDetails.obtainedMarks
//            cell.maxLabel.text = studentData.totalMaxMarks
            cell.minLabel.text = "\(studentData.totalMinMarks ?? "0") - \(studentData.totalMaxMarks ?? "0")"
        } else {
            cell.subName.text = "N/A"
            cell.obtainedMarksTextFeild.text = "N/A"
//            cell.maxLabel.text = "nil/nil"
            cell.minLabel.text = "nil/nil"
        }

        return cell
    }
}

class SubjectsTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var studentMarkExamDataResponse: [StudentMarksData] = []
    
    // Add this closure to handle subject selection
    var didSelectSubject: ((String) -> Void)?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentMarkExamDataResponse.first?.subjectMarksDetails?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamAndSubjectTitleTableViewCell", for: indexPath) as? ExamAndSubjectTitleTableViewCell else {
            return UITableViewCell()
        }
        
        let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails?[indexPath.row]
        cell.titleLabel?.text = subjectData?.subjectName ?? ""
        return cell
    }

    // Trigger the closure when a subject row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubject = studentMarkExamDataResponse.first?.subjectMarksDetails?[indexPath.row].subjectName ?? "N/A"
        didSelectSubject?(selectedSubject)
    }
}

