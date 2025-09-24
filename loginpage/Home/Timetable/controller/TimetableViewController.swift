import UIKit

class TimetableViewController: UIViewController {

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var selectedClassName: String = ""
    var subjects: [SubjectData] = []
    var token: String = ""
    var groupId: String = ""
    var teamIds: [String] = []
    var classList: [ClassData] = []
    var currentRole: String?
    var staffDetails: [Staff] = []
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var isStaffSelected: Bool = false
    var isFreeTeachersSelected: Bool = false
    var isSubjectAgain: Bool = false
    var isDayIselected: Bool = false

    var daysVC: DaysViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "TimetableTableViewCell", bundle: nil), forCellReuseIdentifier: "TimetableTableViewCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        segmentController.isUserInteractionEnabled = true
        handleSegments()
        segmentController.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        print("✅ Token:", token)
        print("✅ GroupId:", groupId)
        print("✅ Subjects:", subjects)
        print("✅ TeamIds:", teamIds)
        print("✅ Staff Details:", staffDetails)

        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func handleSegments() {
        if let role = currentRole?.lowercased() {
            switch role {
            case "admin":
                hideSegment(at: 4)
            case "parent":
                hideSegment(at: 1)
                hideSegment(at: 2)
            case "teacher":
                hideSegment(at: 1)
            default:
                break
            }
        }
    }

    func hideSegment(at index: Int) {
        segmentController.setEnabled(false, forSegmentAt: index)
        segmentController.setWidth(0.1, forSegmentAt: index)
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        print("🔥 Segment Index:", sender.selectedSegmentIndex)

        isStaffSelected = false
        isFreeTeachersSelected = false
        isSubjectAgain = false
        isDayIselected = false

        switch sender.selectedSegmentIndex {
        case 0: break // Default
        case 1: isStaffSelected = true
        case 2: isFreeTeachersSelected = true
        case 3: isSubjectAgain = true
        case 4: isDayIselected = true
        default: break
        }

        print("✅ isStaffSelected:", isStaffSelected)
        print("✅ isFreeTeachersSelected:", isFreeTeachersSelected)
        print("✅ isSubjectAgain:", isSubjectAgain)
        print("✅ isDayIselected:", isDayIselected)

        if isDayIselected {
            showDaysViewController()
        } else {
            hideDaysViewController()
            tableView.reloadData()
        }
    }

    func showDaysViewController() {
        if daysVC == nil {
            let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "DaysViewController") as? DaysViewController {
                vc.currentRole = self.currentRole
                vc.groupId = self.groupId
                daysVC = vc
                addChild(vc)
                vc.view.frame = tableView.bounds
                tableView.addSubview(vc.view)
                vc.didMove(toParent: self)
            }
        }
        daysVC?.view.isHidden = false
    }

    func hideDaysViewController() {
        daysVC?.view.removeFromSuperview()
        daysVC?.removeFromParent()
        daysVC = nil
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

    extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDayIselected {
            return 0
        } else if isFreeTeachersSelected {
            return daysOfWeek.count
        } else if isStaffSelected {
            return staffDetails.count
        } else if isSubjectAgain {
            return subjects.count
        } else {
            return subjects.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableTableViewCell", for: indexPath) as! TimetableTableViewCell

        if isFreeTeachersSelected {
            let day = daysOfWeek[indexPath.row]
            cell.configureCell(with: day, icon: nil)
        } else if isStaffSelected {
            let staff = staffDetails[indexPath.row]
            cell.configureCell(with: staff.name ?? "No Name", icon: nil)
        } else if isSubjectAgain {
            let subject = subjects[indexPath.row]
            cell.configureCell(with: subject.name ?? "No Name", icon: nil)
        } else {
            let subject = subjects[indexPath.row]
            cell.configureCell(with: subject.name ?? "No Name", icon: nil)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            let selectedTeamId = teamIds[indexPath.row]
            let selectedClassName = subjects[indexPath.row].name ?? "No Class Name"
            let vc = storyboard?.instantiateViewController(withIdentifier: "AcademicViewController") as! AcademicViewController
            vc.groupId = groupId
            vc.token = token
            vc.subjects = subjects
            vc.teamIds = [selectedTeamId]
            vc.classTitle = selectedClassName
            navigationController?.pushViewController(vc, animated: true)

        case 1:
            let selectedTeamId = teamIds[indexPath.row]
            let selectedStaff = staffDetails[indexPath.row]
            let userId = selectedStaff.userId ?? ""
            let vc = storyboard?.instantiateViewController(withIdentifier: "TeacherTTViewController") as! TeacherTTViewController
            vc.groupId = groupId
            vc.token = token
            vc.subjects = subjects
            vc.teamIds = [selectedTeamId]
            vc.userId = userId
            navigationController?.pushViewController(vc, animated: true)

        case 2:
            let selectedDay = indexPath.row + 1
            let vc = storyboard?.instantiateViewController(withIdentifier: "PeriodViewController") as! PeriodViewController
            vc.groupId = groupId
            vc.token = token
            vc.teamIds = teamIds
            vc.subjects = subjects
            vc.day = selectedDay
            navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}
