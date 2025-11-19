import UIKit

class StaffAttendenceVc: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var curDate: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var afternoonButton: UIButton!
    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var AllPresent: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var midView: UIView!

    
    var currentDatePicker: UIDatePicker?
    var currentDate: String?
    var groupId: String = ""
    var token: String = ""
    var currentRole: String = ""
    var currentSession: String = "morning"
    var attendanceData: [StaffAttendance] = []
    var isAllPresentSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Staff Attendance VC initialized with:")
        print("Group ID: \(groupId)")
        print("Token: \(token)")
        print("Current Role: \(currentRole)")
        
        setCurrentDate()
        setupTableView()
        
        morningButton.setTitle("", for: .normal)
        afternoonButton.setTitle("", for: .normal)
    
        midView.layer.cornerRadius = 10
        midView.clipsToBounds = true

        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        configureAllPresentButton()
        configureCheckboxButton(morningButton, isChecked: true, title: "")
        configureCheckboxButton(afternoonButton, isChecked: false, title: "")
        
        BackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        AllPresent.addTarget(self, action: #selector(allPresentButtonTapped(_:)), for: .touchUpInside)
        
        BackButton.layer.cornerRadius = BackButton.frame.size.height / 2
        BackButton.clipsToBounds = true
        BackButton.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true

        
        morningButton.addTarget(self, action: #selector(sessionButtonTapped(_:)), for: .touchUpInside)
        afternoonButton.addTarget(self, action: #selector(sessionButtonTapped(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        configureAllPresentButton()

        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        BackButton.layer.cornerRadius = BackButton.frame.size.height / 2
    }

    private func configureCheckboxButton(_ button: UIButton, isChecked: Bool, title: String) {
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 0
        button.layer.borderColor = nil
        button.backgroundColor = .clear
        
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Space between checkbox and text
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    }

    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Attendance",
            message: "Do you want to delete the attendance for \(currentDate ?? "this date")?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAttendance()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    private func deleteAttendance() {
        guard let token = TokenManager.shared.getToken(), !groupId.isEmpty else {
            print("Missing token or group ID")
            showAlert(title: "Error", message: "Authentication failed")
            return
        }
        
        guard let currentDate = currentDate else {
            print("No date selected")
            showAlert(title: "Error", message: "No date selected")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/attendance/take/consolidate?date=\(currentDate)"
        
        print("Attempting to delete attendance at URL: \(urlString)")
        
        let requestBody: [String: Any] = [
            "attendanceData": [
                [
                    "attendance": [
                        ["status": "present", "userIds": []],
                        ["status": "absent", "userIds": []],
                        ["status": "ood", "userIds": []]
                    ],
                    "session": "morning"
                ],
                [
                    "attendance": [
                        ["status": "present", "userIds": []],
                        ["status": "absent", "userIds": []],
                        ["status": "ood", "userIds": []]
                    ],
                    "session": "afternoon"
                ]
            ]
        ]
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            showAlert(title: "Error", message: "Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("API Error: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to delete attendance: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        
                        if (200...299).contains(httpResponse.statusCode) {
                            self.showAlert(title: "Success", message: "Attendance deleted successfully!") {
                                self.fetchData()
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Server returned status code \(httpResponse.statusCode)")
                        }
                    }
                }
            }
            
            task.resume()
            
        } catch {
            print("Error creating JSON: \(error)")
            showAlert(title: "Error", message: "Failed to prepare delete request")
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }

    
    
    @objc func sessionButtonTapped(_ sender: UIButton) {
        if sender == morningButton {
            currentSession = "morning"
            configureCheckboxButton(morningButton, isChecked: true, title: "")
            configureCheckboxButton(afternoonButton, isChecked: false, title: "")
        } else if sender == afternoonButton {
            currentSession = "afternoon"
            configureCheckboxButton(afternoonButton, isChecked: true, title: "")
            configureCheckboxButton(morningButton, isChecked: false, title: "")
        }
        
        fetchData()
    }

    @objc func submitButtonTapped() {
        saveAttendance()
    }

    private func saveAttendance() {
        guard let token = TokenManager.shared.getToken(), !groupId.isEmpty else {
            print("Missing token or group ID")
            showAlert(title: "Error", message: "Authentication failed")
            return
        }
        
        guard let currentDate = currentDate else {
            print("No date selected")
            showAlert(title: "Error", message: "No date selected")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/attendance/take/consolidate?date=\(currentDate)"
        
        print("=== POST API REQUEST ===")
        print("URL: \(urlString)")
        
        let requestBody = prepareRequestBody()
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            showAlert(title: "Error", message: "Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body:")
                print(jsonString)
            } else {
                print("Request Body: Unable to decode JSON data")
            }
            
            print("Headers:")
            print("Authorization: Bearer \(token)")
            print("Content-Type: application/json")
            print("==========================")
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                                            
                if let error = error {
                    print("API Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to save attendance: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "No response from server")
                    }
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if let data = data {
                    let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode raw response"
                    print("Raw API Response: \(rawResponse)")
                    
                    if rawResponse.contains("error") || rawResponse.contains("Error") {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Server error: \(rawResponse)")
                        }
                        return
                    }
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success", message: "Attendance saved successfully!") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.fetchData()
                            }
                        }
                    }
                } else {
                    let errorMessage: String
                    switch httpResponse.statusCode {
                    case 400:
                        errorMessage = "Bad request - please check your data"
                    case 401:
                        errorMessage = "Authentication failed - please login again"
                    case 403:
                        errorMessage = "Access denied"
                    case 404:
                        errorMessage = "Resource not found"
                    case 500:
                        errorMessage = "Internal server error"
                    default:
                        errorMessage = "Server returned status code \(httpResponse.statusCode)"
                    }
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: errorMessage)
                    }
                }
            }
            
            task.resume()
            
        } catch {
            print("Error creating JSON: \(error)")
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Failed to prepare attendance data: \(error.localizedDescription)")
            }
        }
    }
    
    private func prepareRequestBody() -> [String: Any] {
        var presentUserIds = [String]()
        var absentUserIds = [String]()
        var oodUserIds = [String]()
        
        for staff in attendanceData {
            if staff.isOOD {
                oodUserIds.append(staff.id)
            } else if let status = staff.attendanceStatus {
                switch status {
                case "Present":
                    presentUserIds.append(staff.id)
                case "Absent":
                    absentUserIds.append(staff.id)
                case "On Leave":
                    oodUserIds.append(staff.id)
                default:
                    break
                }
            }
        }
        
        print("Attendance Summary:")
        print("Present: \(presentUserIds.count) staff members")
        print("Absent: \(absentUserIds.count) staff members")
        print("On Leave: \(oodUserIds.count) staff members")
        print("Session: \(currentSession)")
        
        let requestBody: [String: Any] = [
            "attendanceData": [
                [
                    "session": currentSession,
                    "attendance": [
                        ["status": "present", "userIds": presentUserIds],
                        ["status": "absent", "userIds": absentUserIds],
                        ["status": "ood", "userIds": oodUserIds]
                    ]
                ]
            ]
        ]
        
        return requestBody
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "StaffAttendenceVcTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StaffAttendenceVcTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAttendenceVcTableViewCell", for: indexPath) as? StaffAttendenceVcTableViewCell else {
            fatalError("Unable to dequeue StaffAttendenceVcTableViewCell")
        }
        
        let staff = attendanceData[indexPath.row]
        cell.name.text = staff.name
        
        cell.configure(with: staff.attendanceStatus, isOOD: staff.isOOD)
        
        cell.attendanceChanged = { [weak self] status in
            self?.attendanceData[indexPath.row].attendanceStatus = status
            if status != "On Leave" {
                self?.attendanceData[indexPath.row].isOOD = false
            }
            self?.updateAllPresentButtonState()
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func leftdateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            currentDate = dateFormatter.string(from: previousDay)
            curDate.setTitle(currentDate, for: .normal)
            fetchData()
        }
    }
    
    @IBAction func rightdateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        let todayDate = Date()
        
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
           nextDay <= todayDate {
            currentDate = dateFormatter.string(from: nextDay)
            curDate.setTitle(currentDate, for: .normal)
            fetchData()
        }
    }
    
    @IBAction func dateChange(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton)
    }
    
    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        curDate.setTitle(self.currentDate, for: .normal)
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
        datePicker.maximumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker
        
        if let currentDate = currentDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let date = dateFormatter.date(from: currentDate) {
                datePicker.date = date
            }
        }
        
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
            fetchData()
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    func fetchData() {
        guard let token = TokenManager.shared.getToken() else {
            print("Missing token")
            showAlert(title: "Error", message: "Authentication failed")
            return
        }
        
        let dateComponents = currentDate?.components(separatedBy: "-")
        guard let day = dateComponents?[0], let month = dateComponents?[1], let year = dateComponents?[2] else {
            print("Invalid date format")
            showAlert(title: "Error", message: "Invalid date format")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/attendance/get?day=\(day)&month=\(month)&year=\(year)&session=\(currentSession)"
        
        print("Attempting to fetch from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            showAlert(title: "Error", message: "Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Network request failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Server returned status code \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No data received from server")
                }
                return
            }
            
            let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode raw response"
            print("Raw API Response: \(rawResponse)")
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(AttendanceResponse.self, from: data)
                
                print("Successfully decoded \(apiResponse.data.count) staff records")
                
                let attendanceData = apiResponse.data.map { staff -> StaffAttendance in
                    let sessionAttendance = staff.attendance.first { $0.session == self.currentSession }
                    
                    var status: String?
                    var isOOD = false
                    
                    if staff.leave {
                        status = "On Leave"
                    }
                    else if let sessionAttendance = sessionAttendance {
                        if sessionAttendance.ood {
                            status = "On Leave"
                            isOOD = true
                        }
                        else if !sessionAttendance.attendance.isEmpty {
                            status = sessionAttendance.attendance
                        }
                    }
                    
                    return StaffAttendance(
                        id: staff.userId,
                        name: staff.name,
                        attendanceStatus: status,
                        isOOD: isOOD
                    )
                }
                
                DispatchQueue.main.async {
                    self.attendanceData = attendanceData
                    self.tableView.reloadData()
                    self.updateAllPresentButtonState()
                    
                    if !self.attendanceData.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
                
            } catch {
                print("Decoding Error: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to decode server response: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func allPresentButtonTapped(_ sender: UIButton) {
        isAllPresentSelected.toggle()
        
        if isAllPresentSelected {
            for index in 0..<attendanceData.count {
                attendanceData[index].attendanceStatus = "Present"
            }
            tableView.reloadData()
            
            let checkedImage = UIImage(systemName: "checkmark.square.fill")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            sender.setImage(checkedImage, for: .normal)
        } else {
            for index in 0..<attendanceData.count {
                attendanceData[index].attendanceStatus = nil
            }
            tableView.reloadData()
            
            let uncheckedImage = UIImage(systemName: "square")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            sender.setImage(uncheckedImage, for: .normal)
        }
    }

    private func updateAllPresentButtonState() {
        let allPresent = attendanceData.allSatisfy { $0.attendanceStatus == "Present" }
        isAllPresentSelected = allPresent
        
        if allPresent {
            let checkedImage = UIImage(systemName: "checkmark.square.fill")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            AllPresent.setImage(checkedImage, for: .normal)
        } else {
            let uncheckedImage = UIImage(systemName: "square")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            AllPresent.setImage(uncheckedImage, for: .normal)
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    private func configureAllPresentButton() {

        
        AllPresent.layer.borderWidth = 0
        AllPresent.layer.cornerRadius = 0
        AllPresent.layer.borderColor = nil
        AllPresent.backgroundColor = .clear
        
        // Start with empty square
        let squareImage = UIImage(systemName: "square")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        AllPresent.setImage(squareImage, for: .normal)
        
        // Add spacing between image and text
        AllPresent.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
    }

}
