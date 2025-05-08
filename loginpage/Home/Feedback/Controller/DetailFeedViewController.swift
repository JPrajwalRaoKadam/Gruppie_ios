import UIKit

class DetailFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var Question: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var titleName: UILabel!
    
    var groupId: String?
    var token: String?
    var feedbackItem: FeedBackItem?
    var totalNoOfQustions: String?
    var classDataList: [FeedClassItem] = [] // Updated type
    var feedbackId: String?
    var role: String? // <-- Add this line

    private let feedbackQuestionLabel: UILabel = {
           let label = UILabel()
           label.text = "FeedBackQuestion"
           label.textColor = .blue
           label.textAlignment = .center
           label.font = UIFont.boldSystemFont(ofSize: 16)
           label.isHidden = true // Initially hidden
           label.isUserInteractionEnabled = true
           return label
       }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        
        // Register the DetailFeedTableViewCell
        TableView.register(UINib(nibName: "DetailFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailFeedCell")
        
        titleName.text = feedbackItem?.title
        
        if let feedbackItem = feedbackItem {
            print("📝 Feedback Item: \(feedbackItem)")
        } else {
            print("❌ Feedback Item is nil")
        }

        
        // Fetch data when the view loads
        fetchClassData()
        
        setupFeedbackQuestionLabel()

    }
    
    
    func setupFeedbackQuestionLabel() {
        view.addSubview(feedbackQuestionLabel)
        feedbackQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackQuestionLabel.topAnchor.constraint(equalTo: Question.bottomAnchor, constant: 10),
            feedbackQuestionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackQuestionLabel.widthAnchor.constraint(equalToConstant: 200),
            feedbackQuestionLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Add tap gesture to navigate to QuestionsViewController
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToQuestions))
        feedbackQuestionLabel.addGestureRecognizer(tapGesture)
    }

    // MARK: - Show "FeedBackQuestion" on Button Tap
    @IBAction func showFeedbackQuestion(_ sender: UIButton) {
        feedbackQuestionLabel.isHidden = false
    }

    // MARK: - Navigate to QuestionsViewController
    @objc func navigateToQuestions() {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let questionsVC = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController") as? QuestionsViewController {
            questionsVC.token = token
            questionsVC.groupId = groupId
            questionsVC.feedbackItem = feedbackItem
            questionsVC.totalQuestions = totalNoOfQustions
            questionsVC.feedbackId = feedbackId // Pass feedbackId
            questionsVC.role = role
            navigationController?.pushViewController(questionsVC, animated: true)
        }
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailFeedCell", for: indexPath) as? DetailFeedTableViewCell else {
            return UITableViewCell()
        }
        
        let classData = classDataList[indexPath.row]
        cell.configure(with: classData)
        
        return cell
    }
    
    // MARK: - API Call
    func fetchClassData() {
        print("🛠️ groupId:", groupId ?? "nil")
        print("🔑 Token:", token ?? "nil")

        guard let groupId = groupId, !groupId.isEmpty,
              let token = token, !token.isEmpty,
              let url = URL(string: "https://api.gruppie.in/api/v1/groups/\(groupId)/class/get") else {
            print("❌ Invalid URL or missing groupId/token")
            return
        }

        print("🌍 API URL:", url.absoluteString)
        print("🔑 Authorization Header: Bearer \(token)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response format")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📌 Raw API Response: \(jsonString)")
            }

            if httpResponse.statusCode != 200 {
                print("❌ Server returned status code \(httpResponse.statusCode)")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(FeedClass.self, from: data)
                self.classDataList = decodedResponse.data // Correctly mapping response
                
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
            } catch {
                print("❌ Decoding Error: \(error)")
            }
        }

        task.resume()
    }
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }


}
