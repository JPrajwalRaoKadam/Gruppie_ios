import UIKit

class StudentSubjectTableViewCell: UITableViewCell {

    @IBOutlet weak var StudentName: UILabel!
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
    func configure(with student: Student, isSelected: Bool) {
        self.isSelectedState = isSelected
        StudentName.text = student.name
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
            print("✅ Selected subject: \(StudentName.text ?? "")")
        } else {
            print("❌ Deselected subject: \(StudentName.text ?? "")")
        }

        checkBoxTappedAction?()  // ✅ Notify controller
    }

}
