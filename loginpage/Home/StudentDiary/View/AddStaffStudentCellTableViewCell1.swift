import UIKit

class AddStaffStudentCellTableViewCell1: UITableViewCell {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    private var isSelectedState: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        updateButtonAppearance()
    }

    @IBAction func selectButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
        updateButtonAppearance()
    }

    private func updateButtonAppearance() {
        let imageName = isSelectedState ? "checkmark.circle.fill" : "circle"
        selectButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    func configure(with name: String, isSelected: Bool) {
        nameLabel.text = name
        self.isSelectedState = isSelected
        updateButtonAppearance()
    }
}
