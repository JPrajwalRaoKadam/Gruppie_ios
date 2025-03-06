import UIKit

class MoreDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var MoreDetailsTableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var editButton: UIButton!

    var groupIds = ""
    var token: String = ""
    var member: Member?
    var selectedSegmentIndex = 0
    var isEditingEnabled = false
    var members: [Member]?

    // For storyboard-based instantiation
    @IBAction func deleteButton(_ sender: UIButton) {
        showDeleteMessage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Custom initializer for programmatic instantiation
    init(groupIds: String, token: String, member: Member?) {
        self.groupIds = groupIds
        self.token = token
        self.member = member
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells
        MoreDetailsTableView.register(UINib(nibName: "AccountInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")
        MoreDetailsTableView.register(UINib(nibName: "BasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")

        MoreDetailsTableView.delegate = self
        MoreDetailsTableView.dataSource = self

        roundImageView()

        if let member = member {
            name.text = member.name
            if let imageUrlString = member.image, let imageUrl = URL(string: imageUrlString) {
                if let data = try? Data(contentsOf: imageUrl) {
                    image.image = UIImage(data: data)
                }
            } else {
                image.image = createFallbackImage(from: member.name)
            }
        }

        updateTableViewForSelectedSegment()
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

    func roundImageView() {
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedSegmentIndex {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as? BasicInfoTableViewCell {
                if let member = member {
                    cell.populate(with: member, isEditingEnabled: isEditingEnabled)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as? AccountInfoTableViewCell {
                return cell
            }
        default:
            break
        }
        
        // Fallback to returning a default UITableViewCell
        let fallbackCell = UITableViewCell(style: .default, reuseIdentifier: "FallbackCell")
        fallbackCell.textLabel?.text = "Error loading cell"
        fallbackCell.textLabel?.textColor = .red
        return fallbackCell
    }

    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        updateTableViewForSelectedSegment()
    }

    func updateTableViewForSelectedSegment() {
        MoreDetailsTableView.reloadData()
    }

    @IBAction func Edit(_ sender: UIButton) {
        isEditingEnabled.toggle()
        
        // Toggle the button text
        editButton.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)

        // Reload the table to update the cells for editing
        MoreDetailsTableView.reloadData()
        
        if !isEditingEnabled {
            // When "Save" is clicked, collect updated data and call the API
            saveUpdatedData()

            // After saving, navigate back to the previous view controller
            navigateToManagementViewController()
        }
    }

    func saveUpdatedData() {
        if let cell = MoreDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BasicInfoTableViewCell {
            let updatedData = cell.collectUpdatedData()

            let requestBody: [String: Any] = [
                "name": updatedData["name"] ?? "",
                // Other fields here...
            ]

            callEditAPI(requestBody)
        }
    }

    func callEditAPI(_ requestBody: [String: Any]) {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/62b32f1197d24b31c4fa7a1a/user/65ded3c194521b7be87234be/management/edit") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing data: \(error.localizedDescription)")
            return
        }

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API call failed with error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("API call successful")
                }
            } else {
                print("API call failed")
            }
        }.resume()
    }

    func showDeleteMessage() {
        let alertController = UIAlertController(
            title: "Delete",
            message: "Are you sure you want to permanently delete this?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.callDeleteAPI()
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func callDeleteAPI() {
        guard let member = member else {
            print("Error: No member data available for deletion.")
            return
        }

        guard let url = URL(string: APIManager.shared.baseURL + "groups/62b32f1197d24b31c4fa7a1a/user/65ded3c194521b7be87234be/management/delete?type=management") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare the request body using the Member model
        let body: [String: Any] = [
            "userId": member.userId // Member's userId will be passed for deletion
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing data: \(error.localizedDescription)")
            return
        }

        let session = URLSession.shared
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        print("Member successfully deleted: \(member.name)")
                        
                        // Remove the member from local model (in MoreDetailViewController)
                        self.removeMemberFromLocalModel(member)

                        // Reload table view if you're displaying the members in a table
                        self.MoreDetailsTableView.reloadData()

                        // Navigate back to the management view controller
                        self.navigateToManagementViewController()
                    }
                } else {
                    print("Failed to delete member: \(member.name), Status Code: \(httpResponse.statusCode)")
                }
            } else {
                print("No valid response received.")
            }
        }.resume()
    }


    func removeMemberFromLocalModel(_ member: Member) {
        // Assuming you have a local model array like `members` (update accordingly)
        if let index = members?.firstIndex(where: { $0.userId == member.userId }) {
            // Remove member from local model
            self.members?.remove(at: index)
            print("Removed member from local model: \(member.name)")
        } else {
            print("Member not found in local model")
        }
    }

    func navigateToManagementViewController() {
        if let navigationController = self.navigationController {
            for viewController in navigationController.viewControllers {
                if let managementVC = viewController as? ManagementViewController {
                    // Pass updated members array back
                    managementVC.members = self.members ?? []
                    
                    // Reload table view in ManagementViewController
                    managementVC.tableView.reloadData()
                    
                    navigationController.popToViewController(managementVC, animated: true)
                    return
                }
            }
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
