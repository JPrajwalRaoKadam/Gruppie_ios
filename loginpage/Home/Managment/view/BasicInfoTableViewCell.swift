import UIKit

class BasicInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var alternativeNo: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var doj: UITextField!
    @IBOutlet weak var aadharNo: UITextField!
    @IBOutlet weak var bloodGroup: UITextField!
    @IBOutlet weak var panNo: UITextField!
    @IBOutlet weak var address: UITextField!

    func populate(with member: Member, isEditingEnabled: Bool) {
        name.text = member.name
        designation.text = member.designation
        country.text = member.country
        phoneNo.text = member.phone
        alternativeNo.text = member.alternativePhone
        email.text = member.email
        gender.text = member.gender
        dob.text = member.dateOfBirth
        doj.text = member.dateOfJoining
        aadharNo.text = member.aadharNumber
        bloodGroup.text = member.bloodGroup
        panNo.text = member.panNumber
        address.text = member.address

        let fields: [UITextField] = [
            name, designation, country, phoneNo, alternativeNo, email, gender, dob, doj,
            aadharNo, bloodGroup, panNo, address
        ]

        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "name": name.text ?? "",
            "designation": designation.text ?? "",
            "country": country.text ?? "",
            "phone": phoneNo.text ?? "",
            "alternativePhone": alternativeNo.text ?? "",
            "email": email.text ?? "",
            "dateOfBirth": dob.text ?? "",
            "dateOfJoining": doj.text ?? "",
            "aadharNumber": aadharNo.text ?? "",
            "bloodGroup": bloodGroup.text ?? "",
            "panNumber": panNo.text ?? "",
            "address": address.text ?? "",
            "gender": gender.text ?? "" 
        ]
    }
}
