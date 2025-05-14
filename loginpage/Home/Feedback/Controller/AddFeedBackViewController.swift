import UIKit

class AddFeedBackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var OptionsView: UIView!
    @IBOutlet weak var OptionsButton: UIButton!
    @IBOutlet weak var EndDate: UITextField!
    @IBOutlet weak var StartDate: UITextField!
    @IBOutlet weak var NoOfOptons: UITextField!
    @IBOutlet weak var NoOfQuestins: UITextField!
    @IBOutlet weak var enterTitle: UITextField!
    
    var questions: [String] = []
    var groupId: String?
    var token: String?
    var feedbackData: [FeedBackItem] = []
    var feedbackOptions: [FeedbackOption] = []
     
    var optionNo: String?
   var option: String?
   var Marks: String?
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OptionsView.isHidden = true
        
        OptionsButton.layer.cornerRadius = 8
        SaveButton.layer.cornerRadius = 8
        OptionsButton.clipsToBounds = true
        SaveButton.clipsToBounds = true
        
        if let text = NoOfOptons.text, let count = Int(text) {
            for i in 1...count {
                let newOption = FeedbackOption(optionNo: "\(i)", option: "", marks: "", answer: false)
                feedbackOptions.append(newOption)
            }
            TableView.reloadData()
        } else {
            print("Invalid number of options entered")
        }

        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "AddFeedBackTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFeedBackCell")
        
        print("Received Group ID Add Feedback: \(groupId ?? "No Group ID")")
        print("Received Token Add Feedback: \(token ?? "No Token")")
        print("Feedback Data: \(feedbackData)")

        setupDatePickers()
        setupTextFields()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addShadow(to: OptionsButton)
        addShadow(to: SaveButton)
    }
    
    func setupDatePickers() {
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .wheels
        startDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePickingDate))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: true)
        
        StartDate.inputView = startDatePicker
        StartDate.inputAccessoryView = toolbar
        EndDate.inputView = endDatePicker
        EndDate.inputAccessoryView = toolbar
    }
    
    func setupTextFields() {
        NoOfQuestins.delegate = self
        NoOfOptons.delegate = self
        NoOfQuestins.keyboardType = .numberPad
        NoOfOptons.keyboardType = .numberPad
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Restrict only NoOfQuestins and NoOfOptons to numbers
        if textField == NoOfQuestins || textField == NoOfOptons {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }

        // Allow text for other fields like Question and Marks
        return true
    }

    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if StartDate.isFirstResponder {
            StartDate.text = dateFormatter.string(from: sender.date)
        } else if EndDate.isFirstResponder {
            EndDate.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @objc func donePickingDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if StartDate.isFirstResponder {
            StartDate.text = dateFormatter.string(from: startDatePicker.date)
        } else if EndDate.isFirstResponder {
            EndDate.text = dateFormatter.string(from: endDatePicker.date)
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        if areAllFieldsFilled() {
                updateQuestionsArray()
                OptionsView.isHidden.toggle()
                OptionsButton.isHidden = true
                
                // Update the feedbackOptions array
                if let count = Int(NoOfOptons.text ?? "0"), count > 0 {
                    feedbackOptions = (1...count).map { FeedbackOption(optionNo: "\($0)", option: "", marks: "", answer: false) }
                } else {
                    feedbackOptions.removeAll()
                }
                
                TableView.reloadData()
            } else {
                showAlert(message: "Please fill in all the fields before proceeding.")
            }
    }
    
    func updateQuestionsArray() {
        if let numberOfQuestions = Int(NoOfQuestins.text ?? "0"), numberOfQuestions > 0 {
            questions = (1...numberOfQuestions).map { "Question \($0)" }
        } else {
            questions.removeAll()
        }
        TableView.reloadData()
    }

    func areAllFieldsFilled() -> Bool {
        let textFields = [enterTitle, NoOfQuestins, NoOfOptons, StartDate, EndDate]
        return textFields.allSatisfy { $0?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Incomplete Data", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowRadius = 3
        button.layer.masksToBounds = false
    }
    
    func updateOptionsArray() {
        if let count = Int(NoOfOptons.text ?? "0"), count > 0 {
            feedbackOptions = (0..<count).map {
                FeedbackOption(optionNo: "\($0 + 1)", option: "", marks: "", answer: false)
            }
        } else {
            feedbackOptions.removeAll()
        }
        TableView.reloadData()
    }

}

extension AddFeedBackViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackOptions.count // Use the count of feedbackOptions instead of NoOfOptons.text
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedBackCell", for: indexPath) as! AddFeedBackTableViewCell
//        cell.QuestionNo.text = "\(indexPath.row + 1)"
//        self.option = cell.Question.text
//        self.optionNo = cell.QuestionNo.text
//        self.Marks = cell.Marks.text
//
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedBackCell", for: indexPath) as! AddFeedBackTableViewCell
       
//        cell.QuestionNo.text = "\(indexPath.row + 1)"
//        self.option = cell.Question.text
        
        let option = feedbackOptions[indexPath.row]
        
        cell.Question.delegate = self
        cell.Marks.delegate = self

        cell.Question.tag = indexPath.row
        cell.Marks.tag = indexPath.row

        cell.QuestionNo.text = option.optionNo
        cell.Question.text = option.option
        cell.Marks.text = option.marks

        // Tag text fields to know which row they belong to
        cell.Question.tag = indexPath.row
        cell.Marks.tag = indexPath.row

        cell.Question.delegate = self
        cell.Marks.delegate = self

        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        guard index < feedbackOptions.count else { return }

        if let cell = TableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AddFeedBackTableViewCell {
            let updatedOption = FeedbackOption(
                optionNo: "\(index + 1)",
                option: cell.Question.text ?? "",
                marks: cell.Marks.text ?? "",
                answer: false // Or keep a toggle/checkbox for answer if needed
            )
            feedbackOptions[index] = updatedOption
        }
    }

    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let groupId = groupId, !groupId.isEmpty else {
            print("Missing groupId")
            return
        }
        guard let title = enterTitle.text, !title.isEmpty else {
            print("Missing title")
            return
        }
        guard let startDate = StartDate.text, !startDate.isEmpty else {
            print("Missing startDate")
            return
        }
        guard let endDate = EndDate.text, !endDate.isEmpty else {
            print("Missing endDate")
            return
        }
        guard let noOfQuestions = NoOfQuestins.text, !noOfQuestions.isEmpty else {
            print("Missing number of questions")
            return
        }
        guard let noOfOptions = NoOfOptons.text, !noOfOptions.isEmpty else {
            print("Missing number of options")
            return
        }

        var questionsArray: [QuestionData] = []
        for i in 0..<questions.count {
            if let cell = TableView.cellForRow(at: IndexPath(row: i, section: 0)) as? AddFeedBackTableViewCell,
               let questionText = cell.Question.text, let marksText = cell.Marks.text {
                let marksInt = Int(marksText) ?? 0  // Convert marksText to Int?
                let question = QuestionData(question: questionText, marks: marksInt, options: feedbackOptions)  // Pass feedbackOptions here
                questionsArray.append(question)
            }
        }

        // Ensure all options are captured in feedbackOptions
        var options: [FeedbackOption] = []
        for i in 0..<feedbackOptions.count {
            let option = feedbackOptions[i]
            options.append(FeedbackOption(optionNo: option.optionNo,
                                          option: option.option,
                                          marks: option.marks,
                                          answer: option.answer))
        }

        // Send the API request with the proper data
        let feedbackData = FeedBackRequest(
            groupId: groupId,
            isActive: true,
            lastDate: endDate,
            noOfOptions: noOfOptions,
            noOfQuestions: noOfQuestions,
            options: options,
            questionsArray: questionsArray,
            startDate: startDate,
            title: title,
            updatedAt: ""
        )

        guard let jsonData = try? JSONEncoder().encode(feedbackData) else {
            print("Failed to encode JSON")
            return
        }

        let url = URL(string:  APIManager.shared.baseURL + "groups/\(groupId)/feedback/title/create")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                print("Feedback successfully saved!")
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true) // Go back to previous screen
                }
            } else {
                print("Failed to save feedback. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }

            // Print API response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response from API: \(responseString)")
            }
        }

        task.resume()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }


}
