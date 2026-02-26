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
        
        classname.text = className ?? "N/A"
        
        // UI Styling
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true

        // Table setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PeriodDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PeriodDetailTableViewCell")

        // Fetch schedule from API
        fetchSchedule()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    // MARK: - Actions
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - API Call
    func fetchSchedule() {
        guard let classId = classId,
              let yearId = groupAcademicYearId else { return }
        
        guard let savedToken = UserDefaults.standard.string(forKey: "user_role_Token"), !savedToken.isEmpty else { return }
        self.token = savedToken
        
        let apiUrlString = "https://dev.gruppie.in/api/v1/time-table/schedule?classId=\(classId)&groupAcademicYearId=\(yearId)"
        guard let url = URL(string: apiUrlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(ScheduleAPIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.daySchedules = decoded.data?.days?.compactMap { day in
                            guard let dayName = day.dayName, let periods = day.periods else { return nil }
                            return DayScheduleData(dayName: dayName, periods: periods)
                        } ?? []

                        let weekdaysOrder = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
                        self.daySchedules.sort {
                            guard let firstIndex = weekdaysOrder.firstIndex(of: $0.dayName),
                                  let secondIndex = weekdaysOrder.firstIndex(of: $1.dayName) else { return false }
                            return firstIndex < secondIndex
                        }

                        self.tableView.reloadData()
                    }
                } catch {
                    print("❌ JSON decode error: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - UITableView
extension PeriodDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daySchedules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodDetailTableViewCell", for: indexPath) as? PeriodDetailTableViewCell else {
            return UITableViewCell()
        }

        let dayData = daySchedules[indexPath.row]
        cell.configure(dayText: dayData.dayName, periodText: "\(dayData.periods.count) Period(s)")
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // 🔹 Navigate to PeriodViewController on selecting a weekday
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDay = daySchedules[indexPath.row]
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)

        if let periodVC = storyboard.instantiateViewController(withIdentifier: "PeriodViewController") as? PeriodViewController {
            
            periodVC.token = token
            periodVC.groupId = groupId
            periodVC.classId = classId
            periodVC.groupAcademicYearId = groupAcademicYearId
            periodVC.day = indexPath.row + 1 // Or map based on day API ID if needed
            periodVC.periods = selectedDay.periods.map {
                PeriodData(
                    staffId: $0.timeTableEntry.staffId,
                    period: $0.periodNumber,
                    name: $0.timeTableEntry.staffName,
                    day: String(indexPath.row + 1),
                    subjectsHandled: [SubjectsData(
                        subjectId: $0.timeTableEntry.subjectId,
                        subjectName: $0.timeTableEntry.subjectName,
                        className: className ?? "Class",
                        optional: false
                    )],
                    startTime: $0.startTime,
                    endTime: $0.endTime
                )
            }
            periodVC.className = className
            periodVC.flowMode = .days
            navigationController?.pushViewController(periodVC, animated: true)
        }
    }
}
