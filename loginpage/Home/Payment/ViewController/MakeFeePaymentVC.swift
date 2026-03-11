//
//  MakeFeePaymentVC.swift
//  loginpage
//
//  Created by apple on 19/02/25.
//

import UIKit

class MakeFeePaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bcbutton: UIButton!
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
    
    @IBOutlet weak var customContainerView: UIView!
    @IBOutlet weak var myStackView: UIStackView!
    
    // MARK: - Variables
    var studentId: String?
    var groupAcademicYearId: String?
    var feeDetails: [FeeDetail] = []
    var paidDetails: [PaidDetail] = []
    var installments: [FeeSummaryInstallment] = []
    
    var studentInfo: StudentInfo?
    var breakdown: FeeBreakdown?
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchStudentFeeSummary()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        
        paymentTableView.layer.cornerRadius = 10
        customContainerView.layer.cornerRadius = 10
        myStackView.layer.cornerRadius = 10
        
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        
        paymentTableView.register(UINib(nibName: "AmoutTableViewCell", bundle: nil), forCellReuseIdentifier: "AmoutTableViewCell")
        paymentTableView.register(UINib(nibName: "InstallmentTableViewCell", bundle: nil), forCellReuseIdentifier: "InstallmentTableViewCell")
    }
    
    // MARK: - Update UI
    func updateUI() {
        
        studentName.text = studentInfo?.fullName
        
        demandAmount.text = "\(Int(breakdown?.totalDue ?? 0))"
        concessionAmount.text = "\(Int(breakdown?.totalConcession ?? 0))"
        collectionAmount.text = "\(Int(breakdown?.totalPaid ?? 0))"
        balenceAmount.text = "\(Int(breakdown?.balance ?? 0))"
        overdueAmount.text = "\(Int(breakdown?.totalArrearsDue ?? 0))"
        fineAmount.text = "\(Int(breakdown?.totalCollectedFine ?? 0))"
    }
    
    // MARK: - Segment Change
    @IBAction func paymentTypeSegmentChanged(_ sender: UISegmentedControl) {
        paymentTableView.reloadData()
    }
    
    // MARK: - Back Action
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Pay Button
    @IBAction func payButtonAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        
        if let amountPaymentVC = storyboard.instantiateViewController(withIdentifier: "AmountPaymentVC") as? AmountPaymentVC {
            
            amountPaymentVC.studentName = studentInfo?.fullName
                        amountPaymentVC.studentId = studentInfo?.studentId
                        amountPaymentVC.demandTotalAmount = demandAmount.text
            
            navigationController?.pushViewController(amountPaymentVC, animated: true)
        }
    }
    
    // MARK: - TableView Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if paymentTypeSegmentControl.selectedSegmentIndex == 0 {
            return paidDetails.count
        } else {
            return installments.count
        }
    }
    
    // MARK: - TableView Cell
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if paymentTypeSegmentControl.selectedSegmentIndex == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmoutTableViewCell", for: indexPath) as! AmoutTableViewCell
            
            receiptLabel.isHidden = false
            
            let paid = paidDetails[indexPath.row]
            
            cell.dateLabel.text = paid.date
            cell.amountLabel.text = "\(Int(paid.amountPaid ?? 0))"
            cell.statusButton.setTitle(paid.status, for: .normal)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstallmentTableViewCell", for: indexPath) as! InstallmentTableViewCell
            
            receiptLabel.isHidden = true
            
            let installment = installments[indexPath.row]
            
            cell.dateLabel.text = installment.dueDate
            cell.amountLabel.text = "\(Int(installment.amount ?? 0))"
            cell.completedLabel.text = installment.status
            
            return cell
        }
    }
    
    // MARK: - API CALL
    func fetchStudentFeeSummary() {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token not found")
            return
        }
        
        guard let studentId = studentId else {
            print("❌ studentId missing")
            return
        }
        
        guard let groupAcademicYearId = groupAcademicYearId else {
            print("❌ groupAcademicYearId missing")
            return
        }
        
        APIManager.shared.request(
            endpoint: "fees/students/\(studentId)/fee-summary",
            method: .get,
            queryParams: [
                "groupAcademicYearId": groupAcademicYearId
            ],
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
            
        ) { (result: Result<StudentFeeSummaryDetailResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                
                print("✅ Student Fee Summary:", response)
                
                DispatchQueue.main.async {
                    
                    let data = response.data
                    
                    self.studentInfo = data?.student
                    self.breakdown = data?.breakdown
                    self.feeDetails = data?.feeDetails ?? []
                    self.paidDetails = data?.paidDetails ?? []
                    self.installments = data?.installments ?? []
                    
                    self.updateUI()
                    self.paymentTableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
            }
        }
    }
}
