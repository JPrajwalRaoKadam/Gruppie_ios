import UIKit

class QuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableVew: UITableView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var QuestionNo: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var forward: UIButton!
    
    var token: String?
    var groupId: String?
    var feedbackId: String?
    var allFeedbackItems: [FeedBackItem] = [] // List of all feedback items
    var currentQuestionIndex = 0
    var totalQuestions: String?
    var savedFeedback: [(question: String, options: [FeedbackOption])] = []
    var selectedOptions: [Int: Int] = [:] // Store selected option per question
    var tQuest = 0
    
    var feedbackItem: FeedBackItem? {
        didSet {
            DispatchQueue.main.async {
                self.updateUIForCurrentQuestion()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableVew.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
        tableVew.delegate = self
        tableVew.dataSource = self
        textView.delegate = self
        
        setupUI()
        printDebugInfo()
        
        // Ensure tQuest is correctly set to the number of feedback items
        tQuest = allFeedbackItems.count
        
        if !allFeedbackItems.isEmpty {
            feedbackItem = allFeedbackItems[currentQuestionIndex]
        }
    }
    
    // MARK: - UI Updates
    func updateUIForCurrentQuestion() {
        guard let feedbackItem = feedbackItem else { return }
        
        titleName.text = feedbackItem.title ?? "No Title"
        QuestionNo.text = "Question \(currentQuestionIndex + 1) of \(tQuest)"
        nextButton.setTitle(currentQuestionIndex + 1 == tQuest ? "Finish" : "Next", for: .normal)
        
        if currentQuestionIndex < savedFeedback.count {
            textView.text = savedFeedback[currentQuestionIndex].question
        } else {
            textView.text = feedbackItem.question ?? "Enter Question"
        }
        
        tableVew.reloadData()
    }
    
    // MARK: - UI Customization
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
    }
    
    // MARK: - UITextViewDelegate
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
    
    // MARK: - Next Button Action
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let currentFeedback = feedbackItem else { return }
        
        let questionText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !questionText.isEmpty {
            if currentQuestionIndex < savedFeedback.count {
                // Update the existing question
                savedFeedback[currentQuestionIndex].question = questionText
            } else {
                // Append new question and options
                let currentOptions = feedbackItem?.options ?? []
                savedFeedback.append((question: questionText, options: currentOptions))
            }
        }
        
        // Check if we reached the required number of questions
        if let totalQuestions = Int(currentFeedback.noOfQuestions ?? ""), savedFeedback.count >= totalQuestions {
            navigateToSummary()
            return
        }
        
        // Move to the next question and clear textView for new input
        currentQuestionIndex += 1
        textView.text = ""
        updateUIForCurrentQuestion()
    }
    
    // MARK: - Navigate to SummaryViewController
    func navigateToSummary() {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController {
            summaryVC.savedFeedback = savedFeedback
            summaryVC.token = token
            summaryVC.groupId = groupId
            summaryVC.allFeedbackItems = allFeedbackItems
            summaryVC.feedbackItem = feedbackItem
            summaryVC.feedbackId = feedbackId
            navigationController?.pushViewController(summaryVC, animated: true)
        }
    }
    
    // MARK: - Debug Info
    func printDebugInfo() {
        print("Token: \(token ?? "No Token")")
        print("Group ID: \(groupId ?? "No Group ID")")
        print("Total Questions (tQuest): \(tQuest)")
        print("Current Question Index: \(currentQuestionIndex)")
        
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
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackItem?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell", for: indexPath) as! QuestionsTableViewCell
        
        if let optionsList = feedbackItem?.options, indexPath.row < optionsList.count {
            let option = optionsList[indexPath.row]
            cell.options.text = option.option
            
            // Restore previous selection
            if let selectedIndex = selectedOptions[currentQuestionIndex], selectedIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let optionsList = feedbackItem?.options, indexPath.row < optionsList.count {
            let selectedOption = optionsList[indexPath.row]
            print("Selected Option: \(selectedOption.option)")
            
            // Save selected option for this question
            selectedOptions[currentQuestionIndex] = indexPath.row
            
            // Refresh table to update checkmarks
            tableView.reloadData()
        }
    }
    
    // MARK: - Back Button
    @IBAction func BackButton(_ sender: UIButton) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            feedbackItem = allFeedbackItems[currentQuestionIndex]
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Back Button Action
    @IBAction func BackwardButton(_ sender: UIButton) {
        if currentQuestionIndex > 0 {
            // Move backward to the previous question
            currentQuestionIndex -= 1
            
            // Ensure the index is valid before accessing the array
            if currentQuestionIndex < allFeedbackItems.count {
                feedbackItem = allFeedbackItems[currentQuestionIndex]
            }
            
            // Check if there's saved feedback for this question and load it into the textView
            if currentQuestionIndex < savedFeedback.count {
                textView.text = savedFeedback[currentQuestionIndex].question
            } else {
                textView.text = feedbackItem?.question ?? "Enter Question"
            }
            
            // Update the UI with the current question details
            updateUIForCurrentQuestion()
        } else {
            // No more previous questions, pop the view controller
            navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Forward Button Action
    @IBAction func ForwardButton(_ sender: UIButton) {
        let questionText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // ✅ Save the current question if it's not empty
        if !questionText.isEmpty {
            if currentQuestionIndex < savedFeedback.count {
                savedFeedback[currentQuestionIndex].question = questionText
            } else {
                let currentOptions = feedbackItem?.options ?? []
                savedFeedback.append((question: questionText, options: currentOptions))
            }
        }

        // ✅ Move only within the savedFeedback array
        if currentQuestionIndex < savedFeedback.count - 1 {
            currentQuestionIndex += 1
            textView.text = savedFeedback[currentQuestionIndex].question
            updateUIForCurrentQuestion()
        }
    }
}
