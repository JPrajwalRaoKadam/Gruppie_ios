import UIKit

class AddRegularClassCell1: UITableViewCell, UITableViewDelegate, UITableViewDataSource, AddRegularClassLabelCellDelegate {

    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var noOfSection: UILabel!
    @IBOutlet weak var TableView: UITableView!

    var classData: [ClassItem] = []
    weak var parentDelegate: AddRegularClassLabelCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }

    private func setupTableView() {
        TableView.delegate = self
        TableView.dataSource = self
        
        let nib = UINib(nibName: "AddRegularClassLabelCell1", bundle: nil)
        TableView.register(nib, forCellReuseIdentifier: "AddRegularClassLabelCell1")
        
        TableView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(className)
        bringSubviewToFront(noOfSection)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddRegularClassLabelCell1", for: indexPath) as? AddRegularClassLabelCell1 else {
            return UITableViewCell()
        }

        let classItem = classData[indexPath.row]
        cell.configure(with: classItem, indexPath: indexPath)
        cell.delegate = parentDelegate as! any AddRegularClassLabelCellDelegate1
        cell.className.text = classItem.className
        cell.noOfSections.text = "\(classItem.noOfSections)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func didTapIncrementButton(for classItem: ClassItem, at indexPath: IndexPath) {
        parentDelegate?.didTapIncrementButton(for: classItem, at: indexPath)
    }

}
