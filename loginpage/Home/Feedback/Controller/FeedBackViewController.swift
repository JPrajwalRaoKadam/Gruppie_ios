import UIKit

// MARK: - Feedback Models

// MARK: - FeedBackViewController
class FeedBackViewController: UIViewController {

    var groupId: String?
    var token: String?
    var feedbackData: [FeedBackItem] = [] // Store API response
    var currentRole: String?
    var feedbackId: String?
    var userId: String = ""
    var teamId: String = ""
    var feedbackQuestions: [[QuestionData]] = []

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        print("Received Group ID: \(groupId ?? "No Group ID")")
        print("Received Token: \(token ?? "No Token")")

        tableView.register(UINib(nibName: "FeedBackTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedBackCell")
        fetchFeedbackData()
        print("-------- FeedBackViewController Initialized --------")
        print("Group ID: \(groupId ?? "nil")")
        print("Token: \(token ?? "nil")")
        print("Current Role: \(currentRole ?? "nil")")
        print("User ID: \(userId)")
        print("Team ID: \(teamId)")
        print("feedback ID: \(self.feedbackId)")
        print("----------------------------------------------------")

// Fetch API data
    }

    // MARK: - API Call
    func fetchFeedbackData() {
        guard let groupId = groupId else {
            print("Group ID is missing")
            return
        }
        
        let urlString = "https://api.gruppie.in/api/v1/groups/\(groupId)/feedback/title/get"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching feedback:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received from API")
                return
            }

            // Print raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API Response JSON: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let feedbackResponse = try decoder.decode(FeedBackResponse.self, from: data)

                // Print structured response
                print("Decoded API Response:", feedbackResponse)
                
                // Store API response in feedbackData
                self.feedbackData = feedbackResponse.data
                print("Stored feedbackData:", self.feedbackData)

                
                // Extract questionArray from each feedback item and store in feedbackQuestions
                self.feedbackQuestions = feedbackResponse.data.map { $0.questionsArray ?? [] }
                print("Extracted feedbackQuestions:", self.feedbackQuestions)

                DispatchQueue.main.async {
                    self.tableView.reloadData() // Refresh table view
                }
            } catch {
                print("Error decoding JSON:", error.localizedDescription)
            }
        }
        task.resume()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FeedBackViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackData.count // Use actual data count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedBackCell", for: indexPath) as! FeedBackTableViewCell
        let feedback = feedbackData[indexPath.row]
        
        cell.name.text = feedback.title ?? "No Title"

        if let options = feedback.options {
            print("Options for '\(feedback.title ?? "No Title")':")
            for option in options {
                print(" - \(option.option) (Marks: \(option.marks))")
            }
        } else {
            print("No options available for '\(feedback.title ?? "No Title")'.")
        }
        
        return cell
    }
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "FeedBack", bundle: nil) // Change "Main" if using a different storyboard
            if let addFeedbackVC = storyboard.instantiateViewController(withIdentifier: "AddFeedBackViewController") as? AddFeedBackViewController {
                addFeedbackVC.groupId = groupId
                addFeedbackVC.token = token
                addFeedbackVC.feedbackData = feedbackData // Passing feedback data

                navigationController?.pushViewController(addFeedbackVC, animated: true)
            }
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFeedback = self.feedbackData[indexPath.row]
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)

        // Assign feedbackId from selectedFeedback (optional)
        self.feedbackId = selectedFeedback.feedbackId

        switch currentRole?.lowercased() {
        case "parent":
            if let vc = storyboard.instantiateViewController(withIdentifier: "listOfStaffVC") as? listOfStaffVC {
                vc.groupId = groupId ?? ""
                vc.token = token ?? ""
                vc.feedbackId = selectedFeedback.feedbackId ?? ""
                vc.feedbackData = selectedFeedback
                vc.teamId = teamId
                vc.userId = userId
                vc.currentRole = currentRole
                vc.feedbackQuestions = feedbackQuestions
                print("Navigating to listOfStaffVC with:")
                print("feedbackData\(feedbackData)")
                print(" - Group ID: \(vc.groupId)")
                print(" - Token: \(vc.token)")
                print(" - Feedback ID: \(vc.feedbackId)")
                print(" - Team ID: \(vc.teamId)")
                print(" - User ID: \(vc.userId)")
                print(" - Current Role: \(vc.currentRole)")

                navigationController?.pushViewController(vc, animated: true)
            }

        case "admin":
            if let vc = storyboard.instantiateViewController(withIdentifier: "DetailFeedViewController") as? DetailFeedViewController {
                vc.groupId = groupId
                vc.token = token
                vc.feedbackItem = selectedFeedback
                vc.feedbackId = selectedFeedback.feedbackId
                vc.totalNoOfQustions = selectedFeedback.noOfQuestions
                vc.role = currentRole

                print("feedbackId passed to DetailFeedViewController: \(selectedFeedback.feedbackId ?? "nil")")

                navigationController?.pushViewController(vc, animated: true)
            }

        default:
            print("Unhandled role: \(currentRole ?? "nil")")
    
         }
    }


}
     
