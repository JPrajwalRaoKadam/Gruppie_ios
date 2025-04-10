//
//  DailySyllubasTrackerVC.swift
//  loginpage
//
//  Created by apple on 19/03/25.
//

//import UIKit
//
//class DailySyllubasTrackerVC: UIViewController, UITableView, UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "DailySyllubasTrackerTableViewCell", bundle: nil), forCellReuseIdentifier: "DailySyllubasTrackerTableViewCell")
//
//        // Do any additional setup after loading the view.
//    }
//    
//
//}

import UIKit

class DailySyllabusTrackerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var syllabusData: [DailySyllabus] = [] // Store decoded data
    var groupId: String = ""
    var teamId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TEAMid DT: \(teamId)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DailySyllabusTrackerTableViewCell", bundle: nil), forCellReuseIdentifier: "DailySyllabusTrackerTableViewCell")
        fetchDailySyllabus()
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Fetch Syllabus Data API Call
    func fetchDailySyllabus() {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let currentDate = getCurrentDate()
        
        let urlString = "https://api.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/plan/get?date=\(currentDate)"
//        let urlString = "https://api.gruppie.in/api/v1/groups/62b32f1197d24b31c4fa7a1a/team/62b32f1397d24b31c41bbc2d/plan/get?date=20-03-2025"
        print("Fetching syllabus data from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print raw API response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response of dailySy: \(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {

                    var syllabusList: [DailySyllabus] = []

                    for item in dataArray {
                        let topic = item["topicName"] as? String ?? "N/A"
                        let chapter = item["chapterName"] as? String ?? "N/A"
                        let fromDate = item["fromDate"] as? String ?? "N/A"
                        let toDate = item["toDate"] as? String ?? "N/A"
                        let actualStart = item["actualStartDate"] as? String ?? "N/A"
                        let actualEnd = item["actualEndDate"] as? String ?? "N/A"

                        let syllabus = DailySyllabus(
                            topicName: topic,
                            chapterName: chapter,
                            fromDate: fromDate,
                            toDate: toDate,
                            actualStartDate: actualStart,
                            actualEndDate: actualEnd
                        )

                        syllabusList.append(syllabus)
                    }

                    DispatchQueue.main.async {
                        self.syllabusData = syllabusList
                        self.tableView.reloadData()
                    }

                } else {
                    print("Failed to decode JSON structure")
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    // MARK: - Helper Method to Get Current Date
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return syllabusData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailySyllabusTrackerTableViewCell", for: indexPath) as? DailySyllabusTrackerTableViewCell else {
            return UITableViewCell()
        }

        let data = syllabusData[indexPath.row]
        cell.configure(with: data)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
        }
}

