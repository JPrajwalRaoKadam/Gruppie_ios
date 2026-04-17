import UIKit
import Easebuzz

class AmountPaymentVC: UIViewController, PayWithEasebuzzCallback {

    // MARK: - OUTLETS
    @IBOutlet weak var customContainerView: UIView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var payableTableView: UITableView!
    @IBOutlet weak var payableAmount: UILabel!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var myStackView: UIStackView!
    
    // MARK: - VARIABLES
    var groupID: String?
    var teamID: String?
    var userID: String?
    var bearerToken = TokenManager.shared.getToken()
    var loader = UIActivityIndicatorView(style: .large)
    var studentName: String?
    var customerMobileNo: String?
    var feeData: [DueFeeData] = []

    struct SplitPayment {
        let amount: String
        let merchantId: String
    }
    var splitPayments: [SplitPayment] = []

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchDueData()
    }

    // MARK: - UI SETUP
    func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2

        payableTableView.register(
            UINib(nibName: "PayablesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PayablesTableViewCell"
        )

        payableTableView.delegate = self
        payableTableView.dataSource = self

        studentNameLabel.text = studentName

        setupLoader()
    }
    
    func setupLoader() {
        loader.center = view.center
        loader.hidesWhenStopped = true
        loader.startAnimating()
        view.addSubview(loader)
    }

    // MARK: - GET DUE DATA
    func fetchDueData() {

        DispatchQueue.main.async {
            self.loader.startAnimating()
        }

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/due/get/new"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in

            DispatchQueue.main.async {
                self.loader.stopAnimating()
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DueResponseModel.self, from: data)

                var tempSplits: [SplitPayment] = []
                var total: Double = 0

                decoded.feeData?.forEach { fee in
                    let due = fee.dueAmount ?? 0
                    total += due

                    if let bank = fee.bankData?.first {
                        tempSplits.append(
                            SplitPayment(
                                amount: "\(Int(due))",
                                merchantId: bank.merchantId ?? ""
                            )
                        )
                    }
                }

                DispatchQueue.main.async {
                    self.feeData = decoded.feeData ?? []
                    self.splitPayments = tempSplits
                    self.payableAmount.text = String(format: "%.2f", total)
                    self.payableTableView.reloadData()
                }

            } catch {
                print("❌ Decode Error:", error)
            }

        }.resume()
    }

    // MARK: - PAYMENT API
    func makePaymentRequest() {

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/easebuzz/pay?type=splitPayments"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken ?? "")", forHTTPHeaderField: "Authorization")

        var feeDataArray: [[String: Any]] = []

        for fee in feeData {

            let enteredAmount = fee.dueAmount ?? 0

            // ✅ BANK DATA
            var bankArray: [[String: Any]] = []
            if let banks = fee.bankData {
                for bank in banks {
                    bankArray.append([
                        "accountId": bank.accountId ?? "",
                        "bankAccountNumber": bank.bankAccountNumber ?? "",
                        "bankAddress": bank.bankAddress ?? "",
                        "bankBranch": bank.bankBranch ?? "",
                        "bankName": bank.bankName ?? "",
                        "merchantId": bank.merchantId ?? "",
                        "totalBalance": bank.totalBalance ?? 0,
                        "totalFee": bank.totalFee ?? 0
                    ])
                }
            }

            // ✅ CONCESSION
            var concessionArray: [[String: Any]] = []
            if let cons = fee.concessionList {
                for c in cons {
                    concessionArray.append([
                        "amount": c.amount ?? "0",
                        "type": c.type ?? ""
                    ])
                }
            }

            // ✅ SAFE DICTIONARY (ONLY AVAILABLE VALUES)
            var feeDict: [String: Any] = [
                "amountPaid": enteredAmount,
                "bankData": bankArray,
                "dueAmount": fee.dueAmount ?? 0,
                "enteredPayAmount": enteredAmount,
                "feeTitle": fee.feeTitle ?? "",
                "paidDate": getTodayDate(),
                "paymentMode": "epay",
                "totalFee": fee.totalFee ?? 0
            ]

            // ✅ OPTIONAL ADD (only if exists)
            if let v = fee.categoryId { feeDict["categoryId"] = v }
            if let v = fee.categoryName { feeDict["categoryName"] = v }
            if let v = fee.feeId { feeDict["feeId"] = v }
            if let v = fee.fineAmount { feeDict["fineAmount"] = v }
            if let v = fee.gruppieCategory { feeDict["gruppieCategory"] = v }
            if let v = fee.payableAmount { feeDict["payableAmount"] = v }
            if let v = fee.teamId ?? teamID { feeDict["teamId"] = v }
            if let v = fee.totalAmountPaid { feeDict["totalAmountPaid"] = v }
            if let v = fee.totalBalanceAmount { feeDict["totalBalanceAmount"] = v }
            if let v = fee.totalConcessionAmount { feeDict["totalConcessionAmount"] = v }
            if let v = fee.concessionAmount { feeDict["concessionAmount"] = v }
            if concessionArray.count > 0 { feeDict["concessionList"] = concessionArray }

            feeDataArray.append(feeDict)
        }

        let totalAmount = String(format: "%.2f", Double(payableAmount.text ?? "") ?? 0)

        var body: [String: Any] = [
            "amount": totalAmount,
            "customerMobileNo": customerMobileNo ?? "",
            "feeData": feeDataArray,
            "frontendUrl": "http://localhost:4200/activity/easebuzz/\(UUID().uuidString)",
            "returnURL": APIManager.shared.baseURL +
            "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/atom/response?type=easebuzz",
            "studentName": studentName ?? "",
            "splitPayments": splitPayments.map {
                [
                    "amount": $0.amount,
                    "merchantId": $0.merchantId
                ]
            }
        ]

        print("🔥 FINAL BODY:", body)

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                print("❌ Request Error:", error)
                return
            }

            guard let data = data else { return }

            print("📦 RESPONSE:", String(data: data, encoding: .utf8) ?? "")

            do {
                let decoded = try JSONDecoder().decode(EasebuzzPaymentResponse.self, from: data)

                DispatchQueue.main.async {
                    self.initiateEasebuzzPayment(accessKey: decoded.data)
                }

            } catch {
                print("❌ Decode Error:", error)
            }

        }.resume()
    }

    // MARK: - DATE
    func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: Date())
    }

    // MARK: - PAYMENT INIT
    func initiateEasebuzzPayment(accessKey: String) {

        let payment = Payment(customerData: [
            "access_key": accessKey,
            "pay_mode": "production"
        ])

        let result = payment.isValid() as (validity: Bool, error: String?)

        if result.validity {
            PayWithEasebuzz.setUp(pebCallback: self)
            PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
        } else {
            print("❌ Invalid:", result.error ?? "")
        }
    }

    // MARK: - CALLBACK
    func PEBCallback(data: [String : AnyObject]) {
        print("🔁 CALLBACK:", data)
    }

    @IBAction func payButtonAction(_ sender: Any) {
        makePaymentRequest()
    }
}

// MARK: - TABLEVIEW
extension AmountPaymentVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PayablesTableViewCell",
            for: indexPath
        ) as? PayablesTableViewCell else {
            return UITableViewCell()
        }

        let fee = feeData[indexPath.row]

        cell.configureCell(
            isChecked: true,
            title: fee.feeTitle ?? "-",
            dueAmount: "\(Int(fee.dueAmount ?? 0))"
        )

        return cell
    }
}
