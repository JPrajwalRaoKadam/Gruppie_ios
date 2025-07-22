import UIKit

class AddHolidaysCallenderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewHolidayDelegate {
    
    @IBOutlet weak var holidaysList: UILabel!
    @IBOutlet weak var addTitle: UILabel!
    @IBOutlet weak var addDate: UILabel!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var holiday: UITableView!
    
    var groupId: String = ""
    var holidays: [Holiday] = []
    var holidayAddCount = 1
    var currentRole: String = ""
    var lastVisibleAddMoreIndex: IndexPath?
    var currentDatePicker: UIDatePicker?
    var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in")
        holiday.delegate = self
        holiday.dataSource = self
        submit.layer.cornerRadius = 10
        submit.clipsToBounds = true
        
        holiday.register(UINib(nibName: "AddNewHoliday", bundle: nil), forCellReuseIdentifier: "AddNewHoliday")
        if currentRole != "admin" {
            submit.isHidden = true
            holidayAddCount = 0 // Prevent new row for adding holidays
        }
        fetchHolidays()
        enableKeyboardDismissOnTap()
    }
        
    @IBAction func submit(_ sender: Any) {
        addHolidayToServer()
    }
    func didTapDateField(textField: UITextField) {
        self.showDatePickerPopup(for: textField)
    }
    
    func didTapAddMore() {
            holidayAddCount += 1 // Increment count
            lastVisibleAddMoreIndex = IndexPath(row: holidayAddCount - 2, section: 1)
            holiday.reloadData()  // Reload table to reflect changes
        }
    
    func fetchHolidays() {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/calendar/events?year=2025"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching holidays: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                  if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                     let dataArray = json["data"] as? [[String: Any]] {
                      
                     self.holidays = dataArray.compactMap { dictionary in
                          guard let year = dictionary["year"] as? Int,
                                let title = dictionary["title"] as? String,
                                let startDate = dictionary["startDate"] as? String else {
                              print("Missing data in JSON: \(dictionary)") // Debugging
                              return nil
                          }
                          
                          // Initialize Holiday safely
                          return Holiday(year: year, title: title, startDate: startDate, endDate: dictionary["endDate"] as? String ?? "")
                      }

                    
                    DispatchQueue.main.async {
                        self.holiday.reloadData()
                    }
                } else {
                    print("Invalid JSON structure")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
    func addHolidayToServer(){
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/add/calendar/events"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var holidaysToSend: [[String: String]] = []

        // Extract new holidays only from section 1 cells
        for row in 0..<holidayAddCount {
            let indexPath = IndexPath(row: row, section: 1)
            if let cell = holiday.cellForRow(at: indexPath) as? AddNewHoliday {
                let title = cell.holidayTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let startDate = cell.holidaydate.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if !title.isEmpty && !startDate.isEmpty {
                    let holidayDict: [String: String] = [
                        "startDate": startDate,
                        "endDate": startDate, // or use separate endDate if provided
                        "title": title
                    ]
                    holidaysToSend.append(holidayDict)
                }
            }
        }

        if holidaysToSend.isEmpty {
            print("No new holidays to send")
            return
        }

        let requestBody: [String: Any] = [
            "calendarData": holidaysToSend
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Final JSON Body Sent: \(jsonString)")
            }
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding holiday: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response of addholiday in calendar: \(rawResponse)")
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("Response from API: \(jsonResponse)")

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Holidays added successfully!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }

            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
            }
        }
        task.resume()
    }



//    func addHolidayToServer() 
    
    // MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return holidays.count  // Dynamic holiday list
        } else {
            return holidayAddCount  // Only 1 row in section 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewHoliday", for: indexPath) as? AddNewHoliday else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            // Section 0: Display holiday data
            let holiday = holidays[indexPath.row]
            cell.holidayTitle.text = holiday.title
            cell.holidaydate.text = holiday.startDate
            cell.holidayTitle.isUserInteractionEnabled = false
            cell.holidaydate.isUserInteractionEnabled = false
            cell.addMore.isHidden = true  // No Add More button in Section 0
        } else {
            // Section 1: Editable rows
            cell.holidayTitle.text = ""
            cell.holidaydate.text = ""
            cell.holidayTitle.isUserInteractionEnabled = true
            cell.holidaydate.isUserInteractionEnabled = true
            cell.delegate = self
            
            // Show "Add More" only for the last row
            cell.addMore.isHidden = indexPath.row != (holidayAddCount)
        }
        
        return cell
    }

    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50 // Holidays are always fixed height
        } else {
            // If it's the last row (where addMore is visible), return 50, else 30
            return indexPath.row == (holidayAddCount - 1) ? 50 : 30
        }
    }

    
//    @IBAction func backButtonTapped(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true) // If pushed, pop the VC
        } else {
            self.dismiss(animated: true, completion: nil) // If presented modally, dismiss
        }
    }

}

extension AddHolidaysCallenderViewController {
    func showDatePickerPopup(for textField: UITextField) {
        // Store the text field reference
        currentTextField = textField
        
        // Create a background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Add a tap gesture recognizer to dismiss the popup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Create a container view for the date picker
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker // Assign the current date picker
        
        // Create a "Done" button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a "Cancel" button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to the container view
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        
        // Add the container view to the background view
        backgroundView.addSubview(containerView)
        
        // Add the background view to the main window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        // Set constraints for the container view
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
    }
    
    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        // Remove the background view when tapping outside
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker, let textField = currentTextField {
            // Format the selected date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy" // Adjust the format as needed
            let selectedDate = formatter.string(from: datePicker.date)
            
            // Update the text field with the selected date
            textField.text = selectedDate
            
            // Print the selected date to the console
            // print("Picked Date: \(selectedDate)")
            
            // Remove the background view to close the popup
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
}
