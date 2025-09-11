
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
     
        @IBAction func attenStatusTapped(_ sender: UIButton) {
            guard let student = students?[indexPath?.row ?? 0],
                  let indexPath = indexPath else { return }
            delegate?.didTapAttendanceStatus(for: student, at: indexPath)
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
            fallback.font = UIFont.boldSystemFont(ofSize: 20)
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

        @objc func checkButtonTapped() {
            checkButton.isSelected.toggle()
            contentView.backgroundColor = .white
        }
        
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

    }

