import UIKit

class AddStudentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var newAdmissionButton: UIButton! // Outlet for button

    // Track the admission status
    var isNewAdmission: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        updateNewAdmissionButton() // Set the initial button state
    }

    // MARK: - Toggle Admission Status on Button Tap
    @IBAction func NewAdmission(_ sender: UIButton) {
        isNewAdmission.toggle() // Toggle the state
        updateNewAdmissionButton() // Update button UI
    }

    // Update button appearance based on selection
    private func updateNewAdmissionButton() {
        if isNewAdmission {
            newAdmissionButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal) // Show tick mark
        } else {
            newAdmissionButton.setImage(UIImage(systemName: "square"), for: .normal) // Empty box
        }
    }

    // MARK: - Get Student Data from TextFields
//    func getStudentData() -> StudentData? {
//        guard let nameText = name.text, !nameText.isEmpty,
//              let countryText = country.text, !countryText.isEmpty,
//              let phoneText = phone.text, !phoneText.isEmpty,
//              let fatherNameText = fatherName.text, !fatherNameText.isEmpty else {
//            return nil // Return nil if any required field is missing
//        }
//
//        // Create and return the student data object
//        return StudentData(admissionType: isNewAdmission ? "New Admission" : "Old Admission",
//                           cCode: 0,
//                           countryCode: countryText,
//                           fatherName: fatherNameText,
//                           name: nameText,
//                           phone: phoneText)
//    }
}
