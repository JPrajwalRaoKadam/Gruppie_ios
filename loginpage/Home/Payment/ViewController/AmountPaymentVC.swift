import UIKit
import Easebuzz

class AmountPaymentVC: UIViewController, PayWithEasebuzzCallback {
    
    // MARK: - OUTLETS
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var payableTableView: UITableView!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    
    // MARK: - VARIABLES
    var studentId: String?
    var bearerToken = SessionManager.useRoleToken
    var groupAcademicYearId: String = ""
    
    var easebuzzResponse: [String: Any]?
    var demands: [PaymentDemand] = []
    var classId: Int = 0
    var paymentMode: String = "GATEWAY"
    var selectedAmounts: [Int: Double] = [:]
    var onPaymentSuccess: (() -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        fetchPaymentView()
        enableKeyboardDismissOnTap()
    }
    
    func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        payableTableView.layer.cornerRadius = 10
    }
    
    func setupTable() {
        payableTableView.delegate = self
        payableTableView.dataSource = self
        payableTableView.register(UINib(nibName: "PayablesTableViewCell", bundle: nil), forCellReuseIdentifier: "PayablesTableViewCell")
    }
    
    // MARK: - ACTIONS
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func payButton(_ sender: Any) {
        if selectedAmounts.isEmpty {
            showAlert(message: "Please select at least one fee")
            return
        }
        
        for (index, amount) in selectedAmounts {
            let demand = demands[index]
            let balance = demand.balance ?? 0
            let fine = demand.fine ?? 0
            
            if amount > balance || (amount + fine) > balance {
                showAlert(message: "Invalid amount selected")
                return
            }
        }
        
        let alert = UIAlertController(title: "Select Payment Mode", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Online Payment", style: .default) { _ in
            self.paymentMode = "GATEWAY"
            self.initiatePaymentGateway()
        })
        alert.addAction(UIAlertAction(title: "Cash Payment", style: .default) { _ in
            self.paymentMode = "CASH"
            self.makeStudentFeePaymentRequest()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showAlert(message: String, onOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOk?() })
        present(alert, animated: true)
    }
}

// MARK: - FETCH
extension AmountPaymentVC {
    func fetchPaymentView() {
        guard let token = bearerToken, let studentId = studentId else { return }
        
        let academicYearId = groupAcademicYearId.isEmpty ? "142" : groupAcademicYearId
        
        APIManager.shared.request(
            endpoint: "fees/students/\(studentId)/payment-view",
            method: .get,
            queryParams: ["groupAcademicYearId": academicYearId],
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentViewResponse, APIManager.APIError>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let data = response.data
                    self.demands = data?.demands ?? []
                    self.studentNameLabel.text = data?.student?.fullName
                    self.classId = Int(data?.student?.classId ?? "0") ?? 0
                    self.payableTableView.reloadData()
                }
            case .failure(let error):
                print("❌ API Error:", error)
            }
        }
    }
}

// MARK: - PAYMENT FLOW
extension AmountPaymentVC {
    func initiatePaymentGateway() {
        guard let token = bearerToken else { return }
        guard let body = buildPaymentBody(includeIdempotency: true) else { return }
        
        APIManager.shared.request(
            endpoint: "payment-gateway/initiate",
            method: .post,
            queryParams: nil,
            body: body,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentGatewayResponse, APIManager.APIError>) in
            switch result {
            case .success(let response):
                if let redirectUrl = response.data?.redirectUrl {
                    let token = redirectUrl.components(separatedBy: "/pay/").last ?? ""
                    DispatchQueue.main.async {
                        self.startEasebuzz(token: token)
                    }
                }
            case .failure(let error):
                print("❌ Gateway Error:", error)
            }
        }
    }
    
    func startEasebuzz(token: String) {
        let payment = Payment(customerData: ["access_key": token, "pay_mode": "test"])
        if payment.isValid().validity {
            PayWithEasebuzz.setUp(pebCallback: self)
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        }
    }
}

// MARK: - EASEBUZZ CALLBACK
extension AmountPaymentVC {
    func PEBCallback(data: [String: AnyObject]) {
        print("Easebuzz:", data)
        
        guard let paymentResponse = data["payment_response"] as? [String: Any],
              let status = paymentResponse["status"] as? String,
              let txnid = paymentResponse["txnid"] as? String else {
            showAlert(message: "Invalid payment response")
            return
        }
        
        // Store the complete response
        easebuzzResponse = data
        
        if status.lowercased() == "success" {
            // Call confirm first
            confirmPayment(txnId: txnid)
        } else {
            showAlert(message: "Payment Failed or Cancelled")
        }
    }
    
    func confirmPayment(txnId: String) {
        guard let token = bearerToken,
              let easebuzzResponse = easebuzzResponse,
              let paymentResponse = easebuzzResponse["payment_response"] as? [String: Any] else {
            showAlert(message: "Missing payment response")
            return
        }
        
        // Create a clean dictionary without any NSNull values
        var cleanResponse: [String: Any] = [:]
        for (key, value) in paymentResponse {
            if !(value is NSNull) {
                cleanResponse[key] = value
            }
        }
        
        do {
            // Use .withoutEscapingSlashes for cleaner JSON
            let jsonData = try JSONSerialization.data(withJSONObject: cleanResponse, options: [])
            
            // Debug print
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Sending to confirm endpoint:", jsonString)
            }
            
            APIManager.shared.request(
                endpoint: "payment-gateway/confirm",
                method: .post,
                queryParams: nil,
                bodyData: jsonData,
                headers: [
                    "Authorization": "Bearer \(token)",
                    "Content-Type": "application/json"
                ]
            ) { (result: Result<GenericResponse, APIManager.APIError>) in
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        print("✅ Confirm Response:", response)
                        
                        if response.success == true {
                            // After confirm succeeds, verify payment
                            self.verifyPayment(txnId: txnId)
                        } else {
                            // If confirm fails, still try to verify and record payment
                            print("⚠️ Confirm failed but continuing with verification")
                            self.verifyPayment(txnId: txnId)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Confirm Error:", error)
                    DispatchQueue.main.async {
                        // Even if confirm fails, try to verify and record payment
                        print("⚠️ Confirm error but continuing with verification")
                        self.verifyPayment(txnId: txnId)
                    }
                }
            }
            
        } catch {
            print("❌ JSON Error:", error)
            // Even if JSON fails, try to verify and record payment
            verifyPayment(txnId: txnId)
        }
    }
    
    func verifyPayment(txnId: String) {
        guard let token = bearerToken else { return }
        
        APIManager.shared.request(
            endpoint: "payment-gateway/status/\(txnId)",
            method: .get,
            queryParams: nil,
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentStatusResponse, APIManager.APIError>) in
            switch result {
            case .success(let response):
                let status = response.data?.status ?? ""
                DispatchQueue.main.async {
                    if status == "SUCCESS" || status == "PENDING" {
                        self.showAlert(message: "Payment Successful") {
                            // Record the fee payment
                            self.makeStudentFeePaymentRequest()
                        }
                    } else {
                        self.showAlert(message: response.data?.errorMessage ?? "Payment Failed")
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showAlert(message: "Verification Failed")
                }
            }
        }
    }
    
    func buildPaymentBody(includeIdempotency: Bool) -> PaymentRequest? {
        let allocations: [Allocation] = selectedAmounts.compactMap { index, amount in
            let demand = demands[index]
            guard let id = Int(demand.studentFeeDemandId ?? "") else { return nil }
            return Allocation(amount: amount, fineAmount: demand.fine ?? 0, studentFeeDemandId: id)
        }
        
        let totalSelectedAmount = selectedAmounts.values.reduce(0, +)
        
        guard totalSelectedAmount > 0 else {
            showAlert(message: "Invalid amount")
            return nil
        }
        
        guard !allocations.isEmpty else {
            showAlert(message: "No allocations selected")
            return nil
        }
        
        let academicYearId = groupAcademicYearId.isEmpty ? "142" : groupAcademicYearId
        
        let paymentData = PaymentData(
            advanceAmounts: [],
            advancePayment: 0,
            allocations: allocations,
            amount: totalSelectedAmount,
            classId: classId,
            groupAcademicYearId: academicYearId,
            idempotencyKey: includeIdempotency ? "\(Int(Date().timeIntervalSince1970))" : nil,
            paymentMode: paymentMode,
            studentId: Int(studentId ?? "0") ?? 0,
            useAdvance: false
        )
        
        return PaymentRequest(data: [paymentData])
    }
    
    func makeStudentFeePaymentRequest() {
        guard let token = bearerToken else { return }
        guard let body = buildPaymentBody(includeIdempotency: false) else { return }
        
        APIManager.shared.request(
            endpoint: "fees/student-fee-payments",
            method: .post,
            queryParams: nil,
            body: body,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentSuccessResponse, APIManager.APIError>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.showAlert(message: response.message ?? "Payment Successful") {
                        self.onPaymentSuccess?()
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.selectedAmounts.removeAll()
                    self.updatePayButton()
                    self.payableTableView.reloadData()
                }
            case .failure(let error):
                print("❌ Payment Error:", error)
                DispatchQueue.main.async {
                    self.showAlert(message: "Payment Failed")
                }
            }
        }
    }
}

// MARK: - TABLE VIEW
extension AmountPaymentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayablesTableViewCell", for: indexPath) as! PayablesTableViewCell
        let demand = demands[indexPath.row]
        cell.configureCell(isChecked: false, demand: demand)
        
        cell.amountChanged = { [weak self] amount, isChecked in
            guard let self = self else { return }
            if isChecked {
                self.selectedAmounts[indexPath.row] = amount
            } else {
                self.selectedAmounts.removeValue(forKey: indexPath.row)
            }
            self.updatePayButton()
        }
        
        return cell
    }
    
    func updatePayButton() {
        let total = selectedAmounts.values.reduce(0, +)
        payButton.setTitle("PAY ₹\(total)", for: .normal)
    }
}
