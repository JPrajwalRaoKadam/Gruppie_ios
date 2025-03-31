import UIKit

class EducationTableViewCell: UITableViewCell {

    @IBOutlet weak var education: UITextField!
    @IBOutlet weak var profession: UITextField!
    @IBOutlet weak var achievementLabel: UITextField!
    @IBOutlet weak var address: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Populate text fields with data
    func populate(with educationInfo: [String: String], isEditingEnabled: Bool) {
        education.text = educationInfo["education"]
        profession.text = educationInfo["profession"]
        achievementLabel.text = educationInfo["achievement"]
        address.text = educationInfo["address"]
        
        let fields: [UITextField] = [education, profession, achievementLabel, address]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    // Collect updated data from text fields
    func collectUpdatedData() -> [String: String] {
        return [
            "education": education.text ?? "",
            "profession": profession.text ?? "",
            "achievement": achievementLabel.text ?? "",
            "address": address.text ?? ""
        ]
    }
}
