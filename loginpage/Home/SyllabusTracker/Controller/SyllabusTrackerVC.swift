
import UIKit
class SyllabusTrackerVC: UIViewController {
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    var subjectstaff: [SubjectStaffSyllabus] = []
    var subjects: [SubjectData] = [] // Store fetched subjects
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamId: String = "" 
    var className: String = ""
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        print("grpid ST: \(groupId)")
        print("TEAMid TT: \(teamId)")
        print("sy class:\(className)")
        print("role in syllubus trackervc:\(currentRole)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SyllabusTrackerTableViewCell", bundle: nil), forCellReuseIdentifier: "SyllabusTrackerTableViewCell")
        enableKeyboardDismissOnTap()
    }
    
    @IBAction func segmentControl(_ sender: Any) {
        tableView.reloadData() 
    }
    @IBAction func backButton(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension SyllabusTrackerVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SyllabusTrackerTableViewCell", for: indexPath) as? SyllabusTrackerTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = subjects[indexPath.row]
        cell.configure(with: subject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 70
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentController.selectedSegmentIndex == 1 {
            let selectedSubject = subjects[indexPath.row]
            let teamId = selectedSubject.teamId // Extract teamId from selected subject
            
            self.className = selectedSubject.name
            fetchSubjectStaffDetails(for: teamId)
            print("Extracted teamId: \(teamId)")
        } else {
            // Navigate to DailySyllabusTrackerVC for index 0
                   print("Navigating to DailySyllabusTrackerVC with index 0")
                   
                   let storyboard = UIStoryboard(name: "SyllabusTracker", bundle: nil)
                   if let dailyVC = storyboard.instantiateViewController(withIdentifier: "DailySyllabusTrackerVC") as? DailySyllabusTrackerVC {
                       
                       // Pass groupId and teamId
                       dailyVC.groupId = self.groupId
                       dailyVC.teamId = teamId
                       
                       self.navigationController?.pushViewController(dailyVC, animated: true)
                   } else {
                       print("Failed to instantiate DailySyllabusTrackerVC")
                   }
               }
    }
}

// MARK: - API Call for Subject Staff Details
extension SyllabusTrackerVC {
    func fetchSubjectStaffDetails(for teamId: String) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/get"
        print("Fetching data from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No Data Received")
                return
            }

            // Print raw API response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response of sub staff: \(jsonString)")
            } else {
                print("Unable to decode API response into a string")
            }

            // Decode using JSONSerialization
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    
                    var subjectStaffList: [SubjectStaffSyllabus] = []
                    
                    for entry in dataArray {
                        if let subjectName = entry["subjectName"] as? String,
                           let subjectId = entry["subjectId"] as? String, // Extract subjectId
                           let staffArray = entry["staffName"] as? [[String: String]],
                           let firstStaff = staffArray.first,
                           let staffName = firstStaff["staffName"] {
                            
                            let subjectStaff = SubjectStaffSyllabus(staffName: staffName, subjectName: subjectName, subjectId: subjectId)
                            subjectStaffList.append(subjectStaff)
                        }
                    }

                    DispatchQueue.main.async {
                        self.subjectstaff = subjectStaffList

                        // 🔹 Pass groupId, teamId, and subjectId
                        if let firstSubject = subjectStaffList.first {
                            self.navigateToSubjectStaffVC(
                                with: self.subjectstaff,
                                groupId: self.groupId,
                                teamId: teamId,
                                subjectId: firstSubject.subjectId
                            )
                        }

                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func navigateToSubjectStaffVC(with staffDetails: [SubjectStaffSyllabus], groupId: String, teamId: String, subjectId: String) {
        let storyboard = UIStoryboard(name: "SyllabusTracker", bundle: nil)
        if let subjectStaffVC = storyboard.instantiateViewController(withIdentifier: "SubjectStaffVC") as? SubjectStaffVC {
            subjectStaffVC.SubjectStaff = staffDetails
            subjectStaffVC.passedClassName = self.className
            subjectStaffVC.passedGroupId = groupId  // Pass groupId
            subjectStaffVC.passedTeamId = teamId    // Pass teamId
            subjectStaffVC.passedSubjectId = subjectId // Pass subjectId
            subjectStaffVC.currentRole = self.currentRole

            self.navigationController?.pushViewController(subjectStaffVC, animated: true)
        }
    }

}
