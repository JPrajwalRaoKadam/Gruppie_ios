import Foundation
import UIKit

class StaffDaysViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var curDate: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var currentDatePicker: UIDatePicker?
    var currentDate : String?
    var currentRole: String?
    var groupIds: String = ""
    var token: String = ""
    var userId: String = ""
    var diaryData: [DiaryData] = []
    var staffName: String?
    var teachingStaff: [Staff]?
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        
        print("Group ID StaffDaysViewController: \(groupIds)")
        print("Token StaffDaysViewController: \(token)")
        print("User ID StaffDaysViewController: \(userId)")
        print("currentRole StaffDaysViewController: \(currentRole)")
        print("📋 Selected Staff Name: \(staffName ?? "Unknown")")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "StaffDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "StaffDaysTableViewCell")
        setCurrentDate()
        fetchData()
        messageTextView.text = "    Enter a message"
        messageTextView.textColor = .lightGray
        
        
        
        messageTextView.delegate = self
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
                if currentRole?.lowercased() == "admin" || currentRole?.lowercased() == "parent" {
                        messageTextView.isHidden = true
                        submitButton.isHidden = true
                    } else if currentRole == "teacher" {
                        messageTextView.isHidden = false
                        submitButton.isHidden = false
                    }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📌 View Appeared with userId: \(userId)")
        fetchData()
    }
    
    func fetchData() {
        guard let token = TokenManager.shared.getToken(), let date = currentDate else {
            print("Missing token or date")
            return
        }
        fetchDiaryData()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter a message" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Enter a message"
            textView.textColor = .lightGray
        }
    }
    
    
    @IBAction func leftdateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            currentDate = dateFormatter.string(from: previousDay)
            curDate.setTitle(currentDate, for: .normal)
            fetchData()
        }
    }
    
    @IBAction func rightdateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
        let todayDate = Date()
        
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
           nextDay <= todayDate {
            currentDate = dateFormatter.string(from: nextDay)
            curDate.setTitle(currentDate, for: .normal)
            fetchData()
        }
    }
    
    @IBAction func dateChange(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton)
    }
    
    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        curDate.setTitle(self.currentDate, for: .normal)
    }
    
    func showDatePickerPopup(for button: UIButton) {
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)
        
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        curDate = button
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            
            curDate.setTitle(selectedDate, for: .normal)
            currentDate = selectedDate
            fetchData()
            
            if let backgroundView = sender.superview?.superview {
                backgroundView.removeFromSuperview()
            }
        }
    }
    
    @objc func datePickerCancelPressed(_ sender: UIButton) {
        if let backgroundView = sender.superview?.superview {
            backgroundView.removeFromSuperview()
        }
    }
    
    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }
    
    private func fetchDiaryData() {
        guard let currentDate = currentDate, !currentDate.isEmpty,
              !userId.isEmpty else {
            print("❌ currentDate or userId is missing or empty")
            return
        }
        print("🔐 Using Token: \(token), for userId: \(userId)")
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupIds)/teachers/diary/get?date=\(currentDate)&userId=\(userId)"
        print("Fetching diary data from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📦 Raw API Response:\n\(rawResponse)")
            }
            
            do {
                let decoder = JSONDecoder()
                let diaryResponse = try decoder.decode(DiaryResponse.self, from: data)
                DispatchQueue.main.async {
                    self.diaryData = diaryResponse.data ?? []
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Failed to decode response: \(error)")
            }
        }
        
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return diaryData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryData[section].diaryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffDaysTableViewCell", for: indexPath) as? StaffDaysTableViewCell else {
            return UITableViewCell()
        }
        
        let diaryItem = diaryData[indexPath.section].diaryItems[indexPath.row]
        cell.time.text = diaryItem.time
        cell.message.text = diaryItem.text
        return cell
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -bottomInset
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        print("submitButtonTapped userId: '\(userId)', currentDate: '\(currentDate ?? "nil")'")
        
        guard !userId.isEmpty,
              !token.isEmpty,
              let currentDate = currentDate, !currentDate.isEmpty else {
            print("❌ Missing required info")
            return
        }
        
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              text != "Enter a message" else {
            print("❌ Message is empty or placeholder text")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: Date())
        
        var allDiaryItems: [[String: Any]] = []
        
        if !diaryData.isEmpty {
            for item in diaryData[0].diaryItems {
                allDiaryItems.append([
                    "text": item.text ?? "",
                    "time": item.time ?? "",
                    "isEditable": true
                ])
            }
        }
        
        allDiaryItems.append([
            "text": text,
            "time": currentTime,
            "isEditable": true
        ])
        
        // ✅ FIX: Change "diaryDate" → "date"
        let requestBody: [String: Any] = [
            "userId": userId,
            "date": currentDate,
            "diaryItems": allDiaryItems
        ]
        
        print("🧾 Final POST Payload:\n\(requestBody)")
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupIds)/teachers/diary/add"
        print("📡 API URL post api: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = bodyData
            
            if let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📤 Request Body: \(bodyString)")
            }
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("📦 Parsed JSON Response:\n\(json)")
            } catch {
                print("❌ Failed to parse JSON response: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Raw Response:\n\(raw)")
                }
            }
            
            DispatchQueue.main.async {
                let newDiaryItem = DiaryItem(time: currentTime, text: text, isEditable: true)
                
                if !self.diaryData.isEmpty {
                    self.diaryData[0].diaryItems.append(newDiaryItem)
                } else {
                    let newDiaryData = DiaryData(
                        diaryItems: [newDiaryItem],
                        userId: self.userId,
                        staffName: self.staffName ?? "",
                        staffImage: nil,
                        diaryDate: currentDate
                    )
                    self.diaryData.append(newDiaryData)
                }
                
                self.tableView.reloadData()
                self.messageTextView.text = "Enter a message"
                self.messageTextView.textColor = .lightGray
                
                let alert = UIAlertController(title: "Success", message: "Diary entry submitted successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        task.resume()
    }

}
