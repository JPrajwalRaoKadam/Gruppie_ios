import UIKit

class BasicInfoCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var satsNumber: UITextField!
    @IBOutlet weak var admissionNumber: UITextField!
    @IBOutlet weak var rollNo: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var doj: UITextField!

    private var studentData = StudentData(
        phone: "", name: "", dob: "", doj: "", admissionNumber: "", rollNumber: "",
        countryCode: "", satsNumber: ""
    )

    private var allTextFields: [UITextField] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
    }

    private func setupTextFields() {
        allTextFields = [name, country, phone, satsNumber, admissionNumber, rollNo, dob, doj]
        allTextFields.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    /// ✅ **Populate cell with data and enable/disable editing**
    func populate(with student: StudentData, isEditingEnabled: Bool) {
        studentData = student

        name.text = student.name
        country.text = student.countryCode
        phone.text = student.phone
        satsNumber.text = student.satsNumber
        admissionNumber.text = student.admissionNumber
        rollNo.text = student.rollNumber
        dob.text = student.dob
        doj.text = student.doj

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
            case name:
                studentData.name = textField.text ?? ""
            case country:
                studentData.countryCode = textField.text ?? ""
            case phone:
                studentData.phone = textField.text ?? ""
            case satsNumber:
                studentData.satsNumber = textField.text ?? ""
            case admissionNumber:
                studentData.admissionNumber = textField.text ?? ""
            case rollNo:
                studentData.rollNumber = textField.text ?? ""
            case dob:
                studentData.dob = textField.text ?? ""
            case doj:
                studentData.doj = textField.text ?? ""
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
