import UIKit

// MARK: - Feedback Models

// MARK: - FeedBackViewController
class FeedBackViewController: UIViewController {

    var groupId: String?
    var token: String?
    var feedbackData: [FeedBackItem] = [] // Store API response

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        print("Received Group ID: \(groupId ?? "No Group ID")")
        print("Received Token: \(token ?? "No Token")")

        tableView.register(UINib(nibName: "FeedBackTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedBackCell")

        fetchFeedbackData() // Fetch API data
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
        let selectedFeedback = feedbackData[indexPath.row] // Get selected feedback item
        
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil) // Ensure correct storyboard name
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailFeedViewController") as? DetailFeedViewController {
            
            // Pass data to DetailFeedViewController
            detailVC.groupId = groupId
            detailVC.token = token
            detailVC.feedbackItem = selectedFeedback
            let totalNoQues = feedbackData[indexPath.row].noOfQuestions
            detailVC.feedbackId = selectedFeedback.feedbackId // Pass feedbackId
            detailVC.totalNoOfQustions = totalNoQues
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}
