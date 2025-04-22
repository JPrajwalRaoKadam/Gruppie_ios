import UIKit

class TimetableViewController: UIViewController {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var selectedClassName: String = ""

    var subjects: [SubjectData] = [] // Store fetched subjects
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamIds: [String] = []
    var classList: [ClassData] = []
    
    // ✅ Store Staff API Data
    var staffDetails: [Staff] = []
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var isStaffSelected: Bool = false
    var isDaySelected: Bool = false
    var isSubjectAgain: Bool = false // For Fourth Index

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "TimetableTableViewCell", bundle: nil), forCellReuseIdentifier: "TimetableTableViewCell")
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        segmentController.isUserInteractionEnabled = true
        
        segmentController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        print("✅ Token:", token)
        print("✅ GroupId:", groupId)
        print("✅ Subjects Array:", subjects)
        print("✅ TeamIds Array:", teamIds)
        print("✅ Staff Details Array:", staffDetails)
        
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // ✅ Fixed Segment Control Handler
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        print("🔥 Segment Index:", sender.selectedSegmentIndex)

        switch sender.selectedSegmentIndex {
        case 0:
            isStaffSelected = false
            isDaySelected = false
            isSubjectAgain = false
        case 1:
            isStaffSelected = true
            isDaySelected = false
            isSubjectAgain = false
        case 2:
            isDaySelected = true
            isStaffSelected = false
            isSubjectAgain = false
        case 3: // ✅ For Fourth Index (Same as First Index)
            isSubjectAgain = true
            isDaySelected = false
            isStaffSelected = false
        default:
            break
        }
        
        print("✅ isStaffSelected:", isStaffSelected)
        print("✅ isDaySelected:", isDaySelected)
        print("✅ isSubjectAgain:", isSubjectAgain)
        
        // ✅ Force Reload UI
        tableView.reloadData()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// ✅ TableView Delegate and DataSource Methods
extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDaySelected {
            return daysOfWeek.count // ✅ 7 Rows for Days
        } else if isStaffSelected {
            return staffDetails.count // ✅ Staff Data
        } else if isSubjectAgain {
            return subjects.count // ✅ Same as First Segment (Subjects)
        } else {
            return subjects.count // ✅ Subject Data
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableTableViewCell", for: indexPath) as! TimetableTableViewCell
        
        if isDaySelected {
            let day = daysOfWeek[indexPath.row]
            cell.configureCell(with: day, icon: nil) // ✅ Display Days
        } else if isStaffSelected {
            let staff = staffDetails[indexPath.row]
            cell.configureCell(with: staff.name ?? "No Name", icon: nil)
        } else if isSubjectAgain {
            let subject = subjects[indexPath.row]
            cell.configureCell(with: subject.gruppieClassName ?? "No Name", icon: nil)
        } else {
            let subject = subjects[indexPath.row]
            cell.configureCell(with: subject.gruppieClassName ?? "No Name", icon: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentController.selectedSegmentIndex == 0 {
            // ✅ First Segment: Navigate to AcademicViewController
            let selectedTeamId = teamIds[indexPath.row]
            let selectedClassName = subjects[indexPath.row].gruppieClassName ?? "No Class Name"
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "AcademicViewController") as! AcademicViewController
            vc.groupId = groupId
            vc.token = token
            vc.subjects = subjects
            vc.teamIds = [selectedTeamId]
            vc.classTitle = selectedClassName
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if segmentController.selectedSegmentIndex == 1 {
            // ✅ Second Segment: Navigate to TeacherTTViewController
            let selectedTeamId = teamIds[indexPath.row]
            let selectedStaff = staffDetails[indexPath.row] // ✅ Fetch staff details
            let userId = selectedStaff.userId ?? "" // ✅ Extract userId safely

            let vc = storyboard?.instantiateViewController(withIdentifier: "TeacherTTViewController") as! TeacherTTViewController
            vc.groupId = groupId
            vc.token = token
            vc.subjects = subjects
            vc.teamIds = [selectedTeamId]
            vc.userId = userId // ✅ Pass userId

            navigationController?.pushViewController(vc, animated: true)
        }
        else if segmentController.selectedSegmentIndex == 2 { 
            let selectedDay = indexPath.row + 1
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "PeriodViewController") as! PeriodViewController
            vc.groupId = groupId
            vc.token = token
            vc.teamIds = teamIds
            vc.subjects = subjects
            vc.day = selectedDay // ✅ Pass Day while navigating
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
