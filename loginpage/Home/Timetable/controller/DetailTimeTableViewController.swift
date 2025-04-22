import UIKit

class DetailTimeTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    
    var token: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var selectedDay: Int = 0
    var subjectIds: [String] = []
    var staffIds: [String] = []
    var allPeriods: [String] = []
    var subjectNames: [String] = []
    var teacherNames: [String] = []
    var selectedSubjectIndex: Int?
    var selectedStaffIndex: Int?
    
    var timeTableData: [Session] = []
    var timetableResponseData: [ClassData] = []
    
    var globalStaffIds: [String] = []
    var globalSubjectIds: [String] = []
    var teacherPickerView: UIPickerView!
    var selectedTeacher: String?
    var teachers: [String] = []
    var selectedIndexPath: IndexPath?
    var selectedSession: Session?
    
    var selectedStartingTime: String?
    var selectedEndingTime: String?
    var selectedPeriod: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🟢 Token DTT: \(token)")
        print("🟢 GroupId DTT: \(groupId)")
        print("🟢 TeamId DTT: \(teamId)")
        print("🟢  selectedDay DTT: \(selectedDay)")
        print("🟢  allPeriods DTT: \(allPeriods)")
        print("🟢  subjectNames DTT: \(subjectNames)")
        print("🟢  teacherNames DTT: \(teacherNames)")
        print("🟢 Received Subject IDs: \(subjectIds)")
        print("🟢 Received Staff IDs: \(staffIds)")
        
        tableView.register(UINib(nibName: "DetailTimeTableTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTimeTableTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        AddButton.layer.cornerRadius = 10
        AddButton.layer.masksToBounds = true
        setupTableHeaderView()
        fetchDetailTimeTable()
        addTimeTable()
    }
    func setupTableHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.systemGray5

        let titles = ["Period", "Time", "Subject", "Teacher"]
        let labelWidth = tableView.frame.width / CGFloat(titles.count)

        for (index, title) in titles.enumerated() {
            var xOffset: CGFloat
            if index == 1 {
                xOffset = CGFloat(index) * (labelWidth * 0.8) - 10
            } else if index < 3 {
                xOffset = CGFloat(index) * (labelWidth * 0.8)
            } else {
                xOffset = CGFloat(index) * labelWidth             }

            let label = UILabel(frame: CGRect(x: xOffset, y: 0, width: labelWidth, height: 50))
            label.text = title
            label.textAlignment = .left
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = .darkGray
            headerView.addSubview(label)
        }

        tableView.tableHeaderView = headerView
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Timetable",
            message: "Are you sure you want to delete this timetable?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.deleteTimeTable()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    func deleteTimeTable() {
        let apiUrl = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/year/timetable/remove?day=\(selectedDay)"
        
        guard let url = URL(string: apiUrl) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("✅ Timetable successfully deleted!")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("❌ Failed to delete timetable.")
                }
            }
        }.resume()
    }
}
extension DetailTimeTableViewController {
    
    // MARK: - Show Picker for Period Selection
    func showPeriodPicker(for cell: DetailTimeTableTableViewCell) {
        let alert = UIAlertController(title: "Select Period", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = 1 // Tag to differentiate pickers
        
        alert.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50)
        ])
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedPeriod = self.allPeriods[selectedRow]
//            self.timeTableData[selectedRow].period
            cell.period.text = "\(selectedPeriod)"
            self.selectedPeriod  = "\(selectedPeriod)"
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @IBAction func BackButton(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
        }
    
    @IBAction func addSessionTapped(_ sender: UIButton) {
        
        guard let startTime = selectedStartingTime,
              let endTime = selectedEndingTime,
              let period = selectedPeriod,
              let selectedSubjectIndex = selectedSubjectIndex,
              let selectedStaffIndex = selectedStaffIndex,
              selectedSubjectIndex < subjectIds.count,
              selectedStaffIndex < staffIds.count else {
            print("⚠️ Missing required data or invalid selection")
            return
        }
        
        let subjectId = subjectIds[selectedSubjectIndex]
        let staffId = staffIds[selectedStaffIndex]

        let apiUrl = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/staff/\(staffId)/year/timetable/add"
        
        let requestBody: [String: Any] = [
            "day": "\(selectedDay)",
            "endTime": endTime,
            "period": "\(period)",
            "startTime": startTime
        ]
        
        print("🟢 Request URL: \(apiUrl)")
        print("🟢 Request Body: \(requestBody)")
        
        let token = TokenManager.shared.getToken() ?? ""
        print("🔑 Bearer Token post: \(token)")

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("🟢 API Response: \(responseString)")
                    
                    if httpResponse.statusCode == 200 {
                        print("✅ Session saved successfully!")
                    } else {
                        print("❌ Failed to save session, status code: \(httpResponse.statusCode)")
                    }
                } else {
                    print("❌ No data received")
                }
            }
        }
        task.resume()
    }


    func showTimePicker(for cell: DetailTimeTableTableViewCell, isStartingTime: Bool) {
        let alert = UIAlertController(title: "Select Time", message: nil, preferredStyle: .alert)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels

        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50)
        ])

        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let selectedTime = formatter.string(from: datePicker.date)
            
            if isStartingTime {
                cell.startingTime.text = selectedTime
                self.selectedStartingTime = selectedTime
            } else {
                cell.endingTime.text = selectedTime
                self.selectedEndingTime = selectedTime
            }
        }

        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - Show Picker for Subject Selection
    func showSubjectPicker(for cell: DetailTimeTableTableViewCell) {
        let alert = UIAlertController(title: "Select Subject", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = 2
        
        alert.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50)
        ])
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedSubject = self.subjectNames[selectedRow]
            self.selectedSubjectIndex = selectedRow
            cell.subject.text = selectedSubject
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func showTeacherPicker(for cell: DetailTimeTableTableViewCell) {
        let alert = UIAlertController(title: "Select Teacher", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = 3

        alert.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50)
        ])

        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedTeacher = self.teacherNames[selectedRow]
            self.selectedStaffIndex = selectedRow
            cell.teacher.text = selectedTeacher
            self.selectedTeacher = selectedTeacher
        }

        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}


extension DetailTimeTableViewController: UITableViewDelegate, UITableViewDataSource {
    private func createHeaderCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "headerCell")
        cell.backgroundColor = UIColor.systemGray6
        cell.textLabel?.text = "Period       Time          Subject               Teacher"
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTableData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTimeTableTableViewCell", for: indexPath) as? DetailTimeTableTableViewCell else {
            return UITableViewCell()
        }

        let session = indexPath.row < timeTableData.count ? timeTableData[indexPath.row] : nil
        configureCell(cell, with: session)

        return cell
    }

    private func configureCell(_ cell: DetailTimeTableTableViewCell, with session: Session?) {
        if let session = session {
            cell.configure(with: session)
        } else {
            cell.configureAsEmpty()
        }

        cell.onPeriodSelection = { [weak self] in
            self?.showPeriodPicker(for: cell)
        }

        cell.onTimeSelection = { [weak self] isStartingTime in
            self?.showTimePicker(for: cell, isStartingTime: isStartingTime)
        }

        cell.onSubjectSelection = { [weak self] in
            self?.showSubjectPicker(for: cell)
        }

        cell.onTeacherSelection = { [weak self] in
            self?.showTeacherPicker(for: cell)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 50 : 80
    }
}

extension DetailTimeTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return allPeriods.count
        case 2:
            return subjectNames.count
        case 3:
            return teacherNames.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return allPeriods[row]
        case 2:
            return subjectNames[row]
        case 3:
            return teacherNames[row]
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            selectedPeriod = allPeriods[row]
        case 2:
            selectedSession?.subjectName = subjectNames[row]
        case 3:
            selectedTeacher = teacherNames[row]
        default:
            break
        }
    }
}

extension DetailTimeTableViewController {
    func fetchDetailTimeTable() {
        let apiUrl = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/year/timetable/get?day=\(selectedDay)"
        
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
                print("🟢 Raw API Response fetchDetailTimeTable: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(AcademicScheduleResponse.self, from: data)
                self.timeTableData = decodedResponse.data.first?.sessions ?? []

                self.globalStaffIds = self.timeTableData.compactMap { $0.staffId }
                self.globalSubjectIds = self.timeTableData.compactMap { $0.subjectId }

                print("🟢 Global Staff IDs: \(self.globalStaffIds)")
                print("🟢 Global Subject IDs: \(self.globalSubjectIds)")
                print("🟢 Timetable Data: \(self.timeTableData)")

                // Extract periods
                let periods = self.allPeriods
                self.timeTableData.map { $0.period }
                print("🟢 Periods Array: \(periods)")

                let subjects = self.timeTableData.map { $0.subjectName }
                print("🟢 Subjects Array: \(subjects)")

                let teachers = self.timeTableData.compactMap { $0.teacherName }
                print("🟢 Teachers Array: \(teachers)")

                print("🔹 Timetable Details:")
                for (index, session) in self.timeTableData.enumerated() {
                    print("🔹 Period: \(session.period) | Subject: \(session.subjectName) | Teacher: \(session.teacherName ?? "N/A")")
                }
                self.teachers = self.timeTableData.compactMap { $0.teacherName }


                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func addTimeTable() {
        let apiUrl = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/year/timetable/add"
        print("🟡 API URL addTimeTable: \(apiUrl)")
        
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "day": "1",
            "period": "2"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("🟡 Request Body: \(jsonString)")             }
        } catch {
            print("❌ Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🟢 Raw addTimeTable API Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(EditTimetableResponse.self, from: data)
                
                let convertedData: [ClassData] = decodedResponse.data.map { subjectData in
                    return ClassData(id: subjectData.subjectWithStaffId,
                                     className: subjectData.subjectName,
                                     classTeacher: subjectData.subjectWithStaffs.first?.staffName ?? "")
                }
                
                DispatchQueue.main.async {
                    self.timetableResponseData = convertedData
                    print("🟢 Decoded TimetableResponse Data: \(self.timetableResponseData)")
                }
                
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }

}
