import UIKit

class AddStudentTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var newAdmissionButton: UIButton!

    var isNewAdmission: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        phone.delegate = self
        phone.keyboardType = .numberPad  
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == phone else { return true }

        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacterSet.isSuperset(of: characterSet) {
            return false
        }

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 10
    }
}
