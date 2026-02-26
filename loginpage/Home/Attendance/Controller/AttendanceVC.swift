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
   var groupAcademicYearResponse: GroupAcademicYearResponse?
   var attendanceSettingsResponse: AttendanceSettingsAllResponse?
   var groupAcademicYearId: String?
   var attendanceClasses: [AttendanceClassSummary] = []
   var currentDatePicker: UIDatePicker?
   var currentDate : String?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        midview.layer.cornerRadius = 10
        TableView.layer.cornerRadius = 10
        self.navigationItem.hidesBackButton = true
        
        TableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        TableView.dataSource = self
        TableView.delegate = self
        // TableView.layer.cornerRadius = 15
        TableView.layer.masksToBounds = true
       
        if let response = groupAcademicYearResponse {
               print("✅ groupAcademicYearResponse received")

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
        
        setCurrentDate()
        fetchAttendanceData()
        enableKeyboardDismissOnTap()
        fetchAttendanceSettingsAll()

        
    }

 func fetchAttendanceData() {
     
     guard let roleToken = SessionManager.useRoleToken else {
         print("❌ Role token missing")
         return
     }

     guard let groupAcademicYearId =
             groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
         print("❌ groupAcademicYearId not available from GroupAcademicYearResponse")
         return
     }


     let inputFormatter = DateFormatter()
     inputFormatter.dateFormat = "dd-MM-yyyy"

     guard let selected = currentDate,
           let date = inputFormatter.date(from: selected) else {
         print("Invalid date")
         return
     }

     let outputFormatter = DateFormatter()
     outputFormatter.dateFormat = "yyyy-MM-dd"
     let apiDate = outputFormatter.string(from: date)

     let headers = [
         "Authorization": "Bearer \(roleToken)"   // ✅ fixed here
     ]

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

             self.TableView.reloadData()

         case .failure(let error):
             print("❌ Attendance summary error :", error)
         }
     }
 }
    
    func fetchAttendanceSettingsAll() {
        
        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        guard let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not found")
            return
        }

        let headers = [
            "Authorization": "Bearer \(roleToken)"
        ]

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

                self.attendanceSettingsResponse = response   // ✅ store it

                print("✅ Attendance settings loaded")
                print("Classes count :", response.data.count)

            case .failure(let error):
                print("❌ Attendance settings error :", error)
            }
        }
    }
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Setting(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "AttenSettingVC") as? AttenSettingVC {
            
            // Pass the groupId to AttenSettingVC
           // settingsVC.groupId = self.groupId
            
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

extension AttendanceVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceClasses.count
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AttendanceTableViewCell",
            for: indexPath
        ) as! AttendanceTableViewCell
        
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
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedClass = attendanceClasses[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
        
        guard let studentVC = storyboard
            .instantiateViewController(withIdentifier: "StudentVC") as? StudentVC else {
            print("❌ Could not instantiate StudentVC")
            return
        }
        
        studentVC.classId = selectedClass.classId
        studentVC.className = selectedClass.className
        studentVC.groupAcademicYearResponse = self.groupAcademicYearResponse
        studentVC.attendanceSettingsResponse = self.attendanceSettingsResponse

        navigationController?.pushViewController(studentVC, animated: true)
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if currentRole == "teacher" || currentRole == "parent" {
    //            // Navigate to subject-specific attendance view for teachers
    //            let selectedSubject = subjects[indexPath.row]
    //            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
    //            if let StudentVC = storyboard.instantiateViewController(withIdentifier: "StudentVC") as? StudentVC {
    //                StudentVC.currentDate = currentDate
    //               // StudentVC.groupId = groupId
    //                let subject = subjects[indexPath.row]
    //                StudentVC.teamId = subject.teamId
    //                StudentVC.className = subject.name
    ////                StudentVC.attendanceData = self.attendanceData
    //  //             StudentVC.selectedClassnumberOfTimeAttendance = Int(selectedAttendance.numberOfTimeAttendance)
    //                navigationController?.pushViewController(StudentVC, animated: true)
    //            } else {
    //                print("❌ Could not instantiate SubjectAttendanceVC")
    //            }
    //        } else if currentRole == "admin" {
    //            // Navigate to student list for selected class
    //            let selectedAttendance = attendanceData[indexPath.row]
    //            let storyboard = UIStoryboard(name: "Attendance", bundle: nil)
    //            if let StudentVC = storyboard.instantiateViewController(withIdentifier: "StudentVC") as? StudentVC {
    //               // StudentVC.groupId = groupId
    //                StudentVC.teamId = selectedAttendance.teamId
    //                StudentVC.currentDate = currentDate
    //                StudentVC.className = selectedAttendance.name
    //                StudentVC.attendanceData = self.attendanceData
    //                StudentVC.selectedClassnumberOfTimeAttendance = Int(selectedAttendance.numberOfTimeAttendance)
    //                navigationController?.pushViewController(StudentVC, animated: true)
    //            } else {
    //                print("❌ Could not instantiate StudentVC")
    //            }
    //        } else {
    //
    //        }
    //    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
