import UIKit

class StudentSubjectTableViewCell: UITableViewCell {

    @IBOutlet weak var SubjectName: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!

    var checkBoxTappedAction: (() -> Void)?  // ✅ Closure for action
    
    private var isSelectedState: Bool = false  // ✅ Track selection state
    private var subject: Staffs?  // ✅ Store the subject data

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // ✅ Configure function to bind data
    func configure(with subject: Staffs, isSelected: Bool) {
        self.subject = subject
        self.isSelectedState = isSelected
        SubjectName.text = subject.subjectName ?? "N/A"
        
        updateButtonAppearance()
    }

    // ✅ Update checkbox appearance
    private func updateButtonAppearance() {
        let imageName = isSelectedState ? "checkmark.square.fill" : "square"
        checkBoxButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // ✅ Toggle selection when checkbox is tapped
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        isSelectedState.toggle()  // ✅ Toggle selection state
        updateButtonAppearance()  // ✅ Update UI

        if isSelectedState {
            print("✅ Selected subject: \(subject?.subjectName ?? "N/A")")
        } else {
            print("❌ Deselected subject: \(subject?.subjectName ?? "N/A")")
        }

        checkBoxTappedAction?()  // ✅ Notify controller
    }

}
