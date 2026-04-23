//
//  AbsentStudentVC.swift
//  loginpage
//
//  Created by apple on 07/04/25.

import UIKit

class AbsentStudentVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var classId: String?
    var attendanceSettingsId: String?
    var groupAcademicYearId: String?
    var sessionDate: String?
    var uncheckedStudents: [String] = []
    var uncheckedStudentsIds: [String] = []
    var presentStudentIds: [String] = []
    var subjectList: [SubjectRegisterSubject] = []
    
    var groupId: String?
    var teamId: String?
    var absentList: [String] = []  // <-- This will receive the data
   
    var attendanceData: [Attendance] = []
    var selectedSubjectIds: [String] = []
    var numberOfTimeAttendance: Int?
    var periodId : String?
    var selectedClassAttendance: Attendance?
    var subID: String?
    var studentID: String?
    var selectedSubjectIndex: IndexPath?
    var selectedPeriodIndex: IndexPath?
    var selectedPeriodNumber: Int?
    var currDate: String?
    var currentDate: String?
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var abtableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPeriodOnLoad()
        DispatchQueue.main.async {
              self.abtableview.reloadData()
              self.checkPeriodOnLoad()
          }
        DoneButton.layer.cornerRadius =  10
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        abtableview.dataSource = self
        abtableview.delegate = self
        abtableview.register(UINib(nibName: "AbsentStudentTableViewCell", bundle: nil), forCellReuseIdentifier: "AbsentStudentTableViewCell")
        abtableview.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectTableViewCell")
//        abtableview.register(UINib(nibName: "PeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "PeriodTableViewCell")
        abtableview.register(UINib(nibName: "A2SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "A2SubjectTableViewCell")
        abtableview.register(UINib(nibName: "A3PeriodTableViewCell", bundle: nil), forCellReuseIdentifier: "A3PeriodTableViewCell")
        print("Received attendanceData @ absent: \(attendanceData)")
        print("Absent Students ab: \(absentList)") // Debug print
        print("teamId ab: \(teamId)")
        print("groupId ab: \(groupId)")
        print("stuId Ab: \(uncheckedStudentsIds)")
        print("curr date for api call\(currDate)")
        print("selected date for api call\(currentDate)")
        print("✅ groupAcademicYearResponse :", groupAcademicYearResponse as Any)
        print("✅ classId :", classId as Any)
        print("✅ attendanceSettingsId :", attendanceSettingsId as Any)
        print("✅ groupAcademicYearId :", groupAcademicYearId as Any)
        print("✅ sessionDate :", sessionDate as Any)
        print("✅ presentStudentIds array count =", presentStudentIds.count)

            for id in presentStudentIds {
                print("👉 present student id =", id)
            }
        fetchSubjectRegister()
        enableKeyboardDismissOnTap()
      }
    func checkPeriodOnLoad() {
        if (numberOfTimeAttendance ?? 0) == 0 {
            
            let alert = UIAlertController(
                title: "Warning",
                message: "No periods available, attendance cannot be taken",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.goBack()
            }))
            
            present(alert, animated: true)
        }
    }
    
    func goBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
      func numberOfSections(in tableView: UITableView) -> Int {
          return 3
      }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label

        switch section {
        case 0:
            label.text = "Absent Students"
        case 1:
            label.text = "Select Subjects"
        case 2:
            label.text = "Select Periods"
        default:
            label.text = ""
        }

        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return absentList.count // Only one cell that contains a nested tableView of absentees
        case 1:
            return subjectList.count
        case 2:
            return numberOfTimeAttendance ?? 0
        default:
            return 0
        }
    }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          switch indexPath.section {
          case 0:
              let cell = tableView.dequeueReusableCell(withIdentifier: "AbsentStudentTableViewCell", for: indexPath) as! AbsentStudentTableViewCell
              let name = absentList[indexPath.row]
               cell.configure(name: name)
              return cell

          case 1:

              let cell = tableView.dequeueReusableCell(
                  withIdentifier: "A2SubjectTableViewCell",
                  for: indexPath
              ) as! A2SubjectTableViewCell

              let subject = subjectList[indexPath.row]

              cell.SubjectsName.text = subject.subjectName
              cell.subjectId = String(subject.subjectId)

              cell.checkButton.isSelected = (indexPath == selectedSubjectIndex)

              cell.onCheckButtonTapped = { [weak self] subjectId, isSelected in
                  guard let self = self else { return }

                  if isSelected {

                      if let old = self.selectedSubjectIndex, old != indexPath {
                          self.selectedSubjectIndex = indexPath
                          self.abtableview.reloadRows(at: [old, indexPath], with: .none)
                      } else {
                          self.selectedSubjectIndex = indexPath
                          self.abtableview.reloadRows(at: [indexPath], with: .none)
                      }

                      // ✅ store single subject id for next API
                      self.subID = subjectId
                      print("✅ Selected subjectId =", subjectId)

                  } else {

                      self.selectedSubjectIndex = nil
                      self.subID = nil
                      self.abtableview.reloadRows(at: [indexPath], with: .none)

                  }
              }

              return cell

              
//          case 2:
//              let cell = tableView.dequeueReusableCell(withIdentifier: "A3PeriodTableViewCell", for: indexPath) as! A3PeriodTableViewCell
//              cell.delegate = self
//              cell.PeriodName.text = "Period \(indexPath.row + 1)"
//              self.absentList
//              return cell
//          default:
//              let cell = UITableViewCell()
//              cell.selectionStyle = .none
//                 return cell
          case 2:
              let cell = tableView.dequeueReusableCell(withIdentifier: "A3PeriodTableViewCell", for: indexPath) as! A3PeriodTableViewCell
              cell.delegate = self
              cell.PeriodName.text = "Period \(indexPath.row + 1)"
              
              // Check button state based on selectedPeriodIndex
              cell.checkButton.isSelected = (indexPath == selectedPeriodIndex)
              
              return cell

          default:
              return UITableViewCell()
          }
      }
    
    
    @IBAction func DoneButton(_ sender: Any) {
        if let selectedId = subID {
              print("🎯 Selected subject ID: \(selectedId)")
              // You can use selectedId in your API call here
          } else {
              print("⚠️ No subject selected.")
          }
        if let period = selectedPeriodNumber {
               print("🕒 Selected Period Number: \(period)")
               // Use this period for your API call
           } else {
               print("⚠️ No period selected.")
           }
        callAttendanceSessionsAPI()
       // self.dismiss(animated: true, completion: nil) // ✅ Dismiss view controller
        // In AbsentStudentVC, when dismissing (after done button is pressed)
        dismiss(animated: true) {
            // Notify StudentVC to reset checkboxes
            if let studentVC = self.presentingViewController as? StudentVC {
                studentVC.resetAllCheckboxes()
            }
        }
    }
    
   func fetchSubjectRegister() {
        
       guard let token = SessionManager.useRoleToken else {
           print("❌ Role token missing")
           return
       }

        guard let classId = classId,
              let groupAcademicYearId = groupAcademicYearId else {
            print("❌ classId / groupAcademicYearId missing")
            return
        }

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        let queryParams: [String: String] = [
            "groupAcademicYearId": groupAcademicYearId,
            "classId": classId,
            "page": "1",
            "limit": "10"
        ]

        APIManager.shared.request(
            endpoint: "subject-register",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<SubjectRegisterResponse1, APIManager.APIError>) in

            switch result {

            case .success(let response):

                // flatten all groups into single list
                let subjects = response.data.subjectGroups.flatMap { $0.subjects }

                self.subjectList = subjects

                print("✅ Class :", response.data.class.className)
                print("✅ Total subjects :", subjects.count)

                for s in subjects {
                    print("Subject :", s.subjectName, " id :", s.subjectId)
                }

                DispatchQueue.main.async {
                    self.abtableview.reloadData()
                }

            case .failure(let error):

                print("❌ subject api error :", error)

                if case .decodingError = error {
                    print("❌ Decoding failed – check subject models")
                }
            }
        }
    }
    
    func callAttendanceSessionsAPI() {

        guard let token = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        guard let sessionDate = convertToAPIDate(sessionDate ?? "Missing date"),
              !sessionDate.isEmpty,
              let period = selectedPeriodNumber,
              let subjectIdStr = subID,
              let subjectId = Int(subjectIdStr),
              let attendanceSettingsIdStr = attendanceSettingsId,
              let attendanceSettingsId = Int(attendanceSettingsIdStr)
        else {
            print("❌ Missing required values")
            print("➡️ currentDate =", currentDate as Any)
            print("➡️ sessionDate =", self.sessionDate as Any)
            return
        }

        let absentString  = uncheckedStudentsIds.joined(separator: ",")
        let presentString = presentStudentIds.joined(separator: ",")

        let body: [String: Any] = [
            "sessionNumber": period,
            "sessionDate": sessionDate,   // ✅ now never null
            "attendance": [
                ["Present": presentString],
                ["absent": absentString],
                ["leave": ""]
            ],
            "subjectId": subjectId,
            "attendanceSettingsId": attendanceSettingsId
        ]

        print("📤 attendance-sessions body =", body)

        let urlString = APIManager.shared.baseURL + "attendance-sessions"

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let http = response as? HTTPURLResponse {
                print("✅ Status code :", http.statusCode)
            }

            guard let data else { return }

            if let json = String(data: data, encoding: .utf8) {
                print("📥 attendance-sessions response :", json)
            }

            do {
                let result = try JSONDecoder().decode(CommonSuccessResponse.self, from: data)

                if result.success {
                    DispatchQueue.main.async {
                        self.showToast(message: result.message)
                    }
                }

            } catch {
                print("❌ decode error :", error)
            }

        }.resume()
    }
    
    func convertToAPIDate(_ input: String) -> String? {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: input) else {
            return nil
        }

        return outputFormatter.string(from: date)
    }
    
    func showToast(message: String) {

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true

        let width = view.frame.width - 40
        label.frame = CGRect(x: 20,
                              y: view.frame.height - 120,
                              width: width,
                              height: 40)

        view.addSubview(label)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            label.removeFromSuperview()
        }
    }

}
extension AbsentStudentVC: A3PeriodTableViewCellDelegate {
//    func didTogglePeriodSelection(cell: A3PeriodTableViewCell, isSelected: Bool) {
//        guard let indexPath = abtableview.indexPath(for: cell) else { return }
//
//        print("Period at section \(indexPath.section), row \(indexPath.row) is now \(isSelected ? "selected" : "deselected")")
//
//        // Example: store selected periods
//        if isSelected {
//            print("✅ Save this period selection")
//        } else {
//            print("❌ Remove this period selection")
//        }
//    }
    func didTogglePeriodSelection(cell: A3PeriodTableViewCell, isSelected: Bool) {
        guard let indexPath = abtableview.indexPath(for: cell) else { return }

        if isSelected {
            // Deselect previously selected cell
            if let previousIndex = selectedPeriodIndex, previousIndex != indexPath {
                selectedPeriodIndex = indexPath
                selectedPeriodNumber = indexPath.row + 1
                abtableview.reloadRows(at: [previousIndex, indexPath], with: .none)
            } else {
                selectedPeriodIndex = indexPath
                selectedPeriodNumber = indexPath.row + 1
                abtableview.reloadRows(at: [indexPath], with: .none)
            }
            print("✅ Selected Period: \(selectedPeriodNumber ?? -1)")

        } else {
            // If the user taps to deselect the already selected period
            selectedPeriodIndex = nil
            selectedPeriodNumber = nil
            abtableview.reloadRows(at: [indexPath], with: .none)
            print("❌ Deselected Period")
        }
    }

}



            
