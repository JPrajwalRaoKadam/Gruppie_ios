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
    var selectedFines: [Int: Double] = [:]
    
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
            if amount > balance {
                showAlert(message: "Total amount exceeds balance")
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
        
        LoaderManager.shared.show()
        view.isUserInteractionEnabled = false
        
        APIManager.shared.request(
            endpoint: "fees/students/\(studentId)/payment-view",
            method: .get,
            queryParams: ["groupAcademicYearId": academicYearId],
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentViewResponse, APIManager.APIError>) in
            
            LoaderManager.shared.hide()
            self.view.isUserInteractionEnabled = true
            
            switch result {
            case .success(let response):
                let data = response.data
                self.demands = data?.demands ?? []
                self.studentNameLabel.text = data?.student?.fullName
                self.classId = Int(data?.student?.classId ?? "0") ?? 0
                self.payableTableView.reloadData()
                
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
        
        LoaderManager.shared.show()
        
        APIManager.shared.request(
            endpoint: "payment-gateway/initiate",
            method: .post,
            queryParams: nil,
            body: body,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentGatewayResponse, APIManager.APIError>) in
            
            LoaderManager.shared.hide()
            
            switch result {
            case .success(let response):
                if let redirectUrl = response.data?.redirectUrl {
                    let token = redirectUrl.components(separatedBy: "/pay/").last ?? ""
                    self.startEasebuzz(token: token)
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

        LoaderManager.shared.show()
        
        var cleanResponse: [String: Any] = [:]
        for (key, value) in paymentResponse {
            if !(value is NSNull) {
                cleanResponse[key] = value
            }
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cleanResponse)

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
                
                LoaderManager.shared.hide()
                
                switch result {
                case .success:
                    self.verifyPayment(txnId: txnId)
                    
                case .failure:
                    self.verifyPayment(txnId: txnId)
                }
            }

        } catch {
            LoaderManager.shared.hide()
            verifyPayment(txnId: txnId)
        }
    }
    
    func verifyPayment(txnId: String) {
        guard let token = bearerToken else { return }
        
        LoaderManager.shared.show()
        
        APIManager.shared.request(
            endpoint: "payment-gateway/status/\(txnId)",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentStatusResponse, APIManager.APIError>) in
            
            LoaderManager.shared.hide()
            
            switch result {
            case .success(let response):
                let status = response.data?.status ?? ""
                
                if status == "SUCCESS" || status == "PENDING" {
                    self.showAlert(message: "Payment Successful") {
                        self.makeStudentFeePaymentRequest()
                    }
                } else {
                    self.showAlert(message: response.data?.errorMessage ?? "Payment Failed")
                }
                
            case .failure:
                self.showAlert(message: "Verification Failed")
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
        
        LoaderManager.shared.show()
        
        APIManager.shared.request(
            endpoint: "fees/student-fee-payments",
            method: .post,
            body: body,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<PaymentSuccessResponse, APIManager.APIError>) in
            
            LoaderManager.shared.hide()
            
            switch result {
            case .success(let response):
                self.showAlert(message: response.message ?? "Payment Successful") {
                    self.onPaymentSuccess?()
                    self.navigationController?.popViewController(animated: true)
                }
                self.selectedAmounts.removeAll()
                self.updatePayButton()
                self.payableTableView.reloadData()
                
            case .failure:
                self.showAlert(message: "Payment Failed")
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
        
        let isChecked = selectedAmounts[indexPath.row] != nil
        
        cell.configureCell(
            isChecked: isChecked,
            demand: demand,
            indexPath: indexPath
        )

        cell.amountChanged = { [weak self] indexPath, amount, fine, isChecked in
            guard let self = self else { return }
            
            if isChecked {
                self.selectedAmounts[indexPath.row] = amount
                self.selectedFines[indexPath.row] = fine
            } else {
                self.selectedAmounts.removeValue(forKey: indexPath.row)
                self.selectedFines.removeValue(forKey: indexPath.row)
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
