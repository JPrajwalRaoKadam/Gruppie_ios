import UIKit
import SDWebImage

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AllIconsTableViewCellDelegate,FeedPageNavigationDelegate, HomePageNavigationDelegate, MoreNavigationDelegate, DashboardNavigationDelegate {
    
    var groupName: String?
    var roleName: String?
    var fullAccess: Bool = false
    
    var indexPath: IndexPath?
    var name: String?
    var groupId: String?
    var school: School? // School object to hold school data
    var imageUrls: [String] = [] // Array to hold multiple image URLs
    var homeData: HomeResponse?
    var feature: [Feature] = []
    var studentTeams: [StudentTeam] = []
    var featureIcon: FeatureIcon?
    var currentRole: String?
//    var teachingStaff: [Staff] = []
    var subjects: [SubjectData] = [] // Store fetched subjects
    var teamIds: [String] = []
    var userIds: [String] = []
    var userId:String = ""
    var featureIcons: [FeatureIcon] = []
    public var groupClasses: [GroupClass] = []
    var feeGroupClasses: [FeeGroupClass] = []
    public var pagination: Pagination?
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var tableView: UITableView! // TableView outlet
    @IBOutlet weak var shortNameLabel: UILabel! // Label to display short name
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    private var pageViewController: UIPageViewController? // UIPageViewController instance
    private var currentPageIndex: Int = 0 // Current page index
    private var timer: Timer?
    private var isProcessingSelection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHomeData()
        fetchGroupAcademicYearList()
        tableView.sectionHeaderTopPadding = 0

        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        self.navigationController?.isNavigationBarHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "BannerAndProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "BannerAndProfileTableViewCell")
        tableView.register(UINib(nibName: "AllIconsTableViewCell", bundle: nil), forCellReuseIdentifier: "AllIconsTableViewCell")
        tableView.separatorStyle = .none
        tableView.contentInset = .zero
        tableView.sectionHeaderHeight = 0
        tableView.tableHeaderView = nil
        tableView.sectionHeaderTopPadding = 10
        
        CustomTabManager.shared.delegate = self
        CustomTabManager.shared.hDelegate = self
        CustomTabManager.shared.mDelegate = self
        CustomTabManager.shared.dbDelegate = self
        enableKeyboardDismissOnTap()
        print("roleName in rolesvc\(roleName)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CustomTabManager.addTabBar(self, isRemoveLast: false, selectIndex: 0, bottomConstraint: &self.bottomTableViewConstraint)
        
    }
    
    private func fetchHomeData() {
        guard let token = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.request(
            endpoint: "home/services",
            method: .get,
            headers: headers
        ) { (result: Result<HomeResponse, APIManager.APIError>) in

            switch result {
            case .success(let response):
                DispatchQueue.main.async {

                    self.homeData = response
                    self.feature = response.features

                    // ✅ Flatten all icons
                    self.featureIcons = response.features.flatMap { $0.featureIcons }

                    // ✅ Extract image URLs
                    self.imageUrls = self.featureIcons.map { $0.logoUrl }

                    // ✅ Set labels
                    self.groupName = response.groupName
                    self.groupId = response.groupId
                    self.roleName = response.role
                    self.shortNameLabel.text = response.groupName

                    print("✅ Home loaded:", self.feature.count)
                    print("✅ Total icons:", self.featureIcons.count)
                    print("✅ Image URLs:", self.imageUrls.count)

                    self.tableView.reloadData()
                }


            case .failure(let error):
                print("❌ Home API Error:", error)
            }
        }
    }

    @IBAction func backAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let grpVC = storyboard.instantiateViewController(withIdentifier: "GrpViewController") as? GrpViewController else {
            print("ViewController with identifier 'feedVC' not found.")
            return
        }
        self.navigationController?.pushViewController(grpVC, animated: true)
    }
    
    func tapforFeeds() {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController else {
            print("ViewController with identifier 'feedVC' not found.")
            return
        }
        feedVC.groupAcademicYearResponse = self.groupAcademicYearResponse
        feedVC.feedSource = .normalFeed
        feedVC.currentRole = self.currentRole
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func getHomedata() {
            if let homeVC = self.navigationController?.viewControllers.first(where: { $0 is HomeVC }) {
                self.navigationController?.popToViewController(homeVC, animated: true)
            } else {
                print("HomeVC not found in the navigation stack.")
            }
    }
    
    func tapforDashboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as? DashBoardVC else {
            print("ViewController with identifier 'dashboardVC' not found.")
            return
        }
        
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    func tapOnMore() {
        let storyboard = UIStoryboard(name: "More", bundle: nil)
        guard let moreVC = storyboard.instantiateViewController(withIdentifier: "MoreViewController") as? MoreViewController else {
            print("ViewController with identifier 'MoreVC' not found.")
            return
        }
        
        self.navigationController?.pushViewController(moreVC, animated: true)
    }
    
    // MARK: - UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        //            return 1 + groupDatas.count
        return feature.count
    }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AllIconsTableViewCell",
            for: indexPath
        ) as! AllIconsTableViewCell

        cell.delegate = self
        cell.configure(with: self.feature[indexPath.section] )
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        let featureIcons = self.feature[indexPath.section].featureIcons
        let count = featureIcons.count
        let itemsPerRow = 4

        if count <= itemsPerRow {
            return 140
        } else if count <= itemsPerRow * 2 {
            return 225
        } else if count <= itemsPerRow * 3 {
            return 320
        } else {
            let rows = ceil(Double(count) / Double(itemsPerRow))
            return CGFloat(rows) * 80 + CGFloat(rows - 1) * 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 1 // Or 0 if you want no space at all
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01 // Must be non-zero to remove default footer space
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isProcessingSelection else {
               print("Tap ignored – already processing.")
               return
           }

        guard indexPath.section > 0 else { return }
        let selectedActivity = homeData?.features[indexPath.section - 1]
        
        if selectedActivity?.activity == "Other Activities" {
            navigateToCalendarViewController()
        } else {
            print("No navigation configured for type: \(selectedActivity?.activity)")
        }
    }
    
    func didSelectIcon(_ featureIcon: FeatureIcon) {
        self.featureIcon = featureIcon
        let featureId = featureIcon.id

        // 🔐 Fetch permissions
        fetchRolePermissions(featureId: featureId) { [weak self] permissions in
            guard let self = self else { return }
            
            guard let permissions = permissions else {
                print("❌ No permissions")
                return
            }

            self.fullAccess = permissions.fullAccess ?? false

            if permissions.view == true {
                print("✅ User can view")
            }

            if permissions.fullAccess == true {
                print("🔥 Full access granted")
            }
        }
        
        // 🚀 Navigation handling
        switch featureIcon.name {
            
        // ✅ COMMON HANDLER (NO DUPLICATE API CALLS)
        case "Notes and videos",
             "Classroom Communication",
             "Student Register",
             "Subject Register",
             "Students Attendance",
             "Homework or Assignment",
             "fee":
            
            handleGroupClassNavigation(featureName: featureIcon.name)
            
            
        case "Staff Diary":
            break
            
        case "Calendar":
            navigateToCalendarViewController()
            
        case "Management Register":
            navigateToManagementViewController()
            
        case "Staff Register":
            navigateToStaffRegister()
            
        case "Staff Attendance":
            navigateToStaffAttendance()
            
        case "Feed Back":
            switch currentRole?.lowercased() {
            case "parent":
                fetchSubjectDataAndNavigate()
            case "admin":
                navigateToFeedBackViewController()
            case "teacher":
                print("❌ Invalid role")
            default:
                print("❌ Invalid or missing role")
            }
            
        case "Notice Board":
            navigateToNoticeBoard()
            
        case "Student Diary":
            fetchSubjectDataAndNavigate()
            fetchStudentDataAndNavigate()
            
        case "Marks Card":
            fetchSubjectDataAndNavigate()
            
        case "Gallery":
            navigateToGalleryViewController()
            
        case "Syllabus Tracker":
            fetchSubjectDataAndNavigate()
            
        case "Time Table", "Timetable":
            navigateToTimeTable()
            
        case "Fee":
            if SessionManager.role_name == "STUDENT" {
                
                fetchFeeUserClasses { [weak self] classes in
                    guard let self = self else { return }
                    
                    guard let classes = classes else {
                        print("❌ No user classes")
                        return
                    }
                    
                    self.feeGroupClasses = classes
                    navigateToFeesNew(groupClass: feeGroupClasses)
                    self.tableView.reloadData()
                }
                
            } else {
                navigateToFeesNew()
            }
            
        case "Notes & Videos":
            fetchSubjectDataAndNavigate()
            
        case "Marks Card New":
            fetchSubjectDataAndNavigate()
            
        case "Bus Register":
            navigateToBusRegister()
            
        case "Gate Management":
            navigateToGateManagement()
            
        case "Gate Pass":
            if currentRole == "admin" {
                navigateToGatePass()
            } else if currentRole == "parent" {
                navigateToStatusApprove()
            } else {
                print("❌ No navigation configured for role: \(currentRole ?? "nil")")
            }
            
        default:
            print("❌ No navigation configured for type: \(featureIcon.name)")
        }
    }
    
    func navigateBasedOnFeature(featureName: String) {
        
        switch featureName {
            
        case "Notes and videos":
            navigateToNotes_Videos(groupClass: groupClasses)
            
        case "Classroom Communication":
            navigateToRlassroomCommunication(groupClass: groupClasses)
            
        case "Student Register":
            navigateToStudentRegister(groupClasses: groupClasses)
            
        case "Subject Register":
            navigateToSubjectRegister(groupClass: groupClasses)
            
        case "Students Attendance":
            navigateToAttendanceViewController(groupClass: groupClasses)
            
        case "Homework or Assignment":
            navigateToHomeworkViewController(groupClass: groupClasses)
            
        default:
            print("⚠️ No navigation mapped for \(featureName)")
        }
    }
    
    func handleGroupClassNavigation(featureName: String) {
        
        // ✅ If already loaded → skip API
        if !groupClasses.isEmpty {
            navigateBasedOnFeature(featureName: featureName)
            return
        }
        
        // ✅ STUDENT → use fetchRoleGroupClasses
        if SessionManager.role_name == "STUDENT" {
            
            fetchRoleGroupClasses { [weak self] (classes: [GroupClass]?) in
                guard let self = self else { return }
                
                guard let classes = classes else {
                    print("❌ No classes (Student API)")
                    return
                }
                
                print("🎓 Student Classes:", classes.count)
                
                self.groupClasses = classes
                self.navigateBasedOnFeature(featureName: featureName)
            }
            
        } else {
            
            // ✅ OTHER ROLES → normal API
            fetchGroupClasses { [weak self] (classes: [GroupClass]?) in
                guard let self = self else { return }
                
                guard let classes = classes else {
                    print("❌ No classes")
                    return
                }
                
                print("🏫 Classes:", classes.count)
                
                self.groupClasses = classes
                self.navigateBasedOnFeature(featureName: featureName)
            }
        }
    }
    
    func fetchRolePermissions(featureId: Int, completion: @escaping (PermissionDetails?) -> Void) {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            completion(nil)
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "role-permissions/feature/\(featureId)"

        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            headers: headers
        ) { (result: Result<RolePermissionResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    
                     print("✅ Full Response:", response)

                    // 🔥 Extract dynamic data
                    if let featureDict = response.data?.first,
                       let roleDict = featureDict.value.first {
                        
                        let permissions = roleDict.value
                        print("🔥 Permissions:", permissions)
                        
                        completion(permissions)
                    } else {
                        print("❌ No permissions found")
                        completion(nil)
                    }
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                completion(nil)
            }
        }
    }
    
    
    private func fetchGroupClasses(
        completion: @escaping ([GroupClass]?) -> Void
    ) {
        APIManager.shared.getGroupClasses(page: 1, limit: 10) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                
                self.groupClasses = response.data
                self.pagination = response.pagination
                
                print("✅ Saved Classes:", self.groupClasses.count)
                
                completion(self.groupClasses)   // ✅ RETURN DATA
                
            case .failure(let error):
                print("❌ API Error:", error)
                completion(nil)
            }
        }
    }
    
    func fetchRoleGroupClasses(
        page: Int = 1,
        limit: Int = 200,
        types: String = "regular,admission",
        completion: @escaping ([GroupClass]?) -> Void
    ) {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            completion(nil)
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        
        let encodedTypes = types.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let endpoint = "group-class?page=\(page)&limit=\(limit)&types=\(encodedTypes)"
        
        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            headers: headers
        ) { (result: Result<GroupClassResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    
                    print("✅ Full Response:", response)
                    
                    let classes = response.data   // ✅ No optional binding
                    
                    completion(classes)
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                completion(nil)
            }
        }
    }
    
    func loadRoleGroupClasses() {
        
        fetchGroupClasses { [weak self] classes in
            guard let self = self else { return }
            
            guard let classes = classes else {
                print("❌ No classes received")
                return
            }
            
            self.groupClasses = classes
            self.tableView.reloadData()
        }
    }
    
    func fetchFeeUserClasses(
        completion: @escaping ([FeeGroupClass]?) -> Void
    ) {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            completion(nil)
            return
        }
        
        guard let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId missing")
            completion(nil)
            return
        }
        
        let endpoint = "group-class/user-classes?groupAcademicYearId=\(groupAcademicYearId)"
        
        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<UserClassResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                DispatchQueue.main.async {
                    print("✅ User Classes:", response.data.count)
                    completion(response.data)
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                completion(nil)
            }
        }
    }
    
    private func navigateToStaffAttendance() {
        let storyboard = UIStoryboard(name: "StaffAttendence", bundle: nil) // Replace with your actual storyboard name
        guard let staffAttendanceVC = storyboard.instantiateViewController(withIdentifier: "StaffAttendenceVc") as? StaffAttendenceVc else {
            print("Failed to instantiate StaffAttendanceVC")
            return
        }
        
        // Pass required parameters
        staffAttendanceVC.token = TokenManager.shared.getToken() ?? ""
        staffAttendanceVC.groupId = school?.id ?? ""
        staffAttendanceVC.currentRole = self.currentRole ?? ""
        
        // You can pass other parameters if needed
        // staffAttendanceVC.someOtherProperty = someValue
        
        navigationController?.pushViewController(staffAttendanceVC, animated: true)
    }
    
    func navigateToBusRegister() {
                let storyboard = UIStoryboard(name: "BusRegister", bundle: nil)
                if let GatePassViewController = storyboard.instantiateViewController(withIdentifier: "BuslistVC") as? BuslistVC {
                    GatePassViewController.groupId = school?.id ?? ""
                    GatePassViewController.currentRole = self.currentRole ?? ""
                    navigationController?.pushViewController(GatePassViewController, animated: true)
                }
            }
    func navigateToGatePass() {
                let storyboard = UIStoryboard(name: "GatePass", bundle: nil)
                if let GatePassViewController = storyboard.instantiateViewController(withIdentifier: "GatePass") as? GatePassVC {
                    GatePassViewController.groupId = school?.id ?? ""
                    GatePassViewController.currentRole = self.currentRole ?? ""
                    print("groupId : \(GatePassViewController.groupId)")
                    navigationController?.pushViewController(GatePassViewController, animated: true)
                }
            }
    func navigateToStatusApprove() {
        let storyboard = UIStoryboard(name: "GatePass", bundle: nil)
        if let statusApproveVC = storyboard.instantiateViewController(withIdentifier: "StatusApproveVC") as? StatusApproveVC {
            statusApproveVC.groupId = school?.id ?? ""
            print("groupId : \(statusApproveVC.groupId)")
            navigationController?.pushViewController(statusApproveVC, animated: true)
        }
    }
    
    
    func navigateToGateManagement() {
                let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
                if let GateManagement = storyboard.instantiateViewController(withIdentifier: "GateManagementVC") as? GateManagementVC {
                    GateManagement.groupId = school?.id ?? ""
                    GateManagement.currentRole = self.currentRole ?? ""
                    print("groupId : \(GateManagement.groupId)")
                    navigationController?.pushViewController(GateManagement, animated: true)
                }
            }
    
    func navigateToNotes_Videos(groupClass: [GroupClass]) {
                let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
            if let Notes_VideosVC = storyboard.instantiateViewController(withIdentifier: "Notes_VideosVC") as? Notes_VideosVC {
                    navigationController?.pushViewController(Notes_VideosVC, animated: true)
                Notes_VideosVC.groupClasses = groupClass
                Notes_VideosVC.groupAcademicYearResponse = self.groupAcademicYearResponse
                } else {
                    print("Failed to instantiate SyllabusTrackerVC")
                }
            }
    
    func navigateToExamination_ActivityVC(subjects: [SubjectData], teamIds: [String],  userIds: [String]) {
                let storyboard = UIStoryboard(name: "Examination Activity", bundle: nil)
            if let examinationActivity = storyboard.instantiateViewController(withIdentifier: "Examination_ActivityVC") as? Examination_ActivityVC {
                examinationActivity.groupId = school?.id ?? ""
                examinationActivity.subjects = subjects
                examinationActivity.currentRole = self.currentRole
                examinationActivity.token = TokenManager.shared.getToken() ?? ""
                examinationActivity.teamId = teamIds[indexPath?.row ?? 0]
                examinationActivity.userId = userIds[indexPath?.row ?? 0]
                navigationController?.pushViewController(examinationActivity, animated: true)
                } else {
                    print("Failed to instantiate SyllabusTrackerVC")
                }
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
                SyllabusTrackerVC.currentRole = self.currentRole
                print("groupId of SyllabusTracker: \(SyllabusTrackerVC.groupId)")
                navigationController?.pushViewController(SyllabusTrackerVC, animated: true)
            } else {
                print("Failed to instantiate SyllabusTrackerVC")
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
    
    func navigateToAttendanceViewController(groupClass: [GroupClass]) {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let attendanceVC = storyboard.instantiateViewController(withIdentifier: "AttendanceVC") as? AttendanceVC {
            attendanceVC.groupClasses = groupClass  // Pass the group classes data
//            attendanceVC.roleName = roleName
            attendanceVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            print("📚 Passing \(groupClass.count) group classes to AttendanceVC")
            navigationController?.pushViewController(attendanceVC, animated: true)
        }
    }
    func navigateToHomeworkViewController(groupClass: [GroupClass]) {
        let storyboard = UIStoryboard(name: "HomeWork", bundle: nil)
        if let attendanceVC = storyboard.instantiateViewController(withIdentifier: "HomeWorkVC") as? HomeWorkVC {
            attendanceVC.groupClasses = groupClass  // Pass the group classes data
            attendanceVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            print("📚 Passing \(groupClass.count) group classes to AttendanceVC")
            navigationController?.pushViewController(attendanceVC, animated: true)
        }
    }
    
    func navigateToTimeTable() {
            let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
            guard let timetableViewController = storyboard.instantiateViewController(withIdentifier: "TimetableViewController") as? TimetableViewController else {
                print("❌ Failed to instantiate TimetableViewController")
                return
            }
            
            navigationController?.pushViewController(timetableViewController, animated: true)
        }
    
    func navigateToGalleryViewController() {
            let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
            if let galleryVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController {
                galleryVC.token = TokenManager.shared.getToken() ?? ""
                galleryVC.currentRole = self.currentRole ?? ""
                print("Navigating to GalleryViewController with:")

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
                        self.userId = subject.userId ?? ""
                        self.userIds.append(subject.userId ?? "")

                    }

                    print("✅ Successfully parsed \(subjects.count) subjects.")
                    
                    // Navigate to Subject Register after fetching
                    DispatchQueue.main.async {
                        print("🚀 Navigating to SubjectViewController with Team IDs: \(teamIds)")
                        switch self.featureIcon?.name {
                        case "Subject Register":
//                            self.navigateToSubjectRegister(subjects: subjects, teamIds: teamIds)
                            break
                        case "Marks Card":
                            break
//                            self.navigateToMarksCard(subjects: subjects, teamIds: teamIds)
                        case "Syllabus Tracker":
                            self.navigateToSyllabusTracker(subjects: subjects, teamIds: teamIds)
                        case "Time Table":
                            self.subjects = subjects
                            self.teamIds = teamIds
//                            self.fetchStaffDataAndNavigate()
                        case "Fee Payment New":
                            break
//                            self.navigateToFeesNew(subjects: subjects)
                        case "Feed Back":
                            self.navigateToListOfStudentsVC(subjects: subjects)
                        case "Notes & Videos":
//                            self.navigateToNotes_Videos(subjects: subjects, teamIds: teamIds)
                            break
                        case "Students Attendance":
                            self.fetchGroupClasses {_ in 
                                       self.navigateToAttendanceViewController(groupClass: self.groupClasses)
                                   }
                        case "Marks Card New":
                            self.navigateToExamination_ActivityVC(subjects: subjects, teamIds: teamIds, userIds: self.userIds)
                        default:
                            print("No navigation configured for type: \(self.featureIcon?.name)")
                            
                        }
                    }

                } catch {
                    print("❌ Error decoding subject data: \(error.localizedDescription)")
                }
            }.resume()
        }
    
    private func fetchGroupAcademicYearList() {

        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ Role token missing")
            return
        }

        let headers: [String: String] = [
            "Authorization": "Bearer \(token)"
        ]

        APIManager.shared.request(
            endpoint: "group-academicyear-list",
            method: .get,
            headers: headers
        ) { (result: Result<GroupAcademicYearResponse, APIManager.APIError>) in

            switch result {

            case .success(let response):

                // store full response so you can pass to next VC
                self.groupAcademicYearResponse = response

                // example log
                print("✅ academic years :", response.data.academicYears.count)

            case .failure(let error):
                print("❌ group academic year api error :", error)
            }
        }
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
        
    func navigateToSubjectRegister(groupClass: [GroupClass]) {
           let storyboard = UIStoryboard(name: "Subject", bundle: nil)
           guard let subjectRegisterVC = storyboard.instantiateViewController(withIdentifier: "SubjectViewController") as? SubjectViewController else {
               print("❌ Failed to instantiate SubjectViewController")
               return
           }
           subjectRegisterVC.groupClasses = groupClass
           
           self.navigationController?.pushViewController(subjectRegisterVC, animated: true)
       }
    
    func navigateToNoticeBoard() {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)

        guard let feedVC = storyboard.instantiateViewController(
            withIdentifier: "FeedViewController"
        ) as? FeedViewController else {
            print("❌ Failed to instantiate FeedViewController")
            return
        }
        feedVC.groupAcademicYearResponse = self.groupAcademicYearResponse
        feedVC.fullAccess = self.fullAccess
        feedVC.feedSource = .noticeBoard   // ✅ IMPORTANT
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func navigateToRlassroomCommunication(groupClass: [GroupClass]) {
        let storyboard = UIStoryboard(name: "Communication", bundle: nil)
        guard let subjectRegisterVC = storyboard.instantiateViewController(withIdentifier: "ClassroomViewController") as? ClassroomViewController else {
            print("❌ Failed to instantiate ClassroomViewController")
            return
        }
        subjectRegisterVC.groupClasses = groupClass
        
        self.navigationController?.pushViewController(subjectRegisterVC, animated: true)
    }
    
    func navigateToFeesNew(groupClass: [FeeGroupClass]? = nil) {
        
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "PaymentClassListingVC"
        ) as? PaymentClassListingVC else {
            print("❌ Failed to instantiate PaymentClassListingVC")
            return
        }
        
        vc.groupAcademicYearResponse = self.groupAcademicYearResponse
        
        // ✅ Pass only if available
        if let groupClass = groupClass {
            vc.groupClasses = groupClass
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func navigateToMarksCard(subjects: [SubjectData], teamIds: [String]) {
//        let storyboard = UIStoryboard(name: "MarksCard", bundle: nil)
//        guard let MarksCardVC = storyboard.instantiateViewController(withIdentifier: "ClassListMarksCardVC") as? ClassListMarksCardVC else {
//            print("❌ Failed to instantiate SubjectViewController")
//            return
//        }
//
//        MarksCardVC.subjects = subjects
//        MarksCardVC.token = TokenManager.shared.getToken() ?? ""
//        MarksCardVC.groupId = school?.id ?? ""
//        MarksCardVC.teamIds = teamIds
//        MarksCardVC.currentRole = self.currentRole
//
//        print("✅ Passing Team IDs to SubjectViewController: \(teamIds)")
//        print("✅ Passing Group ID to SubjectViewController: \(MarksCardVC.groupId)") // Fix: Use subjectRegisterVC.groupId
//
//        self.navigationController?.pushViewController(MarksCardVC, animated: true)
//    }
    
    func navigateToCalendarViewController() {
            let storyboard = UIStoryboard(name: "calender", bundle: nil)
            if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController {
                calendarVC.groupId = school?.id ?? ""
                calendarVC.currentRole = self.currentRole ?? ""
                print("groupId : \(calendarVC.groupId)")
                navigationController?.pushViewController(calendarVC, animated: true)
            }
        }
    
    private func navigateToManagementViewController() {
        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        guard let managementVC = storyboard.instantiateViewController(withIdentifier: "ManagementViewController") as? ManagementViewController else {
            print("Failed to instantiate ManagementViewController")
            return
        }
        managementVC.token = SessionManager.useRoleToken
        navigationController?.pushViewController(managementVC, animated: true)
    }
    
//    private func fetchStaffDataAndNavigate() {
//            guard let token = TokenManager.shared.getToken(), !token.isEmpty, let groupId = school?.id, !groupId.isEmpty else {
//                print("Token or Group ID is missing")
//                return
//            }
//
//            let teachingURL = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching"
//            let dispatchGroup = DispatchGroup()
//            var teachingStaff: [Staff] = []
//
//            dispatchGroup.enter()
//            fetchStaffData(from: teachingURL, token: token) { staff in
//                teachingStaff = staff
//                dispatchGroup.leave()
//            }
//            dispatchGroup.notify(queue: .main) {
//                switch self.featureIcon?.name {
//                case "Staff Diary":
////                    self.navigateToStaffDiary(teachingStaff: teachingStaff)
//                    break
//                case "Staff Register":
////                    self.navigateToStaffRegister(teachingStaff: teachingStaff)
//                    break
//                case "Time Table":
//                    self.navigateToTimeTable(staffDetails: teachingStaff)
//                default:
//                    print("No navigation configured for type: \(self.featureIcon?.name)")
//                }
//            }
//        }
    
//    private func navigateToStaffDiary(teachingStaff: [Staff]) {
//            print("Teaching Staff List:")
//            for staff in teachingStaff {
//                print("qqqqqqqqqqqName: \(staff.name), Phone: \(staff.phone)")
//            }
//
//            if currentRole == "parent" || currentRole == "student" || currentRole == "admin" {
//                let storyboard = UIStoryboard(name: "StaffDiary", bundle: nil)
//                guard let staffDiaryVC = storyboard.instantiateViewController(withIdentifier: "StaffDiaryVc") as? StaffDiaryVc else {
//                    print("Failed to instantiate StaffDiaryVc")
//                    return
//                }
//
//                staffDiaryVC.token = TokenManager.shared.getToken() ?? ""
//                staffDiaryVC.groupIds = school?.id ?? ""
//                staffDiaryVC.teachingStaffData = teachingStaff
//                staffDiaryVC.currentRole = self.currentRole
//
//                print("✅ Assigned \(teachingStaff.count) staff to staffDiaryVC")
//                navigationController?.pushViewController(staffDiaryVC, animated: true)
//
//            } else if currentRole == "teacher" {
//                let storyboard = UIStoryboard(name: "StaffDiary", bundle: nil)
//                guard let staffDaysVC = storyboard.instantiateViewController(withIdentifier: "StaffDaysViewController") as? StaffDaysViewController else {
//                    print("Failed to instantiate StaffDaysViewController")
//                    return
//                }
//
//                staffDaysVC.token = TokenManager.shared.getToken() ?? ""
//                staffDaysVC.groupIds = school?.id ?? ""
//                staffDaysVC.currentRole = self.currentRole
//                staffDaysVC.teachingStaff = teachingStaff
//
//                if let teacherUserId = teachingStaff.first?.userId {
//                    staffDaysVC.userId = teacherUserId
//                    print("👨‍🏫 Passed userId to StaffDaysViewController: \(teacherUserId)")
//                } else {
//                    print("❌ No userId found in teachingStaff")
//                }
//
//                print("✅ Navigating directly to StaffDaysViewController for staff role")
//                navigationController?.pushViewController(staffDaysVC, animated: true)
//            }
//        }
    
//    private func fetchStaffData(from urlString: String, token: String, completion: @escaping ([Staff]) -> Void) {
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL: \(urlString)")
//            completion([])
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                print("Error fetching staff data: \(error.localizedDescription)")
//                completion([])
//                return
//            }
//
//            guard let data = data else {
//                print("No data received.")
//                completion([])
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let responseModel = try decoder.decode(StaffResponse.self, from: data)
//                completion(responseModel.data)
//            } catch {
//                print("Error decoding staff data: \(error.localizedDescription)")
//                completion([])
//            }
//        }.resume()
//    }
    
    private func navigateToStaffRegister() {
        let storyboard = UIStoryboard(name: "Staff", bundle: nil)
        guard let staffRegisterVC = storyboard.instantiateViewController(withIdentifier: "StaffRegister") as? StaffRegister else {
            print("Failed to instantiate StaffRegister view controller")
            return
        }
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
                switch self.featureIcon?.name {
                case "Student Diary":
                    self.navigateToStudentDiary(studentTeams: studentTeams)
                case "Student Register":
//                    self.navigateToStudentRegister(studentTeams: studentTeams)
                    self.studentTeams = studentTeams
                default:
                    print("No navigation configured for type: \(self.featureIcon?.name)")
                }
            }
        }
    
    private func navigateToStudentDiary(studentTeams: [StudentTeam]) {
            if currentRole == "teacher" || currentRole == "admin" {
                let storyboard = UIStoryboard(name: "Student1", bundle: nil)
                guard let studentDiaryVC = storyboard.instantiateViewController(withIdentifier: "StudentViewController1") as? StudentViewController1 else {
                    print("Failed to instantiate StudentViewController1")
                    return
                }

                studentDiaryVC.studentTeams = studentTeams
                studentDiaryVC.token = TokenManager.shared.getToken() ?? ""
                studentDiaryVC.groupIds = school?.id ?? ""
                studentDiaryVC.currentRole = self.currentRole

                self.navigationController?.pushViewController(studentDiaryVC, animated: true)

            } else if currentRole == "parent" {
                let storyboard = UIStoryboard(name: "Student1", bundle: nil)
                guard let studentDaysVC = storyboard.instantiateViewController(withIdentifier: "StudentDaysViewController") as? StudentDaysViewController else {
                    print("Failed to instantiate StudentDaysViewController")
                    return
                }

                let teamId = studentTeams.first?.teamId
                studentDaysVC.currentRole = self.currentRole
                studentDaysVC.studentTeams = studentTeams
                studentDaysVC.token = TokenManager.shared.getToken() ?? ""
                studentDaysVC.groupIds = school?.id ?? ""
                studentDaysVC.teamId = teamId ?? ""
                studentDaysVC.userId = self.userId
                print("✅ Navigating directly to StudentDaysViewController for student role with userId: \(self.userId)")
                print("✅ Navigating directly to StudentDaysViewController for student role with teamId: \(teamId)")
                navigationController?.pushViewController(studentDaysVC, animated: true)
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
    
    private func navigateToStudentRegister(groupClasses: [GroupClass]) {
           let storyboard = UIStoryboard(name: "Student", bundle: nil)
           guard let studentRegisterVC = storyboard.instantiateViewController(withIdentifier: "StudentViewController") as? StudentViewController else {
               print("Failed to instantiate StudentViewController")
               return
           }
        studentRegisterVC.groupClasses = groupClasses
           self.navigationController?.pushViewController(studentRegisterVC, animated: true)
       }
}
