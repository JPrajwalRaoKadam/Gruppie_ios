import UIKit

class StaffDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var staffDetailTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var staffId: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var backButton: UIButton!

    var staffDetails: StaffDetail?
    var staffIdValue: String = ""
    var isEditingStaffInfo = false
    @IBOutlet weak var customView: UIView!

    var staffBasicInfo: Staff?
    var staffAccountInfo: Staff?

    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = staffDetails?.firstName
        staffId.text = staffDetails?.staffType
        editButton.layer.cornerRadius = 10
        editButton.clipsToBounds = true
        
        staffDetailTableView.layer.cornerRadius = 10
        staffDetailTableView.layer.masksToBounds = true

        customView.layer.cornerRadius = 10
        customView.layer.masksToBounds = true
        
        print("staffDetails received: \(staffDetails)")
        guard staffDetailTableView != nil else {
            print("Error: staffDetailTableView is nil")
            return
        }

        staffDetailTableView.delegate = self
        staffDetailTableView.dataSource = self

        staffDetailTableView.register(UINib(nibName: "StaffBasicInfo", bundle: nil), forCellReuseIdentifier: "StaffBasicInfoCell")
        staffDetailTableView.register(UINib(nibName: "StaffAccountInfo", bundle: nil), forCellReuseIdentifier: "StaffAccountInfoCell")

        staffDetailTableView.estimatedRowHeight = 100
        staffDetailTableView.rowHeight = UITableView.automaticDimension
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        fetchStaffDetails(staffId: staffIdValue) { result in
            switch result {
            case .success(let staff):
                self.staffDetails = staff
                DispatchQueue.main.async {
                    self.name.text = "\(staff.firstName ?? "") \(staff.lastName ?? "")"
                    self.staffId.text = staff.staffType
                    self.staffDetailTableView.reloadData()
                }

            case .failure(let error):
                print("❌ Error:", error)
            }
        }

        enableKeyboardDismissOnTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if isEditingStaffInfo {
            isEditingStaffInfo = false
            enableEditing(false)
            sender.setTitle("Edit", for: .normal)
            staffDetailTableView.reloadData()
        } else {
            isEditingStaffInfo = true
            enableEditing(true)
            sender.setTitle("Save", for: .normal)
        }
    }
    
    @IBAction func Admin(_ sender: UIButton) {
            showAdminConfirmationAlert()
        }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this staff?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
//            self.deleteStaff()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func fetchStaffDetails(
        staffId: String,
        completion: @escaping (Result<StaffDetail, APIManager.APIError>) -> Void
    ) {

        let token = UserDefaults.standard.string(forKey: "user_role_Token") ?? ""

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        APIManager.shared.request(
            endpoint: "staff/registration/\(staffId)",
            method: .get,
            headers: headers
        ) { (result: Result<StaffDetailResponse, APIManager.APIError>) in

            switch result {
            case .success(let response):
                completion(.success(response.data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func enableEditing(_ enable: Bool) {
        if let basicInfoCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StaffBasicInfo {
            basicInfoCell.setEditingEnabled(enable)
        }

        if let accountInfoCell = staffDetailTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? StaffAccountInfo {
            accountInfoCell.setEditingEnabled(enable)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffBasicInfoCell", for: indexPath) as? StaffBasicInfo else {
                return UITableViewCell()
            }

            let infoToUse = staffDetails ?? staffDetails
            if let info = infoToUse {
                cell.populate(with: info, isEditingEnabled: isEditingStaffInfo)
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAccountInfoCell", for: indexPath) as? StaffAccountInfo else {
                return UITableViewCell()
            }

            let infoToUse = staffDetails ?? staffDetails
            if let info = infoToUse {
//                cell.populate(with: info, isEditingEnabled: isEditingStaffInfo)
            }

            return cell
        }
    }
    
    private func showAdminConfirmationAlert() {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to make this staff an admin?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
//            self.makeStaffAdmin()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(yesAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Basic Info" : "Account Info"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
