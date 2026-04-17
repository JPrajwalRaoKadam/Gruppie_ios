import UIKit

class StudentVC: UIViewController, StudentCellDelegate, EditAttendanceDelegate {
    
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var studentTBL: UITableView!
    @IBOutlet weak var currDate: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var threeDots: UIButton!
    
    var classId: String?
    var className: String?
    var fullAccess: Bool?
    var roleName: String?
    var minimalStudents: [StudentMinimal] = []
    var studentList: [StudentListItem] = []
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var attendanceSettingsResponse: AttendanceSettingsAllResponse?
    var attendanceSessions: [AttendanceSessionDetail] = []
    var groupAcademicYearId: String?
    var classAttendanceSettings: ClassAttendanceSettingsData?

    var studentID: String?
      var currentDatePicker: UIDatePicker?
      var groupId: String?
      var teamId: String?
      var selectedDate: Date?
      var currentDate: String?
      var students: [StudentAtten] = []
      var attendanceData: [Attendance] = []
      var selectedClassnumberOfTimeAttendance: Int?
      var uncheckedStudents: [String] = []  // ✅ Array to hold unchecked (absent) students
      var uncheckedStudentsIds: [String] = []
      var attendenceId: String?
      var selectedStud: StudentAtten?
      var studAtten: StudentAttendance?
      var selectedAttendanceId: String?
      var selectedUserId: String?
      private var dimmingView: UIView?
       private var popupView: EditAttendance?

    override func viewDidLoad() {
        super.viewDidLoad()
        printAttendanceSettings()
        print("classId: \(classId), className: \(className) ")
        studentTBL.register(UINib(nibName: "StudentVCTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentVCTableViewCell")
        studentTBL.dataSource = self
        studentTBL.delegate = self
        self.navigationItem.hidesBackButton = true

        studentTBL.layer.cornerRadius =  10
        DoneButton.layer.cornerRadius =  10
        midView.layer.cornerRadius =  10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        print("curDate: \(currentDate)")
        print("selected Date: \(selectedDate)")
        // Display the class name in the label
        name.text = className != nil ? "Attendance - (\(className!))" : "No Class Name"
        print("Received attendanceData no of numberOfTimeAttendance: \(selectedClassnumberOfTimeAttendance)")
        self.groupAcademicYearId =
            groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId
        
        if fullAccess == false && roleName == "STUDENT" {
            fetchStudentListForStudent()   // ✅ NEW API
        } else {
            fetchMinimalStudentList()      // ✅ OLD API
        }
        
        if fullAccess == false && roleName == "STUDENT" {
            DoneButton.isHidden = true
            threeDots.isHidden = true
        }

        setCurrentDate()
        enableKeyboardDismissOnTap()
        fetchClassAttendanceSettings()
        fetchAttendanceSessions()
        
    }
    // Add this method to StudentVC
    func resetAllCheckboxes() {
        // Clear the unchecked students arrays
        uncheckedStudents.removeAll()
        uncheckedStudentsIds.removeAll()
        
        // Reload the table view to reset all checkboxes to checked state
        DispatchQueue.main.async {
            self.studentTBL.reloadData()
        }
        
        print("✅ All checkboxes reset to checked state")
    }
    private func printAttendanceSettings() {

        guard let response = attendanceSettingsResponse else {
            print("❌ attendanceSettingsResponse is NIL in StudentVC")
            return
        }

        print("✅ AttendanceSettingsAllResponse received in StudentVC")
        dump(response)
    }
    
    func fetchStudentListForStudent() {

        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            return
        }

        guard let classId = classId,
              let groupAcademicYearId = groupAcademicYearId else {
            print("❌ Missing classId or groupAcademicYearId")
            return
        }

        let endpoint = "group-class/\(classId)/students"

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        let queryParams = [
            "groupAcademicYearId": groupAcademicYearId
        ]

        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<StudentListResponse, APIManager.APIError>) in

            switch result {

            case .success(let response):

                self.studentList = response.data
                print("✅ Student List:", response.data)

                DispatchQueue.main.async {
                    self.studentTBL.reloadData()
                }

            case .failure(let error):
                print("❌ Student list error:", error)
            }
        }
    }
    
//    func fetchMinimalStudentList() 
    func fetchMinimalStudentList() {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        guard let classId = classId,
                let groupAcademicYearId =
                        groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
                    print("❌ groupAcademicYearId not available from GroupAcademicYearResponse")
                    return
                }

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        let queryParams: [String: String] = [
            "classId": classId,
            "groupAcademicYearId": groupAcademicYearId,
            "page": "1",
            "limit": "50"
        ]

        APIManager.shared.request(
            endpoint: "student/minimal-list",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<StudentMinimalListResponse, APIManager.APIError>) in

            switch result {
            case .success(let response):
                self.minimalStudents = response.data.studentsList

                print("✅ class :", response.data.className)
                print("✅ total :", response.data.totalStudents)

                for s in self.minimalStudents {
                    print("Student :", s.fullName, " Roll :", s.rollNumber ?? "-")
                }

                DispatchQueue.main.async {
                    self.studentTBL.reloadData()
                }

            case .failure(let error):
                print("❌ minimal list error :", error)
                
                // Add more detailed error info
                if case .decodingError = error {
                    print("❌ Decoding failed - check your structs match the API response")
                    // You might want to print the raw response here if available
                }
            }
        }
    }
    
    func fetchAttendanceSessions() {

        guard let token = SessionManager.useRoleToken,
              let classId = classId,
              let groupAcademicYearId = groupAcademicYearId,   // ✅ cached value
              let displayDate = currentDate else {

            print("❌ Missing params in fetchAttendanceSessions")
            print("classId:", classId as Any)
            print("groupAcademicYearId:", groupAcademicYearId as Any)
            print("currentDate:", currentDate as Any)
            return
        }

        // Convert dd-MM-yyyy  ->  yyyy-MM-dd
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        guard let dateObj = inputFormatter.date(from: displayDate) else {
            print("❌ Date conversion failed")
            return
        }

        let apiDate = outputFormatter.string(from: dateObj)

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        let queryParams: [String: String] = [
            "groupAcademicYearId": groupAcademicYearId,
            "classId": classId,
            "sessionDate": apiDate
        ]

        APIManager.shared.request(
            endpoint: "attendance-sessions",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<AttendanceSessionsResponse, APIManager.APIError>) in

            switch result {

            case .success(let response):

                self.attendanceSessions = response.data.sessions

                print("✅ attendance sessions count :", self.attendanceSessions.count)

                for s in self.attendanceSessions {
                    print("Session:", s.sessionNumber,
                          "Subject:", s.subjectName,
                          "Marked by:", s.markedByName)
                }

            case .failure(let error):
                print("❌ attendance-sessions error :", error)
            }
        }
    }
    
    func fetchClassAttendanceSettings() {

        guard let token = SessionManager.useRoleToken,
              let classId = classId,
              let groupAcademicYearId = groupAcademicYearId else {

            print("❌ Missing params in fetchClassAttendanceSettings")
            return
        }

        let queryParams: [String: String] = [
            "groupAcademicYearId": groupAcademicYearId,
            "classId": classId,
            "page": "1",
            "limit": "10"
        ]

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        APIManager.shared.request(
            endpoint: "attendance-settings",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<ClassAttendanceSettingsResponse,
                            APIManager.APIError>) in

            switch result {

            case .success(let response):

                self.classAttendanceSettings = response.data
                self.updateSelectedDayAttendanceInfo()

                print("✅ class name :", response.data.className)
                print("✅ settings count :", response.data.attendanceSettings.count)

                // example debug
                for item in response.data.attendanceSettings {
                    print(item.dayOfWeek, item.sessionsPerDay)
                }

            case .failure(let error):
                print("❌ attendance-settings error :", error)
            }
        }
    }
    
    private func weekDayString(from dateString: String) -> String? {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"

        guard let date = formatter.date(from: dateString) else { return nil }

        let weekFormatter = DateFormatter()
        weekFormatter.locale = Locale(identifier: "en_US_POSIX")
        weekFormatter.dateFormat = "EEEE"

        return weekFormatter.string(from: date).uppercased()
    }
    

    private func getSettingForSelectedDate()
    -> (attendanceSettingsId: String, sessionsPerDay: Int)? {

        guard
            let settings = classAttendanceSettings?.attendanceSettings,
            let dateString = currentDate,
            let weekday = weekDayString(from: dateString)
        else {
            print("❌ Missing data for attendance setting lookup")
            return nil
        }

        guard let item = settings.first(where: {
            $0.dayOfWeek.uppercased() == weekday
        }) else {
            print("❌ No attendance setting for weekday:", weekday)
            return nil
        }

        return (item.attendanceSettingsId, item.sessionsPerDay)
    }
    
    private func updateSelectedDayAttendanceInfo() {

        guard let result = getSettingForSelectedDate() else { return }

        self.selectedAttendanceId = result.attendanceSettingsId
        self.selectedClassnumberOfTimeAttendance = result.sessionsPerDay

        print("✅ Selected attendanceSettingsId:", result.attendanceSettingsId)
        print("✅ Selected sessionsPerDay:", result.sessionsPerDay)
    }
    
    private func apiDateString() -> String? {

        guard let displayDate = currentDate else { return nil }

        let input = DateFormatter()
        input.dateFormat = "dd-MM-yyyy"

        let output = DateFormatter()
        output.dateFormat = "yyyy-MM-dd"

        guard let d = input.date(from: displayDate) else { return nil }
        return output.string(from: d)
    }
    
    
    let slideMenuView = UIView()
    let declareHolidayButton = UIButton(type: .system)
    let attendanceReportButton = UIButton(type: .system)

    func didTapAttendanceStatu(attendanceId: String) {
        print("Tapped attendance with ID:", attendanceId)
    }

    @IBAction func addMoreButtonTapped(_ sender: Any) {
        // Remove if already shown
        if let existingView = self.view.viewWithTag(1001) {
            existingView.removeFromSuperview()
            self.view.viewWithTag(1000)?.removeFromSuperview() // also remove background
            return
        }

        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = 100
        let xStart = self.view.frame.width

        // 🔹 Transparent background to detect taps outside
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.tag = 1000
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenuView))
        backgroundView.addGestureRecognizer(tapGesture)
        self.view.addSubview(backgroundView)

        // 🔹 Slide-in menu view
        let menuView = UIView(frame: CGRect(x: xStart, y: 80, width: menuWidth, height: menuHeight))
        menuView.backgroundColor = .white
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowOffset = CGSize(width: -2, height: 2)
        menuView.layer.cornerRadius = 10
        menuView.tag = 1001

        // Buttons
        let declareBtn = UIButton(frame: CGRect(x: 0, y: 0, width: menuWidth, height: 50))
        declareBtn.setTitle("Declare Holiday", for: .normal)
        declareBtn.setTitleColor(.black, for: .normal)
        declareBtn.addTarget(self, action: #selector(showDeclareHolidayAlert), for: .touchUpInside)

        let reportBtn = UIButton(frame: CGRect(x: 0, y: 50, width: menuWidth, height: 50))
        reportBtn.setTitle("Attendance Report", for: .normal)
        reportBtn.setTitleColor(.black, for: .normal)
        reportBtn.addTarget(self, action: #selector(showAttendanceReport), for: .touchUpInside)

        menuView.addSubview(declareBtn)
        menuView.addSubview(reportBtn)
        self.view.addSubview(menuView)

        // Slide in animation
        UIView.animate(withDuration: 0.3) {
            menuView.frame.origin.x = self.view.frame.width - menuWidth - 16
        }
    }
    @objc func dismissMenuView() {
        self.view.viewWithTag(1001)?.removeFromSuperview() // Menu view
        self.view.viewWithTag(1000)?.removeFromSuperview() // Background view
    }

    @objc func showDeclareHolidayAlert() {
        if let menu = self.view.viewWithTag(1001) {
            menu.removeFromSuperview()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let date = selectedDate ?? Date()
        let dateString = formatter.string(from: date)

        let alert = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to declare a holiday on \(dateString)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            print("Holiday declared on \(dateString)")
            // Call your API here
            //self.markHoliday()
        }))

        self.present(alert, animated: true)
    }

    @objc func showAttendanceReport() {
        if let menu = self.view.viewWithTag(1001) {
            menu.removeFromSuperview()
        }
        print("Navigate to Attendance Report")
    }

//    @IBAction func doneButton(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
//        if let absentVC = storyboard.instantiateViewController(withIdentifier: "AbsentStudentVC") as? AbsentStudentVC {
//            absentVC.modalPresentationStyle = .custom
//            absentVC.transitioningDelegate = self
//            absentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
//            absentVC.classId = self.classId
//            
//            absentVC.absentList = uncheckedStudents
//            absentVC.groupId = groupId
//            absentVC.teamId = teamId
//            absentVC.attendanceData = self.attendanceData
//            absentVC.numberOfTimeAttendance = selectedClassnumberOfTimeAttendance
//            absentVC.studentID = self.studentID
//            absentVC.currDate = currDate.titleLabel?.text
//            absentVC.currentDate = self.currentDate
//            
//            absentVC.uncheckedStudentsIds = self.uncheckedStudentsIds
//            present(absentVC, animated: true, completion: nil)
//        }
//    }
     @IBAction func doneButton(_ sender: UIButton) {
        
        guard let setting = getSettingForSelectedDate() else {
            print("❌ No attendance setting for selected date")
            return
        }

        // ✅ all students ids from current screen
        let allStudentIds = minimalStudents.map { $0.studentId }

        // ✅ checked = all - unchecked
        let checkedStudentIds = allStudentIds.filter {
            !uncheckedStudentsIds.contains($0)
        }

        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)

        if let absentVC = storyboard.instantiateViewController(
            withIdentifier: "AbsentStudentVC"
        ) as? AbsentStudentVC {

            absentVC.modalPresentationStyle = .custom
            absentVC.transitioningDelegate = self

            absentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            absentVC.classId = self.classId

            // already passing
            absentVC.absentList = uncheckedStudents
            absentVC.uncheckedStudentsIds = uncheckedStudentsIds

            // ✅ NEW – pass checked students ids
            absentVC.presentStudentIds = checkedStudentIds

            absentVC.numberOfTimeAttendance = setting.sessionsPerDay
            absentVC.attendanceSettingsId = setting.attendanceSettingsId
            absentVC.groupAcademicYearId = self.groupAcademicYearId
            absentVC.sessionDate = self.currentDate

            print("✅ checked student ids :", checkedStudentIds)

            present(absentVC, animated: true)
        }
    }

    func didTapEditAttendance(status: String, attendanceId: String, userId: String) {
        // Call your API from the ViewController here
        
        //editAttendance(attendance: status, attendanceId: attendanceId, userId: userId)
        print("Edit requested with status: \(status), id: \(attendanceId), user: \(userId)")
        dismissPopup()
    }

    func editAttendance(attendance: String, attendanceId: String, userId: String) {
        guard let groupId = self.groupId,
              let teamId = self.teamId else {
                  print("❌ Missing groupId, teamId")
                  return
              }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/edit"
        print("edit atten api::::::\(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "attendance": attendance,
            "attendanceId": attendanceId,
            "userId": userId
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
            
            // 🔍 Print the body as a JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Final JSON Body:\n\(jsonString)")
            }
            
            request.httpBody = jsonData
        } catch {
            print("❌ Failed to encode body: \(error.localizedDescription)")
            return
        }


        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No valid HTTP response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Attendance updated successfully")
            } else {
                print("⚠️ Failed with status code: \(httpResponse.statusCode)")
                if let data = data,
                   let responseBody = String(data: data, encoding: .utf8) {
                    print("📩 Response: \(responseBody)")
                }
                DispatchQueue.main.async {
                    //self.fetchMinimalStudentList() // Or reload UI
                    if self.fullAccess == false && self.roleName == "STUDENT" {
                        self.fetchStudentListForStudent()   // ✅ NEW API
                    } else {
                        self.fetchMinimalStudentList()      // ✅ OLD API
                    }
                }
            }
        }.resume()
    }


    func deleteAttendance(attendanceId: String) {
        print("attendance deletedd")
        guard let groupId = self.groupId,
              let teamId = self.teamId,
              let token = TokenManager.shared.getToken() else {
            print("❌ Missing groupId, teamId, or token")
            return
        }

        // Construct the URL
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/\(attendanceId)/delete"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Optional: Add a request body if required (not needed in this case)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error making PUT request: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Attendance successfully deleted")
                // Optionally refresh data on main thread
                DispatchQueue.main.async {
                   // self. fetchMinimalStudentList() // Or reload UI
                }
            } else {
                print("❌ Failed with status code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }

    // ✅ Fetch student data from API
    func fetchStudentData() {
        guard let groupId = groupId, let teamId = teamId, let date = currentDate else {
            print("❌ Missing parameters")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/get/new?date=\(date)"
        print("url\(urlString)")
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching student data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Invalid response from server")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("🔹 Raw Response os student: \(rawResponse)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let response = try decoder.decode(StudentResponse.self, from: data)
                self.students = response.data
                
                DispatchQueue.main.async {
                    self.studentTBL.reloadData()
                }
                
            } catch {
                print("❌ Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    func markHoliday() {
        // Use selectedDate if available, else default to today's date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let dateToSend = selectedDate ?? Date()
        let formattedDate = dateFormatter.string(from: dateToSend)

        guard let groupId = groupId, let teamId = teamId else {
            print("❌ Missing groupId or teamId")
            return
        }

        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }

        // Constructing POST URL with formatted date
        let urlString = "\(APIManager.shared.baseURL)groups/\(groupId)/team/\(teamId)/attendance/holiday/add?date=\(formattedDate)"
        print("📡 URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Assuming no body is needed. If needed, add a body dictionary and JSON encode it here.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                return
            }

            print("📥 Response Code: \(httpResponse.statusCode)")

            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("🔹 Response Body: \(rawResponse)")
            }

            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if self.fullAccess == false && self.roleName == "STUDENT" {
                        self.fetchStudentListForStudent()   // ✅ NEW API
                    } else {
                        self.fetchMinimalStudentList()      // ✅ OLD API
                    }
            
                    print("✅ Holiday marked successfully")
                    // You can show success alert or reload data if needed
                }
            } else {
                print("❌ Failed to mark holiday. Status Code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }
    
    func didTapAttendanceStatus(for student: StudentAtten, at indexPath: IndexPath) {
        self.selectedStud = student

        // Example: pick latest attendance with non-nil attendanceId
        if let validAttendance = student.lastDaysAttendance.last(where: { $0.attendanceId != nil }) {
            self.studAtten = validAttendance
            self.attendenceId = validAttendance.attendanceId
            print("📌 Selected attendanceId: \(validAttendance.attendanceId ?? "nil")")
        } else {
            self.studAtten = nil
            self.attendenceId = nil
            print("⚠️ No valid attendanceId found.")
        }

        showEditAttendancePopup(for: student)
    }

    func didTapDeleteAttendance(attendanceId: String) {
       // deleteAttendance(attendanceId: attendanceId)
    }
    
    func showEditAttendancePopup(for student: StudentAtten) {
        // 1️⃣ Create and add the dimming view
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.tag = 999  // for easy removal
        view.addSubview(dimView)
        self.dimmingView = dimView

        // 2️⃣ Load and configure your popup
        guard let popup = EditAttendance.loadFromNib() else { return }
        popup.delegate = self
        popup.configure(
            studentName: student.studentName,
            attendanceId: studAtten?.attendanceId ?? "",
            userId: student.userId ?? "",
            status: studAtten?.attendance ?? ""
        )
        popup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popup)
        self.popupView = popup

        // 3️⃣ Center it with Auto Layout
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 293),
            popup.heightAnchor.constraint(equalToConstant: 171)
        ])

        // 4️⃣ Add tap‐to‐dismiss (outside the popup)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(tap)

        // Bring popup above the dimming view
        view.bringSubviewToFront(popup)
    }

    @objc private func dismissPopup() {
        // Remove popup and dimming view
        popupView?.removeFromSuperview()
        dimmingView?.removeFromSuperview()
        popupView = nil
        dimmingView = nil
    }

    @objc private func handleOutsideTap(_ sender: UITapGestureRecognizer) {
        for subview in view.subviews {
            if let popup = subview as? EditAttendance {
                let location = sender.location(in: popup)
                if !popup.bounds.contains(location) {
                    popup.removeFromSuperview()
                }
            }
        }
    }

   
//    @objc private func editButtonTapped(_ sender: UIButton) {
//      let row = sender.tag
//      let indexPath = IndexPath(row: row, section: 0)
//      // Manually forward to your delegate method:
//        self.tableView(self.studentTBL, didSelectRowAt: indexPath)
//        
//        let selectedStudent = students[indexPath.row]
//        self.selectedStud = selectedStudent
//
//        // Safely get attendance data
//        if let firstAttendance = selectedStudent.lastDaysAttendance.first {
//            self.studAtten = firstAttendance
//            self.attendenceId = firstAttendance.attendanceId
//            print("📌 Selected attendanceId: \(firstAttendance.attendanceId ?? "nil")")
//        } else {
//            self.studAtten = nil
//            self.attendenceId = nil
//            print("⚠️ No attendanceId available for this student.")
//        }
//
//        // 💡 Now show popup safely
//        showEditAttendancePopup(for: selectedStudent)
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedStudent = students[indexPath.row]
//       // DoneButton.isHidden = selected.hasHolidayAttendance
//        DoneButton.isHidden = selectedStudent.hasHolidayAttendance
//        self.selectedStud = selectedStudent
//
//        // Safely get attendance data
//        if let firstAttendance = selectedStudent.lastDaysAttendance.first {
//            self.studAtten = firstAttendance
//            self.attendenceId = firstAttendance.attendanceId
//            print("📌 Selected attendanceId: \(firstAttendance.attendanceId ?? "nil")")
//        } else {
//            self.studAtten = nil
//            self.attendenceId = nil
//            print("⚠️ No attendanceId available for this student.")
//        }
//    }
    func didUpdateUncheckedStudent(_ student: StudentMinimal, isChecked: Bool) {

        let name = student.fullName
        let id   = student.studentId

        if isChecked {

            if let index = uncheckedStudents.firstIndex(of: name) {
                uncheckedStudents.remove(at: index)
            }

            if let index = uncheckedStudentsIds.firstIndex(of: id) {
                uncheckedStudentsIds.remove(at: index)
            }

        } else {

            if !uncheckedStudents.contains(name) {
                uncheckedStudents.append(name)
            }

            if !uncheckedStudentsIds.contains(id) {
                uncheckedStudentsIds.append(id)
            }
        }

        print("✅ Unchecked names :", uncheckedStudents)
        print("✅ Unchecked ids   :", uncheckedStudentsIds)
    }
//    func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool) {
//        // 🔍 Find the matching student object
//        guard let student = students.first(where: { $0.studentName == studentName }) else {
//            print("Student not found for name: \(studentName)")
//            return
//        }
//        
//        let studentId = student.userId  // ✅ Now it's in scope
//        
//        if isChecked {
//            // ✅ Remove from unchecked list when reselected
//            if let index = uncheckedStudents.firstIndex(of: studentName) {
//                uncheckedStudents.remove(at: index)
//            }
//            if let index = uncheckedStudentsIds.firstIndex(of: studentId) {
//                uncheckedStudentsIds.remove(at: index)
//            }
//        } else {
//            // ✅ Add to unchecked list when deselected
//            if !uncheckedStudents.contains(studentName), !uncheckedStudentsIds.contains(studentId)  {
//                uncheckedStudents.append(studentName)
//                uncheckedStudentsIds.append(studentId)
//            }
//        }
//
//        print("Unchecked Students: \(uncheckedStudents)")
//        print("Unchecked IDs: \(uncheckedStudentsIds)")
//    }
        @IBAction func sendUncheckedStudents(_ sender: UIButton) {
            print("Sending unchecked students: \(uncheckedStudents)")
            // Here you can send the uncheckedStudents array to your API or perform any action
        }
    
    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        currDate.setTitle(self.currentDate, for: .normal)
        print("Current Date: \(currentDate)")
    }
   
    @IBAction func date(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton) // Call the date picker function
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func previouseDate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let current = dateFormatter.date(from: currentDate ?? "") else { return }
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: current) {
            selectedDate = previousDay
            currentDate = dateFormatter.string(from: previousDay)
            currDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            if self.fullAccess == false && self.roleName == "STUDENT" {
                self.fetchStudentListForStudent()   // ✅ NEW API
            } else {
                self.fetchMinimalStudentList()      // ✅ OLD API
            }
           // fetchStudentData()
        }
    }
    @IBAction func nextDate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let current = dateFormatter.date(from: currentDate ?? "") else { return }
        let todayDate = Date()
        
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: current),
           nextDay <= todayDate {
            selectedDate = nextDay
            currentDate = dateFormatter.string(from: nextDay)
            currDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            if fullAccess == false && roleName == "STUDENT" {
                fetchStudentListForStudent()   // ✅ NEW API
            } else {
                fetchMinimalStudentList()      // ✅ OLD API
            }
           // fetchStudentData()
        } else {
            print("Cannot go beyond today's date")
        }
    }
    func showDatePickerPopup(for button: UIButton) {
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)
        
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        currDate = button
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy" // Format matching your API
            let selectedDate = formatter.string(from: datePicker.date)
            
            currDate.setTitle(selectedDate, for: .normal) // Update button title
            currentDate = selectedDate // Update selected date
            
            
            print("Selected Date: \(selectedDate)")
            if fullAccess == false && roleName == "STUDENT" {
                fetchStudentListForStudent()   // ✅ NEW API
            } else {
                fetchMinimalStudentList()      // ✅ OLD API
            }
            
           // fetchStudentData() // Fetch data for the selected date
            
            if let backgroundView = sender.superview?.superview {
                backgroundView.removeFromSuperview()
            }
        }
    }
    @objc func datePickerCancelPressed(_ sender: UIButton) {
        if let backgroundView = sender.superview?.superview {
            backgroundView.removeFromSuperview()
        }
    }
    
    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }
}
extension StudentVC: UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return ThreeFourthPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fullAccess == false && roleName == "STUDENT" {
               return studentList.count
           } else {
               return minimalStudents.count
           }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "StudentVCTableViewCell",
            for: indexPath
        ) as? StudentVCTableViewCell else {
            return UITableViewCell()
        }

        if fullAccess == false && roleName == "STUDENT" {

            let student = studentList[indexPath.row]

            cell.studentName.text = student.name
            cell.rollNo.text = "Class: \(student.className)"

            cell.images.image = nil
            cell.showFallbackImage(for: student.name)
            cell.fallback.isHidden = false

            cell.attenStatusStackView.isHidden = true

        } else {

            let student = minimalStudents[indexPath.row]

            cell.studentName.text = student.fullName

            if let roll = student.rollNumber, !roll.isEmpty {
                cell.rollNo.text = "Roll No: \(roll)"
            } else {
                cell.rollNo.text = "Roll No: -"
            }

            cell.images.image = nil
            cell.showFallbackImage(for: student.fullName)
            cell.fallback.isHidden = false

            cell.attenStatusStackView.isHidden = true
        }

        return cell
    }


}
