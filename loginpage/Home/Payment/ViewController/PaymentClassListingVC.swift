import UIKit

class PaymentClassListingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var demandAmount: UILabel!
    @IBOutlet weak var concessionAmount: UILabel!
    @IBOutlet weak var collectionAmount: UILabel!
    @IBOutlet weak var balenceAmount: UILabel!
    @IBOutlet weak var overdueAmount: UILabel!
    @IBOutlet weak var fineAmount: UILabel!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var customContainerView: UIView!

    // MARK: - Properties
    var groupId: String?
    var currentRole: String?
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    
    var groupClasses: [FeeGroupClass] = []   // 🔥 fallback data
    var classwiseData: [ClasswiseFeeData] = [] // 🔥 primary data
    var feeTotals: FeeTotals?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if SessionManager.role_name != "STUDENT" {
            fetchClasswiseFeeDetails()
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        
        classTableView.layer.cornerRadius = 10
        customContainerView.layer.cornerRadius = 10
        
        classTableView.delegate = self
        classTableView.dataSource = self
        
        classTableView.register(
            UINib(nibName: "ClassesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ClassesTableViewCell"
        )
    }

    // MARK: - API CALL
    func fetchClasswiseFeeDetails() {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token not found")
            return
        }
        
        guard let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not available")
            return
        }
        
        APIManager.shared.request(
            endpoint: "fees/classwise-fee-details",
            method: .get,
            queryParams: ["groupAcademicYearId": groupAcademicYearId],
            body: nil,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<ClasswiseFeeResponse, APIManager.APIError>) in
            
            switch result {
                
            case .success(let response):
                print("✅ Classwise Fee Response:", response)
                
                DispatchQueue.main.async {
                    self.classwiseData = response.data
                    self.feeTotals = response.totals
                    
                    self.updateTotalsUI()
                    self.classTableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
                
                // 🔥 fallback UI reload
                DispatchQueue.main.async {
                    self.classTableView.reloadData()
                }
            }
        }
    }

    // MARK: - Update Totals
    func updateTotalsUI() {
        demandAmount.text = "₹ \(feeTotals?.totalDemand ?? 0)"
        concessionAmount.text = "₹ \(feeTotals?.totalConcession ?? 0)"
        collectionAmount.text = "₹ \(feeTotals?.totalCollection ?? 0)"
        balenceAmount.text = "₹ \(feeTotals?.totalBalance ?? 0)"
        
        overdueAmount.text = "₹ 0"
        fineAmount.text = "₹ 0"
    }

    // MARK: - Helper
    func isUsingClasswiseData() -> Bool {
        return !classwiseData.isEmpty
    }

    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isUsingClasswiseData() {
            return classwiseData.count
        } else {
            return groupClasses.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ClassesTableViewCell",
            for: indexPath
        ) as? ClassesTableViewCell else {
            return UITableViewCell()
        }
        
        if isUsingClasswiseData() {
            
            // ✅ PRIMARY DATA
            let item = classwiseData[indexPath.row]
            
            cell.nameLabel.text = item.className
            cell.Demand.text = "₹ \(item.demand)"
            cell.Collected.text = "₹ \(item.collection)"
            cell.Balance.text = "₹ \(item.balance)"
            
            cell.iconImageView.image = cell.generateImage(from: item.className)
            cell.configurePayment(with: item)
            
        } else {
            
            // 🔥 FALLBACK DATA
            let item = groupClasses[indexPath.row]
            
            cell.nameLabel.text = item.name
            cell.Demand.text = "-"
            cell.Collected.text = "-"
            cell.Balance.text = "-"
            
            cell.iconImageView.image = cell.generateImage(from: item.name)
        }
        
        return cell
    }

    // MARK: - TableView Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToStudentListing(at: indexPath)
    }

    // MARK: - Navigation
    
    private func navigateToStudentListing(at indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        
        if let studentListingVC = storyboard.instantiateViewController(
            withIdentifier: "StudentListingVC"
        ) as? StudentListingVC {
            
            guard let groupAcademicYearId =
                    groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
                print("❌ groupAcademicYearId not available")
                return
            }
            
            studentListingVC.groupAcademicYearId = groupAcademicYearId
            studentListingVC.groupAcademicYearResponse = groupAcademicYearResponse
            
            // ✅ FIXED: common handling
            if isUsingClasswiseData() {
                
                let selectedClass = classwiseData[indexPath.row]
                
                studentListingVC.selectedClassName = selectedClass.className
                studentListingVC.classId = selectedClass.classId
                studentListingVC.selectedClass = selectedClass
                
            } else {
                
                let selectedClass = groupClasses[indexPath.row]
                
                studentListingVC.selectedClassName = selectedClass.name
                studentListingVC.classId = selectedClass.id
                // ❌ don't pass selectedClass if type mismatch
            }
            
            self.navigationController?.pushViewController(studentListingVC, animated: true)
        }
    }

    // MARK: - Back
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
