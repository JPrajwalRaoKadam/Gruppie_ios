import UIKit
import FSCalendar

class CalenderViewController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource,AddEventDelegate, CallEditEventApi
{
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var calendarViewHieght: NSLayoutConstraint!
    var groupId: String = ""
    var events: [Event] = []
    var selectedSegmentIndex: Int = 0 // Track the selected segment index
    var event: Event?
    var eventEditToBe: Event?
    var selectedReminder = ""
    var eventData : String = ""
    var selectedEventId: String = ""
    var selectedDate: Date?
    var currentDate: Date?
    var currentRole: String = ""
    var filteredEvents: [Event] = []
    var eventIds: [String] = []
    // var selectedEventId: String?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var addEvents: UIButton!
    @IBOutlet weak var addHolidays: UIButton!
    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var calenderViewHeight: NSLayoutConstraint!
    var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        calendarTableView.layer.cornerRadius = 10
        calenderView.layer.cornerRadius = 10
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        for event in events {
            print("🧩 Event title: \(event.title), eventid: \(event.eventid ?? "nil"), selectedEventId\(selectedEventId)")
        }
        print("cal grpid: \(groupId)")
        if currentRole.lowercased() != "admin" {
            addEvents.isHidden = true
        } else {
            addEvents.isHidden = false
        }
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
        //myView.isHidden = true
        // transforentView.isHidden = true
        calendarTableView.register(UINib(nibName:"CalendarTableViewCell" , bundle: nil), forCellReuseIdentifier: "CalendarTableViewCell")
        self.navigationController?.isNavigationBarHidden = true
        // Initialize the calendar
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        self.calenderView.addSubview(calendar)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            calendar.leadingAnchor.constraint(equalTo: calenderView.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: calenderView.trailingAnchor),
            calendar.heightAnchor.constraint(equalToConstant: 280)
        ])
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .white
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.selectionColor = .blue
        calendar.scope = .month
        calendar.scrollDirection = .horizontal
        // Customize fonts
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 17) // Day numbers
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 16) // Weekdays (e.g., Sun, Mon)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 20) // Month and year header
        FSCalendar.appearance().placeholderType = .none
        calendar.scope = .month
        // Set the delegate
        calendar.delegate = self
        let currentDate = Date()
        calendar.setCurrentPage(currentDate, animated: false)  // Set the current month as the initial view
        segmentButtonAction(segmentControl)
        let currentSelectedDate = formatDateToString(date: currentDate)
        //            let selectedDatt = formatDateToString(date: selectedDate!)
        print("currentSelectedDate date: \(currentSelectedDate)")
        //            print("SelectedDate date: \(selectedDatt)")
        let currentPage = calendar.currentPage // Get the current visible month and year from the calendar
        let components = Calendar.current.dateComponents([.month, .year], from: currentPage)
        
        guard let month = components.month, let year = components.year else {
            print("Failed to extract month and year")
            return
        }
        enableKeyboardDismissOnTap()
        fetchEvents(for: month, year: year)
        print("selected id: \(selectedEventId)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarTableView.reloadData()
    }
    
    func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Format to only show date
        return dateFormatter.string(from: date)
    }
    
    // FSCalendar Delegate Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date // Store the selected date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust format as needed
        let formattedDate = dateFormatter.string(from: date)
        print("Selected date: \(formattedDate)")
        selectedDate = date
        if selectedSegmentIndex == 0 {
            selectedDate = date
            filterEventsForSelectedDate()
        }
    }
    
    @IBAction func segmentButtonAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        if selectedSegmentIndex == 0 {
            // Filter for today's date events
            selectedDate = Date() // or use previously selected date if you want
            filterEventsForSelectedDate()
            print("Showing events for today's date")
        } else if selectedSegmentIndex == 1 {
            let currentPage = calendar.currentPage
            let components = Calendar.current.dateComponents([.month, .year], from: currentPage)
            
            guard let month = components.month, let year = components.year else {
                print("Failed to extract month and year")
                return
            }
            fetchEvents(for: month, year: year)
        }
    }
    func filterEventsForSelectedDate() {
        guard let selectedDate = selectedDate else {
            print("selectedDate is nil")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let selectedDateString = formatter.string(from: selectedDate)
        
        filteredEvents = events.filter { $0.startDate == selectedDateString }
        calendarTableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addEventAction(_ sender: UISegmentedControl) {
        showAddEventView()
    }
    
    @IBAction func addHolidayAction(_ sender: UISegmentedControl) {
        let storyboard = UIStoryboard(name: "calender", bundle: nil)
        if let addHolidaysVC = storyboard.instantiateViewController(withIdentifier: "AddHolidaysViewController") as? AddHolidaysCallenderViewController {
            addHolidaysVC.groupId = self.groupId // Pass the groupId
            addHolidaysVC.currentRole = currentRole
            self.navigationController?.pushViewController(addHolidaysVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent: Event
        if selectedSegmentIndex == 0 {
            selectedEvent = filteredEvents[indexPath.row]
        } else {
            selectedEvent = events[indexPath.row]
        }
        
        // Store the event ID
        self.selectedEventId = selectedEvent.eventid ?? ""
        print("📌 Selected Event ID: \(selectedEventId ?? "nil")")
        
        let storyboard = UIStoryboard(name: "calender", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditEventVC") as? EditEventVC {
            editVC.delegate = self
            editVC.event = selectedEvent
            editVC.groupId = self.groupId
            editVC.currentRole = self.currentRole
            editVC.modalPresentationStyle = .pageSheet
            
            if let sheet = editVC.sheetPresentationController {
                sheet.detents =  [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(editVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(events.count)")
        return selectedSegmentIndex == 0 ? filteredEvents.count : events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        //let event = events[indexPath.row]
        let event = selectedSegmentIndex == 0 ? filteredEvents[indexPath.row] : events[indexPath.row]
        cell.title.text = event.title
        cell.startDate.text = event.startDate
        print("eventid edit:\(event.eventid)")
        self.event = event
        
        return cell
    }
    
    func convertJSONToEvent(from jsonString: String) -> Event? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return nil
        }
        
        do {
            var event = try JSONDecoder().decode(Event.self, from: jsonData)
            
            // Assign default values if missing
            event.eventid = " "
            event.reminder = " "
            
            return event
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    func callAddEvent() {
        print("new event \(self.eventData)")
        self.event = convertJSONToEvent(from: self.eventData)
        guard let event = self.event else {
            return
        }
        print("added data \(event)")
        addEventToServer(event: event)
    }
    
    func fetchEvents(for month: Int, year: Int) {
        if groupId.isEmpty {
            print("Group ID is not set")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/calendar/events/get?month=\(month)&year=\(year)&page=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
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
                print("Raw Response of calendar: \(rawResponse)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    
                    var fetchedEvents: [Event] = []
                    
                    for item in dataArray {
                        let eventId = item["id"] as? String ?? "N/A"
                        let title = item["title"] as? String ?? "Untitled"
                        let startDateString = item["startDate"] as? String ?? "-"
                        let endDateString = item["endDate"] as? String ?? "-"
                        let startTime = item["startTime"] as? String ?? "-"
                        let endTime = item["endTime"] as? String ?? "-"
                        let venue = item["venue"] as? String ?? "-"
                        let reminder = item["reminder"] as? String ?? "No Reminder"
                        
                        let event = Event(
                            eventid: eventId,
                            title: title,
                            startDate: startDateString,
                            endDate: endDateString,
                            startTime: startTime,
                            endTime: endTime,
                            venue: venue,
                            reminder: reminder
                        )
                        fetchedEvents.append(event)
                        self.eventIds.append(eventId)
                    }
                    
                    DispatchQueue.main.async {
                        self.events = fetchedEvents
                        
                        self.calendarTableView.reloadData()
                        print("Fetched Events for Month: \(month), Year: \(year): \(fetchedEvents)")
                        print("Stored Event IDs: \(self.eventIds)")
                    }
                } else {
                    print("Invalid JSON structure")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    func didAddEvent(eventData: String) {
        print("received Event \(eventData)")
        self.eventData = eventData
    }
    
    func showAddEventView() {
        let storyboard = UIStoryboard(name: "calender", bundle: nil)
        guard let addEventVC = storyboard.instantiateViewController(withIdentifier: "AddEventVC") as? AddEventVC else {
            print("Failed to instantiate AddEventVC")
            return
        }
        
        addEventVC.groupId = self.groupId
        addEventVC.delegate = self
        //        addEventVC.modalPresentationStyle = .overFullScreen
        //        addEventVC.modalTransitionStyle = .crossDissolve
        //        self.present(addEventVC, animated: true, completion: nil)
        addEventVC.modalPresentationStyle = .pageSheet
        
        if let sheet = addEventVC.sheetPresentationController {
            sheet.detents =  [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        self.present(addEventVC, animated: true)
        
    }
    func addEventToServer(event: Event) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/calendar/events/add"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert date format to match API requirement
        let formattedEvent = Event(
            eventid: event.eventid,
            title: event.title,
            startDate: formatDate(event.startDate ?? "0"),  // Convert to DD-MM-YYYY
            endDate: formatDate(event.endDate ?? "0"),      // Convert to DD-MM-YYYY
            startTime: event.startTime,
            endTime: event.endTime,
            venue: event.venue,
            reminder: event.reminder
        )
        
        do {
            let jsonData = try JSONEncoder().encode(formattedEvent)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ Request JSON Body of addEvent: \(jsonString)")
            }
        } catch {
            print("Error encoding request data: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding event: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Event added successfully: \(json)")
                    DispatchQueue.main.async {
                        self.events.append(formattedEvent)
                        self.calendarTableView.reloadData()
                        let currentPage = self.calendar.currentPage // Get the current visible month and year from the calendar
                        let components = Calendar.current.dateComponents([.month, .year], from: currentPage)
                        
                        guard let month = components.month, let year = components.year else {
                            print("Failed to extract month and year")
                            return
                        }
                        
                        self.fetchEvents(for: month, year: year)
                        if let viewController = UIApplication.shared.windows.first?.rootViewController {
                            self.showSuccessAlert(alertVC: viewController)
                        }
                    }
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // Function to convert date format from "YYYY-MM-DD" to "DD-MM-YYYY"
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString // Return original if parsing fails
        
    }
    
    
    func showSuccessAlert(alertVC: UIViewController) {
        let alert = UIAlertController(title: "Success", message: "Event added successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertVC.present(alert, animated: true)
    }
    
    
    func showAddHolidayView() {
        
    }
    func shouldHideEditButton() -> Bool {
        return currentRole.lowercased() == "teacher"
    }
    
    @objc private func dismissEditEventView(_ sender: UITapGestureRecognizer) {
        // Remove the background view from the main view
        sender.view?.removeFromSuperview()
    }
    
    func updateEditedEvent(editedEvent: Event?) {
        // Update your view controller's editedEvent property
        self.eventEditToBe = editedEvent
        // You can also perform any other necessary actions here
    }
    func triggerEditEventApi() {
        print("Delegate method triggered!")
        guard let event = self.eventEditToBe else {
            print("Event is nil")
            return
        }
        
        editEvent(
            eventid: selectedEventId ?? "",
            event: event,
            startDate: event.startDate,
            startTime: event.startTime,
            endDate: event.endDate,
            endTime: event.endTime,
            title: event.title,
            venue: event.venue,
            selectedReminder: self.selectedReminder
        ) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    // Safely update UI on main thread
                    self.event?.startDate = event.startDate
                    self.event?.startTime = event.startTime
                    self.event?.endDate = event.endDate
                    self.event?.endTime = event.endTime
                    self.event?.title = event.title
                    self.event?.venue = event.venue
                    self.event?.reminder = self.selectedReminder
                    
                    self.calendarTableView.reloadData()
                    
                    let alert = UIAlertController(title: "Success", message: "Event edited successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    print("Error: \(errorMessage ?? "Unknown error")")
                }
            }
        }
    }
    func editEvent(
        eventid: String,
        event: Event,
        startDate: String?,
        startTime: String?,
        endDate: String?,
        endTime: String?,
        title: String?,
        venue: String?,
        selectedReminder: String?,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // Validate required parameters
        guard let token = TokenManager.shared.getToken() else {
            completion(false, "Token not found")
            return
        }
        
        guard !eventid.isEmpty else {
            completion(false, "Event ID is required")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/calendar/\(eventid)/events/edit"
        print("Edit Event URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(false, "Invalid URL")
            return
        }
        
        let requestBody: [String: Any] = [
            "startDate": startDate ?? event.startDate,
            "startTime": startTime ?? event.startTime,
            "endDate": endDate ?? event.endDate,
            "endTime": endTime ?? event.endTime,
            "title": title ?? event.title,
            "venue": venue ?? event.venue,
            "reminder": selectedReminder ?? event.reminder ?? ""
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(false, "Request failed: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "Invalid server response")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No error details"
                    completion(false, "Request failed with status \(httpResponse.statusCode): \(errorMessage)")
                    return
                }
                
                DispatchQueue.main.async {
                    // ✅ Reload calendar and tableView like in addEvent
                    let currentPage = self.calendar.currentPage
                    let components = Calendar.current.dateComponents([.month, .year], from: currentPage)
                    
                    guard let month = components.month, let year = components.year else {
                        print("Failed to extract month and year")
                        return
                    }
                    
                    self.fetchEvents(for: month, year: year)
                    self.calendarTableView.reloadData()
                    
                    if let viewController = UIApplication.shared.windows.first?.rootViewController {
                        self.showSuccessAlert(alertVC: viewController)
                    }
                }
                
                completion(true, nil)
            }.resume()
            
        } catch {
            completion(false, "Failed to encode request: \(error.localizedDescription)")
        }
    }
    
    func deleteEvent() {
        deleteEvent(eventId: selectedEventId ?? "") { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    print("Event deleted successfully")
                    
                    // Refresh calendar and table
                    let currentPage = self.calendar.currentPage
                    let components = Calendar.current.dateComponents([.month, .year], from: currentPage)
                    if let month = components.month, let year = components.year {
                        self.fetchEvents(for: month, year: year)
                    }
                    
                    // Optional: Show alert
                    let alert = UIAlertController(title: "Success", message: "Event deleted successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    
                } else {
                    print("Failed to delete event: \(errorMessage ?? "Unknown error")")
                }
            }
            
        }
            func deleteEvent(eventId: String, completion: @escaping (Bool, String?) -> Void) {
                guard let token = TokenManager.shared.getToken() else {
                    completion(false, "Token not found")
                    return
                }
        
                // Construct the URL for deleting the event
                let urlString = APIManager.shared.baseURL + "/groups/\(groupId)/calendar/\(selectedEventId)/events/delete"
                guard let url = URL(string: urlString) else {
                    completion(false, "Invalid URL")
                    return
                }
        
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(false, "Error: \(error.localizedDescription)")
                        return
                    }
        
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Delete Event Status Code: \(httpResponse.statusCode)")
        
                        guard (200...299).contains(httpResponse.statusCode) else {
                            let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                            completion(false, "Server error: \(errorMessage)")
                            return
                        }
                    }
        
                    // If success
                    completion(true, nil)
                }
        
                task.resume()
            }
    }
}
