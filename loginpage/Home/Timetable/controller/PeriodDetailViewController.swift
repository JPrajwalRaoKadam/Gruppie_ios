import UIKit

// 🔹 Model for day schedule
struct DayScheduleData {
    let dayName: String
    let periods: [PeriodDataAPI]
}

// 🔹 Model for API schedule
class PeriodDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var classname: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
    var classId: String?
    var groupAcademicYearId: String?
    var daySchedules: [DayScheduleData] = []

    var className: String?
    var token: String = ""
    var groupId: String = ""
    var day: Int = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n========== PERIOD DETAIL VIEW CONTROLLER LOADED ==========")
        
        // Verify outlets
        verifyOutlets()
        
        // Set class name
        if classname != nil {
            classname.text = className ?? ""
            print("✅ Class name label set to: \(className ?? "N/A")")
        } else {
            print("❌ classname outlet is nil - Check connection in Storyboard")
        }
        
        // UI Styling
        if contentView != nil {
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
            print("✅ contentView styled")
        } else {
            print("❌ contentView outlet is nil")
        }
        
        if tableView != nil {
            tableView.layer.cornerRadius = 10
            tableView.layer.masksToBounds = true
            print("✅ tableView styled")
        } else {
            print("❌ tableView outlet is nil")
        }
        
        if backButton != nil {
            backButton.layer.cornerRadius = backButton.frame.size.height / 2
            backButton.clipsToBounds = true
            print("✅ backButton styled")
        } else {
            print("❌ backButton outlet is nil")
        }

        // Table setup
        if tableView != nil {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "PeriodDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PeriodDetailTableViewCell")
            print("✅ TableView setup complete")
        }

        // Print received data
        print("\n📊 Received Data in PeriodDetailViewController:")
        print("   - classId: \(classId ?? "nil")")
        print("   - groupAcademicYearId: \(groupAcademicYearId ?? "nil")")
        print("   - className: \(className ?? "nil")")
        print("   - groupId: \(groupId)")
        print("   - day: \(day)")

        // Fetch schedule from API
        fetchSchedule()
    }
    
    private func verifyOutlets() {
        print("\n========== OUTLET VERIFICATION ==========")
        
        if tableView == nil {
            print("❌ CRITICAL: tableView outlet is nil - Check connection in Storyboard")
        } else {
            print("✅ tableView outlet is connected")
        }
        
        if backButton == nil {
            print("❌ CRITICAL: backButton outlet is nil - Check connection in Storyboard")
        } else {
            print("✅ backButton outlet is connected")
        }
        
        if classname == nil {
            print("❌ CRITICAL: classname outlet is nil - Check connection in Storyboard")
        } else {
            print("✅ classname outlet is connected")
        }
        
        if contentView == nil {
            print("❌ CRITICAL: contentView outlet is nil - Check connection in Storyboard")
        } else {
            print("✅ contentView outlet is connected")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if backButton != nil {
            backButton.layer.cornerRadius = backButton.frame.size.height / 2
        }
    }

    // MARK: - Actions
    @IBAction func BackButton(_ sender: UIButton) {
        print("\n⬅️ Navigating back")
        navigationController?.popViewController(animated: true)
    }

    // MARK: - API Call
    func fetchSchedule() {
        print("\n========== FETCHING SCHEDULE API ==========")
        
        // Validate required parameters
        guard let classId = classId else {
            print("❌ Error: classId is nil")
            showErrorMessage("Class ID is missing")
            return
        }
        print("✅ classId: \(classId)")
        
        guard let yearId = groupAcademicYearId else {
            print("❌ Error: groupAcademicYearId is nil")
            showErrorMessage("Academic Year ID is missing")
            return
        }
        print("✅ groupAcademicYearId: \(yearId)")
        
        // Get token
        guard let savedToken = UserDefaults.standard.string(forKey: "user_role_Token"), !savedToken.isEmpty else {
            print("❌ Error: No token found in UserDefaults")
            print("   Key 'user_role_Token' not found or empty")
            showErrorMessage("Authentication token not found")
            return
        }
        self.token = savedToken
        print("✅ Token retrieved: \(token.prefix(30))...")
        
        // Build API URL
        let apiUrlString = "https://backend.gc2.co.in/api/v1/time-table/schedule?classId=\(classId)&groupAcademicYearId=\(yearId)"
        print("🌐 API URL: \(apiUrlString)")
        
        guard let url = URL(string: apiUrlString) else {
            print("❌ Invalid URL: \(apiUrlString)")
            showErrorMessage("Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📤 Sending request to fetch schedule...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorMessage("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized - Token may be invalid or expired")
                    DispatchQueue.main.async {
                        self.showErrorMessage("Session expired. Please login again.")
                    }
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    print("❌ Server error: HTTP \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.showErrorMessage("Server error: HTTP \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            // Check if data exists
            guard let data = data else {
                print("❌ No data received from API")
                DispatchQueue.main.async {
                    self.showErrorMessage("No data received from server")
                }
                return
            }
            
            // Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\n📦 Raw API Response:")
                print("================================================")
                // Print full response for debugging
                print(jsonString)
                print("================================================")
                print("📊 Response Length: \(jsonString.count) characters")
            }
            
            // Parse JSON
            do {
                let decoded = try JSONDecoder().decode(ScheduleAPIResponse.self, from: data)
                print("\n✅ JSON Decoded Successfully!")
                print("📊 Response Structure:")
                print("   - Success: \(decoded.success ?? false)")
                print("   - Message: \(decoded.message ?? "No message")")
                
                // Check if data exists
                guard let responseData = decoded.data else {
                    print("❌ Response data is nil")
                    DispatchQueue.main.async {
                        self.showErrorMessage("No schedule data available")
                        self.tableView?.reloadData()
                    }
                    return
                }
                
                print("   - Days count: \(responseData.days?.count ?? 0)")
                
                // Process days data
                if let days = responseData.days {
                    print("\n📅 Processing Days:")
                    for (index, day) in days.enumerated() {
                        print("   Day \(index + 1):")
                        print("      - Name: \(day.dayName ?? "Unknown")")
                        print("      - Periods count: \(day.periods?.count ?? 0)")
                        
                        if let periods = day.periods {
                            for (periodIndex, period) in periods.enumerated() {
                                print("      Period \(periodIndex + 1):")
                                print("         - Number: \(period.periodNumber ?? "N/A")")
                                print("         - Start: \(period.startTime ?? "N/A")")
                                print("         - End: \(period.endTime ?? "N/A")")
                                print("         - Subject: \(period.timeTableEntry.subjectName ?? "N/A")")
                                print("         - Staff: \(period.timeTableEntry.staffName ?? "N/A")")
                            }
                        }
                    }
                }
                
                // Map to DayScheduleData
                let schedules = decoded.data?.days?.compactMap { day -> DayScheduleData? in
                    guard let dayName = day.dayName, let periods = day.periods else {
                        print("⚠️ Skipping day with missing name or periods")
                        return nil
                    }
                    return DayScheduleData(dayName: dayName, periods: periods)
                } ?? []
                
                print("\n✅ Mapped \(schedules.count) days to DayScheduleData")
                
                // Sort by weekday order
                let weekdaysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                let sortedSchedules = schedules.sorted {
                    guard let firstIndex = weekdaysOrder.firstIndex(of: $0.dayName),
                          let secondIndex = weekdaysOrder.firstIndex(of: $1.dayName) else { return false }
                    return firstIndex < secondIndex
                }
                
                print("\n📅 Sorted Days:")
                for schedule in sortedSchedules {
                    print("   - \(schedule.dayName): \(schedule.periods.count) periods")
                }
                
                DispatchQueue.main.async {
                    self.daySchedules = sortedSchedules
                    print("\n✅ Updating UI with \(self.daySchedules.count) days")
                    self.tableView?.reloadData()
                    
                    if self.daySchedules.isEmpty {
                        print("⚠️ No schedules found for this class")
                        self.showInfoMessage("No timetable found for this class")
                    }
                }
                
            } catch {
                print("\n❌ JSON Decode Error: \(error)")
                print("   Error details: \(error.localizedDescription)")
                
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   Key not found: \(key.stringValue)")
                        print("   Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: \(type)")
                        print("   Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type)")
                        print("   Context: \(context.debugDescription)")
                    default:
                        print("   Other decoding error")
                    }
                }
                
                DispatchQueue.main.async {
                    self.showErrorMessage("Failed to parse schedule data")
                    self.tableView?.reloadData()
                }
            }
        }.resume()
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
}

// MARK: - UITableView
extension PeriodDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = daySchedules.count
        print("📊 Number of rows in table: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodDetailTableViewCell", for: indexPath) as? PeriodDetailTableViewCell else {
            print("❌ Failed to dequeue PeriodDetailTableViewCell")
            return UITableViewCell()
        }

        let dayData = daySchedules[indexPath.row]
        let periodText = dayData.periods.count == 1 ? "\(dayData.periods.count) Period" : "\(dayData.periods.count) Periods"
        cell.configure(dayText: dayData.dayName, periodText: periodText)
        
        print("✅ Configured cell for row \(indexPath.row): \(dayData.dayName) - \(periodText)")
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // 🔹 Navigate to PeriodViewController on selecting a weekday
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\n========== DAY SELECTED ==========")
        
        let selectedDay = daySchedules[indexPath.row]
        print("📅 Selected Day: \(selectedDay.dayName)")
        print("   Periods count: \(selectedDay.periods.count)")
        
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)

        if let periodVC = storyboard.instantiateViewController(withIdentifier: "PeriodViewController") as? PeriodViewController {
            
            // Find day ID from daysList or use index
            let dayId = indexPath.row + 1
            print("   Day ID: \(dayId)")
            
            periodVC.token = token
            periodVC.groupId = groupId
            periodVC.classId = classId
            periodVC.groupAcademicYearId = groupAcademicYearId
            periodVC.day = dayId
            periodVC.periods = selectedDay.periods.map { period in
                PeriodData(
                    staffId: period.timeTableEntry.staffId,
                    period: period.periodNumber,
                    name: period.timeTableEntry.staffName,
                    day: String(dayId),
                    subjectsHandled: [SubjectsData(
                        subjectId: period.timeTableEntry.subjectId,
                        subjectName: period.timeTableEntry.subjectName,
                        className: className ?? "Class",
                        optional: false
                    )],
                    startTime: period.startTime,
                    endTime: period.endTime
                )
            }
            periodVC.className = className
            periodVC.flowMode = .days
            
            print("✅ Navigating to PeriodViewController with \(periodVC.periods.count) periods")
            navigationController?.pushViewController(periodVC, animated: true)
        } else {
            print("❌ Failed to instantiate PeriodViewController")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
