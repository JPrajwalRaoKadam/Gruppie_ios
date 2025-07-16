
protocol A3PeriodTableViewCellDelegate: AnyObject {
    func didTogglePeriodSelection(cell: A3PeriodTableViewCell, isSelected: Bool)
}
import UIKit
class A3PeriodTableViewCell: UITableViewCell {
    @IBOutlet weak var PeriodName: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    

    weak var delegate: A3PeriodTableViewCellDelegate? // <-- Add this
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckButton(initiallySelected: false)
    }

    private func setupCheckButton(initiallySelected: Bool) {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkButton.isSelected = initiallySelected
        checkButton.tintColor = .systemGreen
        checkButton.backgroundColor = .white
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.didTogglePeriodSelection(cell: self, isSelected: sender.isSelected)
    }
}
