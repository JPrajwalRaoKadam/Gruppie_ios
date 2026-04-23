//
//  AttendanceVC.swift
//  loginpage
//
//  Created by apple on 10/02/25.
//

import UIKit

class AttendanceVC: UIViewController {
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var midview: UIView!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var curDate: UIButton!
    
    var groupClasses: [GroupClass] = []
    var groupClassesforStudent: [GroupClass1] = []
    var roleName: String?
    var fullAccess: Bool?
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var attendanceSettingsResponse: AttendanceSettingsAllResponse?
    var groupAcademicYearId: String?
    var attendanceClasses: [AttendanceClassSummary] = []
    var currentDatePicker: UIDatePicker?
    var currentDate: String?
    
    // Track if view is appearing for the first time
    private var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup that only needs to happen once
        setupUI()
        setupTableView()
        setCurrentDate()
        
        // Load data for the first time
        loadAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data when coming back from other VCs (unless it's first load)
        if !isFirstLoad {
            print("🔄 Coming back from another VC - Reloading data")
            loadAllData()
        }
        isFirstLoad = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        midview.layer.cornerRadius = 10
        TableView.layer.cornerRadius = 10
        self.navigationItem.hidesBackButton = true
        
        if let response = groupAcademicYearResponse {
            print("✅ groupAcademicYearResponse received")
            print("roleName in attendancevc\(roleName),  fullAccess: \(fullAccess)")
            print("Group name :", response.data.groupInfo.groupName)
            print("Short name :", response.data.groupInfo.shortName)
            print("Academic years count :", response.data.academicYears.count)
            
            for year in response.data.academicYears {
                print("Year :", year.academicLabel,
                      "ID :", year.groupAcademicYearId)
            }
        } else {
            print("❌ groupAcademicYearResponse is nil")
        }
    }
    
    private func setupTableView() {
        TableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        TableView.dataSource = self
        TableView.delegate = self
        TableView.layer.masksToBounds = true
    }
    
    // MARK: - Data Loading Methods
    private func loadAllData() {
        enableKeyboardDismissOnTap()
        
        let group = DispatchGroup()
        
        if fullAccess == false && roleName == "STUDENT" {
            group.enter()
            fetchStudentClasses {
                group.leave()
            }
        } else {
            group.enter()
            fetchAttendanceData {
                group.leave()
            }
        }
        
        group.enter()
        fetchAttendanceSettingsAll {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            print("✅ All APIs completed")
            self?.TableView.reloadData()
        }
    }
    
    func fetchStudentClasses(completion: @escaping () -> Void) {
        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Token missing")
            completion()
            return
        }
        
        guard let groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId missing")
            completion()
            return
        }
        
        let headers = ["Authorization": "Bearer \(roleToken)"]
        let queryParams = ["groupAcademicYearId": groupAcademicYearId]
        
        APIManager.shared.request(
            endpoint: "group-class/user-classes",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<StudentClassResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                print("✅ Student Classes loaded - Count: \(response.data.count)")
                self.groupClassesforStudent = response.data
                
            case .failure(let error):
                print("❌ Error fetching student classes: \(error)")
                // Keep existing data if API fails
            }
            
            completion()
        }
    }
    
    func fetchAttendanceData(completion: @escaping () -> Void) {
        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            completion()
            return
        }
        
        guard let groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not available")
            completion()
            return
        }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selected = currentDate,
              let date = inputFormatter.date(from: selected) else {
            print("Invalid date")
            completion()
            return
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        let apiDate = outputFormatter.string(from: date)
        
        let headers = ["Authorization": "Bearer \(roleToken)"]
        
        let queryParams = [
            "groupAcademicYearId": groupAcademicYearId,
            "sessionDate": apiDate
        ]
        
        APIManager.shared.request(
            endpoint: "attendance-summary",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<AttendanceSummaryResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                print("✅ Attendance data loaded - Classes count: \(response.data.classes.count)")
                self.attendanceClasses = response.data.classes
                self.groupAcademicYearId = response.data.groupAcademicYearId
                
                print("Academic Year    :", response.data.groupAcademicYearId)
                print("Success :", response.success)
                print("Message :", response.message)
                print("Date :", response.data.date)
                
                for item in response.data.classes {
                    print("ClassId :", item.classId)
                    print("ClassName :", item.className)
                    print("Total Students :", item.totalStudents)
                    print("Sessions count :", item.sessions.count)
                    print("--------------")
                }
                
            case .failure(let error):
                print("❌ Attendance summary error: \(error)")
                // Keep existing data if API fails
            }
            
            completion()
        }
    }
    
    func fetchAttendanceSettingsAll(completion: @escaping () -> Void) {
        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            completion()
            return
        }
        
        guard let groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not found")
            completion()
            return
        }
        
        let headers = ["Authorization": "Bearer \(roleToken)"]
        
        let queryParams = [
            "groupAcademicYearId": groupAcademicYearId,
            "page": "1",
            "limit": "20"
        ]
        
        APIManager.shared.request(
            endpoint: "attendance-settings-all",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<AttendanceSettingsAllResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                print("✅ Attendance settings loaded - Classes count: \(response.data.count)")
                self.attendanceSettingsResponse = response
                
            case .failure(let error):
                print("❌ Attendance settings error: \(error)")
                // Keep existing data if API fails
            }
            
            completion()
        }
    }
    
    // MARK: - Helper Methods
    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        curDate.setTitle(self.currentDate, for: .normal)
        print("Current Date: \(currentDate)")
    }
    
    private func refreshDataForCurrentDate() {
        print("Refreshing data for date: \(currentDate ?? "nil")")
        
        if fullAccess == false && roleName == "STUDENT" {
            fetchStudentClasses {
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
            }
        } else {
            fetchAttendanceData {
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Setting(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "AttenSettingVC") as? AttenSettingVC {
            self.navigationController?.pushViewController(settingsVC, animated: true)
        } else {
            print("Failed to instantiate AttenSettingVC")
        }
    }
    
    @IBAction func nextDate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        let todayDate = Date()
        
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
           nextDay <= todayDate {
            currentDate = dateFormatter.string(from: nextDay)
            curDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            refreshDataForCurrentDate()
        } else {
            print("Cannot go beyond today's date")
            showToast(message: "Cannot go beyond today's date")
        }
    }
    
    @IBAction func previousDate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            currentDate = dateFormatter.string(from: previousDay)
            curDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            refreshDataForCurrentDate()
        }
    }
    
    @IBAction func curDate(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton)
    }
    
    // MARK: - Date Picker Methods
    func showDatePickerPopup(for button: UIButton) {
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.tag = 999
        
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
        
        curDate = button
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            
            curDate.setTitle(selectedDate, for: .normal)
            currentDate = selectedDate
            
            print("Selected Date: \(selectedDate)")
            refreshDataForCurrentDate()
            
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
    
    // MARK: - Toast Message
    func showToast(message: String) {
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
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AttendanceVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fullAccess == false && roleName == "STUDENT" {
            return groupClassesforStudent.count
        } else {
            return attendanceClasses.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AttendanceTableViewCell",
            for: indexPath
        ) as! AttendanceTableViewCell
        
        if fullAccess == false && roleName == "STUDENT" {
            let item = groupClassesforStudent[indexPath.row]
            cell.classLabel.text = item.name
            cell.periodLabel.text = ""
            cell.img.image = nil
            cell.fallbackLabel.isHidden = false
            cell.showFallbackImage(for: item.name)
        } else {
            let item = attendanceClasses[indexPath.row]
            cell.classLabel.text = item.className
            
            if item.sessions.isEmpty {
                cell.periodLabel.text = ""
            } else {
                let periodText = item.sessions
                    .sorted { $0.sessionNumber < $1.sessionNumber }
                    .map { session in
                        "P\(session.sessionNumber): \(session.presentStudents)/\(item.totalStudents)"
                    }
                    .joined(separator: ",  ")
                
                cell.periodLabel.text = periodText
            }
            
            cell.img.image = nil
            cell.fallbackLabel.isHidden = false
            cell.showFallbackImage(for: item.className)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if fullAccess == false && roleName == "STUDENT" {
            let selectedClass = groupClassesforStudent[indexPath.row]
            print("📚 Selected Student Class:", selectedClass.name)
            
            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
            
            guard let studentVC = storyboard
                .instantiateViewController(withIdentifier: "StudentVC") as? StudentVC else {
                print("❌ Could not instantiate StudentVC")
                return
            }
            
            studentVC.classId = selectedClass.id
            studentVC.className = selectedClass.name
            studentVC.fullAccess = self.fullAccess
            studentVC.roleName = self.roleName
            studentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            studentVC.attendanceSettingsResponse = self.attendanceSettingsResponse
            
            navigationController?.pushViewController(studentVC, animated: true)
        } else {
            let selectedClass = attendanceClasses[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
            
            guard let studentVC = storyboard
                .instantiateViewController(withIdentifier: "StudentVC") as? StudentVC else {
                print("❌ Could not instantiate StudentVC")
                return
            }
            
            studentVC.classId = selectedClass.classId
            studentVC.className = selectedClass.className
            studentVC.fullAccess = self.fullAccess
            studentVC.roleName = self.roleName
            studentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            studentVC.attendanceSettingsResponse = self.attendanceSettingsResponse
            
            navigationController?.pushViewController(studentVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
