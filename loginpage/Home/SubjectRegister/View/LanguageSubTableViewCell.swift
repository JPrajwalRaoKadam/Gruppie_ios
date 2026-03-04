import UIKit

// MARK: - Protocol for cell button tap
protocol LanguageSubTableViewCellDelegate: AnyObject {
    func didTapAddButton(on cell: LanguageSubTableViewCell)
}

// MARK: - TableView Cell
class LanguageSubTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var type: UILabel!
    
    weak var delegate: LanguageSubTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc func addButtonTapped() {
        delegate?.didTapAddButton(on: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
