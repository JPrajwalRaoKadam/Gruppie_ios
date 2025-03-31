import UIKit

class EducationInfoCell: UITableViewCell {

    @IBOutlet weak var nationality: UITextField!
    @IBOutlet weak var bloodGroup: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var caste: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var disability: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var admissionNo: UITextField!
    @IBOutlet weak var satsNumber: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var aadharNo: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // ✅ Function to populate fields with student data
    func populate(with educationInfo: EducationInfo?, isEditingEnabled: Bool) {
        guard let educationInfo = educationInfo else { return }

        nationality.text = educationInfo.nationality
        bloodGroup.text = educationInfo.bloodGroup
        religion.text = educationInfo.religion
        caste.text = educationInfo.caste
        category.text = educationInfo.category
        disability.text = educationInfo.disability
        dob.text = educationInfo.dateOfBirth
        admissionNo.text = educationInfo.admissionNumber
        satsNumber.text = educationInfo.satsNumber
        address.text = educationInfo.address
        aadharNo.text = educationInfo.aadharNumber

        let fields: [UITextField] = [
            nationality, bloodGroup, religion, caste, category, disability, dob,
            admissionNo, satsNumber, address, aadharNo
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    // ✅ Function to collect updated data from fields
    func collectUpdatedData() -> EducationInfo {
        let nationalityText = nationality.text ?? ""
        let bloodGroupText = bloodGroup.text ?? ""
        let religionText = religion.text ?? ""
        let casteText = caste.text ?? ""
        let categoryText = category.text ?? ""
        let disabilityText = disability.text ?? ""
        let dateOfBirthText = dob.text ?? ""
        let admissionNumberText = admissionNo.text ?? ""
        let satsNumberText = satsNumber.text ?? ""
        let addressText = address.text ?? ""
        let aadharNumberText = aadharNo.text ?? ""

        return EducationInfo(
            nationality: nationalityText,
            bloodGroup: bloodGroupText,
            religion: religionText,
            caste: casteText,
            category: categoryText,
            disability: disabilityText,
            dateOfBirth: dateOfBirthText,
            admissionNumber: admissionNumberText,
            satsNumber: satsNumberText,
            aadharNumber: aadharNumberText, address: addressText
        )
    }
}
