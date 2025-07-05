//  EditEvent.swift
//  loginpage
//
//  Created by Apple on 22/01/25.
//

import UIKit

protocol CallEditEventApi : AnyObject {
    func triggerEditEventApi()
    func updateEditedEvent(editedEvent: Event?)
    func shouldHideEditButton() -> Bool
}

class EditEvent: UIView, UITextFieldDelegate {
    var event: Event? {
            didSet {
                populateFields()
            }
        }
    
    var editedEvent: Event?
    var groupId: String = ""
    var eventId: String = ""
    var currentRole: String = ""

    @IBOutlet weak var viewheight: NSLayoutConstraint!
    weak var delegate: CallEditEventApi?
    
    // Local variables for text fields
    var editedTitle: String?
    var editedStartDate: String?
    var editedEndDate: String?
    var editedStartTime: String?
    var editedEndTime: String?
    var editedVenue: String?
    var editedReminder: String?

    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var reminderBTn: UIButton!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var edit: UIButton!
    
    private var selectedReminder: String?
    var currentDatePicker: UIDatePicker?
    var currentTextField: UITextField?
    var currentTimePicker: UIDatePicker?
    var currentTextField2: UITextField?
    // Method to populate the fields
        private func populateFields() {
            guard let event = event else { return }
            title.text = event.title
            startDate.text = event.startDate
            endDate.text = event.endDate
            startTime.text = event.startTime
            endTime.text = event.endTime
            venue.text = event.venue
            selectedReminder = event.reminder
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("curr role in editevent of cal \(currentRole)")
        title.delegate = self
        startDate.delegate = self
        endDate.delegate = self
        startTime.delegate = self
        endTime.delegate = self
        venue.delegate = self
        edit.layer.cornerRadius = 10
        
        DispatchQueue.main.async { [weak self] in
            if self?.delegate?.shouldHideEditButton() == true {
                self?.editButtonOutlet?.isHidden = true
            } else {
                self?.editButtonOutlet?.isHidden = false
            }
        }
        
        // Remove viewheight constraint manipulation
        print("Delegate set: \(delegate != nil)")
        print("Should hide edit button: \(delegate?.shouldHideEditButton() ?? false)")
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
    
    // Function to display the reminder list popup
    func showReminderPopup(reminderList: [String]) {
        let alert = UIAlertController(title: "Reminder List", message: nil, preferredStyle: .actionSheet)

        // Add each reminder as an action
        for reminder in reminderList {
            let action = UIAlertAction(title: reminder, style: .default) { [weak self] _ in
                self?.selectedReminder = reminder
                self?.reminderBTn.titleLabel?.text = self?.selectedReminder
                self?.editedReminder = reminder
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
        
    @IBAction func editButton(_ sender: Any) {
        createEditedEvent()
        delegate?.triggerEditEventApi()
        
        // Find and remove the background view
        if let superview = self.superview, superview.tag == 1002 {
            UIView.animate(withDuration: 0.2, animations: {
                superview.alpha = 0
            }) { _ in
                superview.removeFromSuperview()
            }
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
            print("Picked Date: \(selectedDate)")
            
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
                print("Picked Time: \(selectedTime)")

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
 

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case title:
            editedTitle = textField.text
            print("Title field did end editing: \(textField.text ?? "")")
        case startDate:
            editedStartDate = textField.text
            print("Start Date field did end editing: \(textField.text ?? "")")
        case endDate:
            editedEndDate = textField.text
            print("End Date field did end editing: \(textField.text ?? "")")
        case startTime:
            editedStartTime = textField.text
            print("Start Time field did end editing: \(textField.text ?? "")")
        case endTime:
            editedEndTime = textField.text
            print("End Time field did end editing: \(textField.text ?? "")")
        case venue:
            editedVenue = textField.text
            print("Venue field did end editing: \(textField.text ?? "")")
        default:
            print("Unknown text field did end editing: \(textField.text ?? "")")
        }
        createEditedEvent()
        delegate?.updateEditedEvent(editedEvent: editedEvent)
    }
    
    func createEditedEvent() {
        guard let event = event else { return }
        editedEvent = Event(
            title: editedTitle ?? event.title,
            startDate: editedStartDate ?? event.startDate,
            endDate: editedEndDate ?? event.endDate,
            startTime: editedStartTime ?? event.startTime,
            endTime: editedEndTime ?? event.endTime,
            venue: editedVenue ?? event.venue,
            reminder: editedReminder ?? event.reminder
        )
    }
}

