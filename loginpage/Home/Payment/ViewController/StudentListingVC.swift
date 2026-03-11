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
    
    var groupAcademicYearId: String?
    var classId: String?
    var selectedClassName: String?
    var selectedClass: ClasswiseFeeData?
    
    var studentFees: [StudentFeeSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        fetchStudentFeeSummary()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        className.text = selectedClassName
        studentTableView.layer.cornerRadius = 10
        customContainerView.layer.cornerRadius = 10
        
        studentTableView.delegate = self
        studentTableView.dataSource = self
        
        studentTableView.register(UINib(nibName: "ClassesTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "ClassesTableViewCell")
    }
    
    // MARK: - API CALL
    func fetchStudentFeeSummary() {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token not found")
            return
        }
        
        guard let groupAcademicYearId = groupAcademicYearId else {
            print("❌ groupAcademicYearId not available")
            return
        }
        
        guard let classId = classId else {
            print("❌ classId not available")
            return
        }
        
        APIManager.shared.request(
            endpoint: "fees/student-fee-demands/summary",
            method: .get,
            queryParams: [
                "groupAcademicYearId": groupAcademicYearId,
                "classId": classId
            ],
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
            
        ) { (result: Result<StudentFeeSummaryResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                print("✅ Student Fee Summary Response:", response)
                
                DispatchQueue.main.async {
                    self.studentFees = response.data
                    self.studentTableView.reloadData()
                    self.updateUI()
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
            }
        }
    }
    
    // MARK: - Update Total UI
    func updateUI() {
        demandAmount.text = formatAmount(selectedClass?.demand)
        concessionAmount.text = formatAmount(selectedClass?.concession)
        collectionAmount.text = formatAmount(selectedClass?.collection)
        balenceAmount.text = formatAmount(selectedClass?.balance)
        //        overdueAmount.text = selectedClass?.demand
        //        fineAmount.text = selectedClass?.demand
    }
    
    // MARK: - Back Action
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func formatAmount(_ value: Double?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value ?? 0)) ?? "0"
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return studentFees.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = studentFees[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassesTableViewCell",
                                                 for: indexPath) as! ClassesTableViewCell
        cell.configure(with: student)
        
        cell.nameLabel.text = student.studentName ?? "-"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let student = studentFees[indexPath.row]
        
        print("Selected Student ID:", student.studentId ?? "")
        
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        
        if let makeFeePaymentVC = storyboard.instantiateViewController(withIdentifier: "MakeFeePaymentVC") as? MakeFeePaymentVC {
            
            makeFeePaymentVC.studentId = student.studentId
            makeFeePaymentVC.groupAcademicYearId = groupAcademicYearId
            
            navigationController?.pushViewController(makeFeePaymentVC, animated: true)
        }
    }
}
