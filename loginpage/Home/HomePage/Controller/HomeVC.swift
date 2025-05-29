import UIKit
import SDWebImage

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AllIconsTableViewCellDelegate,FeedPageNavigationDelegate, HomePageNavigationDelegate, MoreNavigationDelegate {
  
    var indexPath: IndexPath?
    var name: String?
    var groupId: String?
    var school: School? // School object to hold school data
    var imageUrls: [String] = [] // Array to hold multiple image URLs
    var groupDatas: [GroupData] = []
    var studentTeams: [StudentTeam] = []
    var featureIcon: FeatureIcon?
    var currentRole: String?
    var teachingStaff: [Staff] = []
    var subjects: [SubjectData] = [] // Store fetched subjects
    var teamIds: [String] = []
    var userIds: [String] = []
    var featureIcons: [FeatureIcon] = []
    
    @IBOutlet weak var tableView: UITableView! // TableView outlet
    @IBOutlet weak var menu: UIImageView!
    @IBOutlet weak var home: UIStackView!
    @IBOutlet weak var feed: UIStackView!
    @IBOutlet weak var more: UIStackView!
    @IBOutlet weak var shortNameLabel: UILabel! // Label to display short name
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    private var pageViewController: UIPageViewController? // UIPageViewController instance
    private var currentPageIndex: Int = 0 // Current page index
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "BannerAndProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "BannerAndProfileTableViewCell")
        tableView.register(UINib(nibName: "AllIconsTableViewCell", bundle: nil), forCellReuseIdentifier: "AllIconsTableViewCell")
        
        tableView.contentInset = .zero
        tableView.sectionHeaderHeight = 0
        tableView.tableHeaderView = nil
        
        CustomTabManager.shared.delegate = self
        CustomTabManager.shared.hDelegate = self
        CustomTabManager.shared.mDelegate = self
        // Print the image URLs to verify their content
        print("Image URLs: \(imageUrls)")
        
        for activity in self.groupDatas {
            print("Received Activity: \(activity.activity)")
            self.featureIcons = activity.featureIcons
            for featureIcon in activity.featureIcons {
                print("Received Feature Icon Type: \(featureIcon.name), Image: \(featureIcon.image)")
            }
        }
        
        // Set the shortNameLabel text
        if let school = school {
            shortNameLabel.text = school.shortName
        } else {
            print("No school data provided")
        }
        
        if let name = name {
            print("Name of Profile: \(name)")
        } else {
            print("No profile data provided")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CustomTabManager.addTabBar(self, isRemoveLast: false, selectIndex: 0, bottomConstraint: &self.bottomTableViewConstraint)
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tapforFeeds() {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController else {
            print("ViewController with identifier 'feedVC' not found.")
            return
        }
        
        feedVC.schoolId = school?.id ?? ""
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
//            UserDefaults.standard.removeObject(forKey: "loggedInPhone")
//            let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        navigationController?.setViewControllers([loginVC], animated: true)
        
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "loggedInPhone")

            // Return to login screen
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: loginVC)
            }
        }
    
    func getHomedata(indexpath: IndexPath) {
            if let homeVC = self.navigationController?.viewControllers.first(where: { $0 is HomeVC }) {
                self.navigationController?.popToViewController(homeVC, animated: true)
            } else {
                print("HomeVC not found in the navigation stack.")
            }
    }
    
    func tapOnMore() {
        
    }
    
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1 + groupDatas.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAndProfileTableViewCell", for: indexPath) as! BannerAndProfileTableViewCell
                cell.imageUrls = imageUrls
                cell.configureBannerImage(at: 0)
                cell.Profile.text = name
                cell.Profile.isHidden = (name == nil)
                cell.heightConstraintofAdminLabel.constant = name != nil ? 61 : 0
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllIconsTableViewCell", for: indexPath) as! AllIconsTableViewCell
                cell.delegate = self
                cell.configure(with: groupDatas[indexPath.section - 1])
                return cell
            }
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return section == 0 ? nil : groupDatas[section - 1].activity
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            let featureIcons = groupDatas[indexPath.section - 1].featureIcons // Get icons per section
            let count = featureIcons.count
            
            // Customize height based on number of icons
            if count <= 4 {
                return 100
            } else if count <= 8 {
                return 200
            } else {
                return 300
//            } else {
//                // Calculate based on number of rows needed (assuming 4 per row, for example)
//                let itemsPerRow = 4
//                let rows = ceil(Double(count) / Double(itemsPerRow))
//                let heightPerRow: CGFloat = 100 // Adjust as per design
//                return CGFloat(rows) * heightPerRow
            }
        }
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return UIView() }

        let headerView = UIView()
        headerView.backgroundColor = .white // Match table background

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = groupDatas[section - 1].activity
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard indexPath.section > 0 else { return }
            let selectedActivity = groupDatas[indexPath.section - 1]

            if selectedActivity.activity == "Other Activities" {
                navigateToCalendarViewController()
            } else {
                print("No navigation configured for type: \(selectedActivity.activity)")
            }
        }
    
    func didSelectIcon(_ featureIcon: FeatureIcon) {
        self.featureIcon = featureIcon
        switch featureIcon.name {
        case "Calendar":
            navigateToCalendarViewController()
        case "Management Register":
            navigateToMangementViewController()
        case "Staff Register":
            fetchStaffDataAndNavigate()
        case "Feed Back":
            switch currentRole?.lowercased() {
            case "parent":
                fetchSubjectDataAndNavigate()
            case "admin":
                navigateToFeedBackViewController()
            case "teacher":
                print("❌ Invalid role")
                return
            default:
                print("❌ Invalid or missing role")
                return
            }
        case "Student Register":
            fetchStudentDataAndNavigate()
        case "Subject Register":
            fetchSubjectDataAndNavigate()
        case "Marks Card":
            fetchSubjectDataAndNavigate()
        case "Gallery":
            navigateToGalleryViewController()
        case "Attendance":
            if currentRole == "admin" {
                navigateToAttendanceViewController()
            } else if currentRole == "teacher" {
                fetchSubjectDataAndNavigate()
            }
        case "Syllabus Tracker":
            fetchSubjectDataAndNavigate()
        case "Time Table":
            fetchSubjectDataAndNavigate()
        case "Fee Payment New":
            fetchSubjectDataAndNavigate()
        case "Notes & Videos":
            fetchSubjectDataAndNavigate()
        default:
            print("No navigation configured for type: \(featureIcon.name)")
        }
    }
    
    func navigateToNotes_Videos(subjects: [SubjectData], teamIds: [String]) {
                let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
            if let Notes_VideosVC = storyboard.instantiateViewController(withIdentifier: "Notes_VideosVC") as? Notes_VideosVC {
                Notes_VideosVC.groupId = school?.id ?? ""
                Notes_VideosVC.subjects = subjects
                Notes_VideosVC.currentRole = self.currentRole
                Notes_VideosVC.token = TokenManager.shared.getToken() ?? ""
                Notes_VideosVC.teamId = teamIds[indexPath?.row ?? 0]
                    print("groupId of Notes_Videos: \(Notes_VideosVC.groupId)")
                    navigationController?.pushViewController(Notes_VideosVC, animated: true)
                } else {
                    print("Failed to instantiate SyllabusTrackerVC")
                }
            }
    
    func navigateToFeesNew(subjects: [SubjectData]) {
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentClassListingVC") as! PaymentClassListingVC
        vc.groupId = school?.id ?? ""
        vc.subjects = subjects
        vc.currentRole = self.currentRole
        vc.subjects = subjects
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToTimeTable(staffDetails: [Staff]) {
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
        guard let timetableViewController = storyboard.instantiateViewController(withIdentifier: "TimetableViewController") as? TimetableViewController else {
            print("❌ Failed to instantiate SubjectViewController")
            return
        }
        
        timetableViewController.subjects = self.subjects
        timetableViewController.token = TokenManager.shared.getToken() ?? ""
        timetableViewController.groupId = school?.id ?? ""
        timetableViewController.teamIds = self.teamIds
        timetableViewController.staffDetails = staffDetails
        timetableViewController.currentRole = self.currentRole
        
        print("✅ Passing Team IDs to SubjectViewController: \(teamIds)")
        print("✅ Passing Group ID to SubjectViewController: \(timetableViewController.groupId)") // Fix: Use subjectRegisterVC.groupId
        
        self.navigationController?.pushViewController(timetableViewController, animated: true)
    }
    
    func navigateToSyllabusTracker(subjects: [SubjectData], teamIds: [String]) {
            let storyboard = UIStoryboard(name: "SyllabusTracker", bundle: nil)
            if let SyllabusTrackerVC = storyboard.instantiateViewController(withIdentifier: "SyllabusTrackerVC") as? SyllabusTrackerVC {
                SyllabusTrackerVC.groupId = school?.id ?? ""
                SyllabusTrackerVC.subjects = subjects
                SyllabusTrackerVC.token = TokenManager.shared.getToken() ?? ""
                SyllabusTrackerVC.teamId = teamIds[indexPath?.row ?? 0]
                print("groupId of SyllabusTracker: \(SyllabusTrackerVC.groupId)")
                navigationController?.pushViewController(SyllabusTrackerVC, animated: true)
            } else {
                print("Failed to instantiate SyllabusTrackerVC")
            }
        }
    
    func navigateToAttendanceViewController() {
                let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
                if let attendanceVC = storyboard.instantiateViewController(withIdentifier: "AttendanceVC") as? AttendanceVC {
                    attendanceVC.groupId = school?.id ?? ""
                    attendanceVC.currentRole = self.currentRole ?? ""
                    print("groupId of attendance: \(attendanceVC.groupId)")
                    navigationController?.pushViewController(attendanceVC, animated: true)
                }
            }
    
    func navigateToAttendanceViewControllerWithClass(subjects: [SubjectData], teamIds: [String]) {
                let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
                if let attendanceVC = storyboard.instantiateViewController(withIdentifier: "AttendanceVC") as? AttendanceVC {
                    attendanceVC.groupId = school?.id ?? ""
                    attendanceVC.teamid = teamIds[indexPath?.row ?? 0]
                    attendanceVC.subjects = subjects
                    attendanceVC.currentRole = self.currentRole ?? ""
                    print("groupId of attendance: \(attendanceVC.groupId)")
                    navigationController?.pushViewController(attendanceVC, animated: true)
                }
            }
    
    func navigateToFeedBackViewController() {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "FeedBackViewController") as? FeedBackViewController {
            feedbackVC.groupId = school?.id ?? ""
            feedbackVC.token = TokenManager.shared.getToken() ?? ""
            feedbackVC.currentRole = self.currentRole
            print("Navigating to FeedBackViewController with:")
            print("Group ID: \(feedbackVC.groupId)")
            print("Token: \(feedbackVC.token)")
            
            navigationController?.pushViewController(feedbackVC, animated: true)
        } else {
            print("Failed to instantiate FeedBackViewController")
        }
    }
    
    func navigateToGalleryViewController() {
            let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
            if let galleryVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController {
                galleryVC.groupId = school?.id ?? ""
                galleryVC.token = TokenManager.shared.getToken() ?? ""

                print("Navigating to GalleryViewController with:")
                print("Group ID: \(galleryVC.groupId)")
                print("Token: \(galleryVC.token)")

                navigationController?.pushViewController(galleryVC, animated: true)
            } else {
                print("Failed to instantiate GalleryViewController")
            }
        }
    
    private func fetchSubjectDataAndNavigate() {
            // Ensure token and group ID are available
            guard let token = TokenManager.shared.getToken(), !token.isEmpty,
                  let groupId = school?.id, !groupId.isEmpty else {
                print("❌ Token or Group ID is missing")
                return
            }
        // Choose endpoint based on currentRole
           let endpoint: String
           switch currentRole?.lowercased() {
           case "parent":
               endpoint = APIManager.shared.parentEndPoint
           case "teacher":
               endpoint = APIManager.shared.teacherEndPoint
           case "admin":
               endpoint = APIManager.shared.adminEndPoint
           default:
               print("❌ Invalid or missing role")
               return
           }

           let subjectURL = APIManager.shared.baseURL + "/groups/\(groupId)/" + endpoint
            print("📜 Request URL: \(subjectURL)")

            guard let url = URL(string: subjectURL) else {
                print("❌ Invalid URL: \(subjectURL)")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Error fetching subject data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ No data received.")
                    return
                }

                // Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📜 Raw JSON Response: \(jsonString)")
                } else {
                    print("❌ Failed to convert data to String.")
                }

                // Decode JSON response using JSONSerialization
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let dataArray = json["data"] as? [[String: Any]] else {
                        print("❌ Invalid JSON structure.")
                        return
                    }

                    var subjects: [SubjectData] = []
                    var teamIds: [String] = []

                    for item in dataArray {
                        let subject = SubjectData(
                            totalNoOfStaffAssigned: item["totalNoOfStaffAssigned"] as? Int,
                            teamId: item["teamId"] as? String ?? "",
                            teacherName: item["teacherName"] as? String ?? "",
                            subjectRequired: item["subjectRequired"] as? Bool ?? false,
                            subjectId: item["subjectId"] as? Bool ?? false,
                            studentAssignedStatus: item["studentAssignedStatus"] as? String,
                            staffAssignedStatus: item["staffAssignedStatus"] as? String,
                            sortBy: item["sortBy"] as? String ?? "",
                            role: item["role"] as? String ?? "",
                            phone: item["phone"] as? String ?? "",
                            numberOfTimeAttendance: item["numberOfTimeAttendance"] as? Int ?? 0,
                            name: item["name"] as? String ?? "",
                            userId: item["userId"] as? String ?? "",
                            members: item["members"] as? Int ?? 0,
                            jitsiToken: item["jitsiToken"] as? Bool ?? false,
                            image: item["image"] as? String,
                            gruppieClassName: item["gruppieClassName"] as? String ?? "",
                            enableAttendance: item["enableAttendance"] as? Bool ?? false,
                            ebookId: item["ebookId"] as? Bool ?? false,
                            downloadedCount: item["downloadedCount"] as? Int ?? 0,
                            departmentUserId: item["departmentUserId"] as? String ?? "",
                            departmentHeadName: item["departmentHeadName"] as? String ?? "",
                            department: item["department"] as? String ?? "",
                            classTypeId: item["classTypeId"] as? String ?? "",
                            classTeacherId: item["classTeacherId"] as? String ?? "",
                            classSort: item["classSort"] as? String,
                            category: item["category"] as? String,
                            admissionTeam: item["admissionTeam"] as? Bool ?? false,
                            adminName: item["adminName"] as? String ?? ""
                        )

                        subjects.append(subject)
                        teamIds.append(subject.teamId)
                        self.teamIds.append(subject.teamId)
                        self.userIds.append(subject.userId ?? "")

                    }

                    print("✅ Successfully parsed \(subjects.count) subjects.")
                    
                    // Navigate to Subject Register after fetching
                    DispatchQueue.main.async {
                        print("🚀 Navigating to SubjectViewController with Team IDs: \(teamIds)")
                        switch self.featureIcon?.name {
                        case "Subject Register":
                            self.navigateToSubjectRegister(subjects: subjects, teamIds: teamIds)
                        case "Marks Card":
                            self.navigateToMarksCard(subjects: subjects, teamIds: teamIds)
                        case "Syllabus Tracker":
                            self.navigateToSyllabusTracker(subjects: subjects, teamIds: teamIds)
                        case "Time Table":
                            self.subjects = subjects
                            self.teamIds = teamIds
                            self.fetchStaffDataAndNavigate()
                        case "Fee Payment New":
                            self.navigateToFeesNew(subjects: subjects)
                        case "Feed Back":
                            self.navigateToListOfStudentsVC(subjects: subjects)
                        case "Notes & Videos":
                            self.navigateToNotes_Videos(subjects: subjects, teamIds: teamIds)
                        case "Attendance":
                            self.navigateToAttendanceViewControllerWithClass(subjects: subjects, teamIds: teamIds)
                        default:
                            print("No navigation configured for type: \(self.featureIcon?.name)")
                            
                        }
                    }

                } catch {
                    print("❌ Error decoding subject data: \(error.localizedDescription)")
                }
            }.resume()
        }

    func navigateToListOfStudentsVC(subjects: [SubjectData]) {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "listOfStudentsVC") as? listOfStudentsVC {
            vc.teamIds = self.teamIds
            vc.teamId = self.teamIds.first // ✅ Or whichever one you're selecting
            vc.groupId = school?.id ?? ""
            vc.token = TokenManager.shared.getToken() ?? ""
            vc.subjects = subjects
            vc.userIds = self.userIds  // ✅ Pass the userIds here
            vc.currentRole = self.currentRole
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func fetchSubjectData(from urlString: String, token: String, completion: @escaping ([SubjectData], [String]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion([], [])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching subject data: \(error.localizedDescription)")
                completion([], [])
                return
            }
            
            guard let data = data else {
                print("❌ No data received.")
                completion([], [])
                return
            }
            
            // Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Raw JSON Response: \(jsonString)")
            } else {
                print("❌ Failed to convert data to String.")
            }
            
            // Decode JSON response
            let decoder = JSONDecoder()
            do {
                let subjectResponse = try decoder.decode(SubjectResponse.self, from: data)
                let subjects = subjectResponse.data
                
                // Extract all teamIds
                let teamIds = subjects.compactMap { $0.teamId }
                
                print("📚 Total subjects fetched: \(subjects.count)")
                print("🆔 Extracted Team IDs: \(teamIds)")
                
                for subject in subjects {
                    print("📖 Subject Name: \(subject.name)")
                }
                
                completion(subjects, teamIds) // Return subjects and all teamIds
            } catch {
                print("❌ Error decoding subject data: \(error)")
                completion([], []) // Return empty array and empty teamIds in case of error
            }
        }.resume()
    }
        
    func navigateToSubjectRegister(subjects: [SubjectData], teamIds: [String]) {
        let storyboard = UIStoryboard(name: "Subject", bundle: nil)
        guard let subjectRegisterVC = storyboard.instantiateViewController(withIdentifier: "SubjectViewController") as? SubjectViewController else {
            print("❌ Failed to instantiate SubjectViewController")
            return
        }
        
        subjectRegisterVC.subjects = subjects
        subjectRegisterVC.token = TokenManager.shared.getToken() ?? ""
        subjectRegisterVC.groupId = school?.id ?? ""
        subjectRegisterVC.teamIds = teamIds
        
        print("✅ Passing Team IDs to SubjectViewController: \(teamIds)")
        print("✅ Passing Group ID to SubjectViewController: \(subjectRegisterVC.groupId)") // Fix: Use subjectRegisterVC.groupId
        
        self.navigationController?.pushViewController(subjectRegisterVC, animated: true)
    }
    
    func navigateToMarksCard(subjects: [SubjectData], teamIds: [String]) {
        let storyboard = UIStoryboard(name: "MarksCard", bundle: nil)
        guard let MarksCardVC = storyboard.instantiateViewController(withIdentifier: "ClassListMarksCardVC") as? ClassListMarksCardVC else {
            print("❌ Failed to instantiate SubjectViewController")
            return
        }
        
        MarksCardVC.subjects = subjects
        MarksCardVC.token = TokenManager.shared.getToken() ?? ""
        MarksCardVC.groupId = school?.id ?? ""
        MarksCardVC.teamIds = teamIds
        MarksCardVC.currentRole = self.currentRole
        
        print("✅ Passing Team IDs to SubjectViewController: \(teamIds)")
        print("✅ Passing Group ID to SubjectViewController: \(MarksCardVC.groupId)") // Fix: Use subjectRegisterVC.groupId
        
        self.navigationController?.pushViewController(MarksCardVC, animated: true)
    }
    
    func navigateToCalendarViewController() {
            let storyboard = UIStoryboard(name: "calender", bundle: nil)
            if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController {
                calendarVC.groupId = school?.id ?? ""
                calendarVC.currentRole = self.currentRole ?? ""
                print("groupId : \(calendarVC.groupId)")
                navigationController?.pushViewController(calendarVC, animated: true)
            }
        }
    
    func navigateToMangementViewController() {
        print("Home stack tapped, calling API...")
        
        guard let token = TokenManager.shared.getToken() else {
            print("Token is missing")
            return
        }
        
        let groupId = school?.id ?? ""
        print("Navigating to Management Register with:")
        print("Group ID: \(groupId)")
        print("Token: \(token)")

        fetchMembersData { [weak self] members in
            guard let self = self else { return }
            
            print("Received members count: \(members.count)")
            self.navigateToManagementViewController(members: members)
        }
    }
    
    private func fetchMembersData(completion: @escaping ([Member]) -> Void) {
        var allMembers: [Member] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchMembers(for: school?.id ?? "", token: TokenManager.shared.getToken() ?? "") { members in
            allMembers.append(contentsOf: members)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allMembers)
        }
    }

    private func fetchMembers(for groupId: String, token: String, completion: @escaping ([Member]) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/management/get?page=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching members data for group \(groupId): \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received for group \(groupId).")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseModel = try decoder.decode(MemberResponse.self, from: data)
                completion(responseModel.data)
            } catch {
                print("Error decoding members data: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
    
    private func navigateToManagementViewController(members: [Member]) {
        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        guard let managementVC = storyboard.instantiateViewController(withIdentifier: "ManagementViewController") as? ManagementViewController else {
            print("Failed to instantiate ManagementViewController")
            return
        }
        
        managementVC.token = TokenManager.shared.getToken()
        managementVC.groupIds = school?.id ?? ""
        managementVC.members = members
        
        navigationController?.pushViewController(managementVC, animated: true)

    }
    
    private func fetchStaffDataAndNavigate() {
            guard let token = TokenManager.shared.getToken(), !token.isEmpty, let groupId = school?.id, !groupId.isEmpty else {
                print("Token or Group ID is missing")
                return
            }
            
            let teachingURL = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching"
            let dispatchGroup = DispatchGroup()
            var teachingStaff: [Staff] = []
            
            dispatchGroup.enter()
            fetchStaffData(from: teachingURL, token: token) { staff in
                teachingStaff = staff
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                switch self.featureIcon?.name {
                case "Staff Register":
                    self.navigateToStaffRegister(teachingStaff: teachingStaff)
                case "Time Table":
                    self.navigateToTimeTable(staffDetails: teachingStaff)
                default:
                    print("No navigation configured for type: \(self.featureIcon?.name)")
                }
            }
        }
    
    private func fetchStaffData(from urlString: String, token: String, completion: @escaping ([Staff]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching staff data: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseModel = try decoder.decode(StaffResponse.self, from: data)
                completion(responseModel.data)
            } catch {
                print("Error decoding staff data: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
    
    private func navigateToStaffRegister(teachingStaff: [Staff]) {
        let storyboard = UIStoryboard(name: "Staff", bundle: nil)
        guard let staffRegisterVC = storyboard.instantiateViewController(withIdentifier: "StaffRegister") as? StaffRegister else {
            print("Failed to instantiate StaffRegister view controller")
            return
        }
        staffRegisterVC.token = TokenManager.shared.getToken() ?? ""
        staffRegisterVC.groupIds = school?.id ?? ""
        staffRegisterVC.teachingStaffData = teachingStaff
        navigationController?.pushViewController(staffRegisterVC, animated: true)
    }
    
    private func fetchStudentDataAndNavigate() {
            guard let token = TokenManager.shared.getToken(), !token.isEmpty,
                  let groupId = school?.id, !groupId.isEmpty else {
                print("Token or Group ID is missing")
                return
            }
            
            let studentURL = APIManager.shared.baseURL + "groups/\(groupId)/class/get?type=regular"
            let dispatchGroup = DispatchGroup()
            var studentTeams: [StudentTeam] = []
            
            dispatchGroup.enter()
            fetchStudentData(from: studentURL, token: token) { teams in
                studentTeams = teams
                print("📊 Total students fetched: \(studentTeams.count)") // Print count in console
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.navigateToStudentRegister(studentTeams: studentTeams)
                self.studentTeams = studentTeams
            }
        }
    
    private func fetchStudentData(from urlString: String, token: String, completion: @escaping ([StudentTeam]) -> Void) {
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                completion([])
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching student data: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let data = data else {
                    print("No data received.")
                    completion([])
                    return
                }
                
                // Print raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                } else {
                    print("Failed to convert data to String.")
                }
                
                // Decode JSON response
                do {
                    let decoder = JSONDecoder()
                    let responseModel = try decoder.decode(StudentTeamResponse.self, from: data)
                    print("Decoded Student Team Response: \(responseModel)")
                    completion(responseModel.data)
                } catch {
                    print("Error decoding student data: \(error.localizedDescription)")
                    completion([])
                }
            }.resume()
        }
    
    private func navigateToStudentRegister(studentTeams: [StudentTeam]) {
           let storyboard = UIStoryboard(name: "Student", bundle: nil)
           guard let studentRegisterVC = storyboard.instantiateViewController(withIdentifier: "StudentViewController") as? StudentViewController else {
               print("Failed to instantiate StudentViewController")
               return
           }
           
           studentRegisterVC.studentTeams = studentTeams
           studentRegisterVC.token = TokenManager.shared.getToken() ?? ""
           studentRegisterVC.groupIds = school?.id ?? ""
           
           self.navigationController?.pushViewController(studentRegisterVC, animated: true)
       }
}
