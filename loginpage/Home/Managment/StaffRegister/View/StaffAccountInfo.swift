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

    func populate(with accountInfo: StaffDetailsData, isEditingEnabled: Bool) {
        uanNumber.text = accountInfo.uanNumber
        panNumber.text = accountInfo.panNumber
        bankAccount.text = accountInfo.bankAccount
        bankIfsc.text = accountInfo.bankIfsc

        // Enable or disable user interaction based on editing mode
        allTextFields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> StaffDetailsData {
        return StaffDetailsData(
            staffId: nil,
            aadharNumber: nil,
            address: nil,
            bankAccountNumber: bankAccount.text ?? "",
            bankIfscCode: bankIfsc.text ?? "",
            bloodGroup: nil,
            caste: nil,
            designation: nil,
            disability: nil,
            dob: nil,
            doj: nil,
            email: nil,
            gender: nil,
            image: nil,
            name: nil,
            panNumber: panNumber.text ?? "",
            phone: nil,
            qualification: nil,
            religion: nil,
            staffCategory: nil,
            type: nil,
            uanNumber: uanNumber.text ?? "",
            classType: nil,
            country: "",
            className: "",
            emailId: "",
            aadharNo: "",
            bankAccount: bankAccount.text ?? "",
            bankIfsc: bankIfsc.text ?? ""
        )
    }



    // Dismiss keyboard when pressing "Return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func setEditingEnabled(_ isEnabled: Bool) {
        allTextFields.forEach { $0.isUserInteractionEnabled = isEnabled }
    }

}
