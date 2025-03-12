import UIKit

// MARK: - Define Protocol for Delegate
protocol StaffSubjectTableViewCellDelegate: AnyObject {
    func didTapCheckBox(for staff: Staffs)
}

class StaffSubjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var StaffName: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!

    weak var delegate: StaffSubjectTableViewCellDelegate?
    var staffMember: Staffs?
    private var isSelectedState: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckBoxButton()
    }

    // MARK: - Configure Cell
    func configure(with staff: Staffs, isSelected: Bool) {
        self.staffMember = staff
        self.isSelectedState = isSelected
        StaffName.text = staff.name

        updateButtonAppearance()
    }

    // MARK: - Setup Checkbox Button (Initial Styling)
    private func setupCheckBoxButton() {
        checkBoxButton.setImage(nil, for: .normal) // Ensure no image initially
    }

    @IBAction func checkBoxButtonTapped(_ sender: UIButton) {
        isSelectedState.toggle()
        updateButtonAppearance()

        if let staff = staffMember {
            delegate?.didTapCheckBox(for: staff)
        }
    }

    // MARK: - Update Button Appearance
    private func updateButtonAppearance() {
        if isSelectedState {
            checkBoxButton.backgroundColor = .black
            checkBoxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkBoxButton.tintColor = .white
        } else {
            checkBoxButton.backgroundColor = .clear
            checkBoxButton.setImage(nil, for: .normal)
        }
    }
}
