//
//  Examination_ActivityVC.swift
//  loginpage
//
//  Created by apple on 11/09/25.
//

import UIKit

class Examination_ActivityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var bcbutton: UIButton!
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamId: String = ""
    var className: String = ""
    var subjects: [SubjectData] = [] // Store fetched subjects
    var currentRole: String?
    var userId:String = ""
    
    @IBOutlet weak var Notes_Video: UILabel!
    @IBOutlet weak var marks_card: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        marks_card.delegate = self
        marks_card.dataSource = self
        marks_card.register(UINib(nibName: "ClassNameExamCell", bundle: nil), forCellReuseIdentifier: "ClassNameExamCell")
        //print("gid NV: \(groupId) tid NV: \(subjects.teamId)")
        marks_card.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        enableKeyboardDismissOnTap()
        print("userid in Examination_ActivityVC :\(userId)")
        print("currentRole in Examination_ActivityVC :\(currentRole)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassNameExamCell", for: indexPath) as? ClassNameExamCell else {
            return UITableViewCell()
        }
        
        let subject = subjects[indexPath.row]
        cell.configure(with: subject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubject = subjects[indexPath.row]
        let teamId = selectedSubject.teamId
        self.className = selectedSubject.name
        print("Extracted teamId: \(teamId)")
        self.navigateToSubjectStaffVC(subjects: self.subjects, teamId: teamId, selectedSubject: selectedSubject)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigateToSubjectStaffVC(subjects: [SubjectData], teamId: String, selectedSubject: SubjectData) {
        let storyboard = UIStoryboard(name: "Examination Activity", bundle: nil)
        if let examlist = storyboard.instantiateViewController(withIdentifier: "Exam_listVC") as? Exam_listVC {
            examlist.groupId = self.groupId
            examlist.userId = self.userId
            examlist.teamId = teamId
            examlist.currentRole = self.currentRole
            examlist.className =  self.className
                  print("✅ Selected teamId: \(teamId)")
            self.navigationController?.pushViewController(examlist, animated: true)
        }
    }

}


//import UIKit
//
//protocol StudentMarksNewDetailDelegate: AnyObject {
//    func didUpdateMarks()
//}
//
//class Student_listVC: UIViewController {
//    @IBOutlet weak var bcbutton: UIButton!
//    @IBOutlet weak var subjectsTableView: UITableView!
//    @IBOutlet weak var subjectsLabel: UILabel!
//    @IBOutlet weak var studentMarksTableView: UITableView!
//    @IBOutlet weak var subjectsView: UIView!
//    @IBOutlet weak var AllSubTextFeild: UITextField!
//    @IBOutlet weak var submitAction: UIButton!
//    
//    @IBOutlet weak var editMarkView: UIView!
//    @IBOutlet weak var maxmarks: UILabel!
//    @IBOutlet weak var minmarks: UILabel!
//    @IBOutlet weak var obtmarkks1: UITextField!
//    @IBOutlet weak var obtmarkks2: UITextField!
//    
//    var groupId: String = ""
//    var teamId: String?
//    var testId: String?
//    var currentRole: String?
//    var offlineTestExamId: String?
//    weak var delegate: StudentMarksNewDetailDelegate?
//    var onMarksUpdated: (() -> Void)?
//    var studentMarkExamDataResponse: [StudentMarksData] = []
//    // var examDataResponse: [ExamData] = []
//    var passedExamTitle = ""
//    let subjectsHandler = SubjectsNewTableViewHandler()
//    let studentMarksHandler = StudentMarksNewTableViewHandler()
//    private var currentlyEditingStudentId: String?
//    var updatedMarksList: [[String: Any]] = []
//    var selectedStudentUserId: String?
//    
//    private var currentSelectedSubjectDetail: SubjectMarksDetails?
//     private var currentSelectedStudentId: String?
//     private var currentSelectedSubjectId: String?
//
//    override func viewDidLoad() {
//           super.viewDidLoad()
//           bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
//           bcbutton.clipsToBounds = true
//           subjectsTableView.layer.cornerRadius = 10
//           submitAction.layer.cornerRadius = 10
//        // Hide editMarkView initially
//        editMarkView.isHidden = true
//        
//           fetchMarksCardData { [weak self] in
//               guard let self = self else { return }
//               enableKeyboardDismissOnTap()
//               subjectsView.isHidden = true
//               let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell1", bundle: nil)
//               subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell1")
//               studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell1", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell1")
//               setupTableViews()
//               self.setupSubjectSelectionForTeacher()
//           }
//       }
//    
//    private func showEditMarkView(with subjectDetail: SubjectMarksDetails, studentId: String?, subjectId: String?) {
//            currentSelectedSubjectDetail = subjectDetail
//            currentSelectedStudentId = studentId
//            currentSelectedSubjectId = subjectId
//            
//            // Populate the editMarkView with data
//            maxmarks.text = "Max: \(subjectDetail.maxMarks)"
//            minmarks.text = "Min: \(subjectDetail.minMarks)"
//            
//            // Populate the marks fields if there are subMarks
//            if !subjectDetail.subMarks.isEmpty {
//                // Assuming subMarks is an array of marks, adjust according to your data structure
//                for (index, subMark) in subjectDetail.subMarks.enumerated() {
//                    if index == 0 {
//                        obtmarkks1.text = "\(subMark)" // Adjust based on your actual data structure
//                    } else if index == 1 {
//                        obtmarkks2.text = "\(subMark)" // Adjust based on your actual data structure
//                    }
//                }
//            } else {
//                // Clear fields if no subMarks
//                obtmarkks1.text = ""
//                obtmarkks2.text = ""
//            }
//            
//            // Show the editMarkView with animation
//            editMarkView.isHidden = false
//            editMarkView.alpha = 0
//            UIView.animate(withDuration: 0.3) {
//                self.editMarkView.alpha = 1
//            }
//            
//            print("📝 EditMarkView shown for student: \(studentId ?? ""), subject: \(subjectId ?? "")")
//        }
//        
//        private func hideEditMarkView() {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.editMarkView.alpha = 0
//            }) { _ in
//                self.editMarkView.isHidden = true
//                self.currentSelectedSubjectDetail = nil
//                self.currentSelectedStudentId = nil
//                self.currentSelectedSubjectId = nil
//            }
//        }
//        
//        // MARK: - Button Actions
//        
//        @IBAction func cancelButton(_ sender: Any) {
//            hideEditMarkView()
//        }
//        
//        @IBAction func addButton(_ sender: Any) {
//            // Handle adding/saving the marks from editMarkView
//            guard let subjectDetail = currentSelectedSubjectDetail,
//                  let studentId = currentSelectedStudentId,
//                  let subjectId = currentSelectedSubjectId else {
//                print("❌ No subject selected for editing")
//                return
//            }
//            
//            // Get the marks from text fields
//            let mark1 = obtmarkks1.text ?? ""
//            let mark2 = obtmarkks2.text ?? ""
//            
//            // Process the marks (you'll need to adjust this based on your API requirements)
//            print("💾 Saving marks for student \(studentId), subject \(subjectId):")
//            print("   Mark 1: \(mark1)")
//            print("   Mark 2: \(mark2)")
//            
//            // TODO: Implement your API call to save the marks
//            
//            // Hide the editMarkView after saving
//            hideEditMarkView()
//            
//            // Refresh the table view if needed
//            studentMarksTableView.reloadData()
//        }
//        
//        // MARK: - Setup Table Views
//        
//        private func setupTableViews() {
//            // Set up your table view handlers as before, but make sure to set the delegate
//            studentMarksHandler.delegate = self
//            // ... rest of your setup code
//        }
//    
//
//    func fetchMarksCardData(completion: @escaping () -> Void) {
//        guard let teamId = teamId, let testId = testId else {
//            print("❌ Missing teamId or testId")
//            return
//        }
//        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/new"
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL")
//            return
//        }
//        
//        guard let token = TokenManager.shared.getToken() else {
//            print("❌ Token not found")
//            return
//        }
//        print("📡 Calling API: \(urlString)")
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("❌ Error: \(error.localizedDescription)")
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ Invalid response")
//                return
//            }
//            print("📦 Status Code: \(httpResponse.statusCode)")
//            
//            guard let data = data else {
//                print("❌ No data received")
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                let responseModel = try decoder.decode(MarksCardResponse.self, from: data)
//                
//                // ✅ Store main data
//                self.studentMarkExamDataResponse = responseModel.data
//                
//                DispatchQueue.main.async {
//                    // ✅ Update handlers *before* reload
//                    self.subjectsHandler.studentMarkExamDataResponse = responseModel.data
//                    self.studentMarksHandler.studentMarkExamDataResponse = responseModel.data
//                    
//                    // ✅ Reload tables only once
//                    self.subjectsLabel.text = "Subjects (\(self.studentMarkExamDataResponse.count))"
//                    self.subjectsTableView.reloadData()
//                    self.studentMarksTableView.reloadData()
//                    
//                    print("✅ Successfully decoded and stored data.")
//                    print("🧑‍🎓 Students count: \(self.studentMarkExamDataResponse.count)")
//                    
//                    // ✅ Call completion
//                    completion()
//                }
//                
//            } catch {
//                print("❌ JSON Decoding Error:", error)
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("📄 Raw JSON:\n\(jsonString)")
//                }
//            }
//        }
//        task.resume()
//    }
//    
//   // https://gcc.gruppie.in/api/v1/groups/686cf36e7864a748c987e875/team/686cf36e7864a748c987e87a/testexam/6694fd7984288b5933b8cbf0/markscard/edit/new?userId=687a105f7864a74319bc15b6
//    
//    func updateMarksCard() {
//        guard let teamId = teamId,
//              let testId = testId,
//              let groupId = groupId as String?,
//              let token = TokenManager.shared.getToken() else {
//            showAlert(title: "Error", message: "Missing required information or token.")
//            return
//        }
//
//        // ✅ Print all student data before API call
//        print("📊 All student data before API call:")
//        for (index, student) in studentMarkExamDataResponse.enumerated() {
//            print("Student \(index): \(student.studentName ?? "")")
//            for subject in student.subjectMarksDetails {
//                print("   \(subject.subjectName ?? ""): \(subject.actualMarks ?? "nil")")
//            }
//        }
//
//        // ✅ Update marks for ALL students, not just the first one
//        for student in studentMarkExamDataResponse {
//            guard let gruppieRollNumber = student.gruppieRollNumber else {
//                print("❌ Missing gruppieRollNumber for student: \(student.studentName ?? "")")
//                continue
//            }
//
//            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(gruppieRollNumber)"
//            print("🌐 API URL for \(student.studentName ?? ""): \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                print("❌ Invalid URL for student: \(student.studentName ?? "")")
//                continue
//            }
//
//            // ✅ Construct subMarks array properly for this student
//            let subjectMarksArray = student.subjectMarksDetails.map { subject -> [String: Any] in
//                let subMarksArray = subject.subMarks.map { sub -> [String: Any] in
//                    return [
//                        "actualMarks": sub.actualMarks ?? "",
//                        "attendance": sub.attendance ?? "",
//                        "maxMarks": sub.maxMarks ?? "",
//                        "minMarks": sub.minMarks ?? "",
//                        "shortName": sub.shortName ?? "",
//                        "splitName": sub.splitName ?? "",
//                        "type": sub.type ?? ""
//                    ]
//                }
//
//                return [
//                    "actualMarks": subject.actualMarks ?? "",
//                    "attendance": subject.attendance ?? "",
//                    "date": subject.date ?? "",
//                    "enable": subject.enable ?? true,
//                    "endTime": subject.endTime ?? "",
//                    "gradeRange": subject.gradeRange,
//                    "inwords": subject.inwords ?? "",
//                    "maxMarks": subject.maxMarks,
//                    "minMarks": subject.minMarks,
//                    "shortName": subject.shortName ?? "",
//                    "startTime": subject.startTime ?? "",
//                    "subMarks": subMarksArray,
//                    "subjectAverageMarks": subject.subjectAverageMarks ?? 0.0,
//                    "subjectGrade": subject.subjectGrade ?? "",
//                    "subjectId": subject.subjectId ?? "",
//                    "subjectName": subject.subjectName ?? "",
//                    "subjectPriority": subject.subjectPriority ?? 0,
//                    "subjectSort": subject.subjectSort ?? 0,
//                    "submarkslength": subject.submarkslength ?? 0,
//                    "type": subject.type ?? ""
//                ]
//            }
//
//            // ✅ Create minimal body for this student
//            let minimalBody: [String: Any] = [
//                "studentId": student.studentId ?? "",
//                "testId": student.testId ?? "",
//                "subjectMarksDetails": subjectMarksArray,
//                "actualTotalMarks": student.actualTotalMarks ?? 0,
//                "overallPercentage": student.overallPercentage ?? 0.0,
//                "overallGrade": student.overallGrade ?? "",
//                "studentName": student.studentName ?? "",
//                "rollNumber": student.rollNumber ?? "",
//                "gruppieRollNumber": student.gruppieRollNumber ?? ""
//            ]
//
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: minimalBody, options: [.prettyPrinted])
//                
//                var request = URLRequest(url: url)
//                request.httpMethod = "PUT"
//                request.httpBody = jsonData
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.timeoutInterval = 30
//
//                print("🚀 Sending update for student: \(student.studentName ?? "")")
//
//                // ✅ Use semaphore to wait for each request to complete
//                let semaphore = DispatchSemaphore(value: 0)
//                var success = false
//
//                URLSession.shared.dataTask(with: request) { data, response, error in
//                    defer { semaphore.signal() }
//
//                    if let error = error {
//                        print("❌ API Error for \(student.studentName ?? ""):", error.localizedDescription)
//                        return
//                    }
//
//                    guard let httpResponse = response as? HTTPURLResponse else {
//                        print("❌ Invalid response for \(student.studentName ?? "")")
//                        return
//                    }
//
//                    print("📬 Response Code for \(student.studentName ?? ""): \(httpResponse.statusCode)")
//
//                    if httpResponse.statusCode == 200 {
//                        success = true
//                        print("✅ Successfully updated marks for \(student.studentName ?? "")")
//                    } else {
//                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
//                            print("❌ Error Response for \(student.studentName ?? ""): \(errorString)")
//                        }
//                    }
//                }.resume()
//
//                // Wait for the request to complete
//                _ = semaphore.wait(timeout: .now() + 30)
//
//            } catch {
//                print("❌ JSON Serialization Error for \(student.studentName ?? ""):", error)
//            }
//        }
//
//        // ✅ Show final success message
//        DispatchQueue.main.async {
//            self.showAlert(title: "Success", message: "All marks updated successfully!") {
//                self.fetchMarksCardData {
//                    self.studentMarksTableView.reloadData()
//                }
//            }
//        }
//    }
//
//
//    
//    func setupTableViews() {
//           let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell1", bundle: nil)
//           subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell1")
//           studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell1", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell1")
//           
//           subjectsHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
//           studentMarksHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
//        studentMarksHandler.currentlySelectedStudentId = selectedStudentUserId
//           
//           // ✅ Add this callback to get notified when data changes
//           studentMarksHandler.onDataChanged = { [weak self] updatedData in
//               guard let self = self else { return }
//               // ✅ Update the main data array with the changes
//               self.studentMarkExamDataResponse = updatedData
//               print("📝 Data model updated with new marks")
//           }
//           
//           subjectsTableView.delegate = subjectsHandler
//           subjectsTableView.dataSource = subjectsHandler
//           studentMarksTableView.delegate = studentMarksHandler
//           studentMarksTableView.dataSource = studentMarksHandler
//           
//           studentMarksHandler.onMarksUpdate = { [weak self] in
//               self?.studentMarksTableView.reloadData()
//           }
//           
//           subjectsLabel.text = "All Subjects"
//           subjectsHandler.didSelectSubject = { [weak self] selectedSubject in
//               guard let self = self else { return }
//               self.subjectsLabel.text = selectedSubject
//               self.subjectsView.isHidden = true  // Hide view after selection
//               self.studentMarksHandler.selectedSubject = selectedSubject == "All Subjects" ? nil : selectedSubject
//               print("✅ Selected subject: \(selectedSubject)")
//           }
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap(_:)))
//              studentMarksTableView.addGestureRecognizer(tapGesture)
//           subjectsTableView.reloadData()
//       }
//    
//    @objc func handleTableViewTap(_ gesture: UITapGestureRecognizer) {
//         let location = gesture.location(in: studentMarksTableView)
//         if let indexPath = studentMarksTableView.indexPathForRow(at: location) {
//             let studentData = studentMarksHandler.filteredStudentData[indexPath.section]
//             print("🎯 Selected student: \(studentData.studentName ?? "")")
//         }
//     }
//    
//    func marksUpdated() {
//        onMarksUpdated?()
//    }
//    @objc func disableEditing(_ textField: UITextField) {
//        textField.resignFirstResponder()  // Immediately dismiss keyboard
//    }
//    
//    @IBAction func submitActionTapped(_ sender: UIButton) {
//            // ✅ Print current data to verify changes are saved
//            print("📊 Current student data before API call:")
//            for (index, student) in studentMarkExamDataResponse.enumerated() {
//                print("Student \(index): \(student.studentName ?? "")")
//                for subject in student.subjectMarksDetails {
//                    print("   \(subject.subjectName ?? ""): \(subject.actualMarks ?? "nil")")
//                }
//            }
//            
//            if let selectedStudentId = selectedStudentUserId,
//               let selectedStudent = studentMarkExamDataResponse.first(where: { $0.studentId == selectedStudentId }) {
//                // Update only the selected student
//                updateMarksCardForStudent(selectedStudent)
//            } else {
//                // Update all students
//                updateMarksCard()
//            }
//        }
//        // ✅ Complete implementation of updateMarksCardForStudent
//        func updateMarksCardForStudent(_ student: StudentMarksData) {
//            guard let teamId = teamId,
//                  let testId = testId,
//                  let groupId = groupId as String?,
//                  let token = TokenManager.shared.getToken(),
//                  let gruppieRollNumber = student.gruppieRollNumber else {
//                showAlert(title: "Error", message: "Missing required information or token.")
//                return
//            }
//
//            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(gruppieRollNumber)"
//            print("🌐 API URL for \(student.studentName ?? ""): \(urlString)")
//
//            guard let url = URL(string: urlString) else {
//                print("❌ Invalid URL for student: \(student.studentName ?? "")")
//                return
//            }
//
//            // ✅ Construct subMarks array properly for this student
//            let subjectMarksArray = student.subjectMarksDetails.map { subject -> [String: Any] in
//                let subMarksArray = subject.subMarks.map { sub -> [String: Any] in
//                    return [
//                        "actualMarks": sub.actualMarks ?? "",
//                        "attendance": sub.attendance ?? "",
//                        "maxMarks": sub.maxMarks ?? "",
//                        "minMarks": sub.minMarks ?? "",
//                        "shortName": sub.shortName ?? "",
//                        "splitName": sub.splitName ?? "",
//                        "type": sub.type ?? ""
//                    ]
//                }
//
//                return [
//                    "actualMarks": subject.actualMarks ?? "",
//                    "attendance": subject.attendance ?? "",
//                    "date": subject.date ?? "",
//                    "enable": subject.enable ?? true,
//                    "endTime": subject.endTime ?? "",
//                    "gradeRange": subject.gradeRange,
//                    "inwords": subject.inwords ?? "",
//                    "maxMarks": subject.maxMarks,
//                    "minMarks": subject.minMarks,
//                    "shortName": subject.shortName ?? "",
//                    "startTime": subject.startTime ?? "",
//                    "subMarks": subMarksArray,
//                    "subjectAverageMarks": subject.subjectAverageMarks ?? 0.0,
//                    "subjectGrade": subject.subjectGrade ?? "",
//                    "subjectId": subject.subjectId ?? "",
//                    "subjectName": subject.subjectName ?? "",
//                    "subjectPriority": subject.subjectPriority ?? 0,
//                    "subjectSort": subject.subjectSort ?? 0,
//                    "submarkslength": subject.submarkslength ?? 0,
//                    "type": subject.type ?? ""
//                ]
//            }
//
//            // ✅ Create minimal body for this student
//            let minimalBody: [String: Any] = [
//                "studentId": student.studentId ?? "",
//                "testId": student.testId ?? "",
//                "subjectMarksDetails": subjectMarksArray,
//                "actualTotalMarks": student.actualTotalMarks ?? 0,
//                "overallPercentage": student.overallPercentage ?? 0.0,
//                "overallGrade": student.overallGrade ?? "",
//                "studentName": student.studentName ?? "",
//                "rollNumber": student.rollNumber ?? "",
//                "gruppieRollNumber": student.gruppieRollNumber ?? ""
//            ]
//
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: minimalBody, options: [.prettyPrinted])
//                
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("\n📦 Request Body for \(student.studentName ?? ""):\n\(jsonString)\n")
//                }
//
//                var request = URLRequest(url: url)
//                request.httpMethod = "PUT"
//                request.httpBody = jsonData
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.timeoutInterval = 30
//
//                print("🚀 Sending update for student: \(student.studentName ?? "")")
//
//                // ✅ Call API
//                URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//                    guard let self = self else { return }
//
//                    if let error = error {
//                        print("❌ API Error for \(student.studentName ?? ""):", error.localizedDescription)
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Error", message: "Network error occurred for \(student.studentName ?? "").")
//                        }
//                        return
//                    }
//
//                    guard let httpResponse = response as? HTTPURLResponse else {
//                        print("❌ Invalid response for \(student.studentName ?? "")")
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Error", message: "Invalid server response for \(student.studentName ?? "").")
//                        }
//                        return
//                    }
//
//                    print("📬 Response Code for \(student.studentName ?? ""): \(httpResponse.statusCode)")
//
//                    if httpResponse.statusCode == 200 {
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Success", message: "Marks updated successfully for \(student.studentName ?? "")!") {
//                                self.fetchMarksCardData {
//                                    self.studentMarksTableView.reloadData()
//                                    // ✅ Clear selection after successful update
//                                    self.selectedStudentUserId = nil
//                                }
//                            }
//                        }
//                    } else {
//                        if let data = data,
//                           let errorString = String(data: data, encoding: .utf8) {
//                            print("❌ Error Response for \(student.studentName ?? ""): \(errorString)")
//                        }
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Error", message: "Failed to update marks for \(student.studentName ?? "").")
//                        }
//                    }
//                }.resume()
//
//            } catch {
//                print("❌ JSON Serialization Error for \(student.studentName ?? ""):", error)
//                showAlert(title: "Error", message: "Failed to prepare data for \(student.studentName ?? "").")
//            }
//        }
//    
//    @IBAction func backAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    @IBAction func allSubjectListingButtonAction(_ sender: Any) {
//        subjectsView.isHidden.toggle()
//        subjectsTableView.reloadData()
//    }
//    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
//            completion?()
//        })
//        present(alert, animated: true)
//    }
//}
//
//class StudentMarksNewTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate, SubjectMarksChangeProtocol1 {
//    func didTapEyeButton(studentId: String?, subjectId: String?, subjectDetail: SubjectMarksDetails?) {
//        return
//    }
//    
//    var studentMarkExamDataResponse: [StudentMarksData] = [] {
//        didSet {
//            // Update filtered data when main data changes
//            updateFilteredData()
//        }
//    }
//    
//    var currentlySelectedStudentId: String?
//    var onMarksUpdate: (() -> Void)?
//    var obtainedMarksText: String?
//    var onEditingStarted: ((String) -> Void)?
//    
//    // ✅ Add filtered data array
//    private var _filteredStudentData: [StudentMarksData] = []
//    var selectedSubject: String? {
//        didSet {
//            updateFilteredData()
//            onMarksUpdate?()
//        }
//    }
//    
//    // ✅ Add callback to notify VC about data changes
//    var onDataChanged: (([StudentMarksData]) -> Void)?
//    
//    func sendChangedMarks(maeks: String) {
//        self.obtainedMarksText = maeks
//    }
//    
//    // ✅ Properly update filtered data
//    private func updateFilteredData() {
//        guard let selectedSubject = selectedSubject, selectedSubject != "All Subjects" else {
//            _filteredStudentData = studentMarkExamDataResponse
//            return
//        }
//        
//        _filteredStudentData = studentMarkExamDataResponse.compactMap { studentData in
//            if let subjectDetail = studentData.subjectMarksDetails.first(where: { $0.subjectName == selectedSubject }) {
//                // Create a copy with only the selected subject
//                var filteredStudent = studentData
//                filteredStudent.subjectMarksDetails = [subjectDetail]
//                return filteredStudent
//            }
//            return nil
//        }
//    }
//    
//    var filteredStudentData: [StudentMarksData] {
//        return _filteredStudentData
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return filteredStudentData.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredStudentData[section].subjectMarksDetails.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 80
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let studentData = filteredStudentData[section]
//        let headerView = UIView()
//        
//        if studentData.studentId == currentlySelectedStudentId {
//               headerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
//           } else {
//               headerView.backgroundColor = .white
//           }
//        
//        headerView.backgroundColor = .white
//        
//        let iconImageView = UIImageView(frame: CGRect(x: 15, y: 5, width: 40, height: 40))
//        iconImageView.image = UIImage(systemName: "person.circle")
//        iconImageView.tintColor = .black
//        headerView.addSubview(iconImageView)
//        
//        let nameLabel = UILabel(frame: CGRect(x: 65, y: 5, width: tableView.frame.width - 80, height: 25))
//        nameLabel.text = studentData.studentName
//        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        nameLabel.textColor = .black
//        headerView.addSubview(nameLabel)
//        
//        let totalLabel = UILabel(frame: CGRect(x: 65, y: 30, width: 50, height: 20))
//        totalLabel.text = "Total"
//        totalLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        totalLabel.textColor = .darkGray
//        headerView.addSubview(totalLabel)
//        
//        let obtainedTotal = studentData.subjectMarksDetails.reduce(into: 0) { $0 += Int($1.actualMarks ?? "0") ?? 0 }
//        let maxTotal = studentData.subjectMarksDetails.reduce(into: 0) { $0 += Int($1.maxMarks) ?? 0 }
//        let scoreLabel = UILabel(frame: CGRect(x: totalLabel.frame.maxX + 10, y: 30, width: 100, height: 20))
//        scoreLabel.text = "\(obtainedTotal)/\(maxTotal)"
//        scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        scoreLabel.textColor = .darkGray
//        headerView.addSubview(scoreLabel)
//        
//        let totalWidth = tableView.frame.width
//        let subjectLabel = UILabel(frame: CGRect(x: 0, y: 55, width: totalWidth * 0.6, height: 20))
//        subjectLabel.text = "Subject"
//        subjectLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        subjectLabel.textAlignment = .center
//        subjectLabel.textColor = .black
//        headerView.addSubview(subjectLabel)
//        
//        let remainingLabels = ["Min - Max", "Obtained"]
//        let remainingWidth = totalWidth * 0.4 / CGFloat(remainingLabels.count)
//        
//        for (index, labelText) in remainingLabels.enumerated() {
//            let labelX = totalWidth * 0.6 + CGFloat(index) * remainingWidth
//            let label = UILabel(frame: CGRect(x: labelX, y: 55, width: remainingWidth, height: 20))
//            label.text = labelText
//            label.font = UIFont.boldSystemFont(ofSize: 14)
//            label.textAlignment = .center
//            label.textColor = .black
//            headerView.addSubview(label)
//        }
//        return headerView
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectNameDetailsTableViewCell1", for: indexPath) as? SubjectNameDetailsTableViewCell1 else {
//            return UITableViewCell()
//        }
//        
//        let studentData = filteredStudentData[indexPath.section]
//        let subjectDetail = studentData.subjectMarksDetails[indexPath.row]
//        
//        // ✅ Configure cell with proper data
//        cell.configure(with: subjectDetail, studentId: studentData.studentId)
//        cell.delegate = delegate
//        cell.onMarksChanged = { [weak self] newText, studentId, subjectId in
//            guard let self = self else { return }
//            
//            print("🔄 Updating marks for student: \(studentId), subject: \(subjectId), marks: \(newText)")
//            
//            // ✅ Find the student in the main data array
//            if let studentIndex = self.studentMarkExamDataResponse.firstIndex(where: { $0.studentId == studentId }) {
//                // ✅ Find the subject in the student's subject marks
//                if let subjectIndex = self.studentMarkExamDataResponse[studentIndex].subjectMarksDetails.firstIndex(where: { $0.subjectId == subjectId }) {
//                    
//                    // ✅ Create mutable copies and update
//                    var updatedStudents = self.studentMarkExamDataResponse
//                    var updatedStudent = updatedStudents[studentIndex]
//                    var updatedSubjects = updatedStudent.subjectMarksDetails
//                    var updatedSubject = updatedSubjects[subjectIndex]
//                    
//                    updatedSubject.actualMarks = newText.isEmpty ? nil : newText
//                    updatedSubjects[subjectIndex] = updatedSubject
//                    updatedStudent.subjectMarksDetails = updatedSubjects
//                    updatedStudents[studentIndex] = updatedStudent
//                    
//                    // ✅ Update the main data array
//                    self.studentMarkExamDataResponse = updatedStudents
//                    
//                    // ✅ Also update filtered data to reflect changes immediately
//                    self.updateFilteredData()
//                    
//                    print("✅ Successfully updated marks for \(studentData.studentName ?? "") - \(subjectDetail.subjectName ?? ""): \(newText)")
//                    
//                    // ✅ Notify the view controller that data has changed
//                    self.onDataChanged?(self.studentMarkExamDataResponse)
//                    
//                    // ✅ Reload the specific row to reflect changes
//                    DispatchQueue.main.async {
//                        tableView.reloadRows(at: [indexPath], with: .none)
//                    }
//                } else {
//                    print("❌ Subject not found: \(subjectId)")
//                }
//            } else {
//                print("❌ Student not found: \(studentId)")
//            }
//        }
//        
//        return cell
//    }
//}
//
//
//class SubjectsNewTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
//    var studentMarkExamDataResponse: [StudentMarksData] = []
//    var didSelectSubject: ((String) -> Void)?
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return studentMarkExamDataResponse.first?.subjectMarksDetails.count ?? 0
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // ✅ FIX: Use correct identifier and cell class
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamAndSubjectTitleTableViewCell1", for: indexPath) as? ExamAndSubjectTitleTableViewCell1 else {
//            return UITableViewCell()
//        }
//                if let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row] {
//            cell.titleLabel.text = subjectData.subjectName
//        }
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedSubject = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row].subjectName ?? "N/A"
//        didSelectSubject?(selectedSubject)
//    }
//}
//
//extension Student_listVC {
//    func setupSubjectSelectionForTeacher() {
//        subjectsHandler.didSelectSubject = { [weak self] selectedSubject in
//            guard let self = self else { return }
//
//            // ✅ Find the selected subjectId from data
//            guard let subjectId = self.studentMarkExamDataResponse.first?.subjectMarksDetails.first(where: { $0.subjectName == selectedSubject })?.subjectId else {
//                print("❌ No subjectId found for selected subject \(selectedSubject)")
//                return
//            }
//
//            print("🎯 Selected Subject: \(selectedSubject)")
//            print("🆔 Subject ID: \(subjectId)")
//
//            // ✅ If current role is teacher, navigate to EditAllMarksViewController
//            if self.currentRole == "teacher" {
//                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditAllMarksViewController") as? EditAllMarksViewController {
//                    vc.groupId = self.groupId
//                    vc.teamId = self.teamId
//                    vc.testId = self.testId
//                    vc.currentRole = self.currentRole
//                    vc.subjectId = subjectId  // ✅ Pass subjectId
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            } else {
//                // For admin, keep same subject filtering logic
//                self.subjectsLabel.text = selectedSubject
//                self.subjectsView.isHidden = true
//                self.studentMarksHandler.selectedSubject = selectedSubject == "All Subjects" ? nil : selectedSubject
//                print("✅ Selected subject (Admin): \(selectedSubject)")
//            }
//        }
//    }
//}
//
//// MARK: - SubjectMarksChangeProtocol1 Extension
//extension Student_listVC: SubjectMarksChangeProtocol1 {
//    func sendChangedMarks(maeks: String) {
//        // Your existing implementation
//    }
//    
//    func didTapEyeButton(studentId: String?, subjectId: String?, subjectDetail: SubjectMarksDetails?) {
//        guard let subjectDetail = subjectDetail else {
//            print("❌ No subject detail provided")
//            return
//        }
//        
//        showEditMarkView(with: subjectDetail, studentId: studentId, subjectId: subjectId)
//    }
//}
