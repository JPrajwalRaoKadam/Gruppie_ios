import UIKit
import FSCalendar

class CalenderViewController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource,AddEventDelegate, CallEditEventApi
{
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
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var addEvents: UIButton!
    @IBOutlet weak var addHolidays: UIButton!
    @IBOutlet weak var calenderView: UIView!
    var calendar: FSCalendar!
        override func viewDidLoad() {
            super.viewDidLoad()
            print("cal grpid: \(groupId)")
            calendarTableView.delegate = self
            calendarTableView.dataSource = self
            //myView.isHidden = true
           // transforentView.isHidden = true
            calendarTableView.register(UINib(nibName:"CalendarTableViewCell" , bundle: nil), forCellReuseIdentifier: "CalendarTableViewCell")
            self.navigationController?.isNavigationBarHidden = true
            // Initialize the calendar
            calendar = FSCalendar(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 300))
           self.view.addSubview(calendar)
            calendar.backgroundColor = .white
            calendar.appearance.headerDateFormat = "MMMM yyyy"
            calendar.appearance.weekdayTextColor = .black
            calendar.appearance.selectionColor = .blue
            calendar.scope = .month
            calendar.scrollDirection = .horizontal
            // Customize fonts
            calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18) // Day numbers
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
      }
    @IBAction func segmentButtonAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

        if selectedSegmentIndex == 0 {
            // Clear events and reload table view
            events.removeAll()
            calendarTableView.reloadData()
            print("Cleared events for segment 0")
        } else if selectedSegmentIndex == 1 {
                // Fetch events for the current month and year
                let currentPage = calendar.currentPage // Get the current visible month and year from the calendar
                let components = Calendar.current.dateComponents([.month, .year], from: currentPage)

                guard let month = components.month, let year = components.year else {
                    print("Failed to extract month and year")
                    return
                }
            fetchEvents(for: month, year: year)
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
        }

    @IBAction func addEventAction(_ sender: UISegmentedControl) {
        showAddEventView()
    }

    @IBAction func addHolidayAction(_ sender: UISegmentedControl) {
        let storyboard = UIStoryboard(name: "calender", bundle: nil)  
           if let addHolidaysVC = storyboard.instantiateViewController(withIdentifier: "AddHolidaysViewController") as? AddHolidaysViewController {
               addHolidaysVC.groupId = self.groupId // Pass the groupId
               self.navigationController?.pushViewController(addHolidaysVC, animated: true)
           }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = events[indexPath.row]
        self.selectedEventId = selectedEvent.eventid ?? ""
        showEditEventView(with: selectedEvent)
    }
       

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("Number of rows: \(events.count)")
            return events.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
            let event = events[indexPath.row]
            cell.title.text = event.title
            cell.startDate.text = event.startDate
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
                        if let eventId = item["id"] as? String,
                           let title = item["title"] as? String,
                           let startDateString = item["startDate"] as? String,
                           let endDateString = item["endDate"] as? String,
                           let startTime = item["startTime"] as? String,
                           let endTime = item["endTime"] as? String,
                           let venue = item["venue"] as? String {
                            
                            // Fix: Ensure reminder exists, otherwise use a default value
                            let reminder = item["reminder"] as? String ?? "No Reminder"
                            
                            let event = Event(eventid: eventId, title: title, startDate: startDateString, endDate: endDateString, startTime: startTime, endTime: endTime, venue: venue, reminder: reminder)
                            fetchedEvents.append(event)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.events = fetchedEvents
                        self.calendarTableView.reloadData()
                        print("Fetched Events for Month: \(month), Year: \(year): \(fetchedEvents)")
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
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditEventView(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Attempt to load the nib
        guard let addEventView = Bundle.main.loadNibNamed("AddEvent", owner: self, options: nil)?.first as? AddEvent else {
            print("Failed to load AddEvent nib.")
            return
        }
        
        // Set the size and center position for the EditEventView
        let width: CGFloat = self.view.frame.width * 0.8 // 80% of screen width
        let height: CGFloat = self.view.frame.height * 0.5 // 50% of screen height
        addEventView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        addEventView.center = backgroundView.center
        // Customize the view (optional: rounded corners, shadow)
        addEventView.layer.cornerRadius = 10
        addEventView.layer.masksToBounds = true
        addEventView.delegate = self

        addEventView.reminderBTn.currentTitle ?? ""
       //print("Group ID passed to AddEvent: \(addEventView.groupId)")
        // Add the EditEventView to the background view
        backgroundView.addSubview(addEventView)
        
        self.view.addSubview(backgroundView)
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
           startDate: formatDate(event.startDate),  // Convert to DD-MM-YYYY
           endDate: formatDate(event.endDate),      // Convert to DD-MM-YYYY
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
//pass data to updateEvent
    func showEditEventView(with event: Event) {
        // Create a semi-transparent background view
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Transparent overlay
        
        // Add tap gesture recognizer to detect taps outside the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditEventView(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        if let editEventView = Bundle.main.loadNibNamed("EditEvent", owner: self, options: nil)?.first as? EditEvent {
            // Pass the event data
            editEventView.event = event
            editEventView.reloadInputViews()
//            editEventView.groupId = self.groupId!
            // Set the size and center position for the EditEventView
            let width: CGFloat = self.view.frame.width * 0.8 // 80% of screen width
            let height: CGFloat = self.view.frame.height * 0.5 // 50% of screen height
            editEventView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            editEventView.center = backgroundView.center
            
            // Customize the view (optional: rounded corners, shadow)
            editEventView.layer.cornerRadius = 10
            editEventView.layer.masksToBounds = true
            editEventView.delegate = self
            self.selectedReminder = editEventView.reminderBTn.currentTitle ?? ""
            editEventView.groupId = self.groupId ?? ""
            // Add the EditEventView to the background view
            backgroundView.addSubview(editEventView)
        }
        
        // Add the background view to the main view
        self.view.addSubview(backgroundView)
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
        if let event = self.eventEditToBe {
            editEvent(
                eventid: selectedEventId,
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
                        // Update the old event data with the new details
                        self.event?.startDate = event.startDate
                        self.event?.startTime = event.startTime
                        self.event?.endDate = event.endDate
                        self.event?.endTime = event.endTime
                        self.event?.title = event.title
                        self.event?.venue = event.venue
                        self.event?.reminder = self.selectedReminder ?? ""

                        // Reload your tableView or collectionView or other UI components that display event data
                        self.calendarTableView.reloadData() // Example for tableView reload

                        let alert = UIAlertController(title: "Success", message: "Event edited successfully", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("Error: \(errorMessage ?? "Unknown error")")
                    }
                }
            }
        } else {
            print("Event is nil")
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
        guard let token = TokenManager.shared.getToken() else {
            completion(false, "Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/calendar/\(eventid)/events/edit"
        
        guard let url = URL(string: urlString) else {
            completion(false, "Invalid URL")
            return
        }
        
        // Create request body using old values if new values are not provided
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
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            print("API Request URL: \(urlString)")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, "Request Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "No response from server")
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        completion(false, "Failed to edit event. Server Response: \(responseString)")
                    } else {
                        completion(false, "Failed to edit event. Status Code: \(httpResponse.statusCode)")
                    }
                    return
                }
                
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        print("API Response Data: \(jsonResponse ?? [:])")
                    } catch {
                        print("Error parsing response: \(error.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(true, nil)
                    self.calendarTableView.reloadData()
                }
            }
            task.resume()
        } catch {
            completion(false, "Error encoding request body: \(error.localizedDescription)")
        }
    }

}

