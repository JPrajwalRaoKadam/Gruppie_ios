  import UIKit
// ✅ Protocol to communicate unchecked students back to the previous VC
protocol StudentCellDelegate: AnyObject {
    func didUpdateUncheckedStudents(_ studentName: String, students: [StudentAtten], isChecked: Bool)
}

class StudentVCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var attenStatus: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var rollNo: UILabel!
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var fallback: UILabel!
    
    var studentID: String?
    var students: [StudentAtten]?
    
    weak var delegate: StudentCellDelegate? // Delegate reference

    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnStyles()
        setupCheckButton(initiallySelected: true)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        // ✅ Toggle the selection state
        sender.isSelected.toggle()
        checkButton.backgroundColor = .white
        
        // ✅ Notify the delegate with the student's name and selection state
        if let name = studentName.text , let students = self.students {
            delegate?.didUpdateUncheckedStudents(name, students: students, isChecked: sender.isSelected)
        }
    }
    
    func configureAttendanceButtons(numberOfTimes: Int) {
          attenStatus.setTitle("x\(numberOfTimes)", for: .normal)
      }
    // MARK: - Helper Functions
    
    private func btnStyles() {
        images.layer.cornerRadius = images.frame.width / 2
        images.layer.masksToBounds = true
        images.clipsToBounds = true
        
        fallback.layer.cornerRadius = fallback.frame.width / 2
        fallback.layer.masksToBounds = true
        fallback.clipsToBounds = true
        fallback.backgroundColor = .link
        
        attenStatus.layer.cornerRadius = attenStatus.frame.width / 2
        attenStatus.layer.masksToBounds = true
        attenStatus.clipsToBounds = true
        
        checkButton.backgroundColor = .white
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
    
    // ✅ Set initial state of the checkbox button
    private func setupCheckButton(initiallySelected: Bool) {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal)               // Unchecked
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
        checkButton.isSelected = initiallySelected                                      // Initially checked
        checkButton.backgroundColor = .white                                            // ✅ Keep background white
    }
}
