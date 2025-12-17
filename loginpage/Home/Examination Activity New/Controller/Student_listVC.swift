import UIKit

protocol StudentMarksNewDetailDelegate: AnyObject {
    func didUpdateMarks()
}

class Student_listVC: UIViewController {
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var subjectsLabel: UILabel!
    @IBOutlet weak var studentMarksTableView: UITableView!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var AllSubTextFeild: UITextField!
    @IBOutlet weak var submitAction: UIButton!
    
    @IBOutlet weak var maxMarkofSub: UILabel!
    @IBOutlet weak var minMarkofSub: UILabel!
    @IBOutlet weak var subMarksTableView: UITableView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var cancelAction: UIButton!
    @IBOutlet weak var AddAction: UIButton!
    private var popupSubjectDetail: SubjectMarksDetails?
    private var popupStudentId: String?
    
    
    private var tappedCellIndexPath: IndexPath?
    private var tappedStudentId: String?
    private var tappedSubjectId: String?
    
    var groupId: String = ""
    var teamId: String?
    var testId: String?
    var currentRole: String?
    var offlineTestExamId: String?
    weak var delegate: StudentMarksNewDetailDelegate?
    var onMarksUpdated: (() -> Void)?
    var studentMarkExamDataResponse: [StudentMarksData] = []
    var passedExamTitle = ""
    let subjectsHandler = SubjectsNewTableViewHandler()
    let studentMarksHandler = StudentMarksNewTableViewHandler()
    private var currentlyEditingStudentId: String?
    var updatedMarksList: [[String: Any]] = []
    var selectedStudentUserId: String?
    var totalMarks: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        subjectsHandler.parentVC = self
        subjectsHandler.studentMarkExamDataResponse = studentMarkExamDataResponse

        popUpView.isHidden = true
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        studentMarksTableView.layer.cornerRadius = 10
        submitAction.layer.cornerRadius = 10
        
        // ✅ Initialize empty arrays first
        studentMarkExamDataResponse = []
        
        // ✅ Setup table views with empty data first
        setupTableViews()
        setupPopupView()
        
        // ✅ Then fetch data
        fetchMarksCardData { [weak self] in
            guard let self = self else { return }
            self.subjectsView.isHidden = true
            self.subjectsTableView.reloadData()
            self.studentMarksTableView.reloadData()
        }
        self.studentMarksHandler.parentVC = self
        self.studentMarksHandler.studentMarkExamDataResponse = self.studentMarkExamDataResponse
        self.studentMarksHandler.totalMarks = Int(self.totalMarks ?? "")
        self.studentMarksTableView.reloadData()

    }
//    private func setupPopupView() {
//        popUpView.isHidden = true
//        popUpView.layer.cornerRadius = 12
//        popUpView.layer.shadowColor = UIColor.black.cgColor
//        popUpView.layer.shadowOpacity = 0.3
//        popUpView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        popUpView.layer.shadowRadius = 4
//        
//        // Remove the table view setup from here - it's already in setupPopupTableView()
//        
//        // Add tap gesture to dismiss popup when tapping outside
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
//        tapGesture.cancelsTouchesInView = false
//        tapGesture.delegate = self // Make sure delegate is set
//        view.addGestureRecognizer(tapGesture)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure table views are loaded before setting delegates
        if subjectsTableView != nil && studentMarksTableView != nil {
            // Clear any accidental connections
            subjectsTableView.delegate = nil
            subjectsTableView.dataSource = nil
            studentMarksTableView.delegate = nil
            studentMarksTableView.dataSource = nil
            
            // Set handlers
            subjectsTableView.delegate = subjectsHandler
            subjectsTableView.dataSource = subjectsHandler
            studentMarksTableView.delegate = studentMarksHandler
            studentMarksTableView.dataSource = studentMarksHandler
        }
    }
    
    
    private func setupPopupView() {
        popUpView.isHidden = true
        popUpView.layer.cornerRadius = 12
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOpacity = 0.3
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 2)
        popUpView.layer.shadowRadius = 4
        
        // ✅ CRITICAL: Set up the table view delegate and data source
        subMarksTableView.delegate = self
        subMarksTableView.dataSource = self
        subMarksTableView.rowHeight = 60
        subMarksTableView.separatorStyle = .singleLine
        
        // Add tap gesture to dismiss popup when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self  // ✅ Make sure to set delegate
        view.addGestureRecognizer(tapGesture)
    }
     
    private func handleEyeButtonTapped(subjectDetail: SubjectMarksDetails, studentId: String?) {
        print("👁️ Eye button tapped!")
        print("Subject: \(subjectDetail.subjectName ?? "")")
        print("Student ID: \(studentId ?? "N/A")")
        print("SubMarks count: \(subjectDetail.subMarks.count)")
        print("✅ handleEyeButtonTapped is being called!")
        
        
        
        // Store the data
        popupSubjectDetail = subjectDetail
        popupStudentId = studentId
        tappedStudentId = studentId
        tappedSubjectId = subjectDetail.subjectId
        
        findAndStoreIndexPathFor(subjectDetail: subjectDetail, studentId: studentId)
        
        // Show the popup with sub marks
        showSubMarksPopup(subjectDetail: subjectDetail)
    }
    private func findAndStoreIndexPathFor(subjectDetail: SubjectMarksDetails, studentId: String?) {
        guard let studentId = studentId else { return }
        
        // Search through the filtered data to find the indexPath
        for (sectionIndex, studentData) in studentMarksHandler.filteredStudentData.enumerated() {
            if studentData.studentId == studentId {
                for (rowIndex, subject) in studentData.subjectMarksDetails.enumerated() {
                    if subject.subjectId == subjectDetail.subjectId {
                        tappedCellIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                        print("✅ Found indexPath: section \(sectionIndex), row \(rowIndex)")
                        return
                    }
                }
            }
        }
        print("⚠️ Could not find indexPath for subject: \(subjectDetail.subjectName ?? "")")
    }
     
     private func showSubMarksPopup(subjectDetail: SubjectMarksDetails) {
         // Update popup UI
         subName.text = subjectDetail.subjectName
         maxMarkofSub.text = "Max: \(subjectDetail.maxMarks)"
         minMarkofSub.text = "Min: \(subjectDetail.minMarks)"
         
         // Set popup table view data
         setupSubMarksTableView()
         
         // Show popup with animation
         popUpView.isHidden = false
         popUpView.alpha = 0
         popUpView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
         
         UIView.animate(withDuration: 0.3) {
             self.popUpView.alpha = 1
             self.popUpView.transform = CGAffineTransform.identity
             self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
         }
     }
     
     private func setupSubMarksTableView() {
         // Register cell if needed
         let nib = UINib(nibName: "EditSubMarksTableViewCell", bundle: nil)
         subMarksTableView.register(nib, forCellReuseIdentifier: "EditSubMarksTableViewCell")
         subjectsTableView.register(
             UINib(nibName: "ExamAndSubjectTitleTableViewCell1", bundle: nil),
             forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell1"
         )

   
         subMarksTableView.reloadData()
     }
     
     @IBAction func cancelActionTapped(_ sender: UIButton) {
         dismissPopup()
     }
    @IBAction func addActionTapped(_ sender: UIButton) {
        
        // 1. Calculate total marks from sub marks
        let totalMarks = totalMarks
        print("📊 Calculated total marks: \(totalMarks)")
        
        // 2. Update the specific text field
        updateSpecificTextField(with: totalMarks ?? "")
        
        // 3. Update the data model
        updateDataModel(with: totalMarks ?? "")
        
        dismissPopup()
    }
    private func calculateTotalMarksFromSubMarks() -> String {
        guard let subjectDetail = popupSubjectDetail else {
            print("⚠️ No subject detail found")
            return "0"
        }
        
        var total = 0
        for subMark in subjectDetail.subMarks {
            if let mark = Int(subMark.actualMarks ?? "0") {
                total += mark
            }
        }
        
        print("🧮 Total calculated: \(total) from \(subjectDetail.subMarks.count) sub marks")
        return "\(total)"
    }
    private func updateSpecificTextField(with marks: String) {
        guard let indexPath = tappedCellIndexPath else {
            print("⚠️ No indexPath found")
            return
        }
        
        print("🎯 Updating text field at indexPath: \(indexPath)")
        
        // Update the cell if it's visible
        if let cell = studentMarksTableView.cellForRow(at: indexPath) as? SubjectNameDetailsTableViewCell1 {
            cell.obtainedMarksTextFeild.text = marks
            print("✅ Updated text field directly: \(marks)")
            
            // Trigger the text field delegate to save the change
            cell.textFieldDidEndEditing(cell.obtainedMarksTextFeild)
        } else {
            print("📱 Cell not visible, reloading table")
            // If cell is not visible, reload the data
            studentMarksTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    private func updateDataModel(with marks: String) {
        guard let studentId = tappedStudentId,
              let subjectId = tappedSubjectId else {
            print("⚠️ Missing studentId or subjectId")
            return
        }
        
        print("📊 Updating data model for student: \(studentId), subject: \(subjectId)")
        
        // Find the student in the data model
        if let studentIndex = studentMarkExamDataResponse.firstIndex(where: { $0.studentId == studentId }) {
            // Find the subject in the student's subjects
            if let subjectIndex = studentMarkExamDataResponse[studentIndex].subjectMarksDetails.firstIndex(where: { $0.subjectId == subjectId }) {
                // Update the actual marks
                studentMarkExamDataResponse[studentIndex].subjectMarksDetails[subjectIndex].actualMarks = marks
                
                // Update total marks for the student
                let obtainedTotal = studentMarkExamDataResponse[studentIndex].subjectMarksDetails.reduce(0) {
                    total, subject in
                    total + (Int(subject.actualMarks ?? "0") ?? 0)
                }
                studentMarkExamDataResponse[studentIndex].actualTotalMarks = Double(obtainedTotal)
                
                print("✅ Data model updated successfully")
                
                // Also update the handler's data
                studentMarksHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
                
                // Notify the delegate if needed
                onMarksUpdated?()
                delegate?.didUpdateMarks()
            } else {
                print("❌ Subject not found")
            }
        } else {
            print("❌ Student not found")
        }
    }
     
    @objc private func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.alpha = 0
            self.popUpView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.view.backgroundColor = .clear
        }) { _ in
            self.popUpView.isHidden = true
            self.popupSubjectDetail = nil
            self.popupStudentId = nil
            // Don't reset tappedCellIndexPath here if you need it for Add button
        }
    }
   
    func fetchMarksCardData(completion: @escaping () -> Void) {
        guard let teamId = teamId, let testId = testId else {
            print("❌ Missing teamId or testId")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/new"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        print("📡 Calling API: \(urlString)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }
            print("📦 Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let responseModel = try decoder.decode(MarksCardResponse.self, from: data)

                // ✅ Store main data
                self.studentMarkExamDataResponse = responseModel.data

                DispatchQueue.main.async {
                    // ✅ Update handlers *before* reload
                    self.subjectsHandler.studentMarkExamDataResponse = responseModel.data
                    self.studentMarksHandler.studentMarkExamDataResponse = responseModel.data

                    // ✅ Reload tables only once
                    self.subjectsLabel.text = "Subjects (\(self.studentMarkExamDataResponse.count))"
                    self.subjectsTableView.reloadData()
                    self.studentMarksTableView.reloadData()

                    print("✅ Successfully decoded and stored data.")
                    print("🧑‍🎓 Students count: \(self.studentMarkExamDataResponse.count)")

                    // ✅ Call completion
                    completion()
                }

            } catch {
                print("❌ JSON Decoding Error:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Raw JSON:\n\(jsonString)")
                }
            }
        }
        task.resume()
    }
    
    func updateMarksCardAdmin() {
        guard let teamId = teamId,
              let testId = testId,
              let token = TokenManager.shared.getToken() else {
            self.showAlert(title: "Error", message: "Missing required information or token.")
            return
        }
        
        // ✅ Print all student data before API call
        print("📊 All student data before API call:")
        for (index, student) in studentMarkExamDataResponse.enumerated() {
            print("Student \(index): \(student.studentName ?? "")")
            for subject in student.subjectMarksDetails {
                print("   \(subject.subjectName ?? ""): \(subject.actualMarks ?? "nil")")
            }
        }

        // ✅ Update marks for ALL students, not just the first one
        for student in studentMarkExamDataResponse {
            guard let gruppieRollNumber = student.gruppieRollNumber else {
                print("❌ Missing gruppieRollNumber for student: \(student.studentName ?? "")")
                continue
            }

            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/markscard/edit/new?userId=\(gruppieRollNumber)"
            print("🌐 API URL for \(student.studentName ?? ""): \(urlString)")

            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL for student: \(student.studentName ?? "")")
                continue
            }

            // ✅ Construct subMarks array properly for this student
            let subjectMarksArray = student.subjectMarksDetails.map { subject -> [String: Any] in
                let subMarksArray = subject.subMarks.map { sub -> [String: Any] in
                    return [
                        "actualMarks": sub.actualMarks ?? totalMarks,
                        "attendance": sub.attendance ?? "",
                        "maxMarks": sub.maxMarks ?? "",
                        "minMarks": sub.minMarks ?? "",
                        "shortName": sub.shortName ?? "",
                        "splitName": sub.splitName ?? "",
                        "type": sub.type ?? ""
                    ]
                }

                return [
                    "actualMarks": subject.actualMarks ?? "",
                    "attendance": subject.attendance ?? "",
                    "date": subject.date ?? "",
                    "enable": subject.enable ?? true,
                    "endTime": subject.endTime ?? "",
                    "gradeRange": subject.gradeRange,
                    "inwords": subject.inwords ?? "",
                    "maxMarks": subject.maxMarks,
                    "minMarks": subject.minMarks,
                    "shortName": subject.shortName ?? "",
                    "startTime": subject.startTime ?? "",
                    "subMarks": subMarksArray,
                    "subjectAverageMarks": subject.subjectAverageMarks ?? 0.0,
                    "subjectGrade": subject.subjectGrade ?? "",
                    "subjectId": subject.subjectId ?? "",
                    "subjectName": subject.subjectName ?? "",
                    "subjectPriority": subject.subjectPriority ?? 0,
                    "subjectSort": subject.subjectSort ?? 0,
                    "submarkslength": subject.submarkslength ?? 0,
                    "type": subject.type ?? ""
                ]
            }

            // ✅ Create minimal body for this student
            let minimalBody: [String: Any] = [
                "studentId": student.studentId ?? "",
                "testId": student.testId ?? "",
                "subjectMarksDetails": subjectMarksArray,
                "actualTotalMarks": student.actualTotalMarks ?? 0,
                "overallPercentage": student.overallPercentage ?? 0.0,
                "overallGrade": student.overallGrade ?? "",
                "studentName": student.studentName ?? "",
                "rollNumber": student.rollNumber ?? "",
                "gruppieRollNumber": student.gruppieRollNumber ?? ""
            ]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: minimalBody, options: [.prettyPrinted])
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.httpBody = jsonData
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 30

                print("🚀 Sending update for student: \(student.studentName ?? "")")

                // ✅ Use semaphore to wait for each request to complete
                let semaphore = DispatchSemaphore(value: 0)
                var success = false

                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { semaphore.signal() }

                    if let error = error {
                        print("❌ API Error for \(student.studentName ?? ""):", error.localizedDescription)
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Invalid response for \(student.studentName ?? "")")
                        return
                    }

                    print("📬 Response Code for \(student.studentName ?? ""): \(httpResponse.statusCode)")

                    if httpResponse.statusCode == 200 {
                        success = true
                        print("✅ Successfully updated marks for \(student.studentName ?? "")")
                    } else {
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("❌ Error Response for \(student.studentName ?? ""): \(errorString)")
                        }
                    }
                }.resume()

                // Wait for the request to complete
                _ = semaphore.wait(timeout: .now() + 30)

            } catch {
                print("❌ JSON Serialization Error for \(student.studentName ?? ""):", error)
            }
        }

        // ✅ Show final success message
        DispatchQueue.main.async {
            self.showAlert(title: "Success", message: "All marks updated successfully!") {
                self.fetchMarksCardData {
                    self.studentMarksTableView.reloadData()
                }
            }
        }
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setupTableViews() {
        let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell1", bundle: nil)
        subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell1")
        subjectsTableView.register(
             UINib(nibName: "ExamAndSubjectTitleTableViewCell1", bundle: nil),
             forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell1"
         )
        studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell1", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell1")

        // ✅ Initialize handlers
        subjectsHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
        studentMarksHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
        studentMarksHandler.currentlySelectedStudentId = selectedStudentUserId
        
        // ✅ Add editing callbacks
        studentMarksHandler.onEditingStarted = { [weak self] studentId in
            self?.currentlyEditingStudentId = studentId
        }
        
        studentMarksHandler.onEditingEnded = { [weak self] in
            self?.currentlyEditingStudentId = nil
        }
        
        // ✅ Add eye button callback
        studentMarksHandler.onEyeButtonTapped = { [weak self] subjectDetail, studentId in
            self?.handleEyeButtonTapped(subjectDetail: subjectDetail, studentId: studentId)
        }
        
        // ✅ Add this callback to get notified when data changes
        studentMarksHandler.onDataChanged = { [weak self] updatedData in
            guard let self = self else { return }
            self.studentMarkExamDataResponse = updatedData
            print("📝 Data model updated with new marks")
        }
        
        // ✅ CRITICAL: Clear any existing connections first
        subjectsTableView.delegate = nil
        subjectsTableView.dataSource = nil
        studentMarksTableView.delegate = nil
        studentMarksTableView.dataSource = nil
        
        // ✅ Now set the handlers
        subjectsTableView.delegate = subjectsHandler
        subjectsTableView.dataSource = subjectsHandler
        studentMarksTableView.delegate = studentMarksHandler
        studentMarksTableView.dataSource = studentMarksHandler
        
        studentMarksHandler.onMarksUpdate = { [weak self] in
            self?.studentMarksTableView.reloadData()
        }
        
        subjectsLabel.text = "All Subjects"
        subjectsHandler.didSelectSubject = { [weak self] selectedSubject in
            guard let self = self else { return }
            self.subjectsLabel.text = selectedSubject
            self.subjectsView.isHidden = true
            self.studentMarksHandler.selectedSubject = selectedSubject == "All Subjects" ? nil : selectedSubject
            print("✅ Selected subject: \(selectedSubject)")
        }
        
        // Add tap gesture for table view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        studentMarksTableView.addGestureRecognizer(tapGesture)
        
        subjectsTableView.reloadData()
        studentMarksTableView.reloadData()
    }
    
//    private func handleEyeButtonTapped(subjectDetail: SubjectMarksDetails, studentId: String?) {
//        print("👁️ Eye button tapped!")
//        print("Subject: \(subjectDetail.subjectName ?? "")")
//        print("Student ID: \(studentId ?? "N/A")")
//        print("SubMarks count: \(subjectDetail.subMarks.count)")
//        
//        // Show the sub marks in your popup or navigate to detailed view
//        showSubMarksPopup(subjectDetail: subjectDetail)
//    }
    
//    private func showSubMarksPopup(subjectDetail: SubjectMarksDetails) {
//        // Use the popUpView you already have
//        guard !subjectDetail.subMarks.isEmpty else {
//            showAlert(title: "Info", message: "No sub marks available for this subject.")
//            return
//        }
//        
//        // Example: Show alert with sub marks info
//        var message = "Sub Marks for \(subjectDetail.subjectName ?? ""):\n\n"
//        for (index, subMark) in subjectDetail.subMarks.enumerated() {
//            message += "\(index + 1). \(subMark.splitName ?? ""): \(subMark.actualMarks ?? "")/\(subMark.maxMarks ?? "")\n"
//        }
//        
//        showAlert(title: "Sub Marks Details", message: message)
//    }
    
    @objc func handleTableViewTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: studentMarksTableView)
        if let indexPath = studentMarksTableView.indexPathForRow(at: location) {
            let studentData = studentMarksHandler.filteredStudentData[indexPath.section]
            print("🎯 Selected student: \(studentData.studentName ?? "")")
            
            // Try to start editing when tapping on the cell
            if let cell = studentMarksTableView.cellForRow(at: indexPath) as? SubjectNameDetailsTableViewCell1 {
                cell.obtainedMarksTextFeild.becomeFirstResponder()
            }
        } else {
            // If tapping outside cells, hide keyboard
            hideKeyboard()
        }
    }
    
    @objc func disableEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    @IBAction func submitActionTapped(_ sender: UIButton) {
        print("📊 Current student data before API call:")
        for (index, student) in studentMarkExamDataResponse.enumerated() {
            print("Student \(index): \(student.studentName ?? "")")
            for subject in student.subjectMarksDetails {
                print("   \(subject.subjectName ?? ""): \(subject.actualMarks ?? "nil")")
            }
        }

        // Check user role and call appropriate API
        if let role = currentRole, role.lowercased() == "admin" {
            print("👑 Admin role detected - calling admin API")
            updateMarksCardAdmin()
        } else {
            print("👤 Non-admin role detected - calling non-admin API")
            //updateMarksCardForNonAdmin()
        }
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
        @IBAction func allSubjectListingButtonAction(_ sender: Any) {
            subjectsView.isHidden.toggle()
            subjectsTableView.reloadData()
        }
        private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            present(alert, animated: true)
        }
        func marksUpdated() {
            onMarksUpdated?()
        }// MARK: - UIGestureRecognizerDelegate Extension
    
    func navigateToEditAllMarks(subjectData: SubjectMarksDetails) {

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "EditAllMarksViewController"
        ) as! EditAllMarksViewController

        // Pass IDs
        vc.groupId = self.groupId
        vc.teamId = self.teamId
        vc.testId = self.testId
        vc.subjectId = subjectData.subjectId
        vc.subName = subjectData.subjectName
        navigationController?.pushViewController(vc, animated: true)
    }

        
    }
    
    class StudentMarksNewTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
        
        weak var parentVC: Student_listVC?    // reference to your VC
        var totalMarks: Int?
        var onEyeButtonTapped: ((SubjectMarksDetails, String?) -> Void)?
        
        // MARK: - Properties
        var studentMarkExamDataResponse: [StudentMarksData] = [] {
            didSet {
                updateFilteredData()
            }
        }
        
        var currentlySelectedStudentId: String?
        var onMarksUpdate: (() -> Void)?
        var onEditingStarted: ((String) -> Void)?
        var onEditingEnded: (() -> Void)?
        var onDataChanged: (([StudentMarksData]) -> Void)?
        
        var selectedSubject: String? {
            didSet {
                updateFilteredData()
                onMarksUpdate?()
            }
        }
        
        private var _filteredStudentData: [StudentMarksData] = []
        
        var filteredStudentData: [StudentMarksData] {
            return _filteredStudentData
        }
        
        // MARK: - Data Filtering
        private func updateFilteredData() {
            guard let selectedSubject = selectedSubject, selectedSubject != "All Subjects" else {
                _filteredStudentData = studentMarkExamDataResponse
                return
            }
            
            _filteredStudentData = studentMarkExamDataResponse.compactMap { studentData in
                if let subjectDetail = studentData.subjectMarksDetails.first(where: {
                    $0.subjectName == selectedSubject
                }) {
                    var filteredStudent = studentData
                    filteredStudent.subjectMarksDetails = [subjectDetail]
                    return filteredStudent
                }
                return nil
            }
        }
        
        // MARK: - UITableViewDataSource
        //    func numberOfSections(in tableView: UITableView) -> Int {
        //        return filteredStudentData.count
        //    }
        func numberOfSections(in tableView: UITableView) -> Int {
            print("📊 StudentMarksNewTableViewHandler: numberOfSections called")
            return filteredStudentData.count
        }
        
        //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        guard section < filteredStudentData.count else { return 0 }
        //        return filteredStudentData[section].subjectMarksDetails.count
        //    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("📊 StudentMarksNewTableViewHandler: numberOfRowsInSection called for section \(section)")
            guard section < filteredStudentData.count else { return 0 }
            return filteredStudentData[section].subjectMarksDetails.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SubjectNameDetailsTableViewCell1",
                for: indexPath
            ) as? SubjectNameDetailsTableViewCell1 else {
                return UITableViewCell()
            }
            
            guard indexPath.section < filteredStudentData.count,
                  indexPath.row < filteredStudentData[indexPath.section].subjectMarksDetails.count else {
                return cell
            }
            
            let studentData = filteredStudentData[indexPath.section]
            let subjectDetail = studentData.subjectMarksDetails[indexPath.row]
            
            // Configure the cell
            cell.configure(with: subjectDetail, studentId: studentData.studentId)
            
            // Set up callbacks with weak references
            cell.onEditingBegan = { [weak self] in
                self?.onEditingStarted?(studentData.studentId ?? "")
                self?.currentlySelectedStudentId = studentData.studentId
            }
            
            cell.onEditingEnded = { [weak self] in
                self?.onEditingEnded?()
                self?.currentlySelectedStudentId = nil
            }
            
            cell.onMarksChanged = { [weak self, weak tableView] newText, studentId, subjectId in
                guard let self = self, let tableView = tableView else { return }
                
                self.updateMarksInDataModel(
                    newText: newText,
                    studentId: studentId,
                    subjectId: subjectId,
                    tableView: tableView,
                    indexPath: indexPath
                )
            }
            
            // ✅ Add eye button callback
            cell.onEyeButtonTapped = { [weak self] in
                self?.onEyeButtonTapped?(subjectDetail, studentData.studentId)
            }
            return cell
        }
        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 80
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard section < filteredStudentData.count else { return nil }
            
            let studentData = filteredStudentData[section]
            let headerView = UIView()
            
            // Set background color based on selection
            if studentData.studentId == currentlySelectedStudentId {
                headerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            } else {
                headerView.backgroundColor = .white
            }
            
            // Add icon
            let iconImageView = UIImageView(frame: CGRect(x: 15, y: 5, width: 40, height: 40))
            iconImageView.image = UIImage(systemName: "person.circle")
            iconImageView.tintColor = .black
            headerView.addSubview(iconImageView)
            
            // Student name
            let nameLabel = UILabel(frame: CGRect(x: 65, y: 5, width: tableView.frame.width - 80, height: 25))
            nameLabel.text = studentData.studentName
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            nameLabel.textColor = .black
            headerView.addSubview(nameLabel)
            
            // Calculate totals
            let obtainedTotal = studentData.subjectMarksDetails.reduce(into: 0) {
                $0 += Int($1.actualMarks ?? "0") ?? 0
            }
            let maxTotal = studentData.subjectMarksDetails.reduce(into: 0) {
                $0 += Int($1.maxMarks) ?? 0
            }
            
            // Total label
            let totalLabel = UILabel(frame: CGRect(x: 65, y: 30, width: 50, height: 20))
            totalLabel.text = "Total"
            totalLabel.font = UIFont.boldSystemFont(ofSize: 14)
            totalLabel.textColor = .darkGray
            headerView.addSubview(totalLabel)
            
            // Score label
            let scoreLabel = UILabel(frame: CGRect(x: totalLabel.frame.maxX + 10, y: 30, width: 100, height: 20))
            scoreLabel.text = "\(obtainedTotal)/\(maxTotal)"
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
            scoreLabel.textColor = .darkGray
            headerView.addSubview(scoreLabel)
            
            // Column headers
            let totalWidth = tableView.frame.width
            let subjectLabel = UILabel(frame: CGRect(x: 0, y: 55, width: totalWidth * 0.6, height: 20))
            subjectLabel.text = "Subject"
            subjectLabel.font = UIFont.boldSystemFont(ofSize: 14)
            subjectLabel.textAlignment = .center
            subjectLabel.textColor = .black
            headerView.addSubview(subjectLabel)
            
            let remainingLabels = ["Min - Max", "Obtained"]
            let remainingWidth = totalWidth * 0.4 / CGFloat(remainingLabels.count)
            
            for (index, labelText) in remainingLabels.enumerated() {
                let labelX = totalWidth * 0.6 + CGFloat(index) * remainingWidth
                let label = UILabel(frame: CGRect(x: labelX, y: 55, width: remainingWidth, height: 20))
                label.text = labelText
                label.font = UIFont.boldSystemFont(ofSize: 14)
                label.textAlignment = .center
                label.textColor = .black
                headerView.addSubview(label)
            }
            
            return headerView
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // Start editing the text field
            if let cell = tableView.cellForRow(at: indexPath) as? SubjectNameDetailsTableViewCell1 {
                cell.obtainedMarksTextFeild.becomeFirstResponder()
            }
        }
        
        
        // MARK: - Data Model Update
        private func updateMarksInDataModel(
            newText: String,
            studentId: String?,
            subjectId: String?,
            tableView: UITableView,
            indexPath: IndexPath
        ) {
            guard let studentId = studentId,
                  let subjectId = subjectId,
                  let studentIndex = self.studentMarkExamDataResponse.firstIndex(where: {
                      $0.studentId == studentId
                  }),
                  let subjectIndex = self.studentMarkExamDataResponse[studentIndex].subjectMarksDetails.firstIndex(where: {
                      $0.subjectId == subjectId
                  }) else {
                return
            }
            
            // Update the marks
            var updatedStudents = self.studentMarkExamDataResponse
            updatedStudents[studentIndex].subjectMarksDetails[subjectIndex].actualMarks =
            newText.isEmpty ? nil : newText
            
            // Update total marks
            let obtainedTotal = updatedStudents[studentIndex].subjectMarksDetails.reduce(0) {
                total, subject in
                total + (Int(subject.actualMarks ?? "0") ?? 0)
            }
            
            updatedStudents[studentIndex].actualTotalMarks = Double(obtainedTotal)
            
            // Update the main array
            self.studentMarkExamDataResponse = updatedStudents
            
            // Update filtered data
            self.updateFilteredData()
            
            // Notify that data has changed
            self.onDataChanged?(self.studentMarkExamDataResponse)
            
            // Update UI
            DispatchQueue.main.async {
                // Reload the section header to update total
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
        }
    }
    
//    class SubjectsNewTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
//        var studentMarkExamDataResponse: [StudentMarksData] = []
//        var didSelectSubject: ((String) -> Void)?
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return studentMarkExamDataResponse.first?.subjectMarksDetails.count ?? 0
//        }
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            // ✅ FIX: Use correct identifier and cell class
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamAndSubjectTitleTableViewCell1", for: indexPath) as? ExamAndSubjectTitleTableViewCell1 else {
//                return UITableViewCell()
//            }
//            if let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row] {
//                cell.titleLabel.text = subjectData.subjectName
//            }
//            return cell
//        }
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let selectedSubject = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row].subjectName ?? "N/A"
//            didSelectSubject?(selectedSubject)
//        }
//    }
class SubjectsNewTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var parentVC: Student_listVC?   // ✅ IMPORTANT

    var studentMarkExamDataResponse: [StudentMarksData] = []
    var didSelectSubject: ((String) -> Void)?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentMarkExamDataResponse.first?.subjectMarksDetails.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExamAndSubjectTitleTableViewCell1",
            for: indexPath
        ) as? ExamAndSubjectTitleTableViewCell1 else {
            return UITableViewCell()
        }

        if let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row] {
            cell.titleLabel.text = subjectData.subjectName
        }
        return cell
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let selectedSubject = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row].subjectName ?? "N/A"
//        didSelectSubject?(selectedSubject)
//
//        guard
//            let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails[indexPath.row]
//        else { return }
//
//        // 🚀 Delegate navigation to ViewController
//        parentVC?.navigateToEditAllMarks(subjectData: subjectData)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard
            let subjectData =
                studentMarkExamDataResponse.first?
                    .subjectMarksDetails[indexPath.row]
        else { return }

        let selectedSubject = subjectData.subjectName ?? "N/A"

        // ✅ Always update subject filter
        didSelectSubject?(selectedSubject)

        // ✅ Navigate ONLY if role = TEACHER
        if parentVC?.currentRole?.lowercased() == "teacher" {
            parentVC?.navigateToEditAllMarks(subjectData: subjectData)
        } else {
            // ❌ No navigation for non-teacher
            print("ℹ️ Role is not TEACHER → filtering only")
        }
    }

}

extension Student_listVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't receive touch if it's on the popup view
        let location = touch.location(in: popUpView)
        if popUpView.bounds.contains(location) {
            return false
        }
        
        // Don't receive touch if it's on the table view (to allow cell taps)
        let tableViewLocation = touch.location(in: studentMarksTableView)
        if studentMarksTableView.bounds.contains(tableViewLocation) {
            return false
        }
        
        return true
    }
}
// MARK: - UITableViewDataSource & UITableViewDelegate for Popup Table View
extension Student_listVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Make sure we're returning count for the right table view
        if tableView == subMarksTableView {
            return popupSubjectDetail?.subMarks.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView == subMarksTableView,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditSubMarksTableViewCell",
                for: indexPath
              ) as? EditSubMarksTableViewCell else {
            return UITableViewCell()
        }
        
        if let subMark = popupSubjectDetail?.subMarks[indexPath.row] {
            cell.configureSubMark(subMark: subMark)

            // 🔥 Update model when user types
            cell.onTextChanged = { [weak self] newValue in
                self?.popupSubjectDetail?.subMarks[indexPath.row].actualMarks = newValue
                self?.recalculateTotalMarks()
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    private func recalculateTotalMarks() {
        guard let subMarks = popupSubjectDetail?.subMarks else { return }

        var total = 0

        for subMark in subMarks {
            let mark = Int(subMark.actualMarks ?? "0") ?? 0
            total += mark
        }

        self.totalMarks = String(total)
        print("Updated Total: \(total)")
    }

}
