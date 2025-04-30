
import UIKit

class ChapterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChapterTableViewCellDelegate {
    
    @IBOutlet weak var sessions: UITextField!
    @IBOutlet weak var lecture: UITextField!
    @IBOutlet weak var seminar: UITextField!
    @IBOutlet weak var workshop: UITextField!
    @IBOutlet weak var ex: UITextField!
    @IBOutlet weak var grpDiscussion: UITextField!
    @IBOutlet weak var test: UITextField!
    
    @IBOutlet weak var Chaptertableview: UITableView!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var chapter: UILabel!
    @IBOutlet weak var topic: UILabel!
    
    @IBOutlet weak var dailogboxView: UIView!
    
    // Buttons to show and store the date
    @IBOutlet weak var pStartButton: UIButton!
    @IBOutlet weak var pEndButton: UIButton!
    @IBOutlet weak var aStartButton: UIButton!
    @IBOutlet weak var aEndButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var groupId: String = ""
    var teamId: String = ""
    var subjectId: String = ""
    var passedSubjectName: String = ""
    var chapters: [ChapterData] = []
    var currentButton: UIButton?
    var originalPlan: ChapterPlanResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailogboxView.isHidden = true
        Chaptertableview.delegate = self
        Chaptertableview.dataSource = self
        Chaptertableview.register(UINib(nibName: "ChapterTableViewCell", bundle: nil), forCellReuseIdentifier: "ChapterTableViewCell")
        
        subjectName.text = passedSubjectName
        fetchChapters()
        styleButtons()
     
    }
    private func styleButtons() {
        let buttons = [pStartButton, pEndButton, aStartButton, aEndButton]
        submitButton.layer.cornerRadius = 8
        submitButton.layer.masksToBounds = true
        
        for button in buttons {
            button?.layer.cornerRadius = 8      // Adjust the corner radius
            button?.layer.masksToBounds = true   // Ensure the corners are clipped
            button?.layer.borderWidth = 1        // Add a border (optional)
            button?.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    // MARK: - Button Actions for Date Picker
    @IBAction func pStart(_ sender: UIButton) {
        currentButton = sender
        showDatePickerPopup()
    }
    
    @IBAction func pEnd(_ sender: UIButton) {
        currentButton = sender
        showDatePickerPopup()
    }
    
    @IBAction func aStart(_ sender: UIButton) {
        currentButton = sender
        showDatePickerPopup()
    }
    
    @IBAction func aEnd(_ sender: UIButton) {
        currentButton = sender
        showDatePickerPopup()
    }
    
//    @IBAction func submitButton(_ sender: Any) {
//        dailogboxView.isHidden = true
//    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitButton(_ sender: Any) {
        guard let originalPlan = originalPlan else {
            print("No original data to compare")
            return
        }

        // Extract current UI data
        let updatedPlan = ChapterPlanResponse(
            planId: originalPlan.planId,
            activities: [
                Activity(duration: lecture.text ?? "0", type: "Lecture"),
                Activity(duration: seminar.text ?? "0", type: "Seminar"),
                Activity(duration: workshop.text ?? "0", type: "Workshop"),
                Activity(duration: ex.text ?? "0", type: "Examples"),
                Activity(duration: grpDiscussion.text ?? "0", type: "Group Discussion"),
                Activity(duration: test.text ?? "0", type: "Test")
            ],
            actualEndDate: aEndButton.title(for: .normal) ?? "",
            actualStartDate: aStartButton.title(for: .normal) ?? "",
            endDate: pEndButton.title(for: .normal) ?? "",
            startDate: pStartButton.title(for: .normal) ?? "",
            sessionAvailable: sessions.text ?? "",
            sessionPlaned: originalPlan.sessionPlaned
        )
        
        // Compare changes
        if originalPlan != updatedPlan {
            print("🔹 Changes detected. Sending update...")
            updateChapterPlanAPI(updatedPlan)
        } else {
            print("✅ No changes detected.")
        }
        
        dailogboxView.isHidden = true
    }

    func fetchChapters(){
            guard let token = TokenManager.shared.getToken() else {
                print("Token not found")
                return
            }
    
        let urlString = APIProdManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/syllabus/get"
            print("Fetching chapters from: \(urlString)")
    
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
    
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add token to header
    
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("API Error: \(error.localizedDescription)")
                    return
                }
    
                guard let data = data else {
                    print("No data received")
                    return
                }
    
                // Print raw API response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response: \(jsonString)")
                } else {
                    print("Unable to decode API response into a string")
                }
    
                // Decode using JSONSerialization
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataArray = json["data"] as? [[String: Any]] {
    
                        var chapterList: [ChapterData] = []
    
                        for chapter in dataArray {
                            if let chapterName = chapter["chapterName"] as? String,
                               let chapterId = chapter["chapterId"] as? String,
                               let topicsArray = chapter["topicsList"] as? [[String: Any]] {
    
                                var topicsList: [Topic] = []
    
                                for topic in topicsArray {
                                    if let topicName = topic["topicName"] as? String,
                                       let topicId = topic["topicId"] as? String {
                                        topicsList.append(Topic(topicName: topicName, topicId: topicId))
                                    }
                                }
    
                                let chapterData = ChapterData(chapterName: chapterName, chapterId: chapterId, topicsList: topicsList)
                                chapterList.append(chapterData)
                            }
                        }
    
                        DispatchQueue.main.async {
                            self.chapters = chapterList
                            self.Chaptertableview.reloadData()
                        }
                    } else {
                        print("Invalid JSON structure")
                    }
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    
    func callChapterPlanAPI(chapterId: String, completion: @escaping (ChapterPlanResponse) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIProdManager.shared.baseURL +  "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/plan?chapterId=\(chapterId)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let chapterPlan = try decoder.decode(ChapterPlanResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Store the original plan and update UI
                    self.updateUI(with: chapterPlan)
                    completion(chapterPlan)  // Pass the decoded data to completion
                }

            } catch {
                print("Decoding Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    func updateChapterPlanAPI(_ plan: ChapterPlanResponse) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIProdManager.shared.baseURL +  "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/plan?planId=\(plan.planId)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(plan)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ API Response: \(jsonString)")
            }
        }
        task.resume()
    }



    func updateUI(with plan: ChapterPlanResponse) {
        // Set the date values on the buttons
        pStartButton.setTitle(plan.startDate, for: .normal)
        pEndButton.setTitle(plan.endDate, for: .normal)
        aStartButton.setTitle(plan.actualStartDate, for: .normal)
        aEndButton.setTitle(plan.actualEndDate, for: .normal)

        // Set session values
        sessions.text = plan.sessionAvailable
        
        // Set the duration values in the corresponding text fields
        for activity in plan.activities {
            switch activity.type {
            case "Lecture":
                lecture.text = activity.duration
            case "Seminar":
                seminar.text = activity.duration
            case "Workshop":
                workshop.text = activity.duration
            case "Examples":
                ex.text = activity.duration
            case "Group Discussion":
                grpDiscussion.text = activity.duration
            case "Test":
                test.text = activity.duration
            default:
                print("Unknown activity type: \(activity.type)")
            }
        }
    }


    
    // MARK: - Date Picker Popup
    func showDatePickerPopup() {
        // Create background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.tag = 999  // Tag to identify the view for removal

        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Create container view
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Create UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Done and Cancel buttons
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)

        // Add to main window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }

        // Set constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 350),
            
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }
    
//    @objc func datePickerDonePressed(_ sender: UIButton)
    @objc func datePickerDonePressed(_ sender: UIButton) {
        // Find the background view containing the popup
        if let window = UIApplication.shared.windows.first,
           let backgroundView = window.viewWithTag(999) {

            // Find the date picker inside the container view
            if let datePicker = backgroundView.subviews.first?.subviews.first(where: { $0 is UIDatePicker }) as? UIDatePicker,
               let button = currentButton {

                // Format the selected date
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let selectedDate = formatter.string(from: datePicker.date)

                // ✅ Set the button title and apply font size 12
                button.setTitle(selectedDate, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 5)  // Set text size to 12
            }

            // Remove the popup
            backgroundView.removeFromSuperview()
        }
    }


    @objc func datePickerCancelPressed(_ sender: UIButton) {
        // Remove the popup on cancel
        if let window = UIApplication.shared.windows.first,
           let backgroundView = window.viewWithTag(999) {
            backgroundView.removeFromSuperview()
        }
    }

    // MARK: - TableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterTableViewCell", for: indexPath) as? ChapterTableViewCell else {
            return UITableViewCell()
        }
        
        let chapter = chapters[indexPath.row]
        cell.configure(with: chapter, groupId: groupId, teamId: teamId, subjectId: subjectId)
        cell.delegate = self
        return cell
    }
    
    func didDeleteChapter(chapterId: String) {
        if let index = chapters.firstIndex(where: { $0.chapterId == chapterId }) {
            chapters.remove(at: index)
            Chaptertableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChapter = chapters[indexPath.row]
        let chapterId = selectedChapter.chapterId
        
        callChapterPlanAPI(chapterId: chapterId) { [weak self] plan in
            guard let self = self else { return }
            
            // Store the original data for comparison
            self.originalPlan = plan
            
            // Display dialog box with selected chapter and topic
            DispatchQueue.main.async {
                self.dailogboxView.isHidden = false
                self.chapter.text = "Chapter - \(selectedChapter.chapterName)"
                
                if !selectedChapter.topicsList.isEmpty {
                    let topics = selectedChapter.topicsList[0]
                    self.topic.text = "Topic Name - \(topics.topicName)"
                } else {
                    self.topic.text = "No topics available"
                }
            }
        }
    }


}

extension ChapterPlanResponse: Equatable {
    static func == (lhs: ChapterPlanResponse, rhs: ChapterPlanResponse) -> Bool {
        return lhs.planId == rhs.planId &&
               lhs.activities == rhs.activities &&
               lhs.actualEndDate == rhs.actualEndDate &&
               lhs.actualStartDate == rhs.actualStartDate &&
               lhs.endDate == rhs.endDate &&
               lhs.startDate == rhs.startDate &&
               lhs.sessionAvailable == rhs.sessionAvailable &&
               lhs.sessionPlaned == rhs.sessionPlaned
    }
}

extension Activity: Equatable {
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.duration == rhs.duration && lhs.type == rhs.type
    }
}
