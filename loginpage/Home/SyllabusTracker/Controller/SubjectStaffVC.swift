import UIKit

class SubjectStaffVC: UIViewController {
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var subTableView: UITableView!
    var SubjectStaff: [SubjectStaffSyllabus] = []
    var passedClassName: String = ""
    var passedGroupId: String = ""  // New variable for groupId
    var passedTeamId: String = ""   // New variable for teamId
    var passedSubjectId: String = "" // New variable for subjectId
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subTableView.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        subTableView.delegate = self
        subTableView.dataSource = self
        subTableView.register(UINib(nibName: "SubjectStaffTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectStaffTableViewCell")
        className.text = passedClassName
        print("role in syllubus tracker of subvc:\(currentRole)")
        enableKeyboardDismissOnTap()
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SubjectStaffVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("staff...................///.,,,,,,,,....\(SubjectStaff)")
        return SubjectStaff.count// Update this with actual data when available
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectStaffTableViewCell", for: indexPath) as? SubjectStaffTableViewCell else {
            return UITableViewCell()
        }
        
        // Configure the cell with data when available
        let staff = SubjectStaff[indexPath.row]
               cell.configure(with: staff)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let selectedStaff = SubjectStaff[indexPath.row]

          let storyboard = UIStoryboard(name: "SyllabusTracker", bundle: nil)
          if let chapterVC = storyboard.instantiateViewController(withIdentifier: "ChapterViewController") as? ChapterViewController {
              chapterVC.groupId = passedGroupId
              chapterVC.teamId = passedTeamId
              chapterVC.subjectId = selectedStaff.subjectId
              chapterVC.passedSubjectName = selectedStaff.subjectName
              chapterVC.currentRole = self.currentRole
              self.navigationController?.pushViewController(chapterVC, animated: true)
          }
      }
}
