//
//  EditEventVC.swift
//  loginpage
//
//  Created by apple on 17/07/25.
//

import UIKit

protocol CallEditEventApi : AnyObject {
    func triggerEditEventApi()
    func updateEditedEvent(editedEvent: Event?)
    func shouldHideEditButton() -> Bool
    func deleteEvent()
}

class EditEventVC: UIViewController {
    weak var delegate: CallEditEventApi?

    @IBOutlet weak var EventHEading: UILabel!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var reminder: UITextField!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var startDate: UIButton!
    @IBOutlet weak var endDate: UIButton!
    @IBOutlet weak var startTime: UIButton!
    @IBOutlet weak var endTime: UIButton!
    @IBOutlet weak var delete: UIButton!
    
    private var selectedReminder: String?
    var currentDatePicker: UIDatePicker?
    var currentDateButton: UIButton?
    var currentTimePicker: UIDatePicker?
    var currentTimeButton: UIButton?
    var groupId: String = ""
    var selectedEvent: Event?
    var editedEvent: Event?
    var currentRole: String = ""
    var event: Event?
    // Local variables for text fields
    var editedTitle: String?
    var editedStartDate: String?
    var editedEndDate: String?
    var editedStartTime: String?
    var editedEndTime: String?
    var editedVenue: String?
    var editedReminder: String?
    func populateFields() {
        guard let event = event else { return }
        
        // Ensure outlets are loaded
        guard isViewLoaded else { return }
            self.eventTitleTextField.text = event.title
            self.startDate.setTitle(event.startDate, for: .normal)
            self.endDate.setTitle(event.endDate, for: .normal)
            self.startTime.setTitle(event.startTime, for: .normal)
            self.endTime.setTitle(event.endTime, for: .normal)
            self.venue.text = event.venue
            self.selectedReminder = event.reminder
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        venue.layer.cornerRadius = 10
        venue.layer.masksToBounds = true
        reminder.layer.cornerRadius = 10
        reminder.layer.masksToBounds = true
        eventTitleTextField.layer.cornerRadius = 10
        eventTitleTextField.layer.masksToBounds = true
        populateFields()
    // Add gesture recognizer to the reminder text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reminderTapped))
        reminder.addGestureRecognizer(tapGesture)
        reminder.isUserInteractionEnabled = true
        reminder.inputView = UIView() // prevents keyboard from showing
        edit.layer.cornerRadius = 10
        delete.layer.cornerRadius = 10
        print("eventTitleTextField: \(eventTitleTextField != nil)")
        print("venue: \(venue != nil)")
        print("reminder: \(reminder != nil)")
        print("submit: \(edit != nil)")
        print("startDate: \(startDate != nil)")
        print("endDate: \(endDate != nil)")
        print("startTime: \(startTime != nil)")
        print("endTime: \(endTime != nil)")
        print("selectedevent: \(selectedEvent)")
        // Style buttons
        [startDate, endDate, startTime, endTime, edit].forEach {
            $0?.layer.cornerRadius = 8
        }
    }
    
    @objc func reminderTapped() {
        fetchReminderList()
    }
    // MARK: - Date & Time Actions
    
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
    
    @IBAction func locationAction(_ sender: Any) { }
    
    @IBAction func reminderList(_ sender: Any) {
        fetchReminderList()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        delegate?.deleteEvent()
        self.dismiss(animated: true)
    }
    
    func showReminderPopup(reminderList: [String]) {
        let alert = UIAlertController(title: "Reminder List", message: nil, preferredStyle: .actionSheet)
        
        // Add each reminder as an action
        for reminder in reminderList {
            let action = UIAlertAction(title: reminder, style: .default) { [weak self] _ in
                self?.selectedReminder = reminder
                self?.reminder.text = reminder
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
        
        // First update the edited event
        delegate?.updateEditedEvent(editedEvent: editedEvent)
        
        // Then trigger the API call
        delegate?.triggerEditEventApi()
        
        // Dismiss the view controller
        self.dismiss(animated: true)
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
    

    func showDatePickerPopup(for button: UIButton) {
        // Correctly store the button reference
        currentDateButton = button
        
        // Create a background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Container view for the popup
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget (self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)
        
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        // Set constraints
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
        gesture.view?.removeFromSuperview()
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker, let button = currentDateButton {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            
            // ✅ Set both plain and attributed title
            button.setTitle(selectedDate, for: .normal)
            button.setAttributedTitle(nil, for: .normal)  // Clear placeholder
            
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
    
    @objc func datePickerCancelPressed(_ sender: UIButton) {
        sender.superview?.superview?.removeFromSuperview()
    }
    
    //time picker
    func showTimePickerPopup(for button: UIButton) {
        // Store the button reference
        currentTimeButton = button
        
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
        currentTimePicker = timePicker // Store picker reference
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(timePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(timePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        containerView.addSubview(timePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)
        
        // Add background view to window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        // Constraints
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
        gesture.view?.removeFromSuperview()
    }
    
    @objc func timePickerDonePressed(_ sender: UIButton) {
        if let timePicker = currentTimePicker, let button = currentTimeButton {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let selectedTime = formatter.string(from: timePicker.date)
            
            // ✅ Set both plain and attributed title
            button.setTitle(selectedTime, for: .normal)
            button.setAttributedTitle(nil, for: .normal)  // Clear placeholder
            
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
    
    @objc func timePickerCancelPressed(_ sender: UIButton) {
        sender.superview?.superview?.removeFromSuperview()
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

    
   func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case eventTitleTextField:
            editedTitle = textField.text
        case venue:
            editedVenue = textField.text
        case reminder:
            editedReminder = textField.text
        default:
            break
        }

        createEditedEvent()
        delegate?.updateEditedEvent(editedEvent: editedEvent)
    }

    func createEditedEvent() {
        guard let originalEvent = event else { return }
        
        editedEvent = Event(
            eventid: originalEvent.eventid, // Preserve the original ID
            title: eventTitleTextField.text ?? originalEvent.title,
            startDate: startDate.currentTitle ?? originalEvent.startDate,
            endDate: endDate.currentTitle ?? originalEvent.endDate,
            startTime: startTime.currentTitle ?? originalEvent.startTime,
            endTime: endTime.currentTitle ?? originalEvent.endTime,
            venue: venue.text ?? originalEvent.venue,
            reminder: selectedReminder ?? originalEvent.reminder
        )
        
        print("🛠 Created edited event with ID: \(editedEvent?.eventid ?? "nil")")
    }
}

