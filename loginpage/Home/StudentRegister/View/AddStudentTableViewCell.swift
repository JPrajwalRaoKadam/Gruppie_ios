import UIKit

class AddStudentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var newAdmissionButton: UIButton!

    var isNewAdmission: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        updateNewAdmissionButton()
    }

    @IBAction func NewAdmission(_ sender: UIButton) {
        isNewAdmission.toggle()
        updateNewAdmissionButton()
    }

    private func updateNewAdmissionButton() {
        if isNewAdmission {
            newAdmissionButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            newAdmissionButton.setImage(UIImage(systemName: "square"), for: .normal) 
        }
    }
}
