import UIKit

class Education2TableViewCell: UITableViewCell {

    @IBOutlet weak var Qualification: UITextField!
    @IBOutlet weak var Univesity: UITextField!
    @IBOutlet weak var yearOfCompletion: UITextField!
    @IBOutlet weak var uploadCertificate: UIButton!

    var onEducationChange: ((EditableManagement) -> Void)?
    var onUploadCertificateTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    @IBAction func uploadCertificateTapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadCertificateTapped?()
    }
    func showAadharSelected() {
        print("✅ Aadhar file selected successfully")
        
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        uploadCertificate.setImage(tickImage, for: .normal)
        uploadCertificate.setTitle("", for: .normal)
        uploadCertificate.imageView?.contentMode = .scaleAspectFit
        uploadCertificate.backgroundColor = .clear
    }

    func populate(with data: EditableManagement, isEditingEnabled: Bool) {
        Qualification.text = data.Qualification
        Univesity.text = data.Univesity
        yearOfCompletion.text = data.yearOfCompletion
        
        let fields: [UITextField] = [Qualification, Univesity, yearOfCompletion]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func sendUpdatedData() {
        var data = EditableManagement()
        data.Qualification = Qualification.text ?? ""
        data.Univesity = Univesity.text ?? ""
        data.yearOfCompletion = yearOfCompletion.text ?? ""
        onEducationChange?(data)
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "Qualification": Qualification.text ?? "",
            "Univesity": Univesity.text ?? "",
            "yearOfCompletion": yearOfCompletion.text ?? ""
        ]
    }
}
