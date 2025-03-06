import UIKit

class FamilyInfoCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var fatherPhone: UITextField!
    @IBOutlet weak var fatherEducation: UITextField!
    @IBOutlet weak var fatherOccupation: UITextField!
    @IBOutlet weak var fatherAadhar: UITextField!
    @IBOutlet weak var motherName: UITextField!
    @IBOutlet weak var motherPhone: UITextField!
    @IBOutlet weak var motherOccupation: UITextField!

    private var studentData = StudentData(
        phone: "", name: "",
        dob: "", doj: "", admissionNumber: "", rollNumber: "", countryCode: "",
        satsNumber: ""
    )

    private var allTextFields: [UITextField] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
    }

    private func setupTextFields() {
        allTextFields = [fatherName, fatherPhone, fatherEducation, fatherOccupation, fatherAadhar, motherName, motherPhone, motherOccupation]
        allTextFields.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    /// ✅ **Populate cell with data and enable/disable editing**
    func populate(with student: StudentData, isEditingEnabled: Bool) {
        studentData = student

        fatherName.text = student.fatherName
        fatherPhone.text = student.fatherPhone
        fatherEducation.text = student.fatherEducation
        fatherOccupation.text = student.fatherOccupation
        fatherAadhar.text = student.fatherAadhar
        motherName.text = student.motherName
        motherPhone.text = student.motherPhone
        motherOccupation.text = student.motherOccupation

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
            case fatherName:
                studentData.fatherName = textField.text ?? ""
            case fatherPhone:
                studentData.fatherPhone = textField.text ?? ""
            case fatherEducation:
                studentData.fatherEducation = textField.text ?? ""
            case fatherOccupation:
                studentData.fatherOccupation = textField.text ?? ""
            case fatherAadhar:
                studentData.fatherAadhar = textField.text ?? ""
            case motherName:
                studentData.motherName = textField.text ?? ""
            case motherPhone:
                studentData.motherPhone = textField.text ?? ""
            case motherOccupation:
                studentData.motherOccupation = textField.text ?? ""
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
