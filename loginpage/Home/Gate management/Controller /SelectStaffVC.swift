
import UIKit

class SelectStaffVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var staffRegister: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!

    var filteredTeachingStaff: [Staff] = []
    var filteredNonTeachingStaff: [Staff] = []
    var isSearching = false
    var teachingStaffData: [Staff] = []
    var nonTeachingStaffData: [Staff] = []
    var token: String?
    var groupId: String?

    var searchTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received groupId: \(groupId ?? "nil")")
        print("token staff register: \(token ?? "nil")")

        heightConstraintOfSearchView.constant = 0
        searchView.isHidden = true

        staffRegister.register(UINib(nibName: "TeachingStaff", bundle: nil), forCellReuseIdentifier: "TeachingStaffCell")
        staffRegister.register(UINib(nibName: "NonTeachingStaff", bundle: nil), forCellReuseIdentifier: "NonTeachingStaffCell")

        staffRegister.delegate = self
        staffRegister.dataSource = self
        staffRegister.estimatedRowHeight = 100
        staffRegister.rowHeight = UITableView.automaticDimension

        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)

        if segmentController.selectedSegmentIndex == 0 {
            fetchTeachingStaffData()
        } else {
            fetchNonTeachingStaffData()
        }
    }

    @IBAction func BackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            teachingStaffData.removeAll()
            fetchTeachingStaffData()
        } else {
            nonTeachingStaffData.removeAll()
            fetchNonTeachingStaffData()
        }
    }

    private func fetchTeachingStaffData() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
           // showAlert(message: "Authentication required")
            return
        }
           guard let groupId = groupId else {
               print("Missing groupId")
               return
           }
           let url = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching"
           print("Fetching teaching staff from: \(url)")
           fetchStaffData(from: url, token: token) { [weak self] staff in
               self?.teachingStaffData = staff
               DispatchQueue.main.async {
                   self?.staffRegister.reloadData()
               }
           }
       }
    private func fetchNonTeachingStaffData() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }

        guard let groupId = groupId else {
            print("❌ Missing groupId")
            return
        }

        let url = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=nonteaching"
        print("Fetching non-teaching staff from: \(url)")

        fetchStaffData(from: url, token: token) { [weak self] staff in
            self?.nonTeachingStaffData = staff
            DispatchQueue.main.async {
                self?.staffRegister.reloadData()
            }
        }
    }


    private func fetchStaffData(from urlString: String, token: String, completion: @escaping ([Staff]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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

        // Optional: fetch staff details if needed
        fetchStaffDetails(staffId: selectedStaff.userId) { [weak self] staffDetails in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // ✅ Post notification with selected staff info
                NotificationCenter.default.post(
                    name: Notification.Name("StaffSelected"),
                    object: nil,
                    userInfo: [
                        "name": selectedStaff.name,
                        "userId": selectedStaff.userId
                    ]
                )

                // Optional: Go back if needed
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func fetchStaffDetails(staffId: String, completion: @escaping (StaffDetailsData?) -> Void) {
        guard let groupId = groupId else { return }
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/user/\(staffId)/profile/get?type=staff"
        print("Fetching staff details from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data, error == nil else {
                print("Error fetching staff details:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
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
