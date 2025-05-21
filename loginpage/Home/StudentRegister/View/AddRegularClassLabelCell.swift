import UIKit

protocol AddRegularClassLabelCellDelegate: AnyObject {
    func didTapIncrementButton(for classItem: ClassItem, at indexPath: IndexPath)
}

class AddRegularClassLabelCell: UITableViewCell {
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var noOfSections: UILabel!
    @IBOutlet weak var incrementButton: UIButton!

    weak var delegate: AddRegularClassLabelCellDelegate?
    var classItem: ClassItem?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
    }

    func configure(with item: ClassItem, indexPath: IndexPath) {
        self.classItem = item
        self.indexPath = indexPath
        className.text = item.className
        noOfSections.text = "\(item.noOfSections)"
    }

    @objc private func incrementTapped() {
        guard let item = classItem, let indexPath = indexPath else { return }
        delegate?.didTapIncrementButton(for: item, at: indexPath)
    }
}
