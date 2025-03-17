import UIKit

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    var token: String?
    var groupId: String?
    var savedFeedback: [(question: String, options: [FeedbackOption])] = []
    var allFeedbackItems: [FeedBackItem] = []
    var feedbackItem: FeedBackItem?
    var feedbackId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        bindTitle()
        setupButtons()
        printDebugInfo()
        
        submitButton.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
    }

    func bindTitle() {
        titleName.text = feedbackItem?.title ?? "No Title Available"
    }

    func setupButtons() {
        let buttons = [editButton, submitButton]
        for button in buttons {
            button?.layer.cornerRadius = 10
            button?.clipsToBounds = true
        }
    }

    func printDebugInfo() {
        print("Token: \(token ?? "No Token")")
        print("Group ID: \(groupId ?? "No Group ID")")
        printSavedFeedback()
    }

    func printSavedFeedback() {
        print("Received Saved Feedback:")
        for (index, feedback) in savedFeedback.enumerated() {
            print("Question \(index + 1): \(feedback.question)")
            print("Options:")
            for option in feedback.options {
                print("- \(option.option)")
            }
        }
    }

    // MARK: - Submit Feedback API Call
    // MARK: - Submit Feedback API Call
    // MARK: - Submit Feedback API Call
    @objc func submitFeedback() {
        guard let groupId = groupId, let feedbackId = feedbackId else {
            print("Missing groupId or feedbackId")
            return
        }

        let apiURL = APIManager.shared.baseURL + "groups/\(groupId)/feedback/\(feedbackId)/questions/add"
        
        // Prepare the request body
        var questionsArray: [[String: Any]] = []

        for (index, feedback) in savedFeedback.enumerated() {
            var optionsArray: [[String: Any]] = []
            
            for (optionIndex, option) in feedback.options.enumerated() {
                let optionData: [String: Any] = [
                    "optionNo": "\(optionIndex + 1)",
                    "option": option.option,
                    "marks": option.marks ?? "0",  // Assuming marks may be optional
                    "answer": option.answer ?? false
                ]
                optionsArray.append(optionData)
            }

            let questionData: [String: Any] = [
                "questionNo": index + 1,
                "question": feedback.question,
                "options": optionsArray
            ]
            
            questionsArray.append(questionData)
        }

        let requestBody: [String: Any] = ["questionsArray": questionsArray]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            var request = URLRequest(url: URL(string: apiURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error submitting feedback:", error.localizedDescription)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        print("Successfully saved feedback to the API!")
                        
                        // Show alert on main thread
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Saved", message: "Your feedback has been successfully saved.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        print("Failed to save feedback. Status Code: \(response.statusCode)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from API:", responseString)
                }
            }
            task.resume()
            
        } catch {
            print("Failed to encode JSON:", error.localizedDescription)
        }
    }
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedFeedback.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedFeedback[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell", for: indexPath) as! QuestionsTableViewCell
        
        let option = savedFeedback[indexPath.section].options[indexPath.row]
        cell.options.text = "\(indexPath.row + 1). \(option.option)" // Adding numbering
        
        return cell
    }

    // MARK: - Custom Section Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 16, y: 5, width: tableView.frame.width - 32, height: 35)
        label.text = "\(section + 1). \(savedFeedback[section].question)"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Increased font size & weight
        label.textColor = .black

        headerView.addSubview(label)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Slightly increased height for better spacing
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @objc func editButtonTapped() {
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
    }

}
