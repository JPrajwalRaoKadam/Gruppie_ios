import UIKit

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
    var dailySummaryData: DailySummaryData? // ✅ Store full summary for groupAcademicYearId

    var isStaffSelected: Bool = false
    var isFreeTeachersSelected: Bool = false
    var isSubjectAgain: Bool = false
    var isDayIselected: Bool = false

    var daysVC: DaysViewController?

    // ✅ Date Properties
    private var currentDate: Date = Date()
    private let datePicker = UIDatePicker()

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

        setupDatePicker()
        updateDateButtonTitle()

        tableView.reloadData()
        fetchDays()   // 🔥 First API call
    }

    func fetchDays() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("No token found in UserDefaults")
            return
        }

        guard let url = URL(string: "https://dev.gruppie.in/api/v1/days") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Days API Error:", error)
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DaysResponse.self, from: data)

                DispatchQueue.main.async {
                    self.daysList = decoded.data

                    if let firstDay = self.daysList.first {
                        self.selectedDayId = firstDay.id
                        self.dateButton.setTitle(firstDay.name, for: .normal)

                        self.fetchDailySummary(dayId: firstDay.id) // 🔥 Call second API
                    }
                }

            } catch {
                print("Days Decode Error:", error)
            }

        }.resume()
    }

    func fetchDailySummary(dayId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("No token found in UserDefaults")
            return
        }

        let urlString = "https://dev.gruppie.in/api/v1/time-table/daily-summary?groupAcademicYearId=3&dayId=\(dayId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Summary API Error:", error)
                return
            }

            guard let data = data else { return }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received Daily Summary API Response:\n\(jsonString)")
            }

            do {
                let decoded = try JSONDecoder().decode(DailySummaryAPIResponse.self, from: data)

                DispatchQueue.main.async {
                    self.dailySummaryData = decoded.data // ✅ Store full summary
                    self.classSummaryList = decoded.data.classes
                    self.tableView.reloadData()
                }

            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Summary Decode Error:", error)
                    print("Received JSON:", jsonString)
                }
            }

        }.resume()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedClass = classSummaryList[indexPath.row]

        guard let dailySummaryData = self.dailySummaryData else { return }

        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
        if let periodVC = storyboard.instantiateViewController(withIdentifier: "PeriodViewController") as? PeriodViewController {

            // ✅ Pass all the data
            periodVC.groupId = groupId
            periodVC.token = token
            periodVC.teamIds = teamIds
            periodVC.subjects = subjects
            periodVC.day = selectedDayId ?? 0
            periodVC.classId = selectedClass.classId
            periodVC.groupAcademicYearId = dailySummaryData.groupAcademicYearId // ✅ Correct source
            periodVC.flowMode = .subject
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

            navigationController?.pushViewController(periodVC, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // ✅ Setup DatePicker
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    // ✅ Update Button Title
    private func updateDateButtonTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let dateString = formatter.string(from: currentDate)
        dateButton.setTitle(dateString, for: .normal)
    }

    // ✅ Date Changed
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateDateButtonTitle()
    }

    // ✅ Show DatePicker on Button Click
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        datePicker.date = currentDate

        let alert = UIAlertController(title: "Select Date\n\n\n\n\n\n\n\n\n",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        datePicker.frame = CGRect(x: 0, y: 40, width: alert.view.bounds.width - 20, height: 200)
        alert.view.addSubview(datePicker)

        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            self.currentDate = self.datePicker.date
            self.updateDateButtonTitle()
        }

        alert.addAction(doneAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    // ✅ Next Date
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            currentDate = nextDay
            updateDateButtonTitle()
        }
    }

    // ✅ Previous Date
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            currentDate = previousDay
            updateDateButtonTitle()
        }
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView Delegates
extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
