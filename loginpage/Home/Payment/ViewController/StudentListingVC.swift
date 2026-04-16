import UIKit

class StudentListingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
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
    
    // MARK: - Properties
    var groupAcademicYearId: String?
    var classId: String?
    var selectedClassName: String?
    var selectedClass: ClasswiseFeeData?
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    
    // 🔥 BOTH DATA SOURCES
    var studentFees: [StudentFeeSummary] = []      // For Admin/Parent
    var students: [StudentListItem] = []           // For Student role
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if SessionManager.role_name == "STUDENT" {
            overAllAmountView.isHidden = true   // 🔥 hide totals
            
            fetchStudents(classId: classId ?? "") { [weak self] students in
                guard let self = self else { return }
                
                guard let students = students else {
                    print("❌ No students")
                    return
                }
                
                print("👨‍🎓 Students Count:", students.count)
                
                self.students = students
                self.studentTableView.reloadData()
            }
            
        } else {
            overAllAmountView.isHidden = false
            fetchStudentFeeSummary()
        }
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
        
        studentTableView.register(
            UINib(nibName: "ClassesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ClassesTableViewCell"
        )
    }
    
    // MARK: - Helpers
    func isStudentRole() -> Bool {
        return SessionManager.role_name == "STUDENT"
    }
    
    // MARK: - Update Totals
    func updateUI() {
        demandAmount.text = formatAmount(selectedClass?.demand)
        concessionAmount.text = formatAmount(selectedClass?.concession)
        collectionAmount.text = formatAmount(selectedClass?.collection)
        balenceAmount.text = formatAmount(selectedClass?.balance)
    }
    
    func formatAmount(_ value: Double?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "₹ \(formatter.string(from: NSNumber(value: value ?? 0)) ?? "0")"
    }
    
    // MARK: - Back
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API: Fee Summary
    func fetchStudentFeeSummary() {
        
        guard let token = SessionManager.useRoleToken,
              let groupAcademicYearId = groupAcademicYearId,
              let classId = classId else {
            print("❌ Missing params")
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
    
    // MARK: - API: Student List
    func fetchStudents(
        classId: String,
        completion: @escaping ([StudentListItem]?) -> Void
    ) {
        
        guard let token = SessionManager.useRoleToken,
              let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ Missing params")
            completion(nil)
            return
        }
        
        let endpoint = "group-class/\(classId)/students?groupAcademicYearId=\(groupAcademicYearId)"
        
        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<StudentListResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                DispatchQueue.main.async {
                    completion(response.data)
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                completion(nil)
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return isStudentRole() ? students.count : studentFees.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ClassesTableViewCell",
            for: indexPath
        ) as! ClassesTableViewCell
        
        if isStudentRole() {
            
            // 🔥 STUDENT LIST
            let student = students[indexPath.row]
            
            cell.nameLabel.text = student.name
            cell.Demand.text = "-"
            cell.Collected.text = "-"
            cell.Balance.text = "-"
            
            cell.iconImageView.image = cell.generateImage(from: student.name)
            
        } else {
            
            // 🔥 FEE SUMMARY
            let student = studentFees[indexPath.row]
            
            cell.nameLabel.text = student.studentName ?? "-"
            cell.configure(with: student)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if isStudentRole() {
            
            let student = students[indexPath.row]
            print("👨‍🎓 Selected Student:", student.studentId)
            
            if let makeFeePaymentVC = storyboard?.instantiateViewController(
                withIdentifier: "MakeFeePaymentVC"
            ) as? MakeFeePaymentVC {
                
                makeFeePaymentVC.studentId = student.studentId
                makeFeePaymentVC.groupAcademicYearId = groupAcademicYearId
                
                navigationController?.pushViewController(makeFeePaymentVC, animated: true)
            }
            
        } else {
            
            let student = studentFees[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
            
            if let makeFeePaymentVC = storyboard.instantiateViewController(
                withIdentifier: "MakeFeePaymentVC"
            ) as? MakeFeePaymentVC {
                
                makeFeePaymentVC.studentId = student.studentId
                makeFeePaymentVC.groupAcademicYearId = groupAcademicYearId
                
                navigationController?.pushViewController(makeFeePaymentVC, animated: true)
            }
        }
    }
}
