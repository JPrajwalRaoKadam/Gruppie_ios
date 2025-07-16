
import UIKit
class A2SubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectsName: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var subjectId: String = ""
    var onCheckButtonTapped: ((String, Bool) -> Void)? // (subjectId, isSelected)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckButton(initiallySelected: false)
    }

    private func setupCheckButton(initiallySelected: Bool) {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
        checkButton.isSelected = initiallySelected
        checkButton.tintColor = .systemGreen
        checkButton.backgroundColor = .white
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        onCheckButtonTapped?(subjectId, sender.isSelected)
    }
    
}

