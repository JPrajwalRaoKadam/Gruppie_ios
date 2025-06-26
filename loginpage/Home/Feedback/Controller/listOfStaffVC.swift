import UIKit

class listOfStaffVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    var token: String = ""
    var groupId: String = ""
    var teamIds: [String] = []
    var currentRole: String?
    var subjects: [SubjectData] = []
    var feedbackData: FeedBackItem?
    var feedbackId: String?
    var userId: String = ""
    var teamId: String = ""
    var feedbackQuestions: [[QuestionData]] = []

    var feedbackStudents: [FeedbackStudent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        
        studentsTableView.register(UINib(nibName: "listOfStaffVCTableViewCell", bundle: nil), forCellReuseIdentifier: "listOfStaffVCTableViewCell")
        
        print("🟢 listOfStaffVC - Debug Info")
        print("feedbackData-\(feedbackData)")
        print("Group ID: \(groupId)")
        print("user ID: \(userId)")
        print("team ID: \(teamId)")
        print("currentRole: \(currentRole)")
        print("Feedback ID: \(feedbackId ?? "No Feedback ID")")
        print(" feedback questions: \(feedbackQuestions)")
        // Fetch data from the API
        fetchFeedbackStudentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        studentsTableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchFeedbackStudentData() {
        let urlString =  APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/class/staffs/get?feedbackId=\(feedbackId ?? "")&userId=\(userId)"
        
        print("🌐 Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                print("❌ API call failed with error: \(error)")
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }
            print("🟢 staff Raw API Response: \(String(data: data, encoding: .utf8) ?? "No response body")")
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(FeedbackStudentResponse.self, from: data)
                
                self?.feedbackStudents = decodedResponse.data
                
                if let firstStaff = decodedResponse.data.first {
                    let staffId = firstStaff.userId
                    print("🆔 staffId: \(staffId)")
                }
                
                print("🟢 Decoded Data: \(self?.feedbackStudents ?? [])")
                
                DispatchQueue.main.async {
                    self?.studentsTableView.reloadData()
                }
                
            } catch {
                print("❌ Error decoding the response: \(error)")
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listOfStaffVCTableViewCell", for: indexPath) as? listOfStaffVCTableViewCell else {
            return UITableViewCell()
        }
        
        let student = feedbackStudents[indexPath.row]
        cell.nameLabel.text = student.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = feedbackStudents[indexPath.row]
        
        if let questionsVC = storyboard?.instantiateViewController(withIdentifier: "QuestionsViewController") as? QuestionsViewController {
            
            questionsVC.userId = selectedStudent.userId
            questionsVC.studentName = selectedStudent.name
            questionsVC.isSubmitted = selectedStudent.isSubmitted
            questionsVC.feedbackId = feedbackId ?? ""
            questionsVC.groupId = groupId
            questionsVC.token = token
            questionsVC.role = self.currentRole
            questionsVC.feedbackData = feedbackData
            questionsVC.feedbackQuestions = feedbackQuestions
            questionsVC.teamId = teamId
            questionsVC.userId = userId
            questionsVC.staffId = selectedStudent.userId

            print("🟢 Navigating to QuestionsViewController with userId: \(selectedStudent.userId), studentName: \(selectedStudent.name), isSubmitted: \(selectedStudent.isSubmitted)")
            
            navigationController?.pushViewController(questionsVC, animated: true)
        }
    }
}
