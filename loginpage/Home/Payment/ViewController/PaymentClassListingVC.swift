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
    var currentRole: String?
    var subjects: [SubjectData] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        classTableView.delegate = self
        classTableView.dataSource = self

        classTableView.register(UINib(nibName: "ClassesTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassesTableViewCell")

        let token = TokenManager.shared.getToken() ?? ""
        
        fetchFeeReport(withToken: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let feeReport):
                print("Fee Report fetched successfully!")
                self.feeReport = feeReport
                self.studentData = feeReport.studentData
                self.teamData = feeReport.teamData

                DispatchQueue.main.async {
                    self.classTableView.reloadData()
                    self.updateUI()
                    
                    // ✅ If user is parent, push next VC and hide current
                    if self.currentRole?.lowercased() == "parent" {
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.navigateToStudentListingForParent(at: indexPath)
                    }
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
        if let teamData = teamData?[indexPath.row] {
            cell.configurePayment(with: teamData)
            cell.nameLabel.text = teamData.className
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToStudentListingForParent(at: indexPath)
    }

    
    private func navigateToStudentListingForParent(at indexPath: IndexPath) {
        guard let selectedTeam = teamData?[indexPath.row] else {
            print("❌ Could not find team at index \(indexPath.row)")
            return
        }

        // Extract subject name from firstSubject (optional – you can adjust this logic)
        let trimmedName: String
        if let firstSubject = subjects.first,
           let range = firstSubject.name.range(of: #"(?<=\().*?(?=\))"#, options: .regularExpression) {
            trimmedName = String(firstSubject.name[range])
        } else {
            trimmedName = selectedTeam.className ?? ""
        }

        print("✅ Selected Team: \(selectedTeam.className)")
        print("📋 All teamData class names:")
        teamData?.forEach { print("→ \($0.className)") }

        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        if let studentListingVC = storyboard.instantiateViewController(withIdentifier: "StudentListingVC") as? StudentListingVC {

            studentListingVC.groupId = self.groupId
            studentListingVC.subjects = self.subjects
            studentListingVC.currentRole = self.currentRole
            studentListingVC.teamId = selectedTeam.classId

            // 👇 Force view load before setting label
            _ = studentListingVC.view
            studentListingVC.className.text = selectedTeam.className

            // Replace current VC
            var viewControllers = self.navigationController?.viewControllers ?? []
            viewControllers.removeLast()
            viewControllers.append(studentListingVC)
            self.navigationController?.setViewControllers(viewControllers, animated: false)
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

