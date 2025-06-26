//
//  AbsentStudentVC.swift
//  loginpage
//
//  Created by apple on 07/04/25.

import UIKit

class AbsentStudentVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
 
    var groupId: String?
    var teamId: String?
    var absentList: [String] = []  // <-- This will receive the data
    var subjectList: [SubjectDataAtten] = []
    var attendanceData: [Attendance] = []
    var selectedSubjectIds: [String] = []
    var numberOfTimeAttendance: Int?
    var periodId : String?
    var selectedClassAttendance: Attendance?
    var subID: String?
    var studentID: String?
    var uncheckedStudentsIds: [String] = []
    var selectedSubjectIndex: IndexPath?
    var selectedPeriodIndex: IndexPath?
    var selectedPeriodNumber: Int?
    var currDate: String?
    var currentDate: String?
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var abtableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        fetchSubjects()
        enableKeyboardDismissOnTap()
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
              cell.absentStudentName.text = absentList[indexPath.row]
              return cell

          case 1:
              let cell = tableView.dequeueReusableCell(withIdentifier: "A2SubjectTableViewCell", for: indexPath) as! A2SubjectTableViewCell
              let subject = subjectList[indexPath.row]
              
              cell.SubjectsName.text = subject.subjectName
              cell.subjectId = subject.subjectId
              // Setup selection state
              cell.checkButton.isSelected = (indexPath == selectedSubjectIndex)
              
              // Handle check button tapped
              cell.onCheckButtonTapped = { [weak self] subjectId, isSelected in
                  guard let self = self else { return }

                  if isSelected {
                      // Deselect previously selected cell
                      if let previousIndex = self.selectedSubjectIndex, previousIndex != indexPath {
                          self.selectedSubjectIndex = indexPath
                          self.abtableview.reloadRows(at: [previousIndex, indexPath], with: .none)
                          self.subID = subjectId
    
                      } else {
                          self.selectedSubjectIndex = indexPath
                          self.abtableview.reloadRows(at: [indexPath], with: .none)
                      }
                      self.subID = subjectId // Save selected subject ID
                      
                  } else {
                      self.selectedSubjectIndex = nil
                      self.subID = nil
                      self.abtableview.reloadRows(at: [indexPath], with: .none)
                      print("❌ Deselected Subject")
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
        callTakeAttendanceAPI()
        self.dismiss(animated: true, completion: nil) // ✅ Dismiss view controller
    }
    
      func fetchSubjects() {
         // Step 1: Get the token
         guard let token = TokenManager.shared.getToken() else {
             print("❌ Token not found")
             return
         }

         // Step 2: Validate groupId and teamId
         guard let groupId = groupId, !groupId.isEmpty,
               let teamId = teamId, !teamId.isEmpty else {
             print("❌ Group ID or Team ID is not set properly")
             return
         }

         // Step 3: Construct the URL
         let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/get"
         guard let url = URL(string: urlString) else {
             print("❌ Invalid URL")
             return
         }

         // Step 4: Create request
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

         // Step 5: Make the network call
         URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 print("❌ Request error: \(error.localizedDescription)")
                 return
             }

             guard let data = data else {
                 print("❌ No data found")
                 return
             }

             // Step 6: Print raw JSON
             if let jsonString = String(data: data, encoding: .utf8) {
                 print("📥 Full JSON Response:\n\(jsonString)")
             }

             // Step 7: Decode JSON
             do {
                 let decoder = JSONDecoder()
                 let subjectResponse = try decoder.decode(SubjectResponseAtten.self, from: data)
                 self.subjectList = subjectResponse.data

                 DispatchQueue.main.async {
                     self.abtableview.reloadData()
                 }
             } catch {
                 print("❌ Decoding error: \(error)")
             }

         }.resume()
     }
    
    func callTakeAttendanceAPI() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        guard let groupId = groupId,
              let teamId = teamId,
              let currentDate = currentDate,
              let subjectId = subID,
              let period = selectedPeriodNumber else {
            print("❌ Missing required values")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/attendance/take/new?date=\(currentDate)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        let body: [String: Any] = [
            "absentStudentIds": uncheckedStudentsIds,
            "periodNumber": period,
            "subjectId": subjectId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to serialize body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data in response")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Response:\n\(jsonString)")
            }
        }.resume()
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



            
