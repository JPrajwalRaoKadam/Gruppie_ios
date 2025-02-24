import UIKit

class MoreDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var MoreDetailsTableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!

    var groupIds = ""
    var token: String?
    var member: Member?
    var selectedSegmentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the custom table view cells
        MoreDetailsTableView.register(UINib(nibName: "AccountInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")
        MoreDetailsTableView.register(UINib(nibName: "BasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")

        MoreDetailsTableView.delegate = self
        MoreDetailsTableView.dataSource = self

        // Populate member details if available
        if let member = member {
            name.text = member.name
            // Set image and other details if necessary
        }

        updateTableViewForSelectedSegment()
    }

    // MARK: - UITableView Delegate & DataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only one section, we will change the cells based on the segment
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Return 1 row for each cell type (you can change this logic if you have multiple rows per section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedSegmentIndex {
        case 0: // Basic Info
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as? BasicInfoTableViewCell {
                // Configure the BasicInfoTableViewCell
                return cell
            }
        case 1: // Account Info
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as? AccountInfoTableViewCell {
                // Configure the AccountInfoTableViewCell
                return cell
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }

    // MARK: - Segment Control Action

    @IBAction func segmentButton(_ sender: Any) {
        selectedSegmentIndex = segmentController.selectedSegmentIndex
        updateTableViewForSelectedSegment()
    }

    // Method to update the table view based on the selected segment
    func updateTableViewForSelectedSegment() {
        MoreDetailsTableView.reloadData()
    }
}
