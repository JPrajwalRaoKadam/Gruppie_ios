//
//  AmountPaymentVC.swift
//  loginpage
//
//  Created by apple on 24/02/25.
//

import UIKit
import Easebuzz

class AmountPaymentVC: UIViewController, PayWithEasebuzzCallback {

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var payableTableView: UITableView!
    @IBOutlet weak var gpayButton: UIButton!
    @IBOutlet weak var payableAmount: UILabel!
    @IBOutlet weak var bcbutton: UIButton!
    
    var demandTotalAmount: String?
    var dueAmpount: String?
    
    var feePaymentData: FeePaymentData?
    let feeTypes = ["Tution Fee", "Management Fee"]
    
    var groupID : String?
    var teamID : String?
    var userID : String?
    var bearerToken = TokenManager.shared.getToken()
    
    var studentName: String?
    var customerMobileNo: String?
    
    var redirectionUrl: String?
    var selectedIndex: Int? // Store selected index
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        payableTableView.layer.cornerRadius = 10
        enableKeyboardDismissOnTap()
        // Register the cell
        payableTableView.register(UINib(nibName: "PayablesTableViewCell", bundle: nil), forCellReuseIdentifier: "PayablesTableViewCell")
        
        // Set the table view delegate and data source
        payableTableView.delegate = self
        payableTableView.dataSource = self
        
        studentNameLabel.text = feePaymentData?.name
        gpayButton.layer.borderWidth = 1 // Thin border
        gpayButton.layer.borderColor = UIColor.black.cgColor
        gpayButton.layer.cornerRadius = 8 // Adjust as needed
        gpayButton.clipsToBounds = true
    }

    // MARK: - Easebuzz Callback
    func PEBCallback(data: [String : AnyObject]) {
        let paymentResponse = data["payment_response"]

        if let responseDict = paymentResponse as? [String: Any] {
            print("JSON response: \(responseDict)")
        } else if let responseString = paymentResponse as? String {
            print("String response: \(responseString)")
        } else {
            print("No valid response")
        }

        if let result = data["result"] as? String {
            print("Payment Result: \(result)")
        }
    }
    
    // MARK: - Payment API Call
    func makePaymentRequest(groupID: String, teamID: String, userID: String, bearerToken: String) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupID)/team/\(teamID)/user/\(userID)/easebuzz/pay"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
                    "amount": payableAmount.text ?? "0.00",
                    "studentName": self.studentName ?? "Unknown",
                    "customerMobileNo": self.customerMobileNo ?? "Unknown",
                    "returnURL": APIManager.shared.baseURL + "groups/661643d90dde2b4c5da9fbe5/team/661643d90dde2b4c5da9fbe6/user/661cbd6d84e842a6034715a9/atom/response?type=easebuzz",
                    "frontendUrl": "http://localhost:4200/activity/easebuzz/661643d90dde2b4c5da9fbe5"
                ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error in JSON serialization: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error in API request: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(EasebuzzPaymentResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.initiateEasebuzzPayment(redirectionUrl: decodedResponse.data)
                    self?.redirectionUrl = decodedResponse.redirectionUrl
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    // MARK: - Initiate Easebuzz Payment
    func initiateEasebuzzPayment(redirectionUrl: String) {
        let orderDetails = [
            "access_key": redirectionUrl,
            "pay_mode": "production" // Change to "test" in a live environment
        ] as [String: String]

        let payment = Payment(customerData: orderDetails)
        let paymentValid = payment.isValid().validity

        if !paymentValid {
            print("Invalid payment details")
        } else {
            PayWithEasebuzz.setUp(pebCallback: self)
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        }
    }

    // MARK: - Button Actions
    @IBAction func payButtonAction(_ sender: Any) {
        makePaymentRequest(groupID: groupID ?? "", teamID: teamID ?? "", userID: userID ?? "", bearerToken: bearerToken ?? "")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gpayButtonAction(_ sender: Any) {
        // Implement Google Pay functionality if needed
    }
}

// MARK: - Table View Delegate & Data Source
extension AmountPaymentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeTypes.count
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PayablesTableViewCell", for: indexPath) as? PayablesTableViewCell else {
//            return UITableViewCell()
//        }
//
//        let isChecked = indexPath.row == selectedIndex
//        cell.feeType.text = feeTypes[indexPath.row]
//        cell.configureCell(isChecked: isChecked, payAmount: demandTotalAmount ?? "", dueAmount: dueAmpount ?? "")
//
//        cell.checkBoxAction = { [weak self] in
//            guard let self = self else { return }
//
//            self.selectedIndex = indexPath.row
//            self.payableAmount.text = (dueAmpount ?? "0") + ".0001"
//            tableView.reloadData() // Reload table to update UI
//        }
//
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard feeTypes.indices.contains(indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "PayablesTableViewCell", for: indexPath) as? PayablesTableViewCell else {
            return UITableViewCell()
        }

        let isChecked = true
        cell.feeType.text = feeTypes[indexPath.row]

        var payAmount = "0"
        var dueAmount = "0"

        // First cell → 0 values, others → real values
        if indexPath.row != 0 {
            payAmount = demandTotalAmount ?? "0"
            dueAmount = dueAmpount ?? "0"
        }

        // Configure the cell (always checked)
        cell.configureCell(isChecked: isChecked, payAmount: payAmount, dueAmount: dueAmount)

        // ✅ After all cells are loaded, calculate total due + 0.0001
        DispatchQueue.main.async {
            var totalDue: Double = 0.0

            // If you only have 2 cells (first 0 + second actual)
            totalDue += Double("0") ?? 0.0
            totalDue += Double(self.dueAmpount ?? "0") ?? 0.0

            // Add ₹0.0001 to total
            totalDue += 0.0001

            self.payableAmount.text = String(format: "%.4f", totalDue)
        }

        return cell
    }

}
