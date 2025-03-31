import UIKit

class AddStaffStudentCellTableViewCell: UITableViewCell {

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

    // **Method to update button appearance**
    private func updateButtonAppearance() {
        let imageName = isSelectedState ? "checkmark.circle.fill" : "circle"
        selectButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // **Method to configure the cell with data**
    func configure(with name: String, isSelected: Bool) {
        nameLabel.text = name
        self.isSelectedState = isSelected
        updateButtonAppearance()
    }
}
