import UIKit

class StaffAccountInfo: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var uanNumber: UITextField!
    @IBOutlet weak var panNumber: UITextField!
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var bankIfsc: UITextField!

    private var allTextFields: [UITextField] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
    }

    private func setupTextFields() {
        allTextFields = [uanNumber, panNumber, bankAccount, bankIfsc]
        allTextFields.forEach { $0.delegate = self }
    }

    func populate(with accountInfo: StaffAccountInfoModel, isEditingEnabled: Bool) {
        uanNumber.text = accountInfo.uanNumber
        panNumber.text = accountInfo.panNumber
        bankAccount.text = accountInfo.bankAccount
        bankIfsc.text = accountInfo.bankIfsc

        // Enable or disable user interaction based on editing mode
        allTextFields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> StaffAccountInfoModel {
        return StaffAccountInfoModel(
            uanNumber: uanNumber.text ?? "",
            panNumber: panNumber.text ?? "",
            bankAccount: bankAccount.text ?? "",
            bankIfsc: bankIfsc.text ?? ""
        )
    }

    // Dismiss keyboard when pressing "Return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
