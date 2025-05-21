import UIKit

class EducationTableViewCell: UITableViewCell {
    @IBOutlet weak var education: UITextField!
    @IBOutlet weak var profession: UITextField!
    @IBOutlet weak var achievementLabel: UITextField!
    @IBOutlet weak var address: UITextField!

    func populate(with member: Member, isEditingEnabled: Bool) {
        education.text = member.education
        profession.text = member.profession
        achievementLabel.text = member.achievement
        address.text = member.address

        let fields: [UITextField] = [education, profession, achievementLabel, address]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: String] {
        return [
            "education": education.text ?? "",
            "profession": profession.text ?? "",
            "achievement": achievementLabel.text ?? "",
            "address": address.text ?? ""
        ]
    }
}
