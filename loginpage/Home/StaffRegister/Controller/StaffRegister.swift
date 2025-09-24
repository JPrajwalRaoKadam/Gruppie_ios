import UIKit

class StaffRegister: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var staffRegister: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    
    // Add this outlet - make sure to connect it in your storyboard
    @IBOutlet weak var backButton: UIButton!
    
    var filteredTeachingStaff: [Staff] = []
    var filteredNonTeachingStaff: [Staff] = []
    var isSearching = false
    var staffDetails: StaffDetailsData?
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var teachingStaffData: [Staff] = []
    var nonTeachingStaffData: [Staff] = []
    var token: String?
    var groupIds = ""
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
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

        if segmentController.selectedSegmentIndex == 1 {
            fetchNonTeachingStaffData()
        }
        
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

    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            nonTeachingStaffData.removeAll()
            fetchNonTeachingStaffData()
        } else {
            staffRegister.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == 0 {
            return isSearching ? filteredTeachingStaff.count : teachingStaffData.count
        } else {
            let data = isSearching ? filteredNonTeachingStaff : nonTeachingStaffData
            return max(1, data.count)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentController.selectedSegmentIndex == 0 {
            let staff = isSearching ? filteredTeachingStaff[indexPath.row] : teachingStaffData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeachingStaffCell", for: indexPath)
            if let teachingCell = cell as? TeachingStaff {
                teachingCell.configureCell(with: staff)
            }
            return cell
        } else {
            let data = isSearching ? filteredNonTeachingStaff : nonTeachingStaffData
            if data.isEmpty {
                let emptyCell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
                emptyCell.textLabel?.text = "No Data Available"
                emptyCell.textLabel?.textColor = .gray
                emptyCell.selectionStyle = .none
                return emptyCell
            } else {
                let staff = data[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "NonTeachingStaffCell", for: indexPath)
                if let nonTeachingCell = cell as? NonTeachingStaff {
                    nonTeachingCell.configureCell(with: staff)
                }
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStaff: Staff
        if segmentController.selectedSegmentIndex == 0 {
            selectedStaff = isSearching ? filteredTeachingStaff[indexPath.row] : teachingStaffData[indexPath.row]
        } else {
            selectedStaff = isSearching ? filteredNonTeachingStaff[indexPath.row] : nonTeachingStaffData[indexPath.row]
        }

        fetchStaffDetails(staffId: selectedStaff.userId) { [weak self] staffDetails in
            guard let self = self, let staffDetails = staffDetails else { return }
            DispatchQueue.main.async {
                self.navigateToStaffDetailViewController(with: staffDetails)
            }
        }
    }

    private func navigateToStaffDetailViewController(with staffDetails: StaffDetailsData) {
        guard let staffDetailVC = storyboard?.instantiateViewController(withIdentifier: "StaffDetailViewController") as? StaffDetailViewController else {
            print("Error: StaffDetailViewController could not be instantiated")
            return
        }
        print("staffDetals passing:\(staffDetails)")
        staffDetailVC.staffDetails = staffDetails
        staffDetailVC.token = token
        staffDetailVC.groupId = groupIds

        navigationController?.pushViewController(staffDetailVC, animated: true)
    }

    private func fetchNonTeachingStaffData() {
        let nonTeachingURL = APIManager.shared.baseURL + "groups/\(groupIds)/staff/get?type=nonteaching"

        print("Fetching non-teaching staff from: \(nonTeachingURL)")

        fetchStaffData(from: nonTeachingURL) { [weak self] staff in
            self?.nonTeachingStaffData = staff
            DispatchQueue.main.async {
                self?.staffRegister.reloadData()
            }
        }
    }

    private func fetchStaffDetails(staffId: String, completion: @escaping (StaffDetailsData?) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupIds)/user/\(staffId)/profile/get?type=staff"

        // Print the API URL
        print("Fetching staff details from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)") // Print the status code
            }

            guard let data = data, error == nil else {
                print("Error fetching staff details:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawResponse)")
            }

            do {
                let response = try JSONDecoder().decode(StaffDetailsResponse.self, from: data)
                completion(response.data)
            } catch {
                print("Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }

    private func fetchStaffData(from urlString: String, completion: @escaping ([Staff]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching staff data:", error?.localizedDescription ?? "Unknown error")
                completion([])
                return
            }

            do {
                let responseModel = try JSONDecoder().decode(StaffResponse.self, from: data)
                completion(responseModel.data)
            } catch {
                print("Error decoding staff data:", error)
                completion([])
            }
        }.resume()
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
    
    func filterMembers(textField: String) {
        if textField.isEmpty {
            isSearching = false
            staffRegister.reloadData()
            return
        }

        isSearching = true
        let searchText = textField.lowercased()
        
        if segmentController.selectedSegmentIndex == 0 {
            filteredTeachingStaff = teachingStaffData.filter { $0.name.lowercased().contains(searchText) }
        } else {
            filteredNonTeachingStaff = nonTeachingStaffData.filter { $0.name.lowercased().contains(searchText) }
        }

        staffRegister.reloadData()
    }

    
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    filterMembers(textField: searchText)
    return true
}
}
