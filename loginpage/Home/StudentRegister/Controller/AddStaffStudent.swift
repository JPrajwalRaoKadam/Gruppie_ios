import UIKit

class AddStaffStudent: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var token: String = ""
    var groupId: String = ""
    var userId: String = ""
    var staffList: [StaffMember] = [] // Store fetched staff data
    var selectedStaff: [String: Bool] = [:] // Track selected staff by userId

    @IBAction func AddButton(_ sender: Any) {
        let selectedMembers = staffList.filter { selectedStaff[$0.userId ?? ""] == true }
        
        if selectedMembers.isEmpty {
            print("No staff selected")
        } else {
            var processedCount = 0
            let totalCount = selectedMembers.count
            
            for staff in selectedMembers {
                assignStaffToClass(userId: staff.userId ?? "") { success in
                    processedCount += 1
                    
                    // If all requests are completed, navigate back
                    if processedCount == totalCount {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Token AddStaffStudent: \(token)")
        print("Group ID AddStaffStudent: \(groupId)")
        print("User ID AddStaffStudent: \(userId)")

        // Register the TableViewCell
        TableView.register(UINib(nibName: "AddStaffStudentCellTableViewCell", bundle: nil), forCellReuseIdentifier: "AddStaffStudentCell")

        
        addButton.layer.cornerRadius = 10 // Adjust the value as needed
            addButton.layer.masksToBounds = true

        // Set delegate & dataSource
        TableView.delegate = self
        TableView.dataSource = self

        // Enable automatic cell height
        TableView.estimatedRowHeight = 100
        TableView.rowHeight = UITableView.automaticDimension

        TableView.layer.cornerRadius = 15  // Adjust the radius as needed
        TableView.layer.masksToBounds = true

        if let addButton = self.view.viewWithTag(1) as? UIButton {
            addButton.layer.cornerRadius = addButton.frame.height / 2
            addButton.clipsToBounds = true
        }
    }

    // MARK: - API Call to Assign Staff to Class
    func assignStaffToClass(userId: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://api.gruppie.in/api/v1/groups/62b4265f97d24b15e8123155/team/62b4265f97d24b15e8123158/assign/class/teacher"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response")
                    completion(false)
                    return
                }

                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("✅ API Response: \(jsonResponse)")

                        if httpResponse.statusCode == 200 {
                            print("✅ Staff assigned successfully!")
                            completion(true)
                        } else {
                            print("⚠️ Failed to assign staff. Status Code: \(httpResponse.statusCode)")
                            completion(false)
                        }
                    } catch {
                        print("❌ JSON Parsing Error: \(error.localizedDescription)")
                        completion(false)
                    }
                } else {
                    print("❌ No data received")
                    completion(false)
                }
            }
        }
        task.resume()
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffList.count // Use actual staff data count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddStaffStudentCell", for: indexPath) as? AddStaffStudentCellTableViewCell else {
            return UITableViewCell()
        }

        let staffMember = staffList[indexPath.row]
        let isSelected = selectedStaff[staffMember.userId ?? ""] ?? false // Get selection state

        cell.configure(with: staffMember.name ?? "Unknown", isSelected: isSelected)

        // Handle selection toggle inside cell
        cell.selectButton.tag = indexPath.row
        cell.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)

        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Handle Selection
    @objc func selectButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let staffUserId = staffList[index].userId ?? ""

        // Toggle selection state
        selectedStaff[staffUserId] = !(selectedStaff[staffUserId] ?? false)

        // Reload only the affected row
        let indexPath = IndexPath(row: index, section: 0)
        TableView.reloadRows(at: [indexPath], with: .none)
    }

    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
