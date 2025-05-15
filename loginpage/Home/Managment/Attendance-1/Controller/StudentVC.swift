import UIKit

class StudentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, StudentCellDelegate, EditAttendanceDelegate {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var studentTBL: UITableView!
    @IBOutlet weak var currDate: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    
    var studentID: String?
      var currentDatePicker: UIDatePicker?
      var groupId: String?
      var teamId: String?
      var selectedDate: Date?
      var currentDate: String?
      var className: String?
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTBL.register(UINib(nibName: "StudentVCTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentVCTableViewCell")
        studentTBL.dataSource = self
        studentTBL.delegate = self
        self.navigationItem.hidesBackButton = true

        DoneButton.layer.cornerRadius =  10
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        print("curDate: \(currentDate)")
        print("selected Date: \(selectedDate)")
        // Display the class name in the label
        name.text = className != nil ? "Attendance - (\(className!))" : "No Class Name"
        print("Received attendanceData no of numberOfTimeAttendance: \(selectedClassnumberOfTimeAttendance)")
        setCurrentDate()
        fetchStudentData()
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
            return
        }

        // Create a slide-in view
        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = 100
        let xStart = self.view.frame.width
        
        let menuView = UIView(frame: CGRect(x: xStart, y: 80, width: menuWidth, height: menuHeight)) // adjust y to fit your layout
        menuView.backgroundColor = UIColor.white
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowOffset = CGSize(width: -2, height: 2)
        menuView.layer.cornerRadius = 10
        menuView.tag = 1001

        // Add buttons
        let declareBtn = UIButton(frame: CGRect(x: 0, y: 0, width: menuWidth, height: 50))
        declareBtn.setTitle("Declare Holiday", for: .normal)
        declareBtn.setTitleColor(.black, for: .normal)
        declareBtn.addTarget(self, action: #selector(showDeclareHolidayAlert), for: .touchUpInside)
        
        let reportBtn = UIButton(frame: CGRect(x: 0, y: 50, width: menuWidth, height: 50))
        reportBtn.setTitle("Attendance Report", for: .normal)
        reportBtn.setTitleColor(.black, for: .normal)
        reportBtn.addTarget(self, action: #selector(showAttendanceReport), for: .touchUpInside)

        // Add to view
        menuView.addSubview(declareBtn)
        menuView.addSubview(reportBtn)
        self.view.addSubview(menuView)

        // Animate sliding in from right
        UIView.animate(withDuration: 0.3) {
            menuView.frame.origin.x = self.view.frame.width - menuWidth - 16 // Slide in
        }
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
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let absentVC = storyboard.instantiateViewController(withIdentifier: "AbsentStudentVC") as? AbsentStudentVC {
            absentVC.modalPresentationStyle = .custom
            absentVC.transitioningDelegate = self
            absentVC.absentList = uncheckedStudents
            absentVC.groupId = groupId
            absentVC.teamId = teamId
            absentVC.attendanceData = self.attendanceData
            absentVC.numberOfTimeAttendance = selectedClassnumberOfTimeAttendance
            absentVC.studentID = self.studentID
            absentVC.currDate = currDate.titleLabel?.text
            absentVC.currentDate = self.currentDate
            
            absentVC.uncheckedStudentsIds = self.uncheckedStudentsIds
            present(absentVC, animated: true, completion: nil)
        }
    }

    
    func didTapEditAttendance(status: String, attendanceId: String, userId: String) {
        // Call your API from the ViewController here
        editAttendance(status: status, attendanceId: attendanceId, userId: userId)
        print("Edit requested with status: \(status), id: \(attendanceId), user: \(userId)")
    }
    func editAttendance(status: String, attendanceId: String, userId: String) {
        let url = URL(string: "https://yourapi.com/update-attendance")!  // replace with your actual URL

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "attendance": status,
            "attendanceId": attendanceId,
            "userId": userId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }

            if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                print("✅ Response: \(responseStr)")
            }
        }

        task.resume()
    }

//    func editAttendance(attendance: String, attendanceId: String, userId: String) {
//        let groupId = "yourGroupId" // You should pass this dynamically or inject
//        let teamId = "yourTeamId"   // You should pass this dynamically or inject
//
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/edit"
//        
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL")
//            return
//        }
//        
//        guard let token = TokenManager.shared.getToken() else {
//            print("❌ Token not found")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let body: [String: Any] = [
//            "attendance": attendance,
//            "attendanceId": attendanceId,
//            "userId": userId
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//        } catch {
//            print("❌ Failed to encode body: \(error.localizedDescription)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Request failed: \(error.localizedDescription)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ No valid HTTP response")
//                return
//            }
//
//            if httpResponse.statusCode == 200 {
//                print("✅ Attendance updated successfully")
//            } else {
//                print("⚠️ Failed with status code: \(httpResponse.statusCode)")
//                if let data = data,
//                   let responseBody = String(data: data, encoding: .utf8) {
//                    print("📩 Response: \(responseBody)")
//                }
//                DispatchQueue.main.async {
//                    self.fetchStudentData() // Or reload UI
//                }
//            }
//        }.resume()
//    }


    func deleteAttendance(attendanceId: String) {
        print("attendance deletedd")
        guard let groupId = self.groupId,
              let teamId = self.teamId,
              let token = TokenManager.shared.getToken() else {
            print("❌ Missing groupId, teamId, or token")
            return
        }

        // Construct the URL
        let urlString = "\(APIManager.shared.baseURL)groups/\(groupId)/team/\(teamId)/attendance/\(attendanceId)/delete"
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
                    self.fetchStudentData() // Or reload UI
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
                    self.fetchStudentData() // Or reload UI
            
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

    
//    func didTapAttendanceStatus(for student: StudentAtten, at indexPath: IndexPath){
//        if let selectedStudent = selectedStud {
//            showEditAttendancePopup(for: selectedStudent)
//        } else {
//            print("selectedStud is nil. Cannot show attendance popup.")
//        }
//
//    }
    func didTapDeleteAttendance(attendanceId: String) {
        deleteAttendance(attendanceId: attendanceId)
    }
 func showEditAttendancePopup(for student: StudentAtten) {
       
        
     let selectedAttendance = self.studAtten
        
        if let popupView = EditAttendance.loadFromNib() {
//             Populate the popup with last attendance details for the selected cell
            popupView.attendanceStatus.text = selectedAttendance?.attendance ?? ""
            popupView.studentName.text = student.studentName
            popupView.teacherName.text = selectedAttendance?.teacherName ?? ""
            popupView.subject.text = selectedAttendance?.subjectName ?? ""
            popupView.periodNumber.text = "\(selectedAttendance?.periodNumber ?? 0)"
            popupView.date.text = selectedAttendance?.date ?? ""
            
            // Set delegate and pass attendanceId
            popupView.delegate = self
            popupView.attendanceId = selectedAttendance?.attendanceId

            // Add it to current view
            popupView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(popupView)

            NSLayoutConstraint.activate([
                popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                popupView.widthAnchor.constraint(equalToConstant: 293),
                popupView.heightAnchor.constraint(equalToConstant: 345)
            ])
            
            // Optional: Add a dimmed background
            view.bringSubviewToFront(popupView)
        }
    }



    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentVCTableViewCell", for: indexPath) as? StudentVCTableViewCell else {
//            return UITableViewCell()
//        }
//
//        let student = students[indexPath.row]
//        cell.delegate = self
//         
//
//        // Set student details
//        cell.studentName.text = student.studentName
//        cell.studentID = student.userId
//        cell.students = students
//        self.studentID = student.userId
//        cell.rollNo.text = "Roll No: \(student.rollNumber)"
//
//        // Load student image or show fallback
//        if let imageUrlString = student.studentImage,
//           !imageUrlString.isEmpty,
//           let imageUrl = URL(string: imageUrlString) {
//
//            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        cell.images.image = image
//                        cell.fallback.isHidden = true
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        cell.showFallbackImage(for: student.studentName)
//                        cell.fallback.isHidden = false
//                    }
//                }
//            }.resume()
//        } else {
//            cell.showFallbackImage(for: student.studentName)
//            cell.fallback.isHidden = false
//        }
//
//        // ✅ Configure Attendance Status Button (attenStatus) or hide it
//        if let lastAttendance = student.lastDaysAttendance.first {
//            cell.setAttendanceVisibility(isHidden: false)
//            cell.configureAttendanceStatus(attendance: lastAttendance.attendance!)
//        } else {
//            cell.setAttendanceVisibility(isHidden: true)
//        }
//
//        // Pass the numberOfTimeAttendance to the cell
//        if indexPath.row < attendanceData.count {
//            let attendance = attendanceData[indexPath.row]
//            if let numberOfTimes = Int(attendance.numberOfTimeAttendance) {
//                cell.configureAttendanceButtons(numberOfTimes: numberOfTimes)
//            }
//        }
//         
//         cell.attenStatus.addTarget(
//             self,
//             action: #selector(editButtonTapped(_:)),
//             for: .touchUpInside
//           )
//
//        return cell
//    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "StudentVCTableViewCell",
                for: indexPath
              ) as? StudentVCTableViewCell
        else {
            return UITableViewCell()
        }

        let student = students[indexPath.row]

        // MARK: – Pass context into the cell
        cell.indexPath     = indexPath
        cell.delegate      = self
        cell.students      = students
        cell.studentID     = student.userId
        cell.rollNo.text   = "Roll No: \(student.rollNumber)"
        cell.attendanceId  = nil  // clear first

        // If there's at least one attendance record, assign all of them
        if !student.lastDaysAttendance.isEmpty {
            // You can store the whole array and let the delegate choose later:
            cell.lastDaysAttendance = student.lastDaysAttendance
            
        }

        // MARK: – Image loading / fallback
        if let urlString = student.studentImage,
           let url = URL(string: urlString), !urlString.isEmpty {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.images.image    = img
                        cell.fallback.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.showFallbackImage(for: student.studentName)
                        cell.fallback.isHidden = false
                    }
                }
            }.resume()
        } else {
            cell.showFallbackImage(for: student.studentName)
            cell.fallback.isHidden = false
        }

        // MARK: – Attendance Status Button
        if let last = student.lastDaysAttendance.last {
            // show the button but don’t pick one here
            cell.setAttendanceVisibility(isHidden: false)
            cell.configureAttendanceStatus(attendance: last.attendance ?? "")
            // store the ID on the button tap
            cell.attendanceId = last.attendanceId
        } else {
            cell.setAttendanceVisibility(isHidden: true)
        }

        // MARK: – Checkbox buttons
        if indexPath.row < attendanceData.count {
            if let times = Int(attendanceData[indexPath.row].numberOfTimeAttendance) {
                cell.configureAttendanceButtons(numberOfTimes: times)
            }
        }
        
        cell.attenStatus.addTarget(
                   self,
                   action: #selector(editButtonTapped(_:)),
                   for: .touchUpInside
                 )
      
              return cell

        return cell
    }

    @objc private func editButtonTapped(_ sender: UIButton) {
      let row = sender.tag
      let indexPath = IndexPath(row: row, section: 0)
      // Manually forward to your delegate method:
        self.tableView(self.studentTBL, didSelectRowAt: indexPath)
        
        let selectedStudent = students[indexPath.row]
        self.selectedStud = selectedStudent

        // Safely get attendance data
        if let firstAttendance = selectedStudent.lastDaysAttendance.first {
            self.studAtten = firstAttendance
            self.attendenceId = firstAttendance.attendanceId
            print("📌 Selected attendanceId: \(firstAttendance.attendanceId ?? "nil")")
        } else {
            self.studAtten = nil
            self.attendenceId = nil
            print("⚠️ No attendanceId available for this student.")
        }

        // 💡 Now show popup safely
        showEditAttendancePopup(for: selectedStudent)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = students[indexPath.row]
        self.selectedStud = selectedStudent

        // Safely get attendance data
        if let firstAttendance = selectedStudent.lastDaysAttendance.first {
            self.studAtten = firstAttendance
            self.attendenceId = firstAttendance.attendanceId
            print("📌 Selected attendanceId: \(firstAttendance.attendanceId ?? "nil")")
        } else {
            self.studAtten = nil
            self.attendenceId = nil
            print("⚠️ No attendanceId available for this student.")
        }

        // 💡 Now show popup safely
//        showEditAttendancePopup(for: selectedStudent)
    }


    
    func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool) {
        // 🔍 Find the matching student object
        guard let student = students.first(where: { $0.studentName == studentName }) else {
            print("Student not found for name: \(studentName)")
            return
        }
        
        let studentId = student.userId  // ✅ Now it's in scope
        
        if isChecked {
            // ✅ Remove from unchecked list when reselected
            if let index = uncheckedStudents.firstIndex(of: studentName) {
                uncheckedStudents.remove(at: index)
            }
            if let index = uncheckedStudentsIds.firstIndex(of: studentId) {
                uncheckedStudentsIds.remove(at: index)
            }
        } else {
            // ✅ Add to unchecked list when deselected
            if !uncheckedStudents.contains(studentName), !uncheckedStudentsIds.contains(studentId)  {
                uncheckedStudents.append(studentName)
                uncheckedStudentsIds.append(studentId)
            }
        }

        print("Unchecked Students: \(uncheckedStudents)")
        print("Unchecked IDs: \(uncheckedStudentsIds)")
    }
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
            fetchStudentData()
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
            fetchStudentData()
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
            
            fetchStudentData() // Fetch data for the selected date
            
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
extension StudentVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return ThreeFourthPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
