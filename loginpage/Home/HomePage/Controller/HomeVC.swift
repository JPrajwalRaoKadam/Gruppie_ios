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
        tableView.register(UINib(nibName: "BannerAndProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "BannerAndProfileTableViewCell")
        tableView.register(UINib(nibName: "AllIconsTableViewCell", bundle: nil), forCellReuseIdentifier: "AllIconsTableViewCell")
        
        CustomTabManager.shared.delegate = self
        CustomTabManager.shared.hDelegate = self
        CustomTabManager.shared.mDelegate = self
        // Print the image URLs to verify their content
        print("Image URLs: \(imageUrls)")
        
        for activity in self.groupDatas {
            print("Received Activity: \(activity.activity)")
            for featureIcon in activity.featureIcons {
                print("Received Feature Icon Type: \(featureIcon.type), Image: \(featureIcon.image)")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Display 1 row in section 0
        } else if section == 1 {
            print("Group data items: \(groupDatas.count)")
            return groupDatas.count // Display rows based on groupDatas count
        }
        return 0 // Default case for other sections (if any)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Configure the first cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAndProfileTableViewCell", for: indexPath) as! BannerAndProfileTableViewCell
            cell.imageUrls = imageUrls // Pass the imageUrls to the cell
            cell.configureBannerImage(at: 0) // Load the first image
            print("Image URLs in first cell: \(imageUrls)")
            cell.Profile.text = name // Set the profile name
            
            if let name = name {
                cell.Profile.isHidden = false
                cell.heightConstraintofAdminLabel.constant = 61
            } else {
                cell.Profile.isHidden = true
                cell.heightConstraintofAdminLabel.constant = 0
            }
            
            return cell
        } else if indexPath.section == 1 {
            let allIconCell = tableView.dequeueReusableCell(withIdentifier: "AllIconsTableViewCell", for: indexPath) as! AllIconsTableViewCell
            allIconCell.delegate = self // Set the delegate
            allIconCell.configureActivityNames(indexPath: indexPath, activity: groupDatas)
            self.indexPath = indexPath
            return allIconCell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedActivity = groupDatas[indexPath.row]
            print("Selected activity: \(selectedActivity.activity)")
            
            if selectedActivity.activity == "Other Activities" {
                navigateToCalendarViewController()
            } else {
                print("No navigation configured for type: \(selectedActivity.activity)")
            }
        }
    }
    
    func didSelectIcon(_ featureIcon: FeatureIcon) {
        self.featureIcon = featureIcon
        switch featureIcon.type {
        case "Calendar":
            navigateToCalendarViewController()
        case "Management Register":
            navigateToMangementViewController()
        case "Staff Register":
            fetchStaffDataAndNavigate()
        case "Feed Back": // New case for Feedback navigation
            navigateToFeedBackViewController()
        case "Student Register":
            fetchStudentDataAndNavigate()
        case "Subject Register":
            fetchSubjectDataAndNavigate()
        case "Hostel":
            fetchSubjectDataAndNavigate()
        case "Gallery":
            navigateToGalleryViewController()
        case "Fees New":
            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
            guard let payVC = storyboard.instantiateViewController(withIdentifier: "PaymentClassListingVC") as? PaymentClassListingVC else {
                print("ViewController with identifier 'PaymentClassListingVC' not found.")
                return
            }
            payVC.groupId = school?.id ?? ""
            self.navigationController?.pushViewController(payVC, animated: true)
        default:
            print("No navigation configured for type: \(featureIcon.type)")
        }
    }
    
    func navigateToFeedBackViewController() {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "FeedBackViewController") as? FeedBackViewController {
            feedbackVC.groupId = school?.id ?? ""
            feedbackVC.token = TokenManager.shared.getToken() ?? ""
            
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
        guard let token = TokenManager.shared.getToken(), !token.isEmpty,
              let groupId = school?.id, !groupId.isEmpty else {
            print("❌ Token or Group ID is missing")
            return
        }
        
        let subjectURL = APIManager.shared.baseURL + "groups/\(groupId)/class/get"
        print("📜 Request URL: \(subjectURL)") // Print the final URL
        
        let dispatchGroup = DispatchGroup()
        var subjects: [SubjectData] = []
        var teamIds: [String] = [] // Store multiple teamIds
        
        dispatchGroup.enter()
        fetchSubjectData(from: subjectURL, token: token) { fetchedSubjects, fetchedTeamIds in
            subjects = fetchedSubjects
            teamIds = fetchedTeamIds // Store all teamIds
            
            print("📚 Total subjects fetched: \(subjects.count)") // Print count in console
            print("🆔 Fetched Team IDs: \(teamIds)") // Print all teamIds in console
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("🚀 Navigating to SubjectViewController with Team IDs: \(teamIds)")
            switch self.featureIcon?.type {
            case "Subject Register":
                self.navigateToSubjectRegister(subjects: subjects, teamIds: teamIds)
            case "Hostel":
                self.navigateToMarksCard(subjects: subjects, teamIds: teamIds)
            default:
                print("No navigation configured for type: \(self.featureIcon?.type)")
                
            }
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
        
        print("✅ Passing Team IDs to SubjectViewController: \(teamIds)")
        print("✅ Passing Group ID to SubjectViewController: \(MarksCardVC.groupId)") // Fix: Use subjectRegisterVC.groupId
        
        self.navigationController?.pushViewController(MarksCardVC, animated: true)
    }
    
    func navigateToCalendarViewController() {
        let storyboard = UIStoryboard(name: "calender", bundle: nil)
        if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalenderViewController") as? CalenderViewController {
            calendarVC.groupId = school?.id ?? ""
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
        
        managementVC.modalPresentationStyle = .fullScreen
        present(managementVC, animated: true, completion: nil)
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
            self.navigateToStaffRegister(teachingStaff: teachingStaff)
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
