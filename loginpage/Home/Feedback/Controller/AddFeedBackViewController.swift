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
    
    var questions: [String] = [] // Stores questions based on input
    var groupId: String?
    var token: String?
    var feedbackData: [FeedBackItem] = []
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide OptionsView initially
        OptionsView.isHidden = true
        
        // Apply rounded corners
        OptionsButton.layer.cornerRadius = 8
        SaveButton.layer.cornerRadius = 8
        OptionsButton.clipsToBounds = true
        SaveButton.clipsToBounds = true

        // Register TableView Cell
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
        
        // Apply shadow effect
        addShadow(to: OptionsButton)
        addShadow(to: SaveButton)
    }
    
    // MARK: - Setup Date Pickers
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
    
    // MARK: - Setup TextFields (Restrict Input to Numbers)
    func setupTextFields() {
        NoOfQuestins.delegate = self
        NoOfOptons.delegate = self
        NoOfQuestins.keyboardType = .numberPad
        NoOfOptons.keyboardType = .numberPad
    }
    
    // MARK: - UITextFieldDelegate (Restrict Input to Numbers Only)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    // MARK: - Handle Date Selection
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if StartDate.isFirstResponder {
            StartDate.text = dateFormatter.string(from: sender.date)
        } else if EndDate.isFirstResponder {
            EndDate.text = dateFormatter.string(from: sender.date)
        }
    }
    
    // MARK: - Done Button Action for Date Picker
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
    
    // MARK: - Show/Hide Options View
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        if areAllFieldsFilled() {
            updateQuestionsArray()
            OptionsView.isHidden.toggle()
            OptionsButton.isHidden = true // Hide the button
            TableView.reloadData()
        } else {
            showAlert(message: "Please fill in all the fields before proceeding.")
        }
    }
    
    // MARK: - Update Questions Array Based on User Input
    func updateQuestionsArray() {
        if let numberOfQuestions = Int(NoOfQuestins.text ?? "0"), numberOfQuestions > 0 {
            questions = (1...numberOfQuestions).map { "Question \($0)" }
        } else {
            questions.removeAll()
        }
        TableView.reloadData()
    }

    // MARK: - Check if all text fields are filled
    func areAllFieldsFilled() -> Bool {
        let textFields = [enterTitle, NoOfQuestins, NoOfOptons, StartDate, EndDate]
        return textFields.allSatisfy { $0?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }

    // MARK: - Show Alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Incomplete Data", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Add Shadow Effect
    func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowRadius = 3
        button.layer.masksToBounds = false
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AddFeedBackViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(NoOfOptons.text ?? "0") ?? 0 // Use noOfOptions instead of noOfQuestions
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedBackCell", for: indexPath) as! AddFeedBackTableViewCell
        cell.QuestionNo.text = "\(indexPath.row + 1)"
        return cell
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let groupId = groupId, let title = enterTitle.text,
              let startDate = StartDate.text, let endDate = EndDate.text,
              let noOfQuestions = NoOfQuestins.text, let noOfOptions = NoOfOptons.text else {
            print("Missing required fields")
            return
        }
        
        // Collect questions and marks from TableView cells
        var questionsArray: [FeedbackQuestion] = []
        for i in 0..<questions.count {
            if let cell = TableView.cellForRow(at: IndexPath(row: i, section: 0)) as? AddFeedBackTableViewCell,
               let questionText = cell.Question.text, let marksText = cell.Marks.text {
                let question = FeedbackQuestion(question: questionText, marks: marksText)
                questionsArray.append(question)
            }
        }

        var options: [FeedbackOption] = []
        if let noOfOptionsInt = Int(noOfOptions) {
            options = (1...noOfOptionsInt).map { FeedbackOption(optionNo: "\($0)", option: "Option \($0)", marks: "0", answer: false) }
        } else {
            print("Invalid number of options")
            return
        }

        // Prepare request body
        let feedbackData = FeedBackRequest(
            groupId: groupId,
            isActive: true,
            lastDate: endDate,
            noOfOptions: noOfOptions,
            noOfQuestions: noOfQuestions,
            options: options, // ✅ Now accessible
            questionsArray: questionsArray,
            startDate: startDate,
            title: title,
            updatedAt: ""
        )

        // Convert to JSON
        guard let jsonData = try? JSONEncoder().encode(feedbackData) else {
            print("Failed to encode JSON")
            return
        }

        // API URL
        let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/feedback/title/create")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData

        // Perform API request
        // Perform API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Check for success (200 or 201)
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
