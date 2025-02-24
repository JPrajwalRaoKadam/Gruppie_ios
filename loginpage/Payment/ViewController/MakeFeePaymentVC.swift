//
//  MakeFeePaymentVC.swift
//  loginpage
//
//  Created by apple on 19/02/25.
//

import UIKit

class MakeFeePaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var paymentTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var receiptLabel: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var demandAmount: UILabel!
    @IBOutlet weak var concessionAmount: UILabel!
    @IBOutlet weak var collectionAmount: UILabel!
    @IBOutlet weak var balenceAmount: UILabel!
    @IBOutlet weak var overdueAmount: UILabel!
    @IBOutlet weak var fineAmount: UILabel!
    var groupId: String?
    var teamId: String?
    var userId: String?
    var feePaymentData: FeePaymentData?
    var intallments: [PaymentInstallment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register table view cells
        paymentTableView.register(UINib(nibName: "AmoutTableViewCell", bundle: nil), forCellReuseIdentifier: "AmoutTableViewCell")
        paymentTableView.register(UINib(nibName: "InstallmentTableViewCell", bundle: nil), forCellReuseIdentifier: "InstallmentTableViewCell")
        
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        
        fetchConsolidatedFeeData(groupId: groupId ?? "",
                                 teamId: teamId ?? "",
                                 userId: userId ?? "") { feeData in
            DispatchQueue.main.async {
                if let feeData = feeData {
                    self.studentName.text = feeData.name
                    self.feePaymentData = feeData
                    self.paymentTableView.reloadData()
                    self.updateUI()
                } else {
                    print("Failed to fetch fee data")
                }
            }
        }

    }
    
    func updateUI() {
        demandAmount.text = "\(feePaymentData?.feeData.totalFee ?? 0)"
        concessionAmount.text = "\(feePaymentData?.feeData.totalConcessionAmount ?? 0)"
        collectionAmount.text = "\(feePaymentData?.feeData.totalAmountPaid ?? 0)"
        balenceAmount.text = "\(feePaymentData?.feeData.totalBalanceAmount ?? 0)"
        overdueAmount.text = "\(feePaymentData?.feeData.totalOverDueAmount ?? 0)"
        fineAmount.text = "\(feePaymentData?.feeData.totalFineAmount ?? 0)"
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func paymentTypeSegmentChanged(_ sender: UISegmentedControl) {
        paymentTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feePaymentData?.feeData.feePaidDetails.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if paymentTypeSegmentControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmoutTableViewCell", for: indexPath) as! AmoutTableViewCell
            self.receiptLabel.isHidden = false
            
            // Ensure feePaidDetails is not nil and has enough data
            if let paidDate = feePaymentData?.feeData.feePaidDetails[safe: indexPath.row] {
                cell.dateLabel.text = paidDate.paidDate
                cell.amountLabel.text = "\(paidDate.amountPaidWithFine)"
            } else {
                cell.dateLabel.text = "--"
                cell.amountLabel.text = "--"
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstallmentTableViewCell", for: indexPath) as! InstallmentTableViewCell
            self.receiptLabel.isHidden = true
            let installment = self.intallments[indexPath.row]
            cell.dateLabel.text = installment.date
            cell.completedLabel.text = installment.status
            cell.amountLabel.text = installment.amount
            return cell
        }
    }

    
    func fetchConsolidatedFeeData(groupId: String, teamId: String, userId: String, completion: @escaping (FeePaymentData?) -> Void) {
        let urlString = "https://gcc.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/user/\(userId)/consolidate/fee/get/new"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let decodedData = try JSONDecoder().decode(FeePaymentData.self, from: data)
                completion(decodedData)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }

}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
