import UIKit

class AddRegularClassCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource, AddRegularClassLabelCellDelegate {

    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var noOfSection: UILabel!
    @IBOutlet weak var TableView: UITableView!

    var classData: [ClassItem] = []
    weak var parentDelegate: AddRegularClassLabelCellDelegate? // Reference to parent delegate

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }

    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self
        
        let nib = UINib(nibName: "AddRegularClassLabelCell", bundle: nil)
        TableView.register(nib, forCellReuseIdentifier: "AddRegularClassLabelCell")
        
        TableView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(className)   // Ensure labels are visible
        bringSubviewToFront(noOfSection) // Ensure labels are visible
    }

    // MARK: - UITableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddRegularClassLabelCell", for: indexPath) as? AddRegularClassLabelCell else {
            return UITableViewCell()
        }

        let classItem = classData[indexPath.row]
        cell.configure(with: classItem, indexPath: indexPath)
        cell.delegate = parentDelegate // Assign parent delegate
        cell.className.text = classItem.className
        cell.noOfSections.text = "\(classItem.noOfSections)"
        return cell
    }

    // MARK: - UITableView Delegate Methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func didTapIncrementButton(for classItem: ClassItem, at indexPath: IndexPath) {
        parentDelegate?.didTapIncrementButton(for: classItem, at: indexPath)
    }

}
