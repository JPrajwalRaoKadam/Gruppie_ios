import UIKit


protocol AllSubjectDetailTableViewCellDelegate: AnyObject {
    func didTapStaffSubject(for subjectDetail: SubjectDetail)
    func didTapStudentSubject(for subjectDetail: SubjectDetail) // ✅ New method
}

class AllSubjectDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var staff: UILabel!
    @IBOutlet weak var StaffSubject: UIButton!
    @IBOutlet weak var StudentSubject: UIButton!
    
    weak var delegate: AllSubjectDetailTableViewCellDelegate?
    private var subjectDetail: SubjectDetail?
    
    
    // Updated configure method to accept subject name
    func configure(with staffDetail: SubjectStaffMember, subjectDetail: SubjectDetail) {
        self.subjectDetail = subjectDetail  // Store the subjectDetail for later use
        subject.text = subjectDetail.subjectName    // Set subject name in label
        staff.text = staffDetail.staffName  // Set staff name in label
    }
    @IBAction func staffSubjectButtonTapped(_ sender: UIButton) {
        print("🛑 StaffSubject button tapped")
        if let subjectDetail = subjectDetail {
            print("📌 Subject Name: \(subjectDetail.subjectName)")
            delegate?.didTapStaffSubject(for: subjectDetail) // ✅ Ensure this is being called
        } else {
            print("❌ subjectDetail is nil")
        }
        }
    @IBAction func studentSubjectButtonTapped(_ sender: UIButton) {
        print("🛑 StudentSubject button tapped")
        if let subjectDetail = subjectDetail {
            print("📌 Subject Name: \(subjectDetail.subjectName)")
            delegate?.didTapStudentSubject(for: subjectDetail) // ✅ Notify delegate
        } else {
            print("❌ subjectDetail is nil")
        }
    }

}
