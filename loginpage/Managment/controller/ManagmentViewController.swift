import UIKit

class ManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBAction func addUser(_ sender: UIButton) {
        // Call the API when the "Add User" button is tapped
        callAddManagementAPI()
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    var filteredMembers: [Member] = [] // Array to store filtered members based on search text

    var token: String?
    var groupIds = ""
    var members: [Member] = []

    var searchTextField: UITextField?
    var searchButtonTapped = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let token = token {
            print("Received token in management: \(token)")
        } else {
            print("Received token: No token provided")
        }

//        print("Received groupIds: \(groupIds.isEmpty ? "No Group IDs" : groupIds.joined(separator: ", "))")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "Member_TableViewCell", bundle: nil), forCellReuseIdentifier: "Member_TableViewCell")

        searchView.isHidden = true
        filteredMembers = members // Initially, no search, so display all members

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredMembers.count
           return members.count
// Show filtered members count
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Member_TableViewCell", for: indexPath) as? Member_TableViewCell {
            let member = members[indexPath.row]
            cell.configureCell(with: member)
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = members[indexPath.row]
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
                moreDetailVC.token = self.token!
                moreDetailVC.groupIds = self.groupIds
                moreDetailVC.member = member

                print("Navigating to MoreDetailViewController with member: \(member)")

//                self.navigationController?.pushViewController(moreDetailVC, animated: true)
                
                self.present(moreDetailVC, animated: true, completion: nil)
            } else {
                print("Failed to instantiate MoreDetailViewController from Management storyboard.")
            }
        }
    }

    func callAddManagementAPI() {
        guard let token = token else {
            print("Token is nil, cannot make API call.")
            return
        }

        guard let groupId = groupIds.first else {
            print("No group ID available.")
            return
        }

        let apiUrlString = APIManager.shared.baseURL + "groups/62b4265f97d24b15e8123155/management/add"
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

            // Directly navigate to AddSingleManagement if data is received
            DispatchQueue.main.async {
                print("Navigating to AddSingleManagement now...")
                self.navigateToAddManagement()
            }
        }

        task.resume()
    }

    func navigateToAddManagement() {
        // Debugging to check if navigation is happening
        print("Trying to navigate to AddSingleManagement view controller...")

        let managementStoryboard = UIStoryboard(name: "Management", bundle: nil)

        DispatchQueue.main.async {
            if let addManagementVC = managementStoryboard.instantiateViewController(withIdentifier: "AddSingleManagement") as? AddSingleManagement {
                addManagementVC.token = self.token
                addManagementVC.groupIds = self.groupIds 

                print("Successfully instantiated AddSingleManagement view controller.")
                
                // Check if we have a navigation controller before trying to push
                if let navigationController = self.navigationController {
                    print("Pushing to AddSingleManagement view controller...")
                    navigationController.pushViewController(addManagementVC, animated: true)
                } else {
                    print("Navigation controller is nil. Can't push to AddSingleManagement.")
                    // Fallback to modal presentation
                    self.present(addManagementVC, animated: true, completion: nil)
                }
            } else {
                print("Failed to instantiate AddSingleManagement view controller.")
            }
        }
    }


    @objc func backButtonTapped() {
        if let _ = self.navigationController?.viewControllers {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func searchButtonTappedAction() {
           searchView.isHidden = !searchView.isHidden

           if !searchView.isHidden {
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

       // MARK: - Search Logic

       // This method will filter members based on the search text
    func filterMembers(searchText: String) {
        print("Search text entered: '\(searchText)'")  // Debugging: Print the search text
        
        // Convert the search text to lowercase for case-insensitive comparison
        let lowercasedSearchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        // If the search text is empty, show all members
        if lowercasedSearchText.isEmpty {
            filteredMembers = members
            print("No search text, showing all members.")  // Debugging
        } else {
            // Filter members where the name contains the search text (case-insensitive)
            filteredMembers = members.filter { member in
                // Convert member's name to lowercase for case-insensitive matching
                let lowercasedName = member.name.lowercased()

                // Debugging: Show the comparison between member's name and search text
                print("Comparing member's name: \(lowercasedName) with search text: \(lowercasedSearchText)")

                // Check if the member's name contains the search text
                return lowercasedName.contains(lowercasedSearchText)
            }
        }

        // Debugging: Print filtered results count
        print("Filtered members count: \(filteredMembers.count)")  // Debugging
        tableView.reloadData()  // Reload table view with filtered data
    }


    // UITextField delegate method to handle search text changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterMembers(searchText: searchText) // Call the filter method whenever the user types
        return true
    }


}
