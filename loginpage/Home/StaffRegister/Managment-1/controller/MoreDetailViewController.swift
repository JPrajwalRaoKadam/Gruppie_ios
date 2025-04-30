import UIKit

class MoreDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var moreDetailsTableView: UITableView!
    var groupIds = ""
    var token: String = ""
    var member: Member?
    var isEditingEnabled = false
    var members: [Member]?
    var userId: String?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(groupIds: String, token: String, member: Member?) {
        self.groupIds = groupIds
        self.token = token
        self.member = member
        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Group ID MoreDetail:", groupIds)
        print("User ID MoreDetail:", userId ?? "User ID is nil")
        print("Token MoreDetail:", token)
        editButton.layer.cornerRadius = 10
        editButton.clipsToBounds = true
        moreDetailsTableView.register(UINib(nibName: "BasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
        moreDetailsTableView.register(UINib(nibName: "EducationTableViewCell", bundle: nil), forCellReuseIdentifier: "EducationCell")
        moreDetailsTableView.register(UINib(nibName: "AccountInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")
        moreDetailsTableView.delegate = self
        moreDetailsTableView.dataSource = self
        moreDetailsTableView.separatorStyle = .none
        moreDetailsTableView.estimatedRowHeight = UITableView.automaticDimension
        moreDetailsTableView.rowHeight = UITableView.automaticDimension

        if let member = member {
            name.text = member.name
            designation.text = member.designation
        }
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        print("delete button pressed")
        let alert = UIAlertController(title: "Delete Management",
                                      message: "Are you sure you want to delete this management?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.callDeleteAPI()
        }))
        present(alert, animated: true, completion: nil)
    }
    func callDeleteAPI() {
        guard let userId = userId, !userId.isEmpty else {
            print("❌ User ID is nil or empty")
            return
        }
        let apiUrl = "https://api.gruppie.in/api/v1/groups/\(groupIds)/user/\(userId)/management/delete?type=management"
        guard let url = URL(string: apiUrl) else {
            print("❌ Invalid API URL")
            return
        }
        print("🌍 API URL: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        print("✅ Management deleted successfully.")
                        self.navigateToManagementViewController()
                    }
                } else {
                    print("❌ API call failed. Unable to delete management.")
                }
            }
        }.resume()
    }
    func createFallbackImage(from name: String) -> UIImage? {
        let firstLetter = name.prefix(1).uppercased()
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        UIColor.lightGray.setFill()
        context?.fill(CGRect(origin: .zero, size: size))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.white
        ]
        let textSize = firstLetter.size(withAttributes: attributes)
        let point = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
        firstLetter.draw(at: point, withAttributes: attributes)
        let fallbackImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fallbackImage
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = {
            switch section {
            case 0: return "Basic Info"
            case 1: return "Education and Profession"
            case 2: return "Account Info"
            default: return nil
            }
        }()
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as? BasicInfoTableViewCell {
                if let member = member {
                    cell.populate(with: member, isEditingEnabled: isEditingEnabled)
                }
                return cell
            }
            return UITableViewCell()
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as? EducationTableViewCell ?? UITableViewCell()
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as? AccountInfoTableViewCell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    @IBAction func Edit(_ sender: UIButton) {
        if isEditingEnabled {
            saveUpdatedData()
        }
        isEditingEnabled.toggle()
        editButton.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)
        moreDetailsTableView.reloadData()
    }
    func saveUpdatedData() {
        guard let basicInfoCell = moreDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BasicInfoTableViewCell else {
            print("❌ Could not retrieve BasicInfoTableViewCell")
            return
        }
        let basicData = basicInfoCell.collectUpdatedData()
        guard let educationCell = moreDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? EducationTableViewCell else {
            print("❌ Could not retrieve EducationTableViewCell")
            return
        }
        let educationData = educationCell.collectUpdatedData()
        guard let accountCell = moreDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? AccountInfoTableViewCell else {
            print("❌ Could not retrieve AccountInfoTableViewCell")
            return
        }
        let accountData = accountCell.collectUpdatedData()
        var requestBody: [String: Any] = basicData
        educationData.forEach { requestBody[$0.key] = $0.value }
        accountData.forEach { requestBody[$0.key] = $0.value }
        print("📦 Final Request Body to API:", requestBody)
        callEditAPI(requestBody)
    }
    func callEditAPI(_ requestBody: [String: Any]) {
        guard let userId = userId, !userId.isEmpty else {
            print("❌ User ID is nil or empty")
            return
        }
        guard let url = URL(string: "https://api.gruppie.in/api/v1/groups/\(groupIds)/user/\(userId)/management/edit") else {
            print("❌ Invalid API URL")
            return
        }
        print("🌍 API URL: \(url.absoluteString)")
        print("📩 Request Body: \(requestBody)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ JSON Serialization Error: \(error.localizedDescription)")
            return
        }
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response Status Code: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📨 API Response Data: \(responseString)")
            }
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("✅ Data successfully saved into API.")
                    self.navigateToManagementViewController()
                } else {
                    print("❌ API call failed. Data not saved.")
                }
            }
        }.resume()
    }
    func navigateToManagementViewController() {
        navigationController?.popViewController(animated: true)
    }
}
