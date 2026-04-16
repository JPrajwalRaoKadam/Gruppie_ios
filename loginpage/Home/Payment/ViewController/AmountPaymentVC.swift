import UIKit
import Easebuzz

class AmountPaymentVC: UIViewController, PayWithEasebuzzCallback {

    // MARK: - OUTLETS
    @IBOutlet weak var customContainerView: UIView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var payableTableView: UITableView!
    @IBOutlet weak var payableAmount: UILabel!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var gpayButton: UIButton!
    @IBOutlet weak var myStackView: UIStackView!
    
    // MARK: - VARIABLES
    var groupID: String?
    var teamID: String?
    var userID: String?
    var bearerToken = TokenManager.shared.getToken()

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

    func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2

        payableTableView.register(
            UINib(nibName: "PayablesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PayablesTableViewCell"
        )

        payableTableView.delegate = self
        payableTableView.dataSource = self

        studentNameLabel.text = studentName
    }

    // MARK: - 🔥 GET API
    func fetchDueData() {

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/due/get/new"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DueResponseModel.self, from: data)

                var tempSplits: [SplitPayment] = []
                var total: Double = 0

                decoded.feeData?.forEach { fee in

                    let due = fee.dueAmount ?? 0
                    total += due

                    if let banks = fee.bankData {

                        if banks.count > 1 {
                            // MULTIPLE BANKS → pick first valid
                            if let bank = banks.first(where: {
                                ($0.totalFee ?? 0) > 0 || ($0.totalBalance ?? 0) > 0
                            }) {
                                tempSplits.append(
                                    SplitPayment(
                                        amount: "\(Int(due))",
                                        merchantId: bank.merchantId ?? ""
                                    )
                                )
                            }
                        } else if let bank = banks.first {
                            tempSplits.append(
                                SplitPayment(
                                    amount: "\(Int(due))",
                                    merchantId: bank.merchantId ?? ""
                                )
                            )
                        }
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

    // MARK: - 🔥 PAYMENT API
    func makePaymentRequest() {

        let isSplit = splitPayments.count > 1

        let urlString = APIManager.shared.baseURL +
        "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/easebuzz/pay" +
        (isSplit ? "?type=splitPayments" : "")

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken ?? "")", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "amount": payableAmount.text ?? "0",
            "studentName": studentName ?? "",
            "customerMobileNo": customerMobileNo ?? "",
            "returnURL": APIManager.shared.baseURL +
                "groups/\(groupID ?? "")/team/\(teamID ?? "")/user/\(userID ?? "")/atom/response?type=easebuzz",
            "frontendUrl": "http://localhost:4200/activity/easebuzz/test"
        ]

        if isSplit {
            body["splitPayments"] = splitPayments.map {
                [
                    "amount": $0.amount,
                    "merchantId": $0.merchantId
                ]
            }
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in

            guard let data = data else { return }

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

extension AmountPaymentVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PayablesTableViewCell",
            for: indexPath
        ) as? PayablesTableViewCell else {
            return UITableViewCell()
        }

        // ✅ Safe access
        guard feeData.indices.contains(indexPath.row) else {
            return cell
        }

        let fee = feeData[indexPath.row]

        let title = fee.feeTitle ?? "-"
        let dueAmount = Int(fee.dueAmount ?? 0)

        cell.configureCell(
            isChecked: true, // default checked (you can change later)
            title: title,
            dueAmount: "\(dueAmount)"
        )

        return cell
    }
}
