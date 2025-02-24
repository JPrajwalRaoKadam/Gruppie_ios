import UIKit

class StaffBasicInfo: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var staffId: UITextField!
    @IBOutlet weak var doj: UITextField!
    @IBOutlet weak var Class: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var qualification: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var caste: UITextField!
    @IBOutlet weak var bloodgroup: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var aadharNo: UITextField!
    @IBOutlet weak var type: UITextField!

    private var allTextFields: [UITextField] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
    }

    private func setupTextFields() {
        allTextFields = [
            name, country, phone, staffId, doj, Class, gender, qualification, dob,
            address, religion, caste, bloodgroup, emailId, aadharNo, type
        ]
        allTextFields.forEach { $0.delegate = self }
    }

    func populate(with basicInfo: StaffBasicInfoModel, isEditingEnabled: Bool) {
        name.text = basicInfo.name
        country.text = basicInfo.country
        phone.text = basicInfo.phone
        staffId.text = basicInfo.staffId
        doj.text = basicInfo.doj
        Class.text = basicInfo.className
        gender.text = basicInfo.gender
        qualification.text = basicInfo.qualification
        dob.text = basicInfo.dob
        address.text = basicInfo.address
        religion.text = basicInfo.religion
        caste.text = basicInfo.caste
        bloodgroup.text = basicInfo.bloodGroup
        emailId.text = basicInfo.emailId
        aadharNo.text = basicInfo.aadharNo
        type.text = basicInfo.type

        // Enable or disable user interaction based on editing mode
        allTextFields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> StaffBasicInfoModel {
        return StaffBasicInfoModel(
            name: name.text ?? "",
            country: country.text ?? "",
            phone: phone.text ?? "",
            staffId: staffId.text ?? "",
            doj: doj.text ?? "",
            className: Class.text ?? "",
            gender: gender.text ?? "",
            qualification: qualification.text ?? "",
            dob: dob.text ?? "",
            address: address.text ?? "",
            religion: religion.text ?? "",
            caste: caste.text ?? "",
            bloodGroup: bloodgroup.text ?? "",
            emailId: emailId.text ?? "",
            aadharNo: aadharNo.text ?? "",
            type: type.text ?? ""
        )
    }

    // Dismiss keyboard when pressing "Return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
