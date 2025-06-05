//
//import UIKit
//
//class SubjectNotes_VideosVC: UIViewController, AddSubNotesDelegate {
//    func didAddSubject() {
//        fetchSubjectStaffDetails()
//    }
//    
//    @IBOutlet weak var className: UILabel!
//    @IBOutlet weak var subTableView: UITableView!
//    var SubjectStaff: [SubjectStaffSyllabus] = []
//    var passedClassName: String = ""
//    var passedGroupId: String = ""  // New variable for groupId
//    var passedTeamId: String = ""   // New variable for teamId
//    var passedSubjectId: String = "" // New variable for subjectId
//    var subjectstaff: [SubjectStaffSyllabus] = []
//    var subjects: [SubjectData] = [] 
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fetchSubjectStaffDetails()
//        subTableView.delegate = self
//        subTableView.dataSource = self
//        subTableView.register(UINib(nibName: "SubjectNotes_videosTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNotes_videosTableViewCell")
//        className.text = passedClassName
//        print("gid: \(passedGroupId) tid: \(passedTeamId)")
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        subTableView.reloadData()
//         fetchSubjectStaffDetails()
//    }
//
//    @IBAction func backButton(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func addSubjectNV(_ sender: Any) {
//        print("add button tapped")
//        navigateToAddSubjectVC()
//    }
//    
//    func navigateToAddSubjectVC() {
//        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
//        if let AddSubNotes_VideosVC = storyboard.instantiateViewController(withIdentifier: "AddSubNotes_VideosVC") as? AddSubNotes_VideosVC {
////            SubjectNotes_VideosVC.SubjectStaff = staffDetails
//            AddSubNotes_VideosVC.className = self.passedClassName
//            AddSubNotes_VideosVC.groupId = passedGroupId  // Pass groupId
//            AddSubNotes_VideosVC.teamId  = passedTeamId   // Pass teamId
//            AddSubNotes_VideosVC.delegate = self
////            SubjectNotes_VideosVC.passedSubjectId = subjectId // Pass subjectId
//
//            self.navigationController?.pushViewController(AddSubNotes_VideosVC, animated: true)
//        }
//    }
//    
//    func fetchSubjectStaffDetails() {
//        // 1. Get the token
//        guard let token = TokenManager.shared.getToken() else {
//            print("❌ Token not found")
//            return
//        }
//
//        // 2. Construct the URL
//        let urlString = APIProdManager.shared.baseURL + "groups/\(passedGroupId)/team/\(passedTeamId)/subject/staff/get"
//        print("📡 Fetching data from: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL")
//            return
//        }
//
//        // 3. Prepare the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        // 4. Make the API call
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🚫 API Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data else {
//                print("📭 No Data Received")
//                return
//            }
//
//            // Debug: Raw API response
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📨 API Response of sub staff: \(jsonString)")
//            } else {
//                print("⚠️ Unable to decode API response into a string")
//            }
//
//            // 5. Parse the JSON
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let dataArray = json["data"] as? [[String: Any]] {
//                    
//                    var subjectStaffList: [SubjectStaffSyllabus] = []
//                    
//                    for entry in dataArray {
//                        if let subjectName = entry["subjectName"] as? String,
//                           let subjectId = entry["subjectId"] as? String,
//                           let staffArray = entry["staffName"] as? [[String: String]],
//                           let firstStaff = staffArray.first,
//                           let staffName = firstStaff["staffName"] {
//                            
//                            let subjectStaff = SubjectStaffSyllabus(
//                                staffName: staffName,
//                                subjectName: subjectName,
//                                subjectId: subjectId
//                            )
//                            subjectStaffList.append(subjectStaff)
//                        }
//                    }
//                    print("Subjects fetched: \(self.SubjectStaff.count)")
//                DispatchQueue.main.async {
//                    self.SubjectStaff = subjectStaffList // ✅ required
//                    self.subTableView.reloadData()       // ✅ refresh table
//                }
//
//
//////                    // 6. Update UI on main thread
////                    DispatchQueue.main.async {
////                        self.SubjectStaff = subjectStaffList
////                        self.subTableView.reloadData() // <- this was missing!
////                    }
//                }
//            } catch {
//                print("🧨 Decoding Error: \(error.localizedDescription)")
//            }
//        }
//
//        // 7. Start the task
//        task.resume()
//    }
//
//
//}
//
//// MARK: - TableView Delegate & DataSource
//extension SubjectNotes_VideosVC: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("staff...................///.,,,,,,,,....\(SubjectStaff)")
//        return SubjectStaff.count// Update this with actual data when available
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectNotes_videosTableViewCell", for: indexPath) as? SubjectNotes_videosTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        // Configure the cell with data when available
//        let staff = SubjectStaff[indexPath.row]
//        cell.configure(with: staff)
//        return cell
//    }
//    
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////      let selected = SubjectStaff[indexPath.row]
////      let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
////      guard let details = storyboard.instantiateViewController(
////              withIdentifier: "SubDetailsVC"
////            ) as? SubDetailsVC else { return }
////        
////        details.className   = passedClassName
////        details.subjectName = selected.subjectName
////
////      navigationController?.pushViewController(details, animated: true)
////    }
////    func navigateToSubDetailsVC() {
////        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
////        if let SubDetailsVC = storyboard.instantiateViewController(withIdentifier: "SubDetailsVC") as? SubDetailsVC {
////            SubDetailsVC.className = self.passedClassName
////            SubDetailsVC.groupId = self.passedGroupId  // Pass groupId
////            SubDetailsVC.teamId = self.passedTeamId    // Pass teamId
////           
////
////            self.navigationController?.pushViewController(SubDetailsVC, animated: true)
////        }
////    }
//
//
//}
//
import UIKit
class SubjectNotes_VideosVC: UIViewController, AddSubNotesDelegate {
    func didAddSubject() {
        fetchSubjectStaffDetails()
    }
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var subTableView: UITableView!
   
    //var subjectStaff: [SubjectStaffSyllabus] = []
    var token: String = ""
    var clsName: String = ""
    var groupId: String = ""  // New variable for groupId
    var teamId: String = ""   // New variable for teamId
    var subjectId: String = "" // New variable for subjectId
    var subjectStaff: [SubjectStaffSyllabus] = []
    var subjects: [SubjectData] = []
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSubjectStaffDetails()
        subTableView.delegate = self
        subTableView.dataSource = self
        subTableView.register(UINib(nibName: "SubjectNotes_videosTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNotes_videosTableViewCell")
        if let role = currentRole?.lowercased(), role == "parent" || role == "teacher" {
            plusButton.isHidden = true
        }
        className.text = clsName
        print("111gid: \(groupId) tid: \(teamId)")
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        subTableView.reloadData()
         fetchSubjectStaffDetails()
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addSubjectNV(_ sender: Any) {
        print("add button tapped")
        navigateToAddSubjectVC()
    }
    
    func navigateToAddSubjectVC() {
        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
        if let AddSubNotes_VideosVC = storyboard.instantiateViewController(withIdentifier: "AddSubNotes_VideosVC") as? AddSubNotes_VideosVC {
//            SubjectNotes_VideosVC.SubjectStaff = staffDetails
            AddSubNotes_VideosVC.className = self.clsName
            AddSubNotes_VideosVC.groupId = groupId  // Pass groupId
            AddSubNotes_VideosVC.teamId  = teamId   // Pass teamId
            AddSubNotes_VideosVC.delegate = self
            AddSubNotes_VideosVC.currentRole = self.currentRole
//            SubjectNotes_VideosVC.passedSubjectId = subjectId // Pass subjectId

            self.navigationController?.pushViewController(AddSubNotes_VideosVC, animated: true)
        }
    }
    
    func fetchSubjectStaffDetails() {
                // 1. Get the token
                guard let token = TokenManager.shared.getToken() else {
                    print("❌ Token not found")
                    return
                }
        
                // 2. Construct the URL
                let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/get"
                print("📡 Fetching data from: \(urlString)")
        
                guard let url = URL(string: urlString) else {
                    print("❌ Invalid URL")
                    return
                }
        
                // 3. Prepare the request
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
                // 4. Make the API call
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("🚫 API Error: \(error.localizedDescription)")
                        return
                    }
        
                    guard let data = data else {
                        print("📭 No Data Received")
                        return
                    }
        
                    // Debug: Raw API response
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📨 API Response of sub staff: \(jsonString)")
                    } else {
                        print("⚠️ Unable to decode API response into a string")
                    }
        
                    // 5. Parse the JSON
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let dataArray = json["data"] as? [[String: Any]] {
        
                            var subjectStaffList: [SubjectStaffSyllabus] = []
        
                            for entry in dataArray {
                                if let subjectName = entry["subjectName"] as? String,
                                   let subjectId = entry["subjectId"] as? String,
                                   let staffArray = entry["staffName"] as? [[String: String]],
                                   let firstStaff = staffArray.first,
                                   let staffName = firstStaff["staffName"] {
        
                                    let subjectStaff = SubjectStaffSyllabus(
                                        staffName: staffName,
                                        subjectName: subjectName,
                                        subjectId: subjectId
                                    )
                                    subjectStaffList.append(subjectStaff)
                                }
                            }
                            print("Subjects fetched: \(self.subjectStaff.count)")
                        DispatchQueue.main.async {
                            self.subjectStaff = subjectStaffList // ✅ required
                            self.subTableView.reloadData()       // ✅ refresh table
                        }
        
        
        ////                    // 6. Update UI on main thread
        //                    DispatchQueue.main.async {
        //                        self.SubjectStaff = subjectStaffList
        //                        self.subTableView.reloadData() // <- this was missing!
        //                    }
                        }
                    } catch {
                        print("🧨 Decoding Error: \(error.localizedDescription)")
                    }
                }
        
                // 7. Start the task
                task.resume()
            }


}

// MARK: - TableView Delegate & DataSource
extension SubjectNotes_VideosVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("staff...................///.,,,,,,,,....\(subjectStaff)")
        return subjectStaff.count// Update this with actual data when available
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectNotes_videosTableViewCell", for: indexPath) as? SubjectNotes_videosTableViewCell else {
            return UITableViewCell()
        }
        
        // Configure the cell with data when available
        let staff = subjectStaff[indexPath.row]
        cell.configure(with: staff)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedStaff = subjectStaff[indexPath.row]
//        
//        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
//        if let subDetailsVC = storyboard.instantiateViewController(withIdentifier: "SubDetailsVC") as? SubDetailsVC {
//            subDetailsVC.subjectName = selectedStaff.subjectName // Passing subject name
//            subDetailsVC.className = self.clsName        // Passing class name
//            //subDetailsVC.subjectId = self.subjectId
//            self.navigationController?.pushViewController(subDetailsVC, animated: true)
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubject = subjectStaff[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
        if let subDetailsVC = storyboard.instantiateViewController(withIdentifier: "SubDetailsVC") as? SubDetailsVC {
            subDetailsVC.className = self.clsName
            subDetailsVC.groupId = self.groupId
            subDetailsVC.teamId = self.teamId
            subDetailsVC.subjectId = selectedSubject.subjectId // Pass selected subjectId
            subDetailsVC.subjectName = selectedSubject.subjectName // Optional: pass name too
            subDetailsVC.currentRole = self.currentRole
            self.navigationController?.pushViewController(subDetailsVC, animated: true)
        }
    }

    
}
