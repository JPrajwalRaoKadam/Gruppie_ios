//  import UIKit
//// ✅ Protocol to communicate unchecked students back to the previous VC
//protocol StudentCellDelegate: AnyObject {
//    func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool)
//    func didTapAttendanceStatus(for student: StudentAtten)
////    func didTapEditAttendance(for student: StudentAtten) // ✅ NEW
//}
//
//
//class StudentVCTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var attenStatus: UIButton!
//    @IBOutlet weak var checkButton: UIButton!
//    @IBOutlet weak var studentName: UILabel!
//    @IBOutlet weak var rollNo: UILabel!
//    @IBOutlet weak var images: UIImageView!
//    @IBOutlet weak var fallback: UILabel!
//    
//    var studentID: String?
//    var students: [StudentAtten]?
//    var attendanceId: String?
//    
//    weak var delegate: StudentCellDelegate? // Delegate reference
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        btnStyles()
//        setupCheckButton(initiallySelected: true)
//    }
//    func setAttendanceVisibility(isHidden: Bool) {
//        attenStatus.isHidden = isHidden
//    }
//    @IBAction func attenStatusTapped(_ sender: UIButton) {
//        if let student = students?.first { // Assuming it's a 1-to-1 match
//            delegate?.didTapAttendanceStatus(for: student)
//        }
//    }
//
//
//    @IBAction func checkButtonTapped(_ sender: UIButton) {
//        // ✅ Toggle the selection state
//        sender.isSelected.toggle()
//        checkButton.backgroundColor = .white
//        
//        // ✅ Notify the delegate with the student's name and selection state
//        if let name = studentName.text , let students = self.students {
//            delegate?.didUpdateUncheckedStudents(name, students: students, isChecked: sender.isSelected)
//        }
//    }
//    
//    func configureAttendanceButtons(numberOfTimes: Int) {
//          
//      }
//    // MARK: - Helper Functions
//    
//    private func btnStyles() {
//        images.layer.cornerRadius = images.frame.width / 2
//        images.layer.masksToBounds = true
//        images.clipsToBounds = true
//        
//        fallback.layer.cornerRadius = fallback.frame.width / 2
//        fallback.layer.masksToBounds = true
//        fallback.clipsToBounds = true
//        fallback.backgroundColor = .link
//        
//        attenStatus.layer.cornerRadius = attenStatus.frame.width / 2
//        attenStatus.layer.masksToBounds = true
//        attenStatus.clipsToBounds = true
//        
//        checkButton.backgroundColor = .white
//    }
//    
//    func showFallbackImage(for name: String) {
//        images.image = nil
//        let firstLetter = name.prefix(1).uppercased()
//        
//        fallback.text = firstLetter
//        fallback.font = UIFont.boldSystemFont(ofSize: 18)
//        fallback.textAlignment = .center
//        fallback.textColor = .white
//        images.backgroundColor = UIColor.systemIndigo
//        
//        fallback.frame = images.bounds
//        images.addSubview(fallback)
//    }
//    
//    // ✅ Set initial state of the checkbox button
//    private func setupCheckButton(initiallySelected: Bool) {
//        checkButton.setImage(UIImage(systemName: "square"), for: .normal)               // Unchecked
//        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
//        checkButton.isSelected = initiallySelected                                      // Initially checked
//        checkButton.backgroundColor = .white                                            // ✅ Keep background white
//    }
//    func configureAttendanceStatus(attendance: String) {
//        let lowercased = attendance.lowercased()
//
//        switch lowercased {
//        case "holiday":
//            attenStatus.setTitle("H", for: .normal)
//            attenStatus.backgroundColor = UIColor.systemBlue
//        case "present":
//            attenStatus.setTitle("P", for: .normal)
//            attenStatus.backgroundColor = UIColor.systemGreen
//        case "absent":
//            attenStatus.setTitle("A", for: .normal)
//            attenStatus.backgroundColor = UIColor.systemRed
//        case "leave":
//            attenStatus.setTitle("L", for: .normal)
//            attenStatus.backgroundColor = UIColor.systemYellow
//        default:
//            attenStatus.setTitle("-", for: .normal)
//            attenStatus.backgroundColor = UIColor.lightGray
//        }
//
//        attenStatus.setTitleColor(.white, for: .normal)
//        attenStatus.layer.cornerRadius = 8
//        attenStatus.clipsToBounds = true
//    }
//}
import UIKit
  
  // ✅ Protocol to communicate unchecked students and attendance taps back to the parent VC
  protocol StudentCellDelegate: AnyObject {
      func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool)
      func didTapAttendanceStatus(for student: StudentAtten, at indexPath: IndexPath)
  }
  
  class StudentVCTableViewCell: UITableViewCell {
      @IBOutlet weak var attenStatus: UIButton!
      @IBOutlet weak var checkButton: UIButton!
      @IBOutlet weak var studentName: UILabel!
      @IBOutlet weak var rollNo: UILabel!
      @IBOutlet weak var images: UIImageView!
      @IBOutlet weak var fallback: UILabel!
  
      // MARK: - Data
      var indexPath: IndexPath?
      var studentID: String?
      var students: [StudentAtten]?
      var attendanceId: String?
      var lastDaysAttendance: [StudentAttendance] = []
      
      
      weak var delegate: StudentCellDelegate?
  
      override func awakeFromNib() {
          super.awakeFromNib()
          btnStyles()
          setupCheckButton(initiallySelected: true)
          print("......lllklkllll......\(lastDaysAttendance.count)")
          print("STU\(students?.count)")
      }
  
      func setAttendanceVisibility(isHidden: Bool) {
          attenStatus.isHidden = isHidden
      }
      func configure(with student: StudentAtten,
                      allStudents: [StudentAtten],
                      at indexPath: IndexPath,
                      delegate: StudentCellDelegate) {
         self.students           = allStudents
         self.lastDaysAttendance = student.lastDaysAttendance
         self.indexPath          = indexPath
         self.delegate           = delegate

         // Now you can safely print:
         print("🚀 students.count = \(students!.count)")
         print("🚀 lastDaysAttendance.count = \(lastDaysAttendance.count)")

         // And update your UI:
         studentName.text = student.studentName
         rollNo.text      = "Roll No: \(student.rollNumber)"
         // … load image, configure button, etc. …
       }

  
//      @IBAction func attenStatusTapped(_ sender: UIButton) {
//          // Pass the attendanceId back to the VC
//          guard let id = attendanceId else {
//              print("⚠️ No attendanceId found on cell.")
//              return
//          }
//          if let student = students?.first, let indexPath = indexPath {
//                delegate?.didTapAttendanceStatus(for: student, at: indexPath)
//            }
//      }
      @IBAction func attenStatusTapped(_ sender: UIButton) {
          guard let ip = indexPath else { return }
          // Delegate gets both student and indexPath so it can pick the right entry
          if let student = students?.first, let indexPath = indexPath {
              //                delegate?.didTapAttendanceStatus(for: student, at: indexPath)
              //            }
          }
      }

  
      @IBAction func checkButtonTapped(_ sender: UIButton) {
          sender.isSelected.toggle()
          checkButton.backgroundColor = .white
          if let name = studentName.text, let students = self.students {
              delegate?.didUpdateUncheckedStudents(name, students: students, isChecked: sender.isSelected)
          }
      }
  
      func configureAttendanceButtons(numberOfTimes: Int) {
          // implement as needed
      }
  
      func showFallbackImage(for name: String) {
          images.image = nil
          let firstLetter = name.prefix(1).uppercased()
          fallback.text = firstLetter
          fallback.font = UIFont.boldSystemFont(ofSize: 18)
          fallback.textAlignment = .center
          fallback.textColor = .white
          images.backgroundColor = UIColor.systemIndigo
          fallback.frame = images.bounds
          images.addSubview(fallback)
      }
  
      private func btnStyles() {
          [images, fallback].forEach {
              $0?.layer.cornerRadius = $0!.frame.width / 2
              $0?.layer.masksToBounds = true
          }
          fallback.backgroundColor = .link
          attenStatus.layer.cornerRadius = attenStatus.frame.width / 2
          attenStatus.layer.masksToBounds = true
          checkButton.backgroundColor = .white
      }
  
      private func setupCheckButton(initiallySelected: Bool) {
          checkButton.setImage(UIImage(systemName: "square"), for: .normal)
          checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
          checkButton.isSelected = initiallySelected
          checkButton.backgroundColor = .white
      }
  
      func configureAttendanceStatus(attendance: String) {
          let lowercased = attendance.lowercased()
          switch lowercased {
          case "holiday":    set(status: "H", color: .systemBlue)
          case "present":    set(status: "P", color: .systemGreen)
          case "absent":     set(status: "A", color: .systemRed)
          case "leave":      set(status: "L", color: .systemYellow)
          default:            set(status: "-", color: .lightGray)
          }
      }
  
      private func set(status: String, color: UIColor) {
          attenStatus.setTitle(status, for: .normal)
          attenStatus.backgroundColor = color
          attenStatus.setTitleColor(.white, for: .normal)
          attenStatus.layer.cornerRadius = 8
          attenStatus.clipsToBounds = true
      }
  }
