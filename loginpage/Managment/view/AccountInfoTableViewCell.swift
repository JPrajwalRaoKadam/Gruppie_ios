import UIKit

class AccountInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var uanNumber: UITextField!
    @IBOutlet weak var panNumber: UITextField!
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var bankIfsc: UITextField!

    func populate(with accountInfo: [String: String], isEditingEnabled: Bool) {
        uanNumber.text = accountInfo["uanNumber"]
        panNumber.text = accountInfo["panNumber"]
        bankAccount.text = accountInfo["bankAccount"]
        bankIfsc.text = accountInfo["bankIfsc"]

        let fields: [UITextField] = [uanNumber, panNumber, bankAccount, bankIfsc]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: String] {
        return [
            "uanNumber": uanNumber.text ?? "",
            "panNumber": panNumber.text ?? "",
            "bankAccount": bankAccount.text ?? "",
            "bankIfsc": bankIfsc.text ?? ""
        ]
    }
}
