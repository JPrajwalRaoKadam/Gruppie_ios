import UIKit
protocol AttenSettingCellDelegate: AnyObject {
    func didUpdateAttendance(teamId: String, newValue: String)
}
class AttenSettingTableViewCell: UITableViewCell, UITextFieldDelegate {
    weak var delegate: AttenSettingCellDelegate?

    @IBOutlet weak var nofPeriod: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var classimg: UIImageView!
    @IBOutlet weak var fallbackLabel: UILabel!
    var teamId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckButton()
        classimg.layer.cornerRadius = fallbackLabel.frame.width / 2
        classimg.layer.masksToBounds = true
        classimg.clipsToBounds = true
        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.width / 2
        fallbackLabel.layer.masksToBounds = true
        fallbackLabel.clipsToBounds = true
        nofPeriod.delegate = self
        nofPeriod.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    @objc func textFieldDidChange() {
        guard let teamId = teamId, let newValue = nofPeriod.text else { return }
        delegate?.didUpdateAttendance(teamId: teamId, newValue: newValue)
    }

    func showFallbackImage(for name: String) {
        classimg.image = nil // Ensure the image is nil
        let firstLetter = name.prefix(1).uppercased()

        // Set fallback label text
        fallbackLabel.text = firstLetter
        fallbackLabel.font = UIFont.boldSystemFont(ofSize: 20)
        fallbackLabel.textAlignment = .center
        fallbackLabel.textColor = .white
        classimg.backgroundColor = UIColor.systemIndigo
        fallbackLabel.backgroundColor = .link
        // Ensure the label fills the image view (centered)
        fallbackLabel.frame = classimg.bounds
        classimg.addSubview(fallbackLabel)
    }
    func configureCell(with data: AttendanceModel) {
        teamId = data.teamId
        className.text = data.name
        nofPeriod.text = data.numberOfTimeAttendance
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
         guard let teamId = teamId, let newValue = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newValue.isEmpty else {
             print("Empty or invalid input. Skipping update.")
             return
         }
         print("Updating attendance for teamId: \(teamId) with value: \(newValue)")
         delegate?.didUpdateAttendance(teamId: teamId, newValue: newValue)
     }


    private func setupCheckButton() {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
        checkButton.tintColor = .systemGreen // This sets the checkmark color to green
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }




    @objc func checkButtonTapped() {
        checkButton.isSelected.toggle()
        contentView.backgroundColor = .white
    }
}


