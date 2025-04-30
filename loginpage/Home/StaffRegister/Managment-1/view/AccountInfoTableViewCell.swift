import UIKit

class AccountInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var selectAccountType: UITextField!
    @IBOutlet weak var bankIfsc: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var branch: UITextField!
    @IBOutlet weak var address: UITextField!

    // Populate text fields with account info data
    func populate(with member: Member, isEditingEnabled: Bool) {
        // Use relevant member properties if you have them in your Member model
        bankAccount.text = member.staffId  // Assuming a placeholder for the bankAccount, you may change it
        selectAccountType.text = member.profession
        bankIfsc.text = member.aadharNumber  // Replace this with the actual data
        bankName.text = member.name  // Example mapping
        branch.text = member.religion  // Example mapping
        address.text = member.address

        let fields: [UITextField] = [
            bankAccount, selectAccountType, bankIfsc, bankName, branch, address
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    // Collect updated account info data
    func collectUpdatedData() -> [String: String] {
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
