import UIKit

class listOfStaffVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamIds: [String] = [] // Array to hold team IDs
    var currentRole: String?
    var subjects: [SubjectData] = []
    var feedbackData: FeedBackItem?
    var feedbackId: String?
    var userId: String = ""
    var teamId: String = ""
    var feedbackQuestions: [[QuestionData]] = []

    // Variable to store the decoded API response
    var feedbackStudents: [FeedbackStudent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        
        studentsTableView.register(UINib(nibName: "listOfStaffVCTableViewCell", bundle: nil), forCellReuseIdentifier: "listOfStaffVCTableViewCell")
        
        // ✅ Print debug information
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
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        studentsTableView.reloadData() // Reload data when the view appears
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - API Call to Fetch Feedback Students Data
    
    func fetchFeedbackStudentData() {
        // API URL
        let urlString =  APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/class/staffs/get?feedbackId=\(feedbackId ?? "")&userId=\(userId)"
        
        print("🌐 Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Set token if required
        
        // Start the API call
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Print HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            // Handle errors
            if let error = error {
                print("❌ API call failed with error: \(error)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // Print the raw response
            print("🟢 staff Raw API Response: \(String(data: data, encoding: .utf8) ?? "No response body")")
            
            // Decode the data into FeedbackStudentResponse model
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(FeedbackStudentResponse.self, from: data)
                
                // Store the decoded data in the variable
                self?.feedbackStudents = decodedResponse.data
                
                if let firstStaff = decodedResponse.data.first {
                    let staffId = firstStaff.userId
                    print("🆔 staffId: \(staffId)")
                }
                
                // Print the decoded data
                print("🟢 Decoded Data: \(self?.feedbackStudents ?? [])")
                
                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self?.studentsTableView.reloadData()
                }
                
            } catch {
                print("❌ Error decoding the response: \(error)")
            }
        }.resume()
    }

    // MARK: - UITableViewDataSource Methods
    
    // Number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackStudents.count // Display the number of feedback students
    }
    
    // Configure the cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listOfStaffVCTableViewCell", for: indexPath) as? listOfStaffVCTableViewCell else {
            return UITableViewCell()
        }
        
        // Configure cell with the decoded data
        let student = feedbackStudents[indexPath.row]
        cell.nameLabel.text = student.name
        // Optionally configure other properties based on your model

        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected student
        let selectedStudent = feedbackStudents[indexPath.row]
        
        // Instantiate the QuestionsViewController from the storyboard
        if let questionsVC = storyboard?.instantiateViewController(withIdentifier: "QuestionsViewController") as? QuestionsViewController {
            
            // Pass the necessary data to QuestionsViewController
            questionsVC.userId = selectedStudent.userId
            questionsVC.studentName = selectedStudent.name
            questionsVC.isSubmitted = selectedStudent.isSubmitted
            questionsVC.feedbackId = feedbackId ?? ""
            questionsVC.groupId = groupId
            questionsVC.token = token
            questionsVC.role = self.currentRole
            questionsVC.feedbackData = feedbackData  // 👈 Pass the feedbackData here
            questionsVC.feedbackQuestions = feedbackQuestions
            questionsVC.teamId = teamId
            questionsVC.userId = userId
            questionsVC.staffId = selectedStudent.userId

            // Optionally print debug info
            print("🟢 Navigating to QuestionsViewController with userId: \(selectedStudent.userId), studentName: \(selectedStudent.name), isSubmitted: \(selectedStudent.isSubmitted)")
            
            // Perform the navigation
            navigationController?.pushViewController(questionsVC, animated: true)
        }
    }
}
