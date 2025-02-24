import UIKit

class StaffRegister: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var staffRegister: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var staffDetails: StaffDetailsData?
    
    var teachingStaffData: [Staff] = []
    var nonTeachingStaffData: [Staff] = []
    var token: String?
    var groupIds = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        staffRegister.register(UINib(nibName: "TeachingStaff", bundle: nil), forCellReuseIdentifier: "TeachingStaffCell")
        staffRegister.register(UINib(nibName: "NonTeachingStaff", bundle: nil), forCellReuseIdentifier: "NonTeachingStaffCell")

        staffRegister.delegate = self
        staffRegister.dataSource = self

        staffRegister.estimatedRowHeight = 100
        staffRegister.rowHeight = UITableView.automaticDimension

        if segmentController.selectedSegmentIndex == 1 {
            fetchNonTeachingStaffData()
        }
    }

    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
        return segmentController.selectedSegmentIndex == 0 ? teachingStaffData.count : max(1, nonTeachingStaffData.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentController.selectedSegmentIndex == 0 {
            let staff = teachingStaffData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeachingStaffCell", for: indexPath)
            if let teachingCell = cell as? TeachingStaff {
                teachingCell.configureCell(with: staff)
            }
            return cell
        } else {
            if nonTeachingStaffData.isEmpty {
                let emptyCell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
                emptyCell.textLabel?.text = "No Data Available"
                emptyCell.textLabel?.textColor = .gray
                emptyCell.selectionStyle = .none
                return emptyCell
            } else {
                let staff = nonTeachingStaffData[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "NonTeachingStaffCell", for: indexPath)
                if let nonTeachingCell = cell as? NonTeachingStaff {
                    nonTeachingCell.configureCell(with: staff)
                }
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStaff = segmentController.selectedSegmentIndex == 0 ? teachingStaffData[indexPath.row] : nonTeachingStaffData[indexPath.row]

        print("Selected Staff: \(selectedStaff.name)")

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
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
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
}
