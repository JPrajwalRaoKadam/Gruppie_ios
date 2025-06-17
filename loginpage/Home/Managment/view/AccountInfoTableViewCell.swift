import UIKit

class AccountInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var selectAccountType: UITextField!
    @IBOutlet weak var bankIfsc: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var branch: UITextField!
    @IBOutlet weak var address: UITextField!

    func populate(with member: Member, isEditingEnabled: Bool) {
        bankAccount.text = member.staffId
        selectAccountType.text = member.profession
        bankIfsc.text = member.aadharNumber
        bankName.text = member.name
        branch.text = member.religion
        address.text = member.address

        let fields: [UITextField] = [
            bankAccount, selectAccountType, bankIfsc, bankName, branch, address
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "bankAccount": bankAccount.text ?? "",
            "selectAccountType": selectAccountType.text ?? "",
            "bankIfsc": bankIfsc.text ?? "",
            "bankName": bankName.text ?? "",
            "branch": branch.text ?? "",
            "address": address.text ?? ""
        ]
    }
}
