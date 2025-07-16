import UIKit

class ManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBAction func addUser(_ sender: UIButton) {
        callAddManagementAPI()
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    
    var filteredMembers: [Member] = []
    var token: String?
    var groupIds = ""
    var members: [Member] = []
    var searchTextField: UITextField?
    var searchButtonTapped = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heightConstraintOfSearchView.constant = 0
        print("groupId:\(groupIds)")
        if let token = token {
            print("Received token in management: \(token)")
        } else {
            print("Received token: No token provided")
        }
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UINib(nibName: "Member_TableViewCell", bundle: nil), forCellReuseIdentifier: "Member_TableViewCell")
        searchView.isHidden = true
        filteredMembers = members
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredMembers.count
           return members.count
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Member_TableViewCell", for: indexPath) as? Member_TableViewCell {
            let member = filteredMembers[indexPath.row]
            cell.configureCell(with: member)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = filteredMembers[indexPath.row]
        guard indexPath.row < groupIds.count else {
            print("Error: Index out of bounds for groupIds array.")
            return
        }
        let selectedGroupId = groupIds
        callDynamicAPI(groupId: selectedGroupId, member: member) { [weak self] success, updatedMember in
            if success, let updatedMember = updatedMember {
                print("Fetched API Response: \(updatedMember)")
                self?.navigateToMoreDetailsViewController(member: updatedMember)
            } else {
                print("API call failed, navigation will still happen.")
                self?.navigateToMoreDetailsViewController(member: member)
            }
        }
    }
    func callDynamicAPI(groupId: String, member: Member, completion: @escaping (Bool, Member?) -> Void) {
        guard let token = token else {
            print("Token is nil, cannot make API call.")
            completion(false, nil)
            return
        }
        let apiUrlString = APIManager.shared.baseURL + "groups/\(groupId)/user/\(member.userId)/management/get"
        guard let url = URL(string: apiUrlString) else {
            print("Invalid URL: \(apiUrlString)")
            completion(false, nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            guard let data = data else {
                print("No data received from API")
                completion(false, nil)
                return
            }
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawString)")
            }
            if data.isEmpty {
                print("API response is empty, using original member.")
                completion(true, member)
                return
            }
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(Member.self, from: data)

                print("Parsed API Response: \(apiResponse)")

                if apiResponse.userId.isEmpty || apiResponse.name.isEmpty {
                    print("API response has invalid or empty data, using the original member.")
                    completion(true, member)
                } else {
                    completion(true, apiResponse)
                }
            } catch {
                print("Failed to parse API response: \(error.localizedDescription)")
                completion(true, member)
            }
        }
        task.resume()
    }
    func navigateToMoreDetailsViewController(member: Member) {
        let managementStoryboard = UIStoryboard(name: "Management", bundle: nil)
        DispatchQueue.main.async {
            if let moreDetailVC = managementStoryboard.instantiateViewController(withIdentifier: "MoreDetailViewController") as? MoreDetailViewController {
                moreDetailVC.token = self.token ?? ""
                moreDetailVC.groupIds = self.groupIds
                moreDetailVC.member = member
                moreDetailVC.userId = member.userId
                print("Navigating to MoreDetailViewController with member: \(member)")
                self.navigationController?.pushViewController(moreDetailVC, animated: true)
            } else {
                print("Failed to instantiate MoreDetailViewController from Management storyboard.")
            }
        }
    }
    func callAddManagementAPI() {
        guard let token = token else {
            print("Token is nil, cannot make API call")
            return
        }
        guard let groupId = groupIds.first else {
            print("No group ID available.")
            return
        }
        let apiUrlString = APIManager.shared.baseURL + "groups/\(groupIds)/management/add"
        guard let url = URL(string: apiUrlString) else {
            print("Invalid URL: \(apiUrlString)")
            return
        }
        print("API URL: \(apiUrlString)")
        print("Group ID: \(groupId)")
        print("Token: \(token)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let managementData: [[String: String]] = [
            ["countryCode": "IN", "designation": "zbgs", "name": "hshs sh", "phone": "9764575575"]
        ]
        let body: [String: Any] = ["managementData": managementData]
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = bodyData
        } catch {
            print("Error serializing JSON body: \(error.localizedDescription)")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API request: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received from API")
                return
            }
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(rawString)")
            }
            DispatchQueue.main.async {
                print("Navigating to AddSingleManagement now...")
                self.navigateToAddManagement()
            }
        }
        task.resume()
    }
    func navigateToAddManagement() {
        print("Trying to navigate to AddSingleManagement view controller...")
        let managementStoryboard = UIStoryboard(name: "Management", bundle: nil)
        DispatchQueue.main.async {
            if let addManagementVC = managementStoryboard.instantiateViewController(withIdentifier: "AddSingleManagement") as? AddSingleManagement {
                addManagementVC.token = self.token
                addManagementVC.groupIds = self.groupIds 
                print("Successfully instantiated AddSingleManagement view controller.")
                self.navigationController?.pushViewController(addManagementVC, animated: true)
            } else {
                print("Failed to instantiate AddSingleManagement view controller.")
            }
        }
    }
    @objc func backButtonTapped() {
            self.navigationController?.popViewController(animated: true)
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
        func filterMembers(searchText: String) {
        print("Search text entered: '\(searchText)'")
        let lowercasedSearchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        if lowercasedSearchText.isEmpty {
            filteredMembers = members
            print("No search text, showing all members.")
        } else {
            filteredMembers = members.filter { member in
                let lowercasedName = member.name.lowercased()
                print("Comparing member's name: \(lowercasedName) with search text: \(lowercasedSearchText)")
                return lowercasedName.contains(lowercasedSearchText)
            }
        }
        print("Filtered members count: \(filteredMembers.count)")
        tableView.reloadData()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterMembers(searchText: searchText)
        return true
    }
}
