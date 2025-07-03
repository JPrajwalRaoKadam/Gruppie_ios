import UIKit

protocol AddEventDelegate: AnyObject {
    func didAddEvent(eventData: String)
    func callAddEvent()
}

class AddEvent: UIView {
    
    weak var delegate: AddEventDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var reminderBTn: UIButton!
    @IBOutlet weak var submit: UIButton!
    
    private var selectedReminder: String?
    var currentDatePicker: UIDatePicker?
    var currentTextField: UITextField?
    var currentTimePicker: UIDatePicker?
    var currentTextField2: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        submit.layer.cornerRadius = 10
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
    
    @IBAction func addButton(_ sender: Any) {
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
            "venue": eventVenue
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: eventData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                delegate?.didAddEvent(eventData: jsonString)
                delegate?.callAddEvent()
            }
        } catch {
            print("Error converting eventData to JSON string: \(error.localizedDescription)")
        }
        
        showAlert(title: "Success", message: "Event added successfully.")
        self.removeFromSuperview()
    }
    
    // MARK: - Date Picker
    
    func showDatePickerPopup(for textField: UITextField) {
        currentTextField = textField
        
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        let containerView = createPopupContainer()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker
        
        addPickerAndButtons(to: containerView, picker: datePicker, doneAction: #selector(datePickerDonePressed(_:)), cancelAction: #selector(datePickerCancelPressed(_:)))
        backgroundView.addSubview(containerView)
        
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        setPopupConstraints(containerView, parent: backgroundView, picker: datePicker)
    }
    
    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let picker = currentDatePicker, let textField = currentTextField {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            textField.text = formatter.string(from: picker.date)
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
    @objc func datePickerCancelPressed(_ sender: UIButton) {
        sender.superview?.superview?.removeFromSuperview()
    }
    
    // MARK: - Time Picker
    
    func showTimePickerPopup(for textField: UITextField) {
        currentTextField2 = textField
        
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTimePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        let containerView = createPopupContainer()
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        currentTimePicker = timePicker
        
        addPickerAndButtons(to: containerView, picker: timePicker, doneAction: #selector(timePickerDonePressed(_:)), cancelAction: #selector(timePickerCancelPressed(_:)))
        backgroundView.addSubview(containerView)
        
        if let window = UIApplication.shared.windows.first {
            window.addSubview(backgroundView)
        }
        
        setPopupConstraints(containerView, parent: backgroundView, picker: timePicker)
    }
    
    @objc func dismissTimePickerPopup(_ gesture: UITapGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    
    @objc func timePickerDonePressed(_ sender: UIButton) {
        if let picker = currentTimePicker, let textField = currentTextField2 {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            textField.text = formatter.string(from: picker.date)
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
    @objc func timePickerCancelPressed(_ sender: UIButton) {
        sender.superview?.superview?.removeFromSuperview()
    }
    
    // MARK: - Reminder
    
    func fetchReminderList() {
        let urlString = APIManager.shared.baseURL + "gruppie/reminder/get"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Reminder Error: \(error)")
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let data = json["data"] as? [String: Any],
                  let list = data["reminderList"] as? [String] else {
                print("Invalid JSON")
                return
            }
            DispatchQueue.main.async {
                self?.showReminderPopup(reminderList: list)
            }
        }.resume()
    }
    
    func showReminderPopup(reminderList: [String]) {
        let alert = UIAlertController(title: "Reminder List", message: nil, preferredStyle: .actionSheet)
        reminderList.forEach { reminder in
            let action = UIAlertAction(title: reminder, style: .default) { [weak self] _ in
                self?.selectedReminder = reminder
                self?.reminderBTn.setTitle(reminder, for: .normal)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        getViewController()?.present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    func createPopupContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    func addPickerAndButtons(to container: UIView, picker: UIDatePicker, doneAction: Selector, cancelAction: Selector) {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: doneAction, for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: cancelAction, for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(picker)
        container.addSubview(doneButton)
        container.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            doneButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setPopupConstraints(_ container: UIView, parent: UIView, picker: UIDatePicker) {
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            container.widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 0.85),
            container.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        getViewController()?.present(alert, animated: true)
    }
    
    func getViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let vc = responder as? UIViewController {
                return vc
            }
            nextResponder = responder.next
        }
        return nil
    }
}

