import UIKit

protocol AddSubjectTableViewCellDelegate: AnyObject {
    func didTapCheckBox(for subject: SubjectDetail)  // Make sure SubjectDetail is used
}

class AddSubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var CheckBox: UIButton!
    
    weak var delegate: AddSubjectTableViewCellDelegate?
    private var subject: SubjectDetail?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with subject: SubjectDetail, isSelected: Bool) {
        self.subject = subject
        Subject.text = subject.subjectName
        updateCheckbox(isSelected: isSelected) // ✅ Ensures correct state on reuse
    }

    private func updateCheckbox(isSelected: Bool) {
        let imageName = isSelected ? "checkmark.square.fill" : "square"
        CheckBox.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func checkBoxTapped(_ sender: UIButton) {
        guard let subject = subject else { return }
        delegate?.didTapCheckBox(for: subject) // Delegate will handle selection updates
    }

    }

