import UIKit

class StaffRegister: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var staffRegister: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    private var staffList: [Staff] = []
    var filteredTeachingStaff: [Staff] = []
    var filteredNonTeachingStaff: [Staff] = []
    var isSearching = false
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var teachingStaffData: [Staff] = []
    var nonTeachingStaffData: [Staff] = []
    var token: String?
    var groupIds = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received groupId: \(groupIds)")
        print("token staff register:\(token)")
        
        heightConstraintOfSearchView.constant = 0
        
        staffRegister.register(UINib(nibName: "TeachingStaff", bundle: nil), forCellReuseIdentifier: "TeachingStaffCell")
        staffRegister.register(UINib(nibName: "NonTeachingStaff", bundle: nil), forCellReuseIdentifier: "NonTeachingStaffCell")
        
        staffRegister.delegate = self
        staffRegister.dataSource = self
        
        
        segmentController.layer.cornerRadius = 0
        segmentController.layer.masksToBounds = false
        
        staffRegister.layer.cornerRadius = 10
        staffRegister.layer.masksToBounds = true
        
        staffRegister.estimatedRowHeight = 100
        staffRegister.rowHeight = UITableView.automaticDimension
        
        searchView.isHidden = true
        
        loadStaff()
        
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Configure backButton to have circular corners
        backButton.layer.cornerRadius = backButton.frame.size.width / 2
        backButton.layer.masksToBounds = true
        backButton.clipsToBounds = true
        
    }
    
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
        if shouldShow {
            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
            searchTextField?.placeholder = "Search..."
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchTextField?.backgroundColor = .white
            searchTextField?.layer.cornerRadius = 5
            searchTextField?.layer.borderWidth = 1
            searchTextField?.layer.borderColor = UIColor.gray.cgColor
            if let searchTextField = searchTextField {
                searchView.addSubview(searchTextField)
            }
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
        }
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func AddStaff(_ sender: UIButton) {
        guard let addStaffVC = storyboard?.instantiateViewController(withIdentifier: "AddStaffViewController") as? AddStaffViewController else {
            print("Error: AddStaffViewController could not be instantiated")
            return
        }
        
        addStaffVC.token = TokenManager.shared.getToken() ?? ""
        addStaffVC.groupId = groupIds
        
        navigationController?.pushViewController(addStaffVC, animated: true)
    }
    
    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        isSearching = false
        searchTextField?.text = ""
        
        print("Segment changed to:", sender.selectedSegmentIndex)
        staffRegister.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentController.selectedSegmentIndex == 0 {
            let data = isSearching ? filteredTeachingStaff : teachingStaffData
            return data.isEmpty ? 1 : data.count
        } else {
            let data = isSearching ? filteredNonTeachingStaff : nonTeachingStaffData
            return data.isEmpty ? 1 : data.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentController.selectedSegmentIndex == 0 {
            
            let data = isSearching ? filteredTeachingStaff : teachingStaffData
            
            if data.isEmpty {
                return emptyCell(tableView)
            }
            
            let staff = data[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TeachingStaffCell",
                for: indexPath
            ) as! TeachingStaff
            
            cell.configureCell(with: staff)
            return cell
            
        } else {
            
            let data = isSearching ? filteredNonTeachingStaff : nonTeachingStaffData
            
            if data.isEmpty {
                return emptyCell(tableView)
            }
            
            let staff = data[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "NonTeachingStaffCell",
                for: indexPath
            ) as! NonTeachingStaff
            
            cell.configureCell(with: staff)
            return cell
        }
    }
    
    private func emptyCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
        cell.textLabel?.text = "No Data Available"
        cell.textLabel?.textColor = .gray
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedStaff: Staff
        
        if segmentController.selectedSegmentIndex == 0 {
            selectedStaff = isSearching
            ? filteredTeachingStaff[indexPath.row]
            : teachingStaffData[indexPath.row]
        } else {
            selectedStaff = isSearching
            ? filteredNonTeachingStaff[indexPath.row]
            : nonTeachingStaffData[indexPath.row]
        }
        
        navigateToStaffDetailViewController(staffId: selectedStaff.id)
    }
    
    private func navigateToStaffDetailViewController(staffId: String) {
        
        guard let staffDetailVC = storyboard?
            .instantiateViewController(withIdentifier: "StaffDetailViewController")
                as? StaffDetailViewController else {
            print("Error: StaffDetailViewController could not be instantiated")
            return
        }
        
        staffDetailVC.staffIdValue = staffId
        
        navigationController?.pushViewController(staffDetailVC, animated: true)
    }
    
    
    private func loadStaff() {
        fetchStaffList(page: 1, limit: 10) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let staff):
                
                self.staffList = staff
                
                // ✅ Split staff based on staffType
                self.teachingStaffData = staff.filter {
                    $0.staffType?.uppercased() == "TEACHING"
                }
                
                self.nonTeachingStaffData = staff.filter {
                    $0.staffType?.uppercased() == "NON-TEACHING"
                }
                
                print("Teaching:", self.teachingStaffData.count)
                print("Non-Teaching:", self.nonTeachingStaffData.count)
                
                DispatchQueue.main.async {
                    self.staffRegister.reloadData()
                }
                
            case .failure(let error):
                print("❌ Staff API Error:", error)
            }
        }
    }
    
    
    func fetchStaffList(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[Staff], APIManager.APIError>) -> Void
    ) {
        
        let token = SessionManager.useRoleToken ?? ""
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let queryParams = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        APIManager.shared.request(
            endpoint: "staff/registration",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<StaffRegistrationResponse, APIManager.APIError>) in
            
            switch result {
            case .success(let response):
                completion(.success(response.data))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func filterMembers(textField: String) {
        
        if textField.isEmpty {
            isSearching = false
            staffRegister.reloadData()
            return
        }
        
        isSearching = true
        let searchText = textField.lowercased()
        
        if segmentController.selectedSegmentIndex == 0 {
            filteredTeachingStaff = teachingStaffData.filter {
                ($0.firstName ?? "").lowercased().contains(searchText) ||
                ($0.lastName ?? "").lowercased().contains(searchText)
            }
        } else {
            filteredNonTeachingStaff = nonTeachingStaffData.filter {
                ($0.firstName ?? "").lowercased().contains(searchText) ||
                ($0.lastName ?? "").lowercased().contains(searchText)
            }
        }
        
        staffRegister.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterMembers(textField: searchText)
        return true
    }
}
