//
//  AttendanceVC.swift
//  loginpage
//
//  Created by apple on 10/02/25.
//

import UIKit

class AttendanceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var midview: UIView!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var curDate: UIButton!
    var groupId: String?
    var school: School?
    var currentDatePicker: UIDatePicker?
    var currentDate : String?
    var attendanceData: [Attendance] = []
    var classDetails: [[String: Any]] = []
    var subjects: [SubjectData] = []
    var teamid: String?
    var currentRole: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        midview.layer.cornerRadius = 10
        TableView.layer.cornerRadius = 10
        self.navigationItem.hidesBackButton = true
       // print("grpid atten:\(currentDate) ")
        print("grpid atten:\(String(describing: groupId)) ")
        print( "atten:\(attendanceData) ")
        
        
        TableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        TableView.dataSource = self
        TableView.delegate = self
        // TableView.layer.cornerRadius = 15
        TableView.layer.masksToBounds = true
        
        if currentRole == "teacher" {
              setting.isHidden = true
          }
        
        setCurrentDate()
        fetchAttendanceData()
        enableKeyboardDismissOnTap()
        
    }
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Setting(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "AttenSettingVC") as? AttenSettingVC {
            
            // Pass the groupId to AttenSettingVC
            settingsVC.groupId = self.groupId
            
            self.navigationController?.pushViewController(settingsVC, animated: true)
        } else {
            print("Failed to instantiate AttenSettingVC")
        }
    }
    
    

    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Format: 11-02-2025
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        curDate.setTitle(self.currentDate, for: .normal) // Set button title
        print("Current Date: \(currentDate)") // Print current date in console
    }
    
    @IBAction func nextDate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        let todayDate = Date()
        
        // Check if the next day is not beyond today
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
           nextDay <= todayDate {
            currentDate = dateFormatter.string(from: nextDay)
            curDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            fetchAttendanceData()
        } else {
            print("Cannot go beyond today's date")
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
            fetchAttendanceData()
        }
    }
    
    @IBAction func curDate(_ sender: Any) {
        
        showDatePickerPopup(for: sender as! UIButton) // Call the date picker function
    }
    
    func fetchAttendanceData() {
        guard let groupId = groupId else {
            print("Group ID is missing")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }
        guard let currentDate = currentDate else {
            print("Current date not available")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/attendance/get?date=\(currentDate)&type=attendance"

        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/attendance/get?date=20-02-2024&type=attendance"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching attendance data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response of attendance: \(rawResponse)")
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let attendanceData = jsonResponse["data"] as? [[String: Any]] {
                    print("Parsed JSON Response: \(jsonResponse)")
                    self.attendanceData = attendanceData.map { student in
                        return Attendance(
                            teamId: student["teamId"] as? String ?? "",
                            numberOfTimeAttendance: student["numberOfTimeAttendance"] as? String ?? "0",
                            name: student["name"] as? String ?? "",
                            image: student["image"] as? String,
                            attendanceTaken: student["attendanceTaken"] as? Bool ?? false,
                            attendanceStatus: (student["attendanceStatus"] as? [[String: Any]])?.map { status in
                                return Attendance.AttendanceStatus(
                                    type: status["type"] as? String ?? "",
                                    present: status["present"] as? Int ?? 0,
                                    absent: status["absent"] as? Int ?? 0
                                )
                            } ?? [], // Provide a default empty array if the mapping fails
                            classSort: student["classSort"] as? Int
                        )
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.TableView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentRole == "admin" {
            return attendanceData.count
        } else {
            return subjects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath) as? AttendanceTableViewCell else {
            fatalError("Cell could not be dequeued")
        }
        
        if currentRole == "admin" {
            let attendance = attendanceData[indexPath.row]
            cell.configure(with: attendance)
            
            // Reset image and fallback
            cell.img.image = nil
            cell.fallbackLabel.isHidden = false
            cell.showFallbackImage(for: attendance.name)
            
            // Load image if available
            if let imageUrlString = attendance.image,
               !imageUrlString.isEmpty,
               imageUrlString != "image_url_or_path",
               let imageUrl = URL(string: imageUrlString) {
                
                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            // Only update if cell is still visible for this index path
                            if tableView.indexPath(for: cell) == indexPath {
//                                cell.img.image = image
                                cell.fallbackLabel.isHidden = false
                            }
                        }
                    }
                }.resume()
            }
        } else {
            let subject = subjects[indexPath.row]
            cell.classLabel.text = subject.name
            cell.periodLabel.isHidden = false
            cell.showFallbackImage(for: subject.name)
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentRole == "teacher" || currentRole == "parent" {
            // Navigate to subject-specific attendance view for teachers
            let selectedSubject = subjects[indexPath.row]
            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
            if let StudentVC = storyboard.instantiateViewController(withIdentifier: "StudentVC") as? StudentVC {
                StudentVC.currentDate = currentDate
                StudentVC.groupId = groupId
                let subject = subjects[indexPath.row]
                StudentVC.teamId = subject.teamId
                StudentVC.className = subject.name
//                StudentVC.attendanceData = self.attendanceData
  //             StudentVC.selectedClassnumberOfTimeAttendance = Int(selectedAttendance.numberOfTimeAttendance)
                navigationController?.pushViewController(StudentVC, animated: true)
            } else {
                print("❌ Could not instantiate SubjectAttendanceVC")
            }
        } else if currentRole == "admin" {
            // Navigate to student list for selected class
            let selectedAttendance = attendanceData[indexPath.row]
            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
            if let StudentVC = storyboard.instantiateViewController(withIdentifier: "StudentVC") as? StudentVC {
                StudentVC.groupId = groupId
                StudentVC.teamId = selectedAttendance.teamId
                StudentVC.currentDate = currentDate
                StudentVC.className = selectedAttendance.name
                StudentVC.attendanceData = self.attendanceData
                StudentVC.selectedClassnumberOfTimeAttendance = Int(selectedAttendance.numberOfTimeAttendance)
                navigationController?.pushViewController(StudentVC, animated: true)
            } else {
                print("❌ Could not instantiate StudentVC")
            }
        } else {
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
               return 70
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
        
        // Store the selected button to update its title later
        curDate = button
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy" // Format matching your API
            let selectedDate = formatter.string(from: datePicker.date)
            
            curDate.setTitle(selectedDate, for: .normal) // Update button title
            currentDate = selectedDate // Update selected date
            
            print("Selected Date: \(selectedDate)")
            
            fetchAttendanceData() // Fetch data for the selected date
            
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
