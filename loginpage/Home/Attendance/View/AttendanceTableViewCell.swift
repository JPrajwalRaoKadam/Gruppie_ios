
import UIKit
class AttendanceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var fallbackLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        // Configure image view
        img.layer.cornerRadius = img.frame.width / 2
        img.layer.masksToBounds = true
        img.clipsToBounds = true
        
        // Configure fallback label
        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.width / 2
        fallbackLabel.layer.masksToBounds = true
        fallbackLabel.clipsToBounds = true
        fallbackLabel.font = UIFont.boldSystemFont(ofSize: 18)
        fallbackLabel.textAlignment = .center
        fallbackLabel.textColor = .white
        
        // Ensure proper content mode for image
        img.contentMode = .scaleAspectFill
    }
    
    // Show fallback image with the first letter of the name
    func showFallbackImage(for name: String) {
        img.image = nil
        let firstLetter = name.prefix(1).uppercased()
        fallbackLabel.text = firstLetter
        img.backgroundColor = UIColor.link
    }
    
    func configure(with attendance: Attendance) {
        classLabel.text = attendance.name
        
        if attendance.attendanceTaken, let attendanceStatus = attendance.attendanceStatus, !attendanceStatus.isEmpty {
            let formattedAttendance = attendanceStatus.map { "\($0.type): \($0.present)/\($0.present + $0.absent)" }
            let attendanceText = formattedAttendance.joined(separator: ", ")
            periodLabel.text = attendanceText
            periodLabel.isHidden = false
        } else {
            periodLabel.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        img.image = nil
        fallbackLabel.text = nil
        classLabel.text = nil
        periodLabel.text = nil
    }
}
