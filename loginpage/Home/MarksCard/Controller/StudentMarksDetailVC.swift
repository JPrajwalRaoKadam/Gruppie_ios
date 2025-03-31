//
//  StudentMarksDetailVC.swift
//  loginpage
//
//  Created by apple on 12/03/25.
//

import UIKit

class StudentMarksDetailVC: UIViewController {
    
    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var subjectsLabel: UILabel!
    @IBOutlet weak var studentMarksTableView: UITableView!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var AllSubTextFeild: UITextField!
    
    var groupId: String = ""
    var teamId: String?
    var offlineTestExamId: String?
    
    var studentMarkExamDataResponse: [StudentMarksData] = []
    var examDataResponse: [ExamData] = []
    var passedExamTitle = ""
    let subjectsHandler = SubjectsTableViewHandler()
    let studentMarksHandler = StudentMarksTableViewHandler()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subjectsView.isHidden = true
        let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell", bundle: nil)
        subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell")
        studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell")
        setupTableViews()
    }
    
    func setupTableViews() {
        let nib = UINib(nibName: "ExamAndSubjectTitleTableViewCell", bundle: nil)

        // Register cells
        subjectsTableView.register(nib, forCellReuseIdentifier: "ExamAndSubjectTitleTableViewCell")
        studentMarksTableView.register(UINib(nibName: "SubjectNameDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectNameDetailsTableViewCell")

        AllSubTextFeild.isUserInteractionEnabled = false
        AllSubTextFeild.addTarget(self, action: #selector(disableEditing), for: .editingDidBegin)

        
        // Pass data to handlers
        subjectsHandler.studentMarkExamDataResponse = studentMarkExamDataResponse
        studentMarksHandler.studentMarkExamDataResponse = studentMarkExamDataResponse

        subjectsTableView.delegate = subjectsHandler
        subjectsTableView.dataSource = subjectsHandler

        studentMarksTableView.delegate = studentMarksHandler
        studentMarksTableView.dataSource = studentMarksHandler

        studentMarksHandler.onMarksUpdate = { [weak self] in
                self?.studentMarksTableView.reloadData()
            }
        
        // Handle subject selection
        subjectsHandler.didSelectSubject = { [weak self] selectedSubject in
            self?.subjectsLabel.text = selectedSubject
            self?.subjectsView.isHidden = true  // Hide view after selection
        }
    }

    @objc func disableEditing(_ textField: UITextField) {
        textField.resignFirstResponder()  // Immediately dismiss keyboard
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if let parentVC = navigationController?.viewControllers.first(where: { $0 is ExamVC }) as? ExamVC {
               parentVC.studentMarkExamDataResponse = []  // Force a refresh on return
           }
    }
    
    @IBAction func allSubjectListingButtonAction(_ sender: Any) {
        subjectsView.isHidden.toggle()
        subjectsTableView.reloadData()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        studentMarksHandler.updateStudentTestMarksList(groupId: groupId, teamId: teamId!, selectedTestId: offlineTestExamId!, token: TokenManager.shared.getToken()!)
    }
    
    
    
}

class StudentMarksTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var studentMarkExamDataResponse: [StudentMarksData] = []
    var subjectMarkDetail: [SubjectMarkDetail] = []
    var obtainedMarksText: String?
    var onMarksUpdate: (() -> Void)?
    
    // Number of sections = Number of students
    func numberOfSections(in tableView: UITableView) -> Int {
        return studentMarkExamDataResponse.count
    }
    
    // Number of rows per section = Number of subjects for that student
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentMarkExamDataResponse[section].subjectMarksDetails?.count ?? 0
    }
    
    // Custom section header = Student's name + icon + total + 1 score label
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let studentData = studentMarkExamDataResponse[section]
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        // Profile Image
        let iconImageView = UIImageView(frame: CGRect(x: 15, y: 5, width: 40, height: 40))
        iconImageView.image = UIImage(systemName: "person.circle")
        iconImageView.tintColor = .black
        iconImageView.contentMode = .scaleAspectFit
        headerView.addSubview(iconImageView)
        
        // Student's Name Label
        let nameLabel = UILabel(frame: CGRect(x: 65, y: 5, width: tableView.frame.width - 80, height: 25))
        nameLabel.text = studentData.studentName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black
        headerView.addSubview(nameLabel)
        
        // Total Label (smaller & bold)
        let totalLabel = UILabel(frame: CGRect(x: 65, y: 30, width: 50, height: 20))
        totalLabel.text = "Total"
        totalLabel.font = UIFont.boldSystemFont(ofSize: 14)
        totalLabel.textColor = .darkGray
        headerView.addSubview(totalLabel)
        
        // Single Score Label (e.g., "100/100")
        let scoreLabel = UILabel(frame: CGRect(x: totalLabel.frame.maxX + 10, y: 30, width: 80, height: 20))
        //        let obtainedMarks = studentData.subjectMarksDetails?.reduce(0) { $0 + (Int($1.obtainedMarks ?? "") ?? 0) } ?? 0
        //        let maxMarks = studentData.subjectMarksDetails?.count ?? 0
        scoreLabel.text = " 0/0 "
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 14)
        scoreLabel.textColor = .darkGray
        scoreLabel.textAlignment = .left
        headerView.addSubview(scoreLabel)
        
        // Bottom Labels - Adjusted layout for 60/40 split
        let totalWidth = tableView.frame.width
        
        // "Subject" takes 60% of the width
        let subjectLabel = UILabel(frame: CGRect(x: 0, y: 55, width: totalWidth * 0.6, height: 20))
        subjectLabel.text = "Subject"
        subjectLabel.font = UIFont.boldSystemFont(ofSize: 14)
        subjectLabel.textAlignment = .center
        subjectLabel.textColor = .black
        headerView.addSubview(subjectLabel)
        
        // "Min/Max" and "Obtained" share the remaining 40%
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
    
    // Section height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    // Configure each cell with subject name and obtained marks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectNameDetailsTableViewCell", for: indexPath) as? SubjectNameDetailsTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let studentData = studentMarkExamDataResponse[indexPath.section]
        if let subjectMarkDetail = studentData.subjectMarksDetails?[indexPath.row] {
            cell.subName.text = subjectMarkDetail.subjectName
            cell.obtainedMarksTextFeild.text = subjectMarkDetail.obtainedMarks
            cell.onMarksChanged = { [weak self] newText in
                guard let self = self else { return }
                
                // Ensure data gets updated in the main array
                var studentData = self.studentMarkExamDataResponse[indexPath.section]
                studentData.subjectMarksDetails?[indexPath.row].obtainedMarks = newText
                // Put the modified data back into the original array
                self.studentMarkExamDataResponse[indexPath.section] = studentData

                self.onMarksUpdate?()
                print("✅ Updated marks at row \(indexPath.row): \(newText)")
            }

            self.obtainedMarksText  = cell.obtainedMarksTextFeild.text
                cell.minLabel.text = "\(studentData.totalMinMarks ?? "0") - \(studentData.totalMaxMarks ?? "0")"
            } else {
                cell.subName.text = "N/A"
                cell.obtainedMarksTextFeild.text = "N/A"
                cell.minLabel.text = "nil/nil"
            }
            
            return cell
        }
        
//    func updateStudentTestMarksList(groupId: String, teamId: String, selectedTestId: String, token: String) {
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/offline/testexam/\(selectedTestId)/student/marks/add"
//        
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL")
//            return
//        }
//        
//        // Prepare payload from latest data
//        let responseData = ["examDetails": self.studentMarkExamDataResponse.map { student in
//            return [
//                "userId": student.userId ?? "",
//                "offlineTestExamId": student.offlineTestExamId ?? "",
//                "subjectMarksDetails": student.subjectMarksDetails?.map { subject in
//                    return [
//                        "subjectId": subject.subjectId ?? "",
//                        "obtainedMarks": self.obtainedMarksText
//                    ]
//                } ?? []
//            ]
//        }]
//        
//        // Convert payload to JSON
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: responseData, options: []) else {
//            print("❌ Failed to encode JSON payload")
//            return
//        }
//        
//        // Set up the request
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        // Make the API call
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let error = error {
//                print("❌ Error in PUT request: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ No valid response received")
//                return
//            }
//            
//            // Inside URLSession dataTask's response block
//            if (200...299).contains(httpResponse.statusCode) {
//                if let data = data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//                    print("🔍 Raw Response JSON: \(json)")
//                    
//                    let decodedResponse = try JSONDecoder().decode(ExamMarkDataResponse.self, from: jsonData)
//                    DispatchQueue.main.async {
//                        if let updatedData = decodedResponse.data {
//                            self?.studentMarkExamDataResponse = updatedData
//                            self?.onMarksUpdate?()
//                            print("✅ Marks Card Updated Successfully with latest data!")
//                        } else {
//                            print("❌ Decoding succeeded but data is nil")
//                        }
//                    }
//                } catch let DecodingError.keyNotFound(key, context) {
//                    print("❌ Missing key: \(key.stringValue) – Context: \(context.debugDescription)")
//                } catch let DecodingError.typeMismatch(type, context) {
//                    print("❌ Type mismatch for type \(type) – Context: \(context.debugDescription)")
//                } catch let DecodingError.valueNotFound(value, context) {
//                    print("❌ Value \(value) not found – Context: \(context.debugDescription)")
//                } catch let DecodingError.dataCorrupted(context) {
//                    print("❌ Data corrupted – Context: \(context.debugDescription)")
//                } catch {
//                    print("❌ Unknown decoding error: \(error)")
//                }
//            }
//            }
//            else {
//                print("❌ PUT request failed with status code: \(httpResponse.statusCode)")
//                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
//                    print("🔍 Server error response: \(errorResponse)")
//                }
//            }
//        }.resume()
//    }

    func updateStudentTestMarksList(groupId: String, teamId: String, selectedTestId: String, token: String) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/offline/testexam/\(selectedTestId)/student/marks/add"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        // Prepare payload with updated marks
        let updatedMarksData = self.studentMarkExamDataResponse.map { student in
            return [
                "userId": student.userId ?? "",
                "offlineTestExamId": student.offlineTestExamId ?? "",
                "subjectMarksDetails": student.subjectMarksDetails?.map { subject in
                    return [
                        "subjectId": subject.subjectId ?? "",
                        "obtainedMarks": self.obtainedMarksText ?? "0"
                    ]
                } ?? []
            ]
        }

        // Construct the final payload
        let responseData: [String: Any] = ["examDetails": updatedMarksData]

        // Convert payload to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: responseData) else {
            print("❌ Failed to encode JSON payload")
            return
        }
        print("📌 Final Payload: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")

        // Set up the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        // Make the API call
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error in PUT request: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No valid response received")
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                if let data = data {
                    if let rawResponse = String(data: data, encoding: .utf8) {
                        print("🔍 Raw response: \(rawResponse)")
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decodedResponse = try decoder.decode(ExamMarkDataResponse.self, from: data)
                        DispatchQueue.main.async {
                            if let updatedData = decodedResponse.data, !updatedData.isEmpty {
                                self?.studentMarkExamDataResponse = updatedData
                                self?.onMarksUpdate?()
                                print("✅ Marks Card Updated Successfully with latest data!")
                            } else {
                                print("⚠️ Marks updated successfully but response returned an empty array or missing data")
                                self?.onMarksUpdate?()
                            }
                        }
                    } catch {
                        print("❌ Decoding error: \(error.localizedDescription)")
                    }
                }
            } else {
                print("❌ PUT request failed with status code: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("🔍 Server error response: \(errorResponse)")
                }
            }
        }.resume()
    }

    
}
    
    class SubjectsTableViewHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
        
        var studentMarkExamDataResponse: [StudentMarksData] = []
        
        // Add this closure to handle subject selection
        var didSelectSubject: ((String) -> Void)?
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return studentMarkExamDataResponse.first?.subjectMarksDetails?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamAndSubjectTitleTableViewCell", for: indexPath) as? ExamAndSubjectTitleTableViewCell else {
                return UITableViewCell()
            }
            
            let subjectData = studentMarkExamDataResponse.first?.subjectMarksDetails?[indexPath.row]
            cell.titleLabel?.text = subjectData?.subjectName ?? ""
            return cell
        }
        
        // Trigger the closure when a subject row is selected
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedSubject = studentMarkExamDataResponse.first?.subjectMarksDetails?[indexPath.row].subjectName ?? "N/A"
            didSelectSubject?(selectedSubject)
        }
    }
    


extension StudentMarksTableViewHandler: SubjectMarksChangeProtocol {
    
    func sendChangedMarks(maeks: String) {
        self.obtainedMarksText = maeks
    }
}
