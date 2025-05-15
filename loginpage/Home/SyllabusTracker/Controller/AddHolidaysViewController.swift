//import UIKit
//
//class AddHolidaysViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddNewHolidayDelegate {
//    
//    @IBOutlet weak var holidaysList: UILabel!
//    @IBOutlet weak var addTitle: UILabel!
//    @IBOutlet weak var addDate: UILabel!
//    @IBOutlet weak var submit: UIButton!
//    @IBOutlet weak var holiday: UITableView!
//    
//    var groupId: String = ""
//    var holidays: [Holiday] = []
//    var holidayAddCount = 1
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        holiday.delegate = self
//        holiday.dataSource = self
//        submit.layer.cornerRadius = 10
//        submit.clipsToBounds = true
//        
//        holiday.register(UINib(nibName: "AddNewHoliday", bundle: nil), forCellReuseIdentifier: "AddNewHoliday")
//        fetchHolidays()
//    }
//        
//    @IBAction func submit(_ sender: Any) {
//        addHolidayToServer()
//    }
//    
//    func didTapAddMore() {
//            holidayAddCount += 1 // Increment count
//            holiday.reloadData()  // Reload table to reflect changes
//        }
//    
//    func fetchHolidays() {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token not found")
//            return
//        }
//        let urlString = APIManager.shared.baseURL +  "groups/\(groupId)/get/calendar/events?year=2025"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error fetching holidays: \(error)")
//                return
//            }
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            do {
//                  if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                     let dataArray = json["data"] as? [[String: Any]] {
//                      
//                     self.holidays = dataArray.compactMap { dictionary in
//                          guard let year = dictionary["year"] as? Int,
//                                let title = dictionary["title"] as? String,
//                                let startDate = dictionary["startDate"] as? String else {
//                              print("Missing data in JSON: \(dictionary)") // Debugging
//                              return nil
//                          }
//                          
//                          // Initialize Holiday safely
//                          return Holiday(year: year, title: title, startDate: startDate, endDate: dictionary["endDate"] as? String ?? "")
//                      }
//
//                    
//                    DispatchQueue.main.async {
//                        self.holiday.reloadData()
//                    }
//                } else {
//                    print("Invalid JSON structure")
//                }
//            } catch {
//                print("Error parsing JSON: \(error)")
//            }
//        }
//        task.resume()
//    }
//    func addHolidayToServer() {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token not found")
//            return
//        }
//
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/add/calendar/events"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Prepare holiday data in the required format
//        let holidaysToSend = holidays.map { holiday in
//            return [
//                "startDate": holiday.startDate,
//                "endDate": holiday.endDate,
//                "title": holiday.title
//            ]
//        }
//
//        let requestBody: [String: Any] = [
//            "calendarData": holidaysToSend
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//        } catch {
//            print("Error encoding JSON: \(error)")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error adding holiday: \(error)")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("HTTP Status Code: \(httpResponse.statusCode)")
//            }
//
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            // Print raw response for debugging
//            if let rawResponse = String(data: data, encoding: .utf8) {
//                print("Raw Response: \(rawResponse)")
//            }
//
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print("Response from API: \(jsonResponse)")
//                
//                // Handle successful response
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Success", message: "Holidays added successfully!", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                        self.navigationController?.popViewController(animated: true)
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                }
//
//            } catch {
//                print("Error parsing JSON response: \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//    }
//
//
////    func addHolidayToServer() {
////        guard let token = TokenManager.shared.getToken() else {
////            print("Token not found")
////            return
////        }
////
////        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/add/calendar/events"
////        guard let url = URL(string: urlString) else {
////            print("Invalid URL")
////            return
////        }
////
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
////        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
////
////        // Prepare holiday data
////        let holidaysToSend = holidays.map { holiday in
////            return [
////                "startDate": holiday.startDate,
////                "endDate": holiday.endDate,
////                "title": holiday.title
////            ]
////        }
////
////        let requestBody: [String: Any] = [
////            "calendarData": holidaysToSend
////        ]
////
////        do {
////            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
////        } catch {
////            print("Error encoding JSON: \(error)")
////            return
////        }
////
////        let task = URLSession.shared.dataTask(with: request) { data, response, error in
////            if let error = error {
////                print("Error adding holiday: \(error)")
////                return
////            }
////
////            if let httpResponse = response as? HTTPURLResponse {
////                print("HTTP Status Code: \(httpResponse.statusCode)")
////            }
////
////            guard let data = data else {
////                print("No data received")
////                return
////            }
////
////            if let rawResponse = String(data: data, encoding: .utf8) {
////                print("Raw Response: \(rawResponse)")
////            }
////
////            do {
////                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
////                print("Response from API: \(jsonResponse)")
////            } catch {
////                print("Error parsing JSON response: \(error.localizedDescription)")
////            }
////        }
////        task.resume()
////    }
//    
//    // MARK: - TableView DataSource Methods
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return holidays.count  // Dynamic holiday list
//        } else {
//            return holidayAddCount  // Only 1 row in section 1
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewHoliday", for: indexPath) as? AddNewHoliday {
//            
//            if indexPath.section == 0 {
//                // Section 0: Display holiday data
//                let holiday = holidays[indexPath.row]
//                cell.holidayTitle.text = holiday.title
//                cell.holidaydate.text = holiday.startDate
//                cell.holidayTitle.isUserInteractionEnabled = false
//                cell.holidaydate.isUserInteractionEnabled = false
//
//                cell.addMore.isHidden = true
//            } else {
//                // Section 1: Display static row (without holidays array)
//                cell.holidayTitle.text = ""
//                cell.holidaydate.text = ""
//                cell.addMore.isHidden = false
//                cell.delegate = self
//            }
//            
//            return cell
//        }
//        return UITableViewCell()
//    }
//    
//    // MARK: - TableView Delegate Methods
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//                return 50  // Section 0 (Dynamic Holiday List)
//            } else {
//                return 90  // Section 1 (Static Row)
//            }
//    }
//    
////    @IBAction func backButtonTapped(_ sender: UIButton) {
////        self.dismiss(animated: true, completion: nil)
////    }
//    @IBAction func backButtonTapped(_ sender: UIButton) {
//        if let navigationController = self.navigationController {
//            navigationController.popViewController(animated: true) // If pushed, pop the VC
//        } else {
//            self.dismiss(animated: true, completion: nil) // If presented modally, dismiss
//        }
//    }
//
//}
