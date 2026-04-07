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
    var groupAcademicYearId: String = "142"
    var easebuzzResponse: [String: AnyObject]?
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
        
        payableTableView.register(
            UINib(nibName: "PayablesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PayablesTableViewCell"
        )
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func payButton(_ sender: Any) {
        
        if selectedAmounts.isEmpty {
            showAlert(message: "Please select at least one fee")
            return
        }
        
        // 🔥 VALIDATION HERE
        for (index, amount) in selectedAmounts {
            
            let demand = demands[index]
            let balance = demand.balance ?? 0
            let fine = demand.fine ?? 0
            
            if amount > balance {
                showAlert(message: "Amount cannot exceed balance")
                return
            }
            
            if (amount + fine) > balance {
                showAlert(message: "Amount + fine cannot exceed balance")
                return
            }
        }
        
        // ✅ If everything valid → proceed
        let alert = UIAlertController(title: "Select Payment Mode", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Online Payment", style: .default, handler: { _ in
            self.paymentMode = "GATEWAY"
            self.initiatePaymentGateway()
        }))
        
        alert.addAction(UIAlertAction(title: "Cash Payment", style: .default, handler: { _ in
            self.paymentMode = "CASH"
            self.makeStudentFeePaymentRequest()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showAlert(message: String, onOk: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            onOk?()
        }))
        
        present(alert, animated: true)
    }
    
}


extension AmountPaymentVC {
    
    func fetchPaymentView() {
        
        guard let token = bearerToken,
              let studentId = studentId else { return }
        
        APIManager.shared.request(
            endpoint: "fees/students/\(studentId)/payment-view",
            method: .get,
            queryParams: ["groupAcademicYearId": groupAcademicYearId],
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

extension AmountPaymentVC {
    func buildPaymentBody(includeIdempotency: Bool) -> PaymentRequest? {
        
        let allocations: [Allocation] = selectedAmounts.compactMap { (index, amount) in
            
            let demand = demands[index]
            
            guard let id = Int(demand.studentFeeDemandId ?? "") else { return nil }
            
            return Allocation(
                amount: amount,
                fineAmount: demand.fine ?? 0,
                studentFeeDemandId: id
            )
        }
        
        let totalSelectedAmount = selectedAmounts.values.reduce(0, +)
        
        // ✅ BASIC CHECKS
        guard totalSelectedAmount > 0 else {
            showAlert(message: "Invalid amount")
            return nil
        }

        guard !allocations.isEmpty else {
            showAlert(message: "No allocations selected")
            return nil
        }
        
        // 🔥 ADD YOUR VALIDATION HERE
        for (index, amount) in selectedAmounts {
            let demand = demands[index]
            
            let balance = demand.balance ?? 0
            let fine = demand.fine ?? 0
            
            if amount > balance {
                showAlert(message: "Amount cannot exceed balance")
                return nil
            }
            
            if (amount + fine) > balance {
                showAlert(message: "Amount + fine cannot exceed balance")
                return nil
            }
        }
        
        // ✅ FINAL OBJECT
        let paymentData = PaymentData(
            advanceAmounts: [],
            advancePayment: 0,
            allocations: allocations,
            amount: totalSelectedAmount,
            classId: classId,
            groupAcademicYearId: groupAcademicYearId,
            idempotencyKey: includeIdempotency ? "\(Int(Date().timeIntervalSince1970))" : nil,
            paymentMode: paymentMode,
            studentId: Int(studentId ?? "0") ?? 0,
            useAdvance: false
        )
        
        return PaymentRequest(data: [paymentData])
    }}

extension AmountPaymentVC {
    
    func initiatePaymentGateway() {
        
        guard let token = bearerToken else { return }
        
        let body = buildPaymentBody(includeIdempotency: true)
        
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
                        
                        self.onPaymentSuccess?()   // 🔥 notify previous VC
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    // Optional reset (can also move inside completion)
                    self.selectedAmounts.removeAll()
                    self.updatePayButton()
                    self.payableTableView.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(message: "Payment Failed")
                }
            }
        }
    }
}

extension AmountPaymentVC {
    
    func startEasebuzz(token: String) {
        
        let payment = Payment(customerData: [
            "access_key": token,
            "pay_mode": "test"
        ])
        
        if payment.isValid().validity {
            PayWithEasebuzz.setUp(pebCallback: self)
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        }
    }
    
    func PEBCallback(data: [String : AnyObject]) {
        print("Easebuzz:", data)
        
        if let paymentResponse = data["payment_response"] as? [String: AnyObject],
           let status = paymentResponse["status"] as? String,
           let txnid = paymentResponse["txnid"] as? String {
            self.easebuzzResponse = paymentResponse
            if status.lowercased() == "success" {
                
                // 🔥 CALL VERIFY API INSTEAD OF DIRECT SUCCESS
                self.verifyPayment(txnId: txnid)
                
            } else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Payment Failed or Cancelled")
                }
            }
            
        } else {
            DispatchQueue.main.async {
                self.showAlert(message: "Invalid payment response")
            }
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
                            
                            // ✅ Call confirm API AFTER OK click
                            self.confirmPayment()
                        }
                        
                    } else {
                        self.showAlert(message: response.data?.errorMessage ?? "Payment Failed")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(message: "Verification Failed. Try again.")
                }
                print("❌ Verify API Error:", error)
            }
        }
    }
    
    func confirmPayment() {
        
        guard let token = bearerToken,
              let paymentResponse = easebuzzResponse else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paymentResponse, options: [])
            
            APIManager.shared.request(
                endpoint: "payment-gateway/confirm",
                method: .post,
                queryParams: nil,
                bodyData: jsonData,   // ✅ use raw data
                headers: [
                    "Authorization": "Bearer \(token)",
                    "Content-Type": "application/json"
                ]
            ) { (result: Result<GenericResponse, APIManager.APIError>) in
                
                switch result {
                    
                case .success(let response):
                    DispatchQueue.main.async {
                        print("✅ Confirm Success:", response)
                        
                        if self.paymentMode == "GATEWAY" {
                            self.makeStudentFeePaymentRequest()
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(message: "Confirm Payment Failed")
                    }
                    print("❌ Confirm Error:", error)
                }
            }
            
        } catch {
            print("❌ JSON Conversion Error:", error)
        }
    }
    
}

extension AmountPaymentVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PayablesTableViewCell",
            for: indexPath
        ) as! PayablesTableViewCell
        
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
        
        // assuming your button is payButton
        payButton.setTitle("PAY ₹\(total)", for: .normal)
    }
}

extension AmountPaymentVC {
    
    func totalAmount() -> Double {
        demands.reduce(0) { $0 + ($1.payable ?? 0) }
    }
}

