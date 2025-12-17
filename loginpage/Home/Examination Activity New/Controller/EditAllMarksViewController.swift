import UIKit
class EditAllMarksViewController  : UIViewController {
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var studentMarksTableView: UITableView!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var submitAction: UIButton!
    
    // MARK: - Variables
    var groupId: String = ""
    var teamId: String?
    var testId: String?
    var currentRole: String?
    var subjectId: String?
    var subName: String?
    var students: [EditAllMarksStudent] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("subjectId\(subjectId)")
        self.subjectLabel.text = subName
        studentMarksTableView.layer.cornerRadius = 10
        fetchMarksForOneSub()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        enableKeyboardDismissOnTap()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        submitAction.layer.cornerRadius = 10
        studentMarksTableView.register(UINib(nibName: "EditAllMarksTableViewCell", bundle: nil),
                                       forCellReuseIdentifier: "EditAllMarksTableViewCell")
        studentMarksTableView.dataSource = self
        studentMarksTableView.delegate = self
        
    }
    
    // MARK: - API Call
    func fetchMarksForOneSub() {
        guard let teamId = teamId,
              let testId = testId,
              let subjectId = subjectId else {
            print("❌ Missing IDs")
            return
        }

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/allstudents/markscard?subjectId=\(subjectId)"

        guard let url = URL(string: urlString) else { return }
        guard let token = TokenManager.shared.getToken() else { return }

        print("📡 API:", urlString)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error:", error)
                return
            }

            guard let data = data else { return }

             do {
                 let response = try JSONDecoder().decode(EditAllMarksResponse.self, from: data)
                 DispatchQueue.main.async {
                     self.students = response.data
                     self.studentMarksTableView.reloadData()
                 }

            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }
    
    
    
    func buildUpdateRequestBody() -> EditAllMarksUpdateRequest {

        let updates = students.map { student in
            EditAllMarksStudentUpdate(
                actualMarks: student.actualMarks ?? "0",
                attendance: student.attendance ?? "",
                gruppieRollNumber: student.gruppieRollNumber ?? "",
                inwords: student.inwords ?? "",
                maxMarks: student.maxMarks ?? "",
                minMarks: student.minMarks ?? "",
                rollNumber: student.rollNumber ?? "",
                studentImage: student.studentImage ?? "",
                studentName: student.studentName ?? "",
                subMarks: student.subMarks ?? [],
                subjectId: student.subjectId ?? "",
                subjectName: student.subjectName ?? "",
                subjectPriority: student.subjectPriority ?? 0
            )
        }

        return EditAllMarksUpdateRequest(studentMarksUpdates: updates)
    }

    func submitAllMarks() {

        guard let teamId = teamId,
              let testId = testId,
              let subjectId = subjectId else {
            print("❌ Missing IDs")
            return
        }

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupId)/team/\(teamId)/testexam/\(testId)/subject/\(subjectId)/markscard/edit/all"

        guard let url = URL(string: urlString),
              let token = TokenManager.shared.getToken() else { return }

        let requestBody = buildUpdateRequestBody()

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            print("📤 PUT BODY:", String(data: jsonData, encoding: .utf8) ?? "")

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("❌ PUT Error:", error)
                    return
                }

                if let data = data {
                    print("✅ PUT Response:", String(data: data, encoding: .utf8) ?? "")
                }
            }.resume()

        } catch {
            print("❌ Encoding error:", error)
        }
    }

    // MARK: - Actions
    @IBAction func submitActionTapped(_ sender: UIButton) {
        submitAllMarks()
    }


    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView: Students Marks
extension EditAllMarksViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "EditAllMarksTableViewCell",
            for: indexPath
        ) as? EditAllMarksTableViewCell else {
            return UITableViewCell()
        }

        let student = students[indexPath.row]

        cell.StudentNameClass.text = student.studentName ?? "N/A"
       
    // ✅ FORCE DISPLAY "0" ALSO
        if let marks = student.actualMarks, !marks.isEmpty {
            cell.ObtainedMarks.text = marks
        } else {
            cell.ObtainedMarks.text = "0"
        }

        cell.ObtainedMarks.tag = indexPath.row
        cell.ObtainedMarks.delegate = self
        cell.ObtainedMarks.addTarget(
            self,
            action: #selector(marksTextChanged(_:)),
            for: .editingChanged
        )

        // Image / fallback
        if let imageString = student.studentImage,
           imageString.hasPrefix("http"),
           let url = URL(string: imageString) {

            cell.iconImageView.isHidden = false
            cell.fallbackLabel.isHidden = true
            cell.loadImage(from: url)

        } else {
            cell.iconImageView.isHidden = true
            cell.fallbackLabel.isHidden = false
            cell.fallbackLabel.text = String(student.studentName?.prefix(1) ?? "?")
        }

        return cell
    }


    @objc func marksTextChanged(_ textField: UITextField) {
        let row = textField.tag
        guard students.indices.contains(row) else { return }

        let value = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        students[row].actualMarks = value.isEmpty ? "0" : value
    }
}
