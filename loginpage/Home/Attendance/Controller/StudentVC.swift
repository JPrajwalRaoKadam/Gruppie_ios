////
//  StudentVC.swift
//  loginpage
//
//  Created by apple on 27/03/25.
//

import UIKit

class StudentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, StudentCellDelegate {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var studentTBL: UITableView!
    @IBOutlet weak var currDate: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    
    var studentID: String?
    var currentDatePicker: UIDatePicker?
    var groupId: String?
    var teamId: String?
    var currentDate: String?
    var className: String?
    var students: [StudentAtten] = []
    var attendanceData: [Attendance] = []
    var selectedClassnumberOfTimeAttendance: Int?
    var uncheckedStudents: [String] = []  // ✅ Array to hold unchecked (absent) students
    var uncheckedStudentsIds: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTBL.register(UINib(nibName: "StudentVCTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentVCTableViewCell")
        studentTBL.dataSource = self
        studentTBL.delegate = self
        self.navigationItem.hidesBackButton = true

        DoneButton.layer.cornerRadius =  10
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        print("absent curDate: \(currDate)")
        // Display the class name in the label
        name.text = className != nil ? "Attendance - (\(className!))" : "No Class Name"
        print("Received attendanceData no of numberOfTimeAttendance: \(selectedClassnumberOfTimeAttendance)")
        setCurrentDate()
        fetchStudentData()
    }
    
//    @IBAction func doneButton(_ sender: Any) {
//        
//    }
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

    
    // ✅ TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentVCTableViewCell", for: indexPath) as? StudentVCTableViewCell else {
            return UITableViewCell()
        }

        let student = students[indexPath.row]
        cell.delegate = self

        // Set student details
        cell.studentName.text = student.studentName
        cell.studentID = student.userId
        cell.students = students
        self.studentID = student.userId
        cell.rollNo.text = "Roll No: \(student.rollNumber)"
        
        // Load student image or show fallback
        if let imageUrlString = student.studentImage,
           !imageUrlString.isEmpty,
           let imageUrl = URL(string: imageUrlString) {
            
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.images.image = image
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

        // Pass the numberOfTimeAttendance to the cell
        if indexPath.row < attendanceData.count {
            let attendance = attendanceData[indexPath.row]
            if let numberOfTimes = Int(attendance.numberOfTimeAttendance) {
                cell.configureAttendanceButtons(numberOfTimes: numberOfTimes)
            }
        }

        return cell
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


        // ✅ Example of how to send unchecked students to the server or other VC
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
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            currentDate = dateFormatter.string(from: previousDay)
            currDate.setTitle(currentDate, for: .normal)
            
            print("Selected Date: \(currentDate ?? "")")
            fetchStudentData()
        }
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
        
        // Store the selected button to update its title later
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

