import UIKit

class AccountInfoCell: UITableViewCell {
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

    func populate(with account: StudentData, isEditingEnabled: Bool) {
        fatherName.text = account.fatherName
        motherName.text = account.motherName
        fatherPhone.text = account.fatherPhone
        motherPhone.text = account.motherPhone
        fatherEmail.text = account.fatherEmail
        motherEmail.text = account.motherEmail
        fatherQualification.text = account.fatherEducation
        motherQualification.text = account.motherEducation
        fatherOccupation.text = account.fatherOccupation
        motherOccupation.text = account.motherOccupation
        fatherAadharNo.text = account.fatherAadharNumber
        motherAadharNo.text = account.motherAadharNumber
        fatherIncome.text = account.fatherIncome

        [fatherName, motherName, fatherPhone, motherPhone, fatherEmail, motherEmail, fatherQualification, motherQualification, fatherOccupation, motherOccupation, fatherAadharNo, motherAadharNo, fatherIncome].forEach {
            $0?.isUserInteractionEnabled = isEditingEnabled
            $0?.backgroundColor = isEditingEnabled ? .white : .clear
        }
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


