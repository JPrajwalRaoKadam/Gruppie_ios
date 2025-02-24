import UIKit

class OtherInfoCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nationality: UITextField!
    @IBOutlet weak var bloodGroup: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var caste: UITextField!
    @IBOutlet weak var subCaste: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var aadharNo: UITextField!

    private var studentData = StudentData(
        phone: "", name: "", groupId: "", fatherName: "", admissionType: nil,
        countryCode: ""
    )

    private var allTextFields: [UITextField] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
    }

    private func setupTextFields() {
        allTextFields = [nationality, bloodGroup, religion, caste, subCaste, category, address, aadharNo]
        allTextFields.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    /// ✅ **Populate cell with data and enable/disable editing**
    func populate(with student: StudentData, isEditingEnabled: Bool) {
        studentData = student

        nationality.text = student.nationality
        bloodGroup.text = student.bloodGroup
        religion.text = student.religion
        caste.text = student.caste
        subCaste.text = student.subCaste
        category.text = student.category
        address.text = student.address
        aadharNo.text = student.aadharNumber

        allTextFields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    /// ✅ **Detects when text fields finish editing and updates `studentData`**
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateStudentData(from: textField)
    }

    /// ✅ **Detects real-time changes and updates `studentData`**
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateStudentData(from: textField)
    }

    /// ✅ **Updates the `studentData` object based on the text field edited**
    private func updateStudentData(from textField: UITextField) {
        switch textField {
            case nationality:
                studentData.nationality = textField.text ?? ""
            case bloodGroup:
                studentData.bloodGroup = textField.text ?? ""
            case religion:
                studentData.religion = textField.text ?? ""
            case caste:
                studentData.caste = textField.text ?? ""
            case subCaste:
                studentData.subCaste = textField.text ?? ""
            case category:
                studentData.category = textField.text ?? ""
            case address:
                studentData.address = textField.text ?? ""
            case aadharNo:
                studentData.aadharNumber = textField.text ?? ""
            default:
                break
        }
    }

    /// ✅ **Returns the latest updated data**
    func collectUpdatedData() -> StudentData {
        return studentData
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

