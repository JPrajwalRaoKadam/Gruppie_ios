import UIKit

class TeacherTTViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var timeTableData: [DaySchedule] = []
    var token: String = TokenManager.shared.getToken() ?? ""
    var subjects: [SubjectData] = []
    var groupId: String = ""
    var teamIds: [String] = []
    var userId: String = ""

    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var expandedSections: Set<Int> = []
    
    var allPeriods: [String] = []
    var subjectNames: [String] = []
    var teacherNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "AcademicTableViewCell", bundle: nil), forCellReuseIdentifier: "AcademicTableViewCell")
        
        expandCurrentDaySection()
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        print("📌 groupId: \(groupId)")
        print("📌 token: \(token)")
        print("📌 userId: \(userId)")
        
        fetchTimeTableAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func expandCurrentDaySection() {
        let currentDay = Calendar.current.component(.weekday, from: Date())
        let currentIndex = (currentDay == 1) ? 6 : currentDay - 2
        expandedSections.insert(currentIndex)
    }

    func fetchTimeTableAPI() {
        let selectedTeamId = teamIds.first ?? ""
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/staff/timetable/get?userId=\(userId)"

        guard let url = URL(string: apiUrl) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            print("✅ API URL: \(apiUrl)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟢 Raw API Response: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(AcademicScheduleResponse.self, from: data)
                self.timeTableData = decodedResponse.data

                self.allPeriods.removeAll()
                self.subjectNames.removeAll()
                self.teacherNames.removeAll()

                for daySchedule in self.timeTableData {
                    for session in daySchedule.sessions {
                        if !self.allPeriods.contains(session.period) {
                            self.allPeriods.append(session.period)
                        }
                        if !self.subjectNames.contains(session.subjectName) {
                            self.subjectNames.append(session.subjectName)
                        }
                        if let teacherName = session.teacherName, !self.teacherNames.contains(teacherName) {
                            self.teacherNames.append(teacherName)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("📌 Periods: \(self.allPeriods)")
                    print("📌 Subjects: \(self.subjectNames)")
                    print("📌 Teachers: \(self.teacherNames)")
                }

            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

extension TeacherTTViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return weekdays.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard expandedSections.contains(section), section < timeTableData.count else {
            return 0
        }
        return 1 + timeTableData[section].sessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.contentView.addSubview(createTableHeaderView())
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AcademicTableViewCell", for: indexPath) as? AcademicTableViewCell else {
            return UITableViewCell()
        }

        let sessionData = timeTableData[indexPath.section].sessions[indexPath.row - 1]

        cell.period.text = " \(sessionData.period)"
        cell.startingTime.text = sessionData.startTime
        cell.endingTime.text = sessionData.endTime
        cell.subject.text = "Subject: \(sessionData.subjectName)"
        cell.teacher.text = "Teacher: \(sessionData.teacherName ?? "")"

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = weekdays[section]
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        let bottomLine = UIView()
        bottomLine.backgroundColor = .gray
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -6),
            
            bottomLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section

        return headerView
    }

    @objc func headerTapped(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }

        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 40 : 80
    }
}

extension TeacherTTViewController {
    
    func createTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        headerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        let titles = ["Period", "Subject/Teacher", "Time"]
        let width = view.frame.width / 3

        for i in 0..<titles.count {
            let label = UILabel(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: 40))
            label.text = titles[i]
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.textColor = .darkGray

            switch i {
            case 0:
                label.frame.origin.x += 25
                label.textAlignment = .left
            case 1:
                label.textAlignment = .center
            case 2: // Time - move slightly left
                label.frame.origin.x -= 25
                label.textAlignment = .right
            default:
                break
            }

            headerView.addSubview(label)
        }

        return headerView
    }
}
