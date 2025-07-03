import UIKit

protocol AddSubjectTableViewCellDelegate: AnyObject {
    func didTapCheckBox(for subject: SubjectDetail)
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
        updateCheckbox(isSelected: isSelected)
    }

    private func updateCheckbox(isSelected: Bool) {
        let imageName = isSelected ? "checkmark.square.fill" : "square"
        CheckBox.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func checkBoxTapped(_ sender: UIButton) {
        guard let subject = subject else { return }
        delegate?.didTapCheckBox(for: subject) 
    }

    }

