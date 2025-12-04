import UIKit

class StudentListingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var demandAmount: UILabel!
    @IBOutlet weak var concessionAmount: UILabel!
    @IBOutlet weak var collectionAmount: UILabel!
    @IBOutlet weak var balenceAmount: UILabel!
    @IBOutlet weak var overdueAmount: UILabel!
    @IBOutlet weak var fineAmount: UILabel!
    @IBOutlet weak var overAllAmountView: UIView!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var customContainerView: UIView!

    var groupId: String?
    var teamId: String?
    var studentFees: [StudentFinancialData] = []
    var filteredStudentFees: [StudentFinancialData] = []
    var currentRole: String?
    var subjects: [SubjectData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        studentTableView.layer.cornerRadius = 10
        enableKeyboardDismissOnTap()
        studentTableView.register(UINib(nibName: "ClassesTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassesTableViewCell")
        customContainerView.layer.cornerRadius = 10

        fetchStudentFeeList(token: TokenManager.shared.getToken() ?? "", groupId: groupId ?? "", teamId: teamId ?? "") { result in
            switch result {
            case .success(let data):
                print("Fetched Data: \(data)")
                DispatchQueue.main.async {
                    self.studentFees = data

                 if self.currentRole?.lowercased() == "parent" {
                        self.filteredStudentFees = self.subjects.compactMap { subject in
                            let trimmedName = subject.name.components(separatedBy: " (").first ?? subject.name
                            print("🔍 Looking for exact match for: \(trimmedName)")
                            
                            if let matchingStudent = data.first(where: { $0.name == trimmedName }) {
                                print("✅ Found match: \(matchingStudent.name)")
                                return matchingStudent
                            } else {
                                print("❌ No match found for: \(trimmedName)")
                                return nil
                            }
                        }

                        print("🎯 Filtered students: \(self.filteredStudentFees.map { $0.name })")
                    }

                    self.studentTableView.reloadData()
                    self.updateUI()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }


    func updateUI() {
        
        let studentFees = currentRole?.lowercased() == "parent" ? filteredStudentFees : studentFees
        
        let totalFee = studentFees.reduce(0) { $0 + $1.totalFee }
        let totalConcession = studentFees.reduce(0) { $0 + $1.totalConcessionAmount }
        let totalAmountPaid = studentFees.reduce(0) { $0 + $1.totalAmountPaid }
        let totalBalance = studentFees.reduce(0) { $0 + $1.totalBalanceAmount }
        let totalOverdue = studentFees.reduce(0) { $0 + $1.totalOverDueAmount }
        let totalFine = studentFees.reduce(0) { $0 + $1.totalFineAmount }

        demandAmount.text = "\(totalFee)"
        concessionAmount.text = "\(totalConcession)"
        collectionAmount.text = "\(totalAmountPaid)"
        balenceAmount.text = "\(totalBalance)"
        overdueAmount.text = "\(totalOverdue)"
        fineAmount.text = "\(totalFine)"
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentRole?.lowercased() == "parent" {
            return filteredStudentFees.count
        } else {
            return studentFees.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassesTableViewCell", for: indexPath) as! ClassesTableViewCell
        
        if currentRole?.lowercased() == "parent" {
            let subject = filteredStudentFees[indexPath.row]
            cell.nameLabel.text = subject.name
        } else {
            let student = studentFees[indexPath.row]
            cell.configure(with: student)
            cell.nameLabel.text = student.name
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        
        if let makeFeePaymentVC = storyboard.instantiateViewController(withIdentifier: "MakeFeePaymentVC") as? MakeFeePaymentVC {
            makeFeePaymentVC.groupId = self.groupId
            makeFeePaymentVC.teamId = self.teamId
            
            if currentRole?.lowercased() == "parent" {
                let subject = subjects[indexPath.row]
                let trimmedName = subject.name.components(separatedBy: " (").first ?? subject.name

                print("Trimmed subject name: \(trimmedName)")
                            print("Student names in studentFees:")
                            for student in studentFees {
                                print("-------- \(student.name)")
                            }
                
                if let student = studentFees.first(where: { $0.name == trimmedName }) {
                    makeFeePaymentVC.userId = student.userId
                    makeFeePaymentVC.intallments = student.installments
                }
                
            } else {
                let student = studentFees[indexPath.row]
                makeFeePaymentVC.userId = student.userId
                makeFeePaymentVC.intallments = student.installments
            }

            navigationController?.pushViewController(makeFeePaymentVC, animated: true)
        }
    }

    
    func fetchStudentFeeList(token: String, groupId: String, teamId: String, completion: @escaping (Result<[StudentFinancialData], Error>) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/fee/list"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                
                if decodedResponse.data.isEmpty {
                    completion(.failure(NSError(domain: "No data available", code: 0, userInfo: nil)))
                } else {
                    completion(.success(decodedResponse.data))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}


