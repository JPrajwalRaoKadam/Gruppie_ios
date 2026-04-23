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
    var uncheckedStudents: [String] = []
    var uncheckedStudentsIds: Set<String> = []
    var attendenceId: String?
    var selectedStud: StudentAtten?
    var studAtten: StudentAttendance?
    var selectedAttendanceId: String?
    var selectedUserId: String?
    private var dimmingView: UIView?
    private var popupView: EditAttendance?
    
    // Track if a toast is currently showing
    private var isShowingToast = false

    override func viewDidLoad() {
        super.viewDidLoad()
        printAttendanceSettings()
        print("classId: \(classId), className: \(className) ")
        studentTBL.register(UINib(nibName: "StudentVCTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentVCTableViewCell")
        studentTBL.dataSource = self
        studentTBL.delegate = self
        self.navigationItem.hidesBackButton = true

        studentTBL.layer.cornerRadius = 10
        DoneButton.layer.cornerRadius = 10
        midView.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        print("curDate: \(currentDate)")
        print("selected Date: \(selectedDate)")
        
        name.text = className != nil ? "Attendance - (\(className!))" : "No Class Name"
        print("Received attendanceData no of numberOfTimeAttendance: \(selectedClassnumberOfTimeAttendance)")
        
        self.groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId
        
        if fullAccess == false && roleName == "STUDENT" {
            fetchStudentListForStudent()
        } else {
            fetchMinimalStudentList()
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
    
    func resetAllCheckboxes() {
        uncheckedStudents.removeAll()
        uncheckedStudentsIds.removeAll()

        DispatchQueue.main.async {
            self.studentTBL.reloadData()
        }
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
        let headers = ["Authorization": "Bearer \(token)"]
        let queryParams = ["groupAcademicYearId": groupAcademicYearId]

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
    
    func fetchMinimalStudentList() {
        guard let token = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        guard let classId = classId,
              let groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not available from GroupAcademicYearResponse")
            return
        }

        let headers = ["Authorization": "Bearer \(token)"]
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
                if case .decodingError = error {
                    print("❌ Decoding failed - check your structs match the API response")
                }
            }
        }
    }
    
    func fetchAttendanceSessions() {
        guard let token = SessionManager.useRoleToken,
              let classId = classId,
              let groupAcademicYearId = groupAcademicYearId,
              let displayDate = currentDate else {
            print("❌ Missing params in fetchAttendanceSessions")
            return
        }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        guard let dateObj = inputFormatter.date(from: displayDate) else {
            print("❌ Date conversion failed")
            return
        }

        let apiDate = outputFormatter.string(from: dateObj)
        let headers = ["Authorization": "Bearer \(token)"]
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

        let headers = ["Authorization": "Bearer \(token)"]

        APIManager.shared.request(
            endpoint: "attendance-settings",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<ClassAttendanceSettingsResponse, APIManager.APIError>) in
            switch result {
            case .success(let response):
                self.classAttendanceSettings = response.data
                self.updateSelectedDayAttendanceInfo()
                print("✅ class name :", response.data.className)
                print("✅ settings count :", response.data.attendanceSettings.count)
                
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
    
    private func getSettingForSelectedDate() -> (attendanceSettingsId: String, sessionsPerDay: Int)? {
        guard let settings = classAttendanceSettings?.attendanceSettings,
              let dateString = currentDate,
              let weekday = weekDayString(from: dateString) else {
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
        if let existingView = self.view.viewWithTag(1001) {
            existingView.removeFromSuperview()
            self.view.viewWithTag(1000)?.removeFromSuperview()
            return
        }

        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = 100
        let xStart = self.view.frame.width

        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.tag = 1000
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenuView))
        backgroundView.addGestureRecognizer(tapGesture)
        self.view.addSubview(backgroundView)

        let menuView = UIView(frame: CGRect(x: xStart, y: 80, width: menuWidth, height: menuHeight))
        menuView.backgroundColor = .white
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowOffset = CGSize(width: -2, height: 2)
        menuView.layer.cornerRadius = 10
        menuView.tag = 1001

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

        UIView.animate(withDuration: 0.3) {
            menuView.frame.origin.x = self.view.frame.width - menuWidth - 16
        }
    }
    
    @objc func dismissMenuView() {
        self.view.viewWithTag(1001)?.removeFromSuperview()
        self.view.viewWithTag(1000)?.removeFromSuperview()
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
            self.markHoliday()
        }))

        self.present(alert, animated: true)
    }

    @objc func showAttendanceReport() {
        if let menu = self.view.viewWithTag(1001) {
            menu.removeFromSuperview()
        }
        print("Navigate to Attendance Report")
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        guard let setting = getSettingForSelectedDate() else {
            print("❌ No attendance setting for selected date")
            showToast(message: "No attendance setting for selected date")
            return
        }

        let allStudentIds = minimalStudents.map { $0.studentId }
        let checkedStudentIds = allStudentIds.filter {
            !uncheckedStudentsIds.contains($0)
        }

        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)

        if let absentVC = storyboard.instantiateViewController(
            withIdentifier: "AbsentStudentVC"
        ) as? AbsentStudentVC {
            
            absentVC.delegate = self
            absentVC.modalPresentationStyle = .custom
            absentVC.transitioningDelegate = self
            
            absentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            absentVC.classId = self.classId
            absentVC.absentList = uncheckedStudents
            absentVC.uncheckedStudentsIds = Array(uncheckedStudentsIds)
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
                DispatchQueue.main.async {
                    self.showToast(message: "Attendance updated successfully")
                    if self.fullAccess == false && self.roleName == "STUDENT" {
                        self.fetchStudentListForStudent()
                    } else {
                        self.fetchMinimalStudentList()
                    }
                }
            } else {
                print("⚠️ Failed with status code: \(httpResponse.statusCode)")
                if let data = data,
                   let responseBody = String(data: data, encoding: .utf8) {
                    print("📩 Response: \(responseBody)")
                }
            }
        }.resume()
    }

    func deleteAttendance(attendanceId: String) {
        print("attendance deleted")
        guard let groupId = self.groupId,
              let teamId = self.teamId,
              let token = TokenManager.shared.getToken() else {
            print("❌ Missing groupId, teamId, or token")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/\(attendanceId)/delete"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                DispatchQueue.main.async {
                    self.showToast(message: "Attendance deleted successfully")
                    if self.fullAccess == false && self.roleName == "STUDENT" {
                        self.fetchStudentListForStudent()
                    } else {
                        self.fetchMinimalStudentList()
                    }
                }
            } else {
                print("❌ Failed with status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }

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
                    self.showToast(message: "Holiday marked successfully")
                    if self.fullAccess == false && self.roleName == "STUDENT" {
                        self.fetchStudentListForStudent()
                    } else {
                        self.fetchMinimalStudentList()
                    }
                }
            } else {
                print("❌ Failed to mark holiday. Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.showToast(message: "Failed to mark holiday")
                }
            }
        }
        task.resume()
    }
    
    func didTapAttendanceStatus(for student: StudentAtten, at indexPath: IndexPath) {
        self.selectedStud = student
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
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.tag = 999
        view.addSubview(dimView)
        self.dimmingView = dimView

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

        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 293),
            popup.heightAnchor.constraint(equalToConstant: 171)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(tap)
        view.bringSubviewToFront(popup)
    }

    @objc private func dismissPopup() {
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
    
    func didUpdateUncheckedStudent(_ student: StudentMinimal, isChecked: Bool) {
        let id = student.studentId
        if isChecked {
            uncheckedStudentsIds.remove(id)
        } else {
            uncheckedStudentsIds.insert(id)
        }
        print("✅ Unchecked IDs:", uncheckedStudentsIds)
    }
    
    @IBAction func sendUncheckedStudents(_ sender: UIButton) {
        print("Sending unchecked students: \(uncheckedStudents)")
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
        showDatePickerPopup(for: sender as! UIButton)
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
                self.fetchStudentListForStudent()
            } else {
                self.fetchMinimalStudentList()
            }
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
                fetchStudentListForStudent()
            } else {
                fetchMinimalStudentList()
            }
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
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            
            currDate.setTitle(selectedDate, for: .normal)
            currentDate = selectedDate
            
            print("Selected Date: \(selectedDate)")
            if fullAccess == false && roleName == "STUDENT" {
                fetchStudentListForStudent()
            } else {
                fetchMinimalStudentList()
            }
            
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
            cell.checkButton.isHidden = true
            cell.images.image = nil
            cell.showFallbackImage(for: student.name)
            cell.fallback.isHidden = false
            cell.attenStatusStackView.isHidden = true
        } else {
            let student = minimalStudents[indexPath.row]
            cell.student = student
            cell.delegate = self
            let isChecked = !uncheckedStudentsIds.contains(student.studentId)
            cell.checkButton.isSelected = isChecked
            cell.studentName.text = student.fullName
            cell.rollNo.text = student.rollNumber?.isEmpty == false
                ? "Roll No: \(student.rollNumber!)"
                : "Roll No: -"
            cell.images.image = nil
            cell.showFallbackImage(for: student.fullName)
            cell.fallback.isHidden = false
            cell.attenStatusStackView.isHidden = true
        }
        return cell
    }
}

extension StudentVC: AttendanceSubmitDelegate {
    func didSubmitAttendanceSuccessfully() {
        showToast(message: "Attendance submitted successfully ✅")
        
        // Refresh data after successful submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.fullAccess == false && self.roleName == "STUDENT" {
                self.fetchStudentListForStudent()
            } else {
                self.fetchMinimalStudentList()
            }
        }
    }
    
    func showToast(message: String) {
        // Prevent multiple toasts from showing simultaneously
        guard !isShowingToast else { return }
        isShowingToast = true
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.alpha = 0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true

        let maxWidth = self.view.frame.size.width - 40
        let size = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        
        toastLabel.frame = CGRect(
            x: 20,
            y: self.view.frame.size.height - 100,
            width: maxWidth,
            height: size.height + 20
        )

        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
                self.isShowingToast = false
            }
        }
    }
}
