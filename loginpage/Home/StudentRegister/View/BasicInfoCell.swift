import UIKit

class BasicInfoCell: UITableViewCell {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var studentClass: UITextField! // Mapped to className
    @IBOutlet weak var section: UITextField!
    @IBOutlet weak var rollNo: UITextField! // Mapped to rollNumber
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var doj: UITextField! // Mapped to dateOfJoining

    func populate(with student: StudentData, isEditingEnabled: Bool) {
        name.text = student.name
        gender.text = student.gender
        studentClass.text = student.className // ✅ Correct mapping
        section.text = student.section
        rollNo.text = student.rollNumber // ✅ Correct mapping
        email.text = student.email
        phone.text = student.phone
        doj.text = student.dateOfJoining // ✅ Correct mapping

        let fields: [UITextField] = [
            name, gender, studentClass, section, rollNo, email, phone, doj
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "name": name.text ?? "",
            "gender": gender.text ?? "",
            "className": studentClass.text ?? "", // ✅ Correct key
            "section": section.text ?? "",
            "rollNumber": rollNo.text ?? "", // ✅ Correct key
            "email": email.text ?? "",
            "phone": phone.text ?? "",
            "dateOfJoining": doj.text ?? "" // ✅ Correct key
        ]
    }
}
