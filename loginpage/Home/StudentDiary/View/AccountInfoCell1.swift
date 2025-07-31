import UIKit

class AccountInfoCell1: UITableViewCell {
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var motherName: UITextField!
    @IBOutlet weak var fatherPhone: UITextField!
    @IBOutlet weak var motherPhone: UITextField!
    @IBOutlet weak var fatherEmail: UITextField!
    @IBOutlet weak var motherEmail: UITextField!
    @IBOutlet weak var fatherQualification: UITextField!
    @IBOutlet weak var motherQualification: UITextField!
    @IBOutlet weak var fatherOccupation: UITextField!
    @IBOutlet weak var motherOccupation: UITextField!
    @IBOutlet weak var fatherAadharNo: UITextField!
    @IBOutlet weak var motherAadharNo: UITextField!
    @IBOutlet weak var fatherIncome: UITextField!
    @IBOutlet weak var motherIncome: UITextField!

    func populate(with accountInfo: AccountInfo?, isEditingEnabled: Bool) {
        guard let accountInfo = accountInfo else { return }
        
        fatherName.text = accountInfo.fatherName
        motherName.text = accountInfo.motherName
        fatherPhone.text = accountInfo.fatherPhone
        motherPhone.text = accountInfo.motherPhone
        fatherEmail.text = accountInfo.fatherEmail
        motherEmail.text = accountInfo.motherEmail
        fatherQualification.text = accountInfo.fatherQualification
        motherQualification.text = accountInfo.motherQualification
        fatherOccupation.text = accountInfo.fatherOccupation
        motherOccupation.text = accountInfo.motherOccupation
        fatherAadharNo.text = accountInfo.fatherAadharNo
        motherAadharNo.text = accountInfo.motherAadharNo
        fatherIncome.text = accountInfo.fatherIncome
        motherIncome.text = accountInfo.motherIncome
        
        let fields: [UITextField] = [
            fatherName, motherName, fatherPhone, motherPhone, fatherEmail, motherEmail,
            fatherQualification, motherQualification, fatherOccupation, motherOccupation,
            fatherAadharNo, motherAadharNo, fatherIncome, motherIncome
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> AccountInfo {
        return AccountInfo(
            fatherName: fatherName.text ?? "",
            motherName: motherName.text ?? "",
            fatherPhone: fatherPhone.text ?? "",
            motherPhone: motherPhone.text ?? "",
            fatherEmail: fatherEmail.text ?? "",
            motherEmail: motherEmail.text ?? "",
            fatherQualification: fatherQualification.text ?? "",
            motherQualification: motherQualification.text ?? "",
            fatherOccupation: fatherOccupation.text ?? "",
            motherOccupation: motherOccupation.text ?? "",
            fatherAadharNo: fatherAadharNo.text ?? "",
            motherAadharNo: motherAadharNo.text ?? "",
            fatherIncome: fatherIncome.text?.isEmpty == false ? fatherIncome.text ?? "0" : "0",
            motherIncome: motherIncome.text?.isEmpty == false ? motherIncome.text ?? "0" : "0"
        )
    }
}
