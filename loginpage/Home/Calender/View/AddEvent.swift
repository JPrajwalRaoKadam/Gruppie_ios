import UIKit

protocol AddEventDelegate: AnyObject {
    func didAddEvent(eventData: String)
    func callAddEvent()
}

class AddEvent: UIView {
    weak var delegate: AddEventDelegate?
    
    
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var reminderBTn: UIButton!
    @IBOutlet weak var submit: UIButton!
    
    private var doneButtonKey: UInt8 = 0
    private var cancelButtonKey: UInt8 = 0
    private var selectedReminder: String?
    var currentDatePicker: UIDatePicker?
    var currentTextField: UITextField?
    var currentTimePicker: UIDatePicker?
    var currentTextField2: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        submit.layer.cornerRadius = 10
    }
    
    
    @IBAction func addStartDate(_ sender: Any) {
        showDatePickerPopup(for: startDate)
    }
    
    @IBAction func addEndDate(_ sender: Any) {
        showDatePickerPopup(for: endDate)
    }
    
    @IBAction func addStartTime(_ sender: Any) {
        showTimePickerPopup(for: startTime)
    }
    
    @IBAction func addEndTime(_ sender: Any) {
        showTimePickerPopup(for: endTime)
    }
    
    @IBAction func locationAction(_ sender: Any) {
    }
    
    
    @IBAction func reminderList(_ sender: Any) {
        fetchReminderList()
    }
    
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
            formatter.dateFormat = "yyyy-MM-dd" // Adjust the format as needed
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
    
    //time picker
    func showTimePickerPopup(for textField: UITextField) {
        // Store the text field reference
        currentTextField2 = textField
        
        // Create a background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Add a tap gesture recognizer to dismiss the popup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTimePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Create a container view for the time picker
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the UIDatePicker for time selection
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        currentTimePicker = timePicker // Assign the current time picker
        
        // Create a "Done" button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(timePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a "Cancel" button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(timePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to the container view
        containerView.addSubview(timePicker)
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
            
            timePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            
            doneButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func dismissTimePickerPopup(_ gesture: UITapGestureRecognizer) {
        // Remove the background view when tapping outside
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }
    
    @objc func timePickerDonePressed(_ sender: UIButton) {
        if let timePicker = currentTimePicker, let textField = currentTextField2 {
            // Format the selected time
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a" // Adjust the format as needed
            let selectedTime = formatter.string(from: timePicker.date)
            
            // Update the text field with the selected time
            textField.text = selectedTime
            
            // Print the selected time to the console
            //print("Picked Time: \(selectedTime)")
            
            // Remove the background view to close the popup
            if let backgroundView = sender.superview?.superview {
                backgroundView.removeFromSuperview()
            }
        }
    }
    
    @objc func timePickerCancelPressed(_ sender: UIButton) {
        if let backgroundView = sender.superview?.superview {
            backgroundView.removeFromSuperview()
        }
    }
    
    // Function to display the reminder list popup
    func showReminderPopup(reminderList: [String]) {
        let alert = UIAlertController(title: "Reminder List", message: nil, preferredStyle: .actionSheet)
        
        // Add each reminder as an action
        for reminder in reminderList {
            let action = UIAlertAction(title: reminder, style: .default) { [weak self] _ in
                self?.selectedReminder = reminder
                self?.reminderBTn.titleLabel?.text = self?.selectedReminder
                print("Selected reminder: \(reminder)")
            }
            alert.addAction(action)
        }
        
        // Add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        if let viewController = self.getViewController() {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // Helper method to get the view controller
    private func getViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            nextResponder = responder.next
        }
        return nil
    }
    
    func fetchReminderList() {
        let urlString = APIManager.shared.baseURL + "gruppie/reminder/get"
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Create a URL request
        let request = URLRequest(url: url)
        
        // Fetch data using URLSession
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching reminder list: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Parse JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let reminderList = data["reminderList"] as? [String] {
                    
                    // Present the popup on the main thread
                    DispatchQueue.main.async {
                        self?.showReminderPopup(reminderList: reminderList)
                    }
                } else {
                    print("Invalid response format")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
    
    @IBAction func addButton(_ sender: Any) {
        // Ensure all fields have values
        guard let eventTitle = title.text, !eventTitle.isEmpty,
              let eventStartDate = startDate.text, !eventStartDate.isEmpty,
              let eventEndDate = endDate.text, !eventEndDate.isEmpty,
              let eventStartTime = startTime.text, !eventStartTime.isEmpty,
              let eventEndTime = endTime.text, !eventEndTime.isEmpty,
              let eventVenue = venue.text, !eventVenue.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill all the fields.")

            return
        }

        let eventData: [String: Any] = [

            "title": eventTitle,
            "startDate": eventStartDate,
            "endDate": eventEndDate,
            "startTime": eventStartTime,
            "endTime": eventEndTime,
            "venue": eventVenue,
            //"reminder": selectedReminder ?? ""
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: eventData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body1: \(jsonString)")
                delegate?.didAddEvent(eventData: jsonString)
                delegate?.callAddEvent()
            }
        } catch {
            print("Error converting eventData to JSON string: \(error.localizedDescription)")
        }

        showAlert(title: "Success", message: "Event added successfully.")
        // Remove the view after adding the event
        self.removeFromSuperview()
    }
    // Function to show an alert message
    func showAlert(title: String, message: String) {
        if let viewController = getViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
        // Get the current date
        let currentDate = Date()
        
        // Use Calendar to get the current month and year
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
      
    }
}
