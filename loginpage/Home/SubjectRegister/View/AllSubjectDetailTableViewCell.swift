//import UIKit
//
//
//protocol AllSubjectDetailTableViewCellDelegate: AnyObject {
//    func didTapStaffSubject(for subjectDetail: SubjectDetail)
//    func didTapStudentSubject(for subjectDetail: SubjectDetail)
//}
//
//class AllSubjectDetailTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var subject: UILabel!
//    @IBOutlet weak var staff: UILabel!
//    @IBOutlet weak var StaffSubject: UIButton!
//    @IBOutlet weak var StudentSubject: UIButton!
//    
//    weak var delegate: AllSubjectDetailTableViewCellDelegate?
//    private var subjectDetail: SubjectDetail?
//    
//    
//    func configure(with staffDetail: SubjectStaffMember, subjectDetail: SubjectDetail) {
//        self.subjectDetail = subjectDetail
//        subject.text = subjectDetail.subjectName
//        staff.text = staffDetail.staffName
//    }
//    @IBAction func staffSubjectButtonTapped(_ sender: UIButton) {
//        print("🛑 StaffSubject button tapped")
//        if let subjectDetail = subjectDetail {
//            print("📌 Subject Name: \(subjectDetail.subjectName)")
//            delegate?.didTapStaffSubject(for: subjectDetail)
//        } else {
//            print("❌ subjectDetail is nil")
//        }
//        }
//    @IBAction func studentSubjectButtonTapped(_ sender: UIButton) {
//        print("🛑 StudentSubject button tapped")
//        if let subjectDetail = subjectDetail {
//            print("📌 Subject Name: \(subjectDetail.subjectName)")
//            delegate?.didTapStudentSubject(for: subjectDetail) 
//        } else {
//            print("❌ subjectDetail is nil")
//        }
//    }
//
//}
