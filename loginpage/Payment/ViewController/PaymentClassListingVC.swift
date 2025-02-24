//
//  PaymentClassListingVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 06/02/25.
//

import UIKit

class PaymentClassListingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var demandAmount: UILabel!
    @IBOutlet weak var concessionAmount: UILabel!
    @IBOutlet weak var collectionAmount: UILabel!
    @IBOutlet weak var balenceAmount: UILabel!
    @IBOutlet weak var overdueAmount: UILabel!
    @IBOutlet weak var fineAmount: UILabel!
    
    var groupId: String?
    var feeReport: PaymentResponse?
    // Update type to store team data instead of the entire PaymentResponse
    let totalFee: Double? = nil
    var studentData: [StudentDataa]? = nil
    var teamData: [TeamData]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classTableView.delegate = self
        classTableView.dataSource = self
        
        // Register your custom cell
        classTableView.register(UINib(nibName: "ClassesTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassesTableViewCell")
        
        let token = TokenManager.shared.getToken() ?? ""
        
        fetchFeeReport(withToken: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let feeReport):
                print("Fee Report fetched successfully!")
                print("Total Fee: \(feeReport.totalFee)")
                self.feeReport = feeReport
                // Save the team data from the API response to your teamDataList
                self.studentData = feeReport.studentData
                self.teamData = feeReport.teamData
                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self.classTableView.reloadData()
                    self.updateUI()
                }
            case .failure(let error):
                print("Error fetching fee report: \(error.localizedDescription)")
            }
        }

    }
    
    func updateUI() {
        demandAmount.text = "\(feeReport?.totalFee ?? 0)"
        concessionAmount.text = "\(feeReport?.totalConcession ?? 0)"
        collectionAmount.text = "\(feeReport?.totalAmountPaid ?? 0)"
        balenceAmount.text = "\(feeReport?.totalBalance ?? 0)"
        overdueAmount.text = "\(feeReport?.totalOverDue ?? 0)"
        fineAmount.text = "\(feeReport?.fineAmount ?? 0)"
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("counttt...\(teamData?.count)")
        return teamData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassesTableViewCell", for: indexPath) as! ClassesTableViewCell
        let teamData = teamData?[indexPath.row]
        cell.className.text = teamData?.className
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        let teamData = teamData?[indexPath.row]
           if let studentListingVC = storyboard.instantiateViewController(withIdentifier: "StudentListingVC") as? StudentListingVC {
               studentListingVC.groupId = self.groupId
               studentListingVC.teamId = teamData?.classId
               DispatchQueue.main.async {
                   studentListingVC.className.text = teamData?.className
               }
               navigationController?.pushViewController(studentListingVC, animated: true)
           }
    }
    
    // MARK: - API Call
    func fetchFeeReport(withToken token: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        // Safely unwrap groupId and create the URL string with interpolation.
        guard let groupId = groupId,
              let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/fee/report/get") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add the token to the request header.
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create a URLSession data task.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // Print the raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(jsonString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }

            do {
                let decoder = JSONDecoder()
                let feeReport = try decoder.decode(PaymentResponse.self, from: data)
                print(feeReport.installments ?? "No installments data available")
                completion(.success(feeReport))
            } catch {
                print("Decoding Error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
}

