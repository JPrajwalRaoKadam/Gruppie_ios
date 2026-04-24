import UIKit

// MARK: - Custom Day Picker ViewController
class DayPickerViewController: UIViewController {
    
    private let pickerView = UIPickerView()
    private let titleLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let containerView = UIView()
    
    var weekDays: [String] = []
    var selectedDay: Int = 0
    var onDaySelected: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPicker()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Container view
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Title
        titleLabel.text = "Select Day"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Buttons
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(doneButton)
        
        // Picker View
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pickerView)
        
        // Separators
        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topSeparator)
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bottomSeparator)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cancelButton.widthAnchor.constraint(equalToConstant: 70),
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            
            doneButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            doneButton.widthAnchor.constraint(equalToConstant: 70),
            doneButton.heightAnchor.constraint(equalToConstant: 30),
            
            topSeparator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            topSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            pickerView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 10),
            pickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 180),
            
            bottomSeparator.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10),
            bottomSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(selectedDay, inComponent: 0, animated: false)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        onDaySelected?(selectedRow)
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView Delegates for DayPickerViewController
extension DayPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weekDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = weekDays[row]
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = row == pickerView.selectedRow(inComponent: 0) ? .systemBlue : .black
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(0)
    }
}

// MARK: - Main TimetableViewController
class TimetableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var contentView: UIView!

    var selectedClassName: String = ""
    var subjects: [SubjectData] = []
    var token: String = ""
    var groupId: String = ""
    var teamIds: [String] = []
    var classList: [ClassData] = []
    var currentRole: String?
    var staffDetails: [Staff] = []
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    // API Data
    var daysList: [DayData] = []
    var classSummaryList: [DailyClass] = []
    var selectedDayId: Int?
    var dailySummaryData: DailySummaryData?

    var isStaffSelected: Bool = false
    var isFreeTeachersSelected: Bool = false
    var isSubjectAgain: Bool = false
    var isDayIselected: Bool = false

    var daysVC: DaysViewController?

    // ✅ Week Selection Properties
    private var currentDate: Date = Date()
    private var selectedWeekday: Int = 0 // 0 = Monday, 1 = Tuesday, etc.
    private let calendar = Calendar.current
    
    // Week picker
    private var weekDays: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: "TimetableTableViewCell", bundle: nil), forCellReuseIdentifier: "TimetableTableViewCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl

        setupWeekDays()
        updateDateButtonTitle()

        print("\n========== TIMETABLE VIEW CONTROLLER LOADED ==========")
        print("📅 Current Date: \(getFormattedDate())")
        print("📅 Current Day: \(getCurrentDayName())")
        
        fetchDays()
    }
    
    private func setupWeekDays() {
        // Get all weekdays in order (Monday to Sunday)
        let dateFormatter = DateFormatter()
        weekDays = dateFormatter.weekdaySymbols // Returns ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        // Reorder to start from Monday
        if let mondayIndex = weekDays.firstIndex(of: "Monday") {
            let mondayToSunday = Array(weekDays[mondayIndex...]) + Array(weekDays[..<mondayIndex])
            weekDays = mondayToSunday
        }
        
        // Set current day
        let currentDayName = getCurrentDayName()
        if let selectedIndex = weekDays.firstIndex(of: currentDayName) {
            selectedWeekday = selectedIndex
        }
    }

    private func getCurrentDayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: currentDate)
    }
    
    private func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
    
    private func updateDateButtonTitle() {
        let selectedDayName = weekDays[selectedWeekday]
        dateButton.setTitle(selectedDayName, for: .normal)
    }

    @objc private func refreshData() {
        print("\n🔄 Pull-to-refresh triggered")
        fetchDays()
    }
    
    func fetchDays() {
        print("\n========== FETCHING DAYS API ==========")
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ No token found in SessionManager")
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.showErrorMessage("Authentication failed. Please login again.")
            }
            return
        }
        print("✅ Token retrieved: \(token.prefix(30))...")

        guard let url = URL(string: "https://backend.gc2.co.in/api/v1/days") else {
            print("❌ Invalid URL for days API")
            return
        }
        print("🌐 Days API URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Days API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received from Days API")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("No data received from server")
                }
                return
            }
            
            // Print HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized - Token may be invalid or expired")
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                        self.showErrorMessage("Session expired. Please login again.")
                    }
                    return
                }
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Days API Response:")
                print(jsonString)
            }

            do {
                let decoded = try JSONDecoder().decode(DaysResponse.self, from: data)
                print("✅ Days fetched successfully: \(decoded.data.count) days")

                DispatchQueue.main.async {
                    self.daysList = decoded.data
                    
                    print("\n📅 Available Days:")
                    for day in self.daysList {
                        print("   Day \(day.id): \(day.name)")
                    }

                    // Fetch data for selected weekday
                    self.fetchDataForSelectedWeekday()
                }

            } catch {
                print("❌ Days Decode Error: \(error)")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("Failed to parse days data")
                }
            }

        }.resume()
    }

    func fetchDailySummary(dayId: Int) {
        print("\n========== FETCHING DAILY SUMMARY API ==========")
        print("📅 Day ID: \(dayId)")
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ No token found in SessionManager")
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.showErrorMessage("Authentication failed")
            }
            return
        }
        print("✅ Token retrieved: \(token.prefix(30))...")

        let urlString = "https://backend.gc2.co.in/api/v1/time-table/daily-summary?groupAcademicYearId=3&dayId=\(dayId)"
        print("🌐 Daily Summary API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Summary API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                print("❌ No data received from Summary API")
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("No data received")
                }
                return
            }

            // Print HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized - Token may be invalid")
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                        self.showErrorMessage("Session expired. Please login again.")
                    }
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    print("❌ Server error: HTTP \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                        self.showErrorMessage("Server error: HTTP \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\n📦 Daily Summary API Response:")
                print("================================================")
                let preview = jsonString.prefix(1000)
                print(preview)
                if jsonString.count > 1000 {
                    print("... (truncated, total length: \(jsonString.count) characters)")
                }
                print("================================================")
            }

            do {
                let decoded = try JSONDecoder().decode(DailySummaryAPIResponse.self, from: data)
                print("\n✅ Daily Summary Decoded Successfully!")
                print("📊 Response Summary:")
                print("   - Success: \(decoded.success)")
                print("   - Message: \(decoded.message)")
                print("   - Group Academic Year ID: \(decoded.data.groupAcademicYearId)")
                print("   - Day ID: \(decoded.data.dayId)")
                print("   - Day Name: \(decoded.data.dayName)")
                print("   - Total Classes: \(decoded.data.summary.totalClasses)")
                print("   - Active Classes: \(decoded.data.summary.activeClasses)")
                print("   - Total Scheduled Periods: \(decoded.data.summary.totalScheduledPeriods)")

                DispatchQueue.main.async {
                    self.dailySummaryData = decoded.data
                    self.classSummaryList = decoded.data.classes
                    
                    print("\n📚 Class Summary:")
                    for classItem in self.classSummaryList {
                        print("   Class: \(classItem.className ?? "Unknown")")
                        print("      - ID: \(classItem.classId)")
                        print("      - Scheduled Periods: \(classItem.scheduledPeriods ?? 0)")
                        print("      - Periods Count: \(classItem.periods?.count ?? 0)")
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }

            } catch {
                print("❌ Summary Decode Error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed JSON: \(jsonString)")
                }
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.showErrorMessage("Failed to parse timetable data")
                }
            }

        }.resume()
    }
    
    func fetchDataForSelectedWeekday() {
        let selectedDayName = weekDays[selectedWeekday].uppercased()
        print("\n========== FETCHING DATA FOR SELECTED WEEKDAY ==========")
        print("📅 Selected Weekday: \(selectedDayName)")
        
        if let selectedDay = daysList.first(where: { $0.name == selectedDayName }) {
            selectedDayId = selectedDay.id
            print("✅ Found matching day: \(selectedDay.name) (ID: \(selectedDay.id))")
            fetchDailySummary(dayId: selectedDay.id)
        } else {
            print("⚠️ No matching day found for: \(selectedDayName)")
            print("Available days: \(daysList.map { $0.name }.joined(separator: ", "))")
            showErrorMessage("No timetable available for \(selectedDayName)")
        }
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showInfoMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Info",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\n========== TABLE VIEW CELL SELECTED ==========")
        print("📊 Selected row at index: \(indexPath.row)")
        
        let selectedClass = classSummaryList[indexPath.row]
        print("📚 Selected Class: \(selectedClass.className ?? "Unknown")")
        print("   Class ID: \(selectedClass.classId)")
        print("   Periods Count: \(selectedClass.periods?.count ?? 0)")
        
        // Check if the class has any periods
        let periodCount = selectedClass.periods?.count ?? 0
        
        if periodCount == 0 {
            print("⚠️ No periods found for this class on the selected day")
            showInfoMessage("No periods scheduled for \(selectedClass.className ?? "this class") on \(weekDays[selectedWeekday]).")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        guard let dailySummaryData = self.dailySummaryData else {
            print("❌ dailySummaryData is nil")
            showErrorMessage("Unable to load timetable data")
            return
        }

        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
        if let periodVC = storyboard.instantiateViewController(withIdentifier: "PeriodViewController") as? PeriodViewController {

            // ✅ Pass all the data
            periodVC.groupId = groupId
            periodVC.token = token
            periodVC.teamIds = teamIds
            periodVC.subjects = subjects
            periodVC.day = selectedDayId ?? 0
            periodVC.classId = selectedClass.classId
            periodVC.groupAcademicYearId = dailySummaryData.groupAcademicYearId
            periodVC.flowMode = .subject
            periodVC.className = selectedClass.className
            
            // Map periods
            periodVC.periods = selectedClass.periods?.map {
                PeriodData(
                    staffId: $0.timeTableEntry.staffId,
                    period: $0.periodNumber,
                    name: $0.timeTableEntry.staffName,
                    day: selectedDayId != nil ? String(selectedDayId!) : nil,
                    subjectsHandled: [SubjectsData(
                        subjectId: $0.timeTableEntry.subjectId,
                        subjectName: $0.timeTableEntry.subjectName,
                        className: selectedClass.className,
                        optional: false
                    )],
                    startTime: $0.startTime,
                    endTime: $0.endTime
                )
            } ?? []
            
            print("\n📊 Passing \(periodVC.periods.count) periods to PeriodViewController")

            navigationController?.pushViewController(periodVC, animated: true)
        }
        
        // Deselect the row after handling
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @IBAction func dateButtonTapped(_ sender: UIButton) {
        print("\n========== WEEK PICKER BUTTON TAPPED ==========")
        
        let dayPickerVC = DayPickerViewController()
        dayPickerVC.weekDays = weekDays
        dayPickerVC.selectedDay = selectedWeekday
        dayPickerVC.modalPresentationStyle = .overFullScreen
        dayPickerVC.modalTransitionStyle = .crossDissolve
        
        dayPickerVC.onDaySelected = { [weak self] selectedRow in
            guard let self = self else { return }
            if selectedRow != self.selectedWeekday {
                self.selectedWeekday = selectedRow
                self.updateDateButtonTitle()
                print("📅 Selected Weekday: \(self.weekDays[selectedRow])")
                
                if !self.daysList.isEmpty {
                    self.fetchDataForSelectedWeekday()
                }
            }
        }
        
        present(dayPickerVC, animated: true)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("\n========== NEXT BUTTON TAPPED ==========")
        if selectedWeekday < weekDays.count - 1 {
            selectedWeekday += 1
            updateDateButtonTitle()
            print("📅 Next Weekday: \(weekDays[selectedWeekday])")
            
            if !daysList.isEmpty {
                fetchDataForSelectedWeekday()
            }
        }
    }

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        print("\n========== PREVIOUS BUTTON TAPPED ==========")
        if selectedWeekday > 0 {
            selectedWeekday -= 1
            updateDateButtonTitle()
            print("📅 Previous Weekday: \(weekDays[selectedWeekday])")
            
            if !daysList.isEmpty {
                fetchDataForSelectedWeekday()
            }
        }
    }

    @IBAction func BackButton(_ sender: UIButton) {
        print("\n========== BACK BUTTON TAPPED ==========")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView Delegates
extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 Number of rows in table view: \(classSummaryList.count)")
        return classSummaryList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TimetableTableViewCell",
            for: indexPath) as! TimetableTableViewCell

        let classItem = classSummaryList[indexPath.row]
        cell.configureCell(with: classItem)

        return cell
    }
}
