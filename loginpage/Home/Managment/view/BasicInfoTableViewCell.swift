import UIKit

class BasicInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var staffId: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var doj: UITextField!
    @IBOutlet weak var profession: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var qualification: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var bloodGroup: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var aadharNo: UITextField!
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var motherName: UITextField!
    @IBOutlet weak var emerContact: UITextField!
    @IBOutlet weak var disability: UITextField!

    func populate(with member: Member, isEditingEnabled: Bool) {
        name.text = member.name
        phone.text = member.phone
        staffId.text = member.staffId
        designation.text = member.designation
        doj.text = member.dateOfJoining
        profession.text = member.profession
        gender.text = member.gender
        qualification.text = member.qualification
        dob.text = member.dateOfBirth
        address.text = member.address
        religion.text = member.religion
        bloodGroup.text = member.bloodGroup
        emailId.text = member.emailId
        aadharNo.text = member.aadharNumber
        fatherName.text = member.fatherName
        motherName.text = member.motherName
        emerContact.text = member.emergencyContact
        disability.text = member.disability

        let fields: [UITextField] = [
            name, phone, staffId, designation, doj, profession, gender, qualification, dob,
            address, religion, bloodGroup, emailId, aadharNo, fatherName, motherName, emerContact, disability
        ]
        
        // Enable or disable user interaction based on the editing mode
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "name": name.text ?? "",
            "phone": phone.text ?? "",
            "staffId": staffId.text ?? "",
            "designation": designation.text ?? "",
            "dateOfJoining": doj.text ?? "",
            "profession": profession.text ?? "",
            "gender": gender.text ?? "",
            "qualification": qualification.text ?? "",
            "dateOfBirth": dob.text ?? "",
            "address": address.text ?? "",
            "religion": religion.text ?? "",
            "bloodGroup": bloodGroup.text ?? "",
            "emailId": emailId.text ?? "",
            "aadharNumber": aadharNo.text ?? "",
            "fatherName": fatherName.text ?? "",
            "motherName": motherName.text ?? "",
            "emergencyContact": emerContact.text ?? "",
            "disability": disability.text ?? ""
        ]
    }
}
