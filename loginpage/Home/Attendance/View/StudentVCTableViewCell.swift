
import UIKit
  
  // ✅ Protocol to communicate unchecked students and attendance taps back to the parent VC
protocol StudentCellDelegate: AnyObject {
    func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool)
    func didTapAttendanceStatus(for student: StudentAtten, at indexPath: IndexPath)
    
    //      func didTapAttendanceStatus(for student: StudentAtten, attendanceList: [StudentAttendance], at indexPath: IndexPath)
      }
    
    class StudentVCTableViewCell: UITableViewCell {
//        @IBOutlet weak var attenStatus: UIButton!
        @IBOutlet weak var attenStatusStackView: UIStackView!
        @IBOutlet weak var checkButton: UIButton!
        @IBOutlet weak var studentName: UILabel!
        @IBOutlet weak var rollNo: UILabel!
        @IBOutlet weak var images: UIImageView!
        @IBOutlet weak var fallback: UILabel!
        var userId: String?
        
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
            attenStatusStackView.spacing = 8
            attenStatusStackView.axis = .horizontal
            attenStatusStackView.alignment = .center
        }
        
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            btnStyles()
//            setupCheckButton(initiallySelected: true)
//            print("......lllklkllll......\(lastDaysAttendance.count)")
//            print("STU\(students?.count)")
//            print("studentId: \(studentID)")
//        }
        
        func setAttendanceVisibility(isHidden: Bool) {
            //attenStatus.isHidden = isHidden
            attenStatusStackView.isHidden = isHidden
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
        //          guard let ip = indexPath else { return }
        //          // Delegate gets both student and indexPath so it can pick the right entry
        //          if let student = students?.first, let indexPath = indexPath {
        //              //                delegate?.didTapAttendanceStatus(for: student, at: indexPath)
        //              //            }
        //          }
        //      }
        @IBAction func attenStatusTapped(_ sender: UIButton) {
            guard let student = students?[indexPath?.row ?? 0],
                  let indexPath = indexPath else { return }
            delegate?.didTapAttendanceStatus(for: student, at: indexPath)
        }
        //      @IBAction func attenStatusTapped(_ sender: UIButton) {
        //          guard let indexPath = indexPath,
        //                let students = students,
        //                indexPath.row < students.count else { return }
        //
        //          let student = students[indexPath.row]
        //          delegate?.didTapAttendanceStatus(for: student, attendanceList: lastDaysAttendance, at: indexPath)
        //      }
        
        
        
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
//            attenStatus.layer.cornerRadius = attenStatus.frame.width / 2
//            attenStatus.layer.masksToBounds = true
            checkButton.backgroundColor = .white
        }
        
        private func setupCheckButton(initiallySelected: Bool) {
            checkButton.setImage(UIImage(systemName: "square"), for: .normal)
            checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            checkButton.isSelected = initiallySelected
            checkButton.tintColor = .systemGreen
            checkButton.backgroundColor = .white
        }
//        private func setupCheckButton() {
//            checkButton.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked
//            checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
//            checkButton.tintColor = .systemGreen // This sets the checkmark color to green
//            checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
//        }




        @objc func checkButtonTapped() {
            checkButton.isSelected.toggle()
            contentView.backgroundColor = .white
        }
        
//        func configureAttendanceStatus(attendance: String) {
//            let lowercased = attendance.lowercased()
//            switch lowercased {
//            case "holiday":    set(status: "H", color: .systemBlue)
//            case "present":    set(status: "P", color: .systemGreen)
//            case "absent":     set(status: "A", color: .systemRed)
//            case "leave":      set(status: "L", color: .systemYellow)
//            default:            set(status: "-", color: .lightGray)
//            }
//        }
        func configureAttendanceButtons(lastDaysAttendance: [StudentAttendance]) {
            // Clear any existing buttons
            attenStatusStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for (index, attendance) in lastDaysAttendance.enumerated() {
                let button = UIButton(type: .system)
                button.layer.cornerRadius = 8
                button.clipsToBounds = true
                button.setTitleColor(.white, for: .normal)
                button.tag = index
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                
                switch attendance.attendance?.lowercased() {
                case "holiday":
                    configureButton(button, with: "H", color: .systemBlue)
                case "present":
                    configureButton(button, with: "P", color: .systemGreen)
                case "absent":
                    configureButton(button, with: "A", color: .systemRed)
                case "leave":
                    configureButton(button, with: "L", color: .systemYellow)
                default:
                    configureButton(button, with: "-", color: .lightGray)
                }
                
                button.addTarget(self, action: #selector(attenStatusTapped(_:)), for: .touchUpInside)
                attenStatusStackView.addArrangedSubview(button)
            }
        }

        private func configureButton(_ button: UIButton, with title: String, color: UIColor) {
            button.setTitle(title, for: .normal)
            button.backgroundColor = color
            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }

        
//        private func set(status: String, color: UIColor) {
//            attenStatus.setTitle(status, for: .normal)
//            attenStatus.backgroundColor = color
//            attenStatus.setTitleColor(.white, for: .normal)
//            attenStatus.layer.cornerRadius = 8
//            attenStatus.clipsToBounds = true
//        }
    }

