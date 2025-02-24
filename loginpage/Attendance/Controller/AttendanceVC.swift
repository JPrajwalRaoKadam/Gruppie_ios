//
//  AttendanceVC.swift
//  loginpage
//
//  Created by apple on 10/02/25.
//

    import UIKit

    class AttendanceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
        @IBOutlet weak var TableView: UITableView!
        @IBOutlet weak var name: UILabel!
        @IBOutlet weak var setting: UIButton!
        @IBOutlet weak var curDate: UIButton!
        var groupId: String?
        var classDetails: [[String: Any]] = []
        
        @IBAction func backButton(_ sender: UIButton) {
            navigationController?.popViewController(animated: true)
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            
            TableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
            TableView.dataSource = self
            TableView.delegate = self
            TableView.layer.cornerRadius = 15
            TableView.layer.masksToBounds = true
            fetchAttendanceData()
        }
        
        func fetchAttendanceData() {
                guard let groupId = groupId else {
                    print("Group ID is missing")
                    return
                }
                
                guard let token = TokenManager.shared.getToken() else {
                    print("Token not found")
                    return
                }
                
                let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/attendance/get?date=20-02-2024&type=attendance"
                guard let url = URL(string: urlString) else {
                    print("Invalid URL")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error fetching attendance data: \(error)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        print("Invalid response from server")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data received")
                        return
                    }
                    if let rawResponse = String(data: data, encoding: .utf8) {
                              print("Raw Response of attendance: \(rawResponse)")
                          }
                    
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let attendanceData = jsonResponse["data"] as? [[String: Any]] {
                            
                            // Remove unnecessary data and store only required values
                            self.classDetails = attendanceData.map { student in
                                return [
                                    "name": student["name"] as? String ?? "",
                                    "image": student["image"] as? String ?? ""
                                ]
                            }
                            
                            DispatchQueue.main.async {
                                self.TableView.reloadData()
                            }
                        }
                    } catch {
                        print("Error parsing JSON response: \(error.localizedDescription)")
                    }
                }
                task.resume()
            }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return classDetails.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath) as? AttendanceTableViewCell else {
                fatalError("Cell could not be dequeued")
            }
            let className = classDetails[indexPath.row]
            cell.classLabel.text = className["name"] as? String ?? "Unknown"
            print("Class Name: \(cell.classLabel.text ?? "")")
            return cell
        }

//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let selectedStudent = studentDetails[indexPath.row]
//                DispatchQueue.main.async {
//                    let storyboard = UIStoryboard(name: "Student", bundle: nil)
//                    if let studentDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentDetailViewController") as? StudentDetailViewController
//                        
//                        self.navigationController?.pushViewController(studentDetailVC, animated: true)
//                    }
//                }
    
    }
