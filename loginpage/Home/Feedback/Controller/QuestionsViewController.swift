import UIKit

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var QuestionNo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var token: String?
    var groupId: String?
    var allFeedbackItems: [FeedBackItem] = []
    var currentQuestionIndex = 0
    var totalQuestions: String?
    var savedFeedback: [(question: String, options: [FeedbackOption])] = []
    var selectedOptions: [Int: Int] = [:]
    var tQuest = 0
    var userId: String?
    var studentName: String?
    var isSubmitted: Bool?
    var feedbackId: String?
    var feedbackData: FeedBackItem?
    var role: String?
    var feedbackQuestions: [[QuestionData]] = []
    var teamId: String = ""
    var staffId: String = ""

    var feedbackItem: FeedBackItem? {
        didSet {
            DispatchQueue.main.async {
                self.updateUIForCurrentQuestion()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
        
        print("userId: \(userId ?? "No userId")")
        print("teamId: \(teamId ?? "No teamId")")
        print("staffId: \(staffId ?? "No staffId")")
        print("groupId: \(groupId ?? "No groupId")")
        print("feedbackId: \(feedbackId ?? "No feedbackId")")
        print("role: \(role ?? "No role")")

        print("studentName: \(studentName ?? "No studentName")")
        print("isSubmitted: \(isSubmitted ?? false)")
        print("feedbackData: \(feedbackData)")
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
        
        setupUI()
        printDebugInfo()
        
        guard let role = role else { return }

           if role == "admin" {
               tQuest = allFeedbackItems.count
               if !allFeedbackItems.isEmpty {
                   feedbackItem = allFeedbackItems[currentQuestionIndex]
               }
           } else if role == "parent" || role == "teacher" {
               setupParentFeedback()
               tQuest = feedbackData?.questionsArray?.count ?? 0
               updateUIForCurrentQuestion()
           }
           
        
        tQuest = allFeedbackItems.count
        
        if !allFeedbackItems.isEmpty {
            feedbackItem = allFeedbackItems[currentQuestionIndex]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    func setupParentFeedback() {
        guard let feedbackData = feedbackData else {
            print("No feedback data for parent")
            return
        }

        titleName.text = feedbackData.title ?? "No Title"
        QuestionNo.text = "Feedback Summary"
        nextButton.isHidden = false
        backward.isHidden = false
        forward.isHidden = false
        textView.isEditable = false
        
        if let question = feedbackData.questionsArray?.first?.question {
            textView.text = question
            print("Binding textView with question: \(question)")
            
        } else {
            textView.text = "No question available"
            print("No question found, setting default: No question available")
        }
        
        feedbackItem = feedbackData
        tableView.reloadData()
    }
    
    func updateUIForCurrentQuestion() {
        guard let questions = feedbackData?.questionsArray, currentQuestionIndex < questions.count else {
            textView.text = "No more questions"
            return
        }

        let currentQuestion = questions[currentQuestionIndex]
        textView.text = currentQuestion.question ?? "Enter Question"
        
        titleName.text = feedbackData?.title ?? "No Title"
        QuestionNo.text = "Question \(currentQuestionIndex + 1) of \(questions.count)"
        nextButton.setTitle(currentQuestionIndex + 1 == questions.count ? "Finish" : "Next", for: .normal)
        
        tableView.reloadData()
    }


    func setupUI() {
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.masksToBounds = true
        textView.isEditable = true
        textView.isScrollEnabled = false
        
        mainView.layer.cornerRadius = 12
        mainView.layer.masksToBounds = true
        
        nextButton.layer.cornerRadius = 10
        nextButton.layer.masksToBounds = true
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let updatedQuestion = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !updatedQuestion.isEmpty {
            if currentQuestionIndex < savedFeedback.count {
                savedFeedback[currentQuestionIndex].question = updatedQuestion
            } else {
                if let currentOptions = feedbackItem?.options {
                    savedFeedback.append((question: updatedQuestion, options: currentOptions))
                }
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let currentFeedback = feedbackItem else { return }
        
        let questionText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !questionText.isEmpty {
            if currentQuestionIndex < savedFeedback.count {
                savedFeedback[currentQuestionIndex].question = questionText
            } else {
                let currentOptions = feedbackItem?.options ?? []
                savedFeedback.append((question: questionText, options: currentOptions))
            }
        }
        
        if let totalQuestions = Int(currentFeedback.noOfQuestions ?? ""), savedFeedback.count >= totalQuestions {
            navigateToSummary()
            return
        }
        
        currentQuestionIndex += 1
        textView.text = ""
        
        updateUIForCurrentQuestion()
    }
    
    func navigateToSummary() {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController {
            summaryVC.savedFeedback = savedFeedback
            summaryVC.token = token
            summaryVC.groupId = groupId
            summaryVC.allFeedbackItems = allFeedbackItems
            summaryVC.feedbackItem = feedbackItem
            summaryVC.feedbackId = feedbackId
            summaryVC.staffId = staffId
            summaryVC.teamId = teamId
            summaryVC.userId = userId
            summaryVC.role = role
            summaryVC.selectedOptions = self.selectedOptions


            navigationController?.pushViewController(summaryVC, animated: true)
        }
    }
    
    func printDebugInfo() {
        print("Token: \(token ?? "No Token")")
        print("Group ID: \(groupId ?? "No Group ID")")
        print("Total Questions (tQuest): \(tQuest)")
        print("Current Question Index: \(currentQuestionIndex)")

        print("All Feedback Items:")
        for (index, item) in allFeedbackItems.enumerated() {
            print("Item \(index + 1):")
            print(" - Title: \(item.title ?? "No Title")")
            print(" - Question: \(item.question ?? "No Question")")
            print(" - No of Questions: \(item.noOfQuestions ?? "N/A")")
            print(" - Options: \(item.options?.map { $0.option } ?? [])")
        }

        if let feedback = feedbackItem {
            do {
                let jsonData = try JSONEncoder().encode(feedback)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Feedback Item: \(jsonString)")
                }
            } catch {
                print("Error encoding feedbackItem: \(error)")
            }
        } else {
            print("Feedback Item: No Feedback Item")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackItem?.options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell", for: indexPath) as! QuestionsTableViewCell
        
        if let optionsList = feedbackItem?.options, indexPath.row < optionsList.count {
            let option = optionsList[indexPath.row]
            cell.options.text = option.option
            
            if let selectedIndex = selectedOptions[currentQuestionIndex], selectedIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let optionsList = feedbackItem?.options, indexPath.row < optionsList.count {
            let selectedOption = optionsList[indexPath.row]
            print("Selected Option: \(selectedOption.option)")
            
            selectedOptions[currentQuestionIndex] = indexPath.row
            
            tableView.reloadData()
        }
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            feedbackItem = allFeedbackItems[currentQuestionIndex]
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func BackwardButton(_ sender: UIButton) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            
            if currentQuestionIndex < allFeedbackItems.count {
                feedbackItem = allFeedbackItems[currentQuestionIndex]
            }
            
            if currentQuestionIndex < savedFeedback.count {
                textView.text = savedFeedback[currentQuestionIndex].question
            } else {
                textView.text = feedbackItem?.question ?? "Enter Question"
            }
            
            updateUIForCurrentQuestion()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func ForwardButton(_ sender: UIButton) {
        let questionText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !questionText.isEmpty {
            if currentQuestionIndex < savedFeedback.count {
                savedFeedback[currentQuestionIndex].question = questionText
            } else {
                let currentOptions = feedbackItem?.options ?? []
                savedFeedback.append((question: questionText, options: currentOptions))
            }
        }

        if currentQuestionIndex < savedFeedback.count - 1 {
            currentQuestionIndex += 1
            textView.text = savedFeedback[currentQuestionIndex].question
            updateUIForCurrentQuestion()
        }
    }
}
