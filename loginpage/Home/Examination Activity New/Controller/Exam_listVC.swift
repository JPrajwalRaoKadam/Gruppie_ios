
import UIKit
import SafariServices

class Exam_listVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var examListTableView: UITableView!
    @IBOutlet weak var bcbutton: UIButton!
    
    var selectStudentView: UIView!
    var groupId: String = ""
    var teamId: String = ""
    var currentRole: String?
    var className: String = ""
    var userId: String = ""
    var exams: [ExamData1] = [] // Store API response
    var selectedOption: Int = 0  // ✅ Remember selection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        examListTableView.register(UINib(nibName: "Exam_listVCTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "Exam_listVCTableViewCell")
        examListTableView.delegate = self
        examListTableView.dataSource = self
        
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        examListTableView.layer.cornerRadius = 10
        
        print("currentRole is : \(currentRole ?? "nil")")
        print("Extracted teamId in examll: \(teamId)")
        print("Extracted groupId in examll: \(groupId)")
        
        fetchExamList()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchExamList() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/gruppie/exam/new"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(ExamResponse1.self, from: data)
                let enabledExams = decodedResponse.scheduleData.filter { $0.enable == true }
                DispatchQueue.main.async {
                    self?.exams = enabledExams
                    self?.examListTableView.reloadData()
                }
            } catch {
                print("❌ Decoding Error: \(error)")
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { exams.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Exam_listVCTableViewCell",
                                                       for: indexPath) as? Exam_listVCTableViewCell else {
            return UITableViewCell()
        }
        cell.classLabel.text = exams[indexPath.row].aliasName ?? "N/A"
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exam = exams[indexPath.row]
         
        if currentRole == "admin" || currentRole == "teacher" {
            // ✅ Navigate to Student_listVC
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Student_listVC") as? Student_listVC {
                vc.groupId = self.groupId
                vc.teamId = self.teamId
                vc.testId = exam.testId   // Pass testId
                vc.currentRole = self.currentRole
                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    self.present(vc, animated: true)
                }
            }
        } else if currentRole == "parent" {
            // ✅ Show popup for Marks Card selection
            showMarksCardPopup(for: exam)
        }
    }
    func extractTextInsideBrackets(from text: String) -> String {
        if let startRange = text.range(of: "("),
           let endRange = text.range(of: ")", range: startRange.upperBound..<text.endIndex) {
            return String(text[startRange.upperBound..<endRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return text
    }
     
    func showMarksCardPopup(for exam: ExamData1) {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.tag = 999
        self.view.addSubview(backgroundView)

        let popupWidth: CGFloat = self.view.frame.width - 60
        let popupView = UIView(frame: CGRect(x: 30, y: self.view.frame.height / 2 - 120,
                                             width: popupWidth, height: 240))
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        backgroundView.addSubview(popupView)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: popupWidth, height: 25))
        titleLabel.text = "Marks Card View"
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 18)
        popupView.addSubview(titleLabel)

        // MARK: - Buttons
        let singleButton = UIButton(frame: CGRect(x: 40, y: 70, width: popupWidth - 80, height: 40))
        singleButton.setTitle("Single Marks Card Template", for: .normal)
        singleButton.setTitleColor(.black, for: .normal)
        singleButton.contentHorizontalAlignment = .left
        singleButton.tag = 1

        let splitButton = UIButton(frame: CGRect(x: 40, y: 120, width: popupWidth - 80, height: 40))
        splitButton.setTitle("Split Marks Card Template", for: .normal)
        splitButton.setTitleColor(.black, for: .normal)
        splitButton.contentHorizontalAlignment = .left
        splitButton.tag = 2

        // MARK: - Circles (Radio Buttons)
        let singleCircle = UIImageView(frame: CGRect(x: 10, y: 80, width: 20, height: 20))
        singleCircle.image = UIImage(systemName: "circle")
        singleCircle.tintColor = .gray
        singleCircle.tag = 101
        singleCircle.isUserInteractionEnabled = true

        let splitCircle = UIImageView(frame: CGRect(x: 10, y: 130, width: 20, height: 20))
        splitCircle.image = UIImage(systemName: "circle")
        splitCircle.tintColor = .gray
        splitCircle.tag = 102
        splitCircle.isUserInteractionEnabled = true

        // MARK: - Cancel and OK buttons
        let cancelButton = UIButton(frame: CGRect(x: 20, y: 180, width: (popupWidth - 60) / 2, height: 40))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .systemGray5
        cancelButton.layer.cornerRadius = 8

        let okButton = UIButton(frame: CGRect(x: cancelButton.frame.maxX + 20, y: 180,
                                              width: (popupWidth - 60) / 2, height: 40))
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = .systemBlue
        okButton.layer.cornerRadius = 8

        [singleButton, splitButton, singleCircle, splitCircle, cancelButton, okButton].forEach {
            popupView.addSubview($0)
        }

        // ✅ Common update function
        func updateSelection(to option: Int) {
            selectedOption = option
            singleCircle.image = UIImage(systemName: option == 1 ? "circle.inset.filled" : "circle")
            singleCircle.tintColor = option == 1 ? .systemBlue : .gray
            splitCircle.image = UIImage(systemName: option == 2 ? "circle.inset.filled" : "circle")
            splitCircle.tintColor = option == 2 ? .systemBlue : .gray
        }

        // ✅ Text taps
        singleButton.addAction(UIAction { [weak self] _ in
            self?.selectedOption = 1
            updateSelection(to: 1)
        }, for: .touchUpInside)

        splitButton.addAction(UIAction { [weak self] _ in
            self?.selectedOption = 2
            updateSelection(to: 2)
        }, for: .touchUpInside)

        // ✅ Circle taps
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleCircleTapped(_:)))
        singleCircle.addGestureRecognizer(singleTap)
        singleCircle.isUserInteractionEnabled = true

        let splitTap = UITapGestureRecognizer(target: self, action: #selector(splitCircleTapped(_:)))
        splitCircle.addGestureRecognizer(splitTap)
        splitCircle.isUserInteractionEnabled = true

        // ✅ Cancel & OK
        cancelButton.addAction(UIAction { _ in
            backgroundView.removeFromSuperview()
        }, for: .touchUpInside)

        okButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            backgroundView.removeFromSuperview()
            self.handleSelection(for: exam)
        }, for: .touchUpInside)
    }

    @objc func singleCircleTapped(_ sender: UITapGestureRecognizer) {
        selectedOption = 1
        if let popupView = sender.view?.superview,
           let singleCircle = popupView.viewWithTag(101) as? UIImageView,
           let splitCircle = popupView.viewWithTag(102) as? UIImageView {
            singleCircle.image = UIImage(systemName: "circle.inset.filled")
            singleCircle.tintColor = .systemBlue
            splitCircle.image = UIImage(systemName: "circle")
            splitCircle.tintColor = .gray
        }
    }

    @objc func splitCircleTapped(_ sender: UITapGestureRecognizer) {
        selectedOption = 2
        if let popupView = sender.view?.superview,
           let singleCircle = popupView.viewWithTag(101) as? UIImageView,
           let splitCircle = popupView.viewWithTag(102) as? UIImageView {
            splitCircle.image = UIImage(systemName: "circle.inset.filled")
            splitCircle.tintColor = .systemBlue
            singleCircle.image = UIImage(systemName: "circle")
            singleCircle.tintColor = .gray
        }
    }


    private struct AssociatedKeys {
        static var updateSelection = "updateSelection"
    }

    // MARK: - Handle Selection
    func handleSelection(for exam: ExamData1) {
        // use testId (not _id)
        let testId = exam.testId
        if testId.isEmpty {
            print("⚠️ Missing testId")
            return
        }

        // prefer the extracted/trimmed class name (safe)
        let trimmedClassName = extractTextInsideBrackets(from: className)
        let encodedClassName = trimmedClassName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString: String
        if selectedOption == 1 {
            urlString = "https://campus.gc2.co.in/StudentMTemplate/group/\(groupId)/team/\(teamId)/user/\(userId)?testId=\(testId)&className=\(encodedClassName)"
        } else if selectedOption == 2 {
            urlString = "https://campus.gc2.co.in/StudentSlipt/group/\(groupId)/team/\(teamId)/user/\(userId)?testId=\(testId)&className=\(encodedClassName)"
        } else {
            print("⚠️ Please select a template option before continuing.")
            return
        }

        callMarksCardAPI(url: urlString)
        // reset selection if you want (optional)
        selectedOption = 0
    }

    // MARK: - API Call
    func callMarksCardAPI(url: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        guard let apiUrl = URL(string: url) else {
            print("❌ Invalid API URL: \(url)")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                return
            }

            // treat 200..299 as success
            if (200...299).contains(httpResponse.statusCode) {
                print("✅ Marks card API success: \(url) (status: \(httpResponse.statusCode))")
                DispatchQueue.main.async {
                    // open the URL in SFSafariViewController
                    let safariVC = SFSafariViewController(url: apiUrl)
                    safariVC.modalPresentationStyle = .pageSheet
                    self?.present(safariVC, animated: true)
                }
            } else {
                print("⚠️ API returned unexpected status: \(httpResponse.statusCode)")
                if let data = data, let txt = String(data: data, encoding: .utf8) {
                    print("Response body: \(txt)")
                }
            }
        }.resume()
    }
}
//    func callEditMarksAPI() {
//        guard let teamId = teamId,
//              let testId = testId,
//              let groupId = groupId as String?,
//              let token = TokenManager.shared.getToken() else {
//            showAlert(title: "Error", message: "Missing required information or token.")
//            return
//        }
//
//        // ✅ Example — assuming user selected student
//        guard let selectedStudent = studentMarkExamDataResponse.first else {
//            showAlert(title: "Error", message: "No student data found.")
//            return
//        }
//
//        guard let userId = selectedStudent.userId,
//              let gruppieRollNumber = selectedStudent.gruppieRollNumber else {
//            showAlert(title: "Error", message: "Missing user or roll number.")
//            return
//        }
//
//        // ✅ Construct URL
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(gruppieRollNumber)"
//        print("🌐 API URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL: \(urlString)")
//            return
//        }
//
////        // ✅ Prepare JSON body
////        var body: [String: Any] = [
////            "studentId": selectedStudent.studentId ?? "",
////            "userId": selectedStudent.userId ?? "",
////            "teamId": selectedStudent.teamId ?? "",
////            "groupId": selectedStudent.groupId ?? "",
////            "gruppieRollNumber": selectedStudent.gruppieRollNumber ?? "",
////            "studentName": selectedStudent.studentName ?? "",
////            "overallPercentage": selectedStudent.overallPercentage ?? 0.0,
////            "overallGrade": selectedStudent.overallGrade ?? "",
////            "status": selectedStudent.status ?? "",
////            "resultDate": selectedStudent.resultDate ?? "",
////            "testExamTitle": selectedStudent.testExamTitle ?? "",
////            "subjectMarksDetails": selectedStudent.subjectMarksDetails.map { subject in
////                return [
////                    "actualMarks": subject.actualMarks ?? "",
////                    "subjectId": subject.subjectId ?? "",
////                    "subjectName": subject.subjectName ?? "",
////                    "minMarks": subject.minMarks,
////                    "maxMarks": subject.maxMarks,
////                    "attendance": subject.attendance ?? "",
////                    "date": subject.date ?? "",
////                    "enable": subject.enable ?? true,
////                    "subjectPriority": subject.subjectPriority ?? 0,
////                    "subjectSort": subject.subjectSort ?? 0,
////                    "subjectGrade": subject.subjectGrade ?? "",
////                    "type": subject.type ?? ""
////                ]
////            }
////        ]
//        // ✅ Prepare JSON body
//        var body: [String: Any] = [
//            "actualTotalMarks": selectedStudent.actualTotalMarks ?? 0,
//            "address": selectedStudent.address ?? "",
//            "admissionNumber": selectedStudent.admissionNumber ?? "",
//            "attendanceEndDate": selectedStudent.attendanceEndDate ?? "",
//            "attendanceStartDate": selectedStudent.attendanceStartDate ?? "",
//            "attendanceString": selectedStudent.attendanceString ?? "0 / 0",
//            "averageMarks": selectedStudent.averageMarks ?? 0,
//            "dob": selectedStudent.dob ?? "",
//            "duration": selectedStudent.duration ?? "",
//            "fatherName": selectedStudent.fatherName ?? "",
//            "gender": selectedStudent.gender ?? "",
//            "gradeRange": selectedStudent.gradeRange,
//            "groupId": selectedStudent.groupId ?? "",
//            "gruppieRollNumber": selectedStudent.gruppieRollNumber ?? "",
//            "isApproved": selectedStudent.isApproved,
//            "isPublished": selectedStudent.isPublished,
//            "motherName": selectedStudent.motherName ?? "",
//            "noteForMarkscard": selectedStudent.noteForMarkscard ?? "",
//            "numberOfWorkingDays": selectedStudent.numberOfWorkingDays ?? "0",
//            "omrNO": selectedStudent.omrNO ?? "",
//            "overallGrade": selectedStudent.overallGrade ?? "",
//            "overallPercentage": selectedStudent.overallPercentage ?? 0.0,
//            "partB": [
//                ["enable": true, "grade": "", "title": "Handwriting", "type": "handwriting"],
//                ["enable": true, "grade": "", "title": "Drawing", "type": "drawing"],
//                ["enable": true, "grade": "", "title": "Writing speed (minute)", "type": "writingSpeed"],
//                ["enable": true, "grade": "", "title": "Reading speed (minute)", "type": "readingSpeed"],
//                ["enable": true, "grade": "", "title": "Public speaking", "type": "publicSpeaking"]
//            ],
//            "presentDays": selectedStudent.presentDays ?? "0",
//            "resultDate": selectedStudent.resultDate ?? "",
//            "rollNumber": selectedStudent.rollNumber ?? "",
//            "satsNumber": selectedStudent.satsNumber ?? selectedStudent.satsNo ?? "",
//            "status": selectedStudent.status ?? "",
//            "studentId": selectedStudent.studentId ?? "",
//            "studentImage": selectedStudent.studentImage ?? "",
//            "studentName": selectedStudent.studentName ?? "",
//
//            // ✅ Nested subjectMarksDetails
//            "subjectMarksDetails": selectedStudent.subjectMarksDetails.map { subject in
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
//                    "subMarks": subject.subMarks.map { sub in
//                        return [
//                            "type": sub.type ?? "",
//                            "splitName": sub.splitName ?? "",
//                            "shortName": sub.shortName ?? "",
//                            "minMarks": sub.minMarks ?? "",
//                            "maxMarks": sub.maxMarks ?? "",
//                            "attendance": sub.attendance ?? "",
//                            "applyAttendance": sub.applyAttendance ?? false,
//                            "actualMarks": sub.actualMarks ?? ""
//                        ]
//                    },
//                    "subjectAverageMarks": subject.subjectAverageMarks ?? 0.0,
//                    "subjectGrade": subject.subjectGrade ?? "",
//                    "subjectId": subject.subjectId ?? "",
//                    "subjectName": subject.subjectName ?? "",
//                    "subjectPriority": subject.subjectPriority ?? 0,
//                    "subjectSort": subject.subjectSort ?? 0,
//                    "submarkslength": subject.submarkslength ?? 0,
//                    "type": subject.type ?? ""
//                ]
//            },
//
//            "teamId": selectedStudent.teamId ?? "",
//            "testExamIds": selectedStudent.testExamIds,
//            "testExamTitle": selectedStudent.testExamTitle ?? "",
//            "testId": selectedStudent.testId ?? "",
//            "totalMaxMarks": selectedStudent.totalMaxMarks ?? 0,
//            "totalMinMarks": selectedStudent.totalMinMarks ?? 0,
//            "updatedBy": selectedStudent.updatedBy ?? "",
//            "userId": selectedStudent.userId ?? ""
//        ]
//
//
//        // ✅ Convert body to JSON data
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted]) else {
//            showAlert(title: "Error", message: "Failed to encode JSON body.")
//            return
//        }
//
//        // ✅ Print the JSON body before sending
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print("\n📦 Request Body JSON:\n\(jsonString)\n")
//        }
//
//        // ✅ Create Request
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.httpBody = jsonData
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // ✅ API Call
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("❌ API Error:", error.localizedDescription)
//                DispatchQueue.main.async {
//                    self.showAlert(title: "Error", message: "Network error occurred.")
//                }
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ Invalid response.")
//                return
//            }
//
//            print("📬 Response Code: \(httpResponse.statusCode)")
//
//            if httpResponse.statusCode == 200 {
//                DispatchQueue.main.async {
//                    self.showAlert(title: "Success", message: "Marks updated successfully!") {
//                        self.fetchMarksCardData {
//                            self.studentMarksTableView.reloadData()
//                        }
//                    }
//                }
//            } else {
//                if let data = data,
//                   let errorString = String(data: data, encoding: .utf8) {
//                    print("❌ Error Response: \(errorString)")
//                }
//                DispatchQueue.main.async {
//                    self.showAlert(title: "Error", message: "Failed to update marks.")
//                }
//            }
//        }
//
//        task.resume()
//    }
    
// MARK: - Gesture Handlers
extension Exam_listVC {
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        if let updateSelection = objc_getAssociatedObject(self, &AssociatedKeys.updateSelection) as? (Int) -> Void {
            updateSelection(1) // fills Single circle
        }
    }

    @objc func handleSplitTap(_ sender: UITapGestureRecognizer) {
        if let updateSelection = objc_getAssociatedObject(self, &AssociatedKeys.updateSelection) as? (Int) -> Void {
            updateSelection(2) // fills Split circle
        }
    }
}







// ✅ API Call to Update Marks
//private func updateStudentMarks(studentData: StudentMarksData, teamId: String, testId: String, token: String) {
//    let urlString = "https://gcc.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(studentData.userId ?? "")"
//    
//    guard let url = URL(string: urlString) else {
//        print("❌ Invalid URL")
//        showAlert(title: "Error", message: "Invalid API URL.")
//        return
//    }
//    
//    print("📡 Calling PUT API: \(urlString)")
//    
//    var request = URLRequest(url: url)
//    request.httpMethod = "PUT"
//    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.setValue("application/json", forHTTPHeaderField: "Accept")
//    
//    do {
//        let encoder = JSONEncoder()
//        let requestBody = studentData
//        let jsonData = try encoder.encode(requestBody)
//        request.httpBody = jsonData
//        
//        print("📦 Request Body:")
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//        }
//        
//    } catch {
//        print("❌ JSON Encoding Error: \(error)")
//        showAlert(title: "Error", message: "Failed to prepare data for submission.")
//        return
//    }
//    
//    let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//        guard let self = self else { return }
//        
//        DispatchQueue.main.async {
//            if let error = error {
//                print("❌ Error: \(error.localizedDescription)")
//                self.showAlert(title: "Error", message: "Network error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ Invalid response")
//                self.showAlert(title: "Error", message: "Invalid server response.")
//                return
//            }
//            
//            print("📦 Status Code: \(httpResponse.statusCode)")
//            
//            if httpResponse.statusCode == 200 {
//                print("✅ Marks updated successfully!")
//                self.showAlert(title: "Success", message: "Marks updated successfully!") {
//                    // ✅ Reset editing state and refresh data
//                    self.currentlyEditingStudentId = nil
//                    self.marksUpdated()
//                    self.fetchMarksCardData {
//                        print("✅ Data refreshed after update")
//                    }
//                }
//            } else {
//                print("❌ Server returned error: \(httpResponse.statusCode)")
//                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
//                    print("📄 Error Response: \(errorMessage)")
//                    self.showAlert(title: "Error", message: "Server error: \(errorMessage)")
//                } else {
//                    self.showAlert(title: "Error", message: "Server returned error: \(httpResponse.statusCode)")
//                }
//            }
//        }
//    }
//    task.resume()
//}

//@IBAction func submitAction(_ sender: Any) {
//    guard let teamId = teamId,
//          let testId = testId,
//          let token = TokenManager.shared.getToken() else {
//        print("❌ Missing required identifiers or token.")
//        showAlert(title: "Error", message: "Missing required information.")
//        return
//    }
//    
//    // ✅ Check if any student is being edited
//    guard let editingStudentId = currentlyEditingStudentId,
//          let studentData = studentMarkExamDataResponse.first(where: { $0.studentId == editingStudentId }) else {
//        showAlert(title: "No Changes", message: "Please edit a student's marks before submitting.")
//        return
//    }
//    
//    // ✅ Call API to update marks
//    updateStudentMarks(studentData: studentData, teamId: teamId, testId: testId, token: token)
//}





// MARK: - Teacher Update
//func editMarksForTeacher(teamId: String, testId: String, updatedEntry: [String: Any]) {
//    guard let token = TokenManager.shared.getToken() else {
//        showAlert(title: "Error", message: "Authorization token missing.")
//        return
//    }
//
//    guard let studentId = updatedEntry["studentId"] as? String,
//          let subjectId = updatedEntry["subjectId"] as? String else {
//        showAlert(title: "Error", message: "Missing student ID or subject ID.")
//        return
//    }
//
//    // ✅ Fetch old marks for this subject
//    var oldMarks = "N/A"
//    if let student = studentMarkExamDataResponse.first(where: { $0.studentId == studentId }) {
//        if let subject = student.subjectMarksDetails.first(where: { $0.subjectId == subjectId }) {
//            oldMarks = subject.actualMarks ?? "N/A"
//        }
//    }
//
//    let newMarks = updatedEntry["actualMarks"] ?? "N/A"
//
//    print("\n🧾 TEACHER UPDATE")
//    print("👩‍🏫 Student ID: \(studentId)")
//    print("📘 Subject: \(updatedEntry["subjectName"] ?? "")")
//    print("🔹 Old Marks: \(oldMarks)")
//    print("🔹 New Marks: \(newMarks)")
//
//    let urlString = "https://gcc.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(studentId)"
//    guard let url = URL(string: urlString) else { return }
//
//    print("📡 Teacher API URL: \(urlString)")
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "PUT"
//    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    let body: [String: Any] = [
//        "actualMarks": newMarks,
//        "subjectId": subjectId,
//        "studentId": studentId,
//        "attendance": updatedEntry["attendance"] ?? "P",
//        "maxMarks": updatedEntry["maxMarks"] ?? "",
//        "minMarks": updatedEntry["minMarks"] ?? "",
//        "subjectName": updatedEntry["subjectName"] ?? "",
//        "studentName": updatedEntry["studentName"] ?? ""
//    ]
//
//    do {
//        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
//        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
//            print("📦 Teacher Request Body:\n\(jsonString)")
//        }
//    } catch {
//        print("❌ JSON Encoding Error: \(error)")
//        return
//    }
//
//    performEditRequest(request, role: "Teacher")
//}
