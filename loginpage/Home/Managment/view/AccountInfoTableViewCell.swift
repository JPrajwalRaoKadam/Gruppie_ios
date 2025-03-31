import UIKit

class AccountInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var selectAccountType: UITextField!
    @IBOutlet weak var bankIfsc: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var branch: UITextField!
    @IBOutlet weak var address: UITextField!

    func populate(with accountInfo: [String: String], isEditingEnabled: Bool) {
        bankAccount.text = accountInfo["bankAccount"]
        selectAccountType.text = accountInfo["selectAccountType"]
        bankIfsc.text = accountInfo["bankIfsc"]
        bankName.text = accountInfo["bankName"]
        branch.text = accountInfo["branch"]
        address.text = accountInfo["address"]

        let fields: [UITextField] = [
            bankAccount, selectAccountType, bankIfsc, bankName, branch, address
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: String] {
        return [
            "bankAccount": bankAccount.text ?? "",
            "selectAccountType": selectAccountType.text ?? "",
            "bankIfsc": bankIfsc.text ?? "",
            "bankName": bankName.text ?? "",
            "branch": branch.text ?? "",
            "address": address.text ?? "",
        ]
    }
}
