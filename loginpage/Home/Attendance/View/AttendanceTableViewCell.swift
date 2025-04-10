//
//  AttendanceTableViewCell.swift
//  loginpage
//
//  Created by apple on 10/02/25.
//
import UIKit

class AttendanceTableViewCell: UITableViewCell {
        
        @IBOutlet weak var classLabel: UILabel!
        @IBOutlet weak var periodLabel: UILabel!
        @IBOutlet weak var img: UIImageView!
        @IBOutlet weak var fallbackLabel: UILabel!
    
        override func awakeFromNib() {
            super.awakeFromNib()
            img.layer.cornerRadius = fallbackLabel.frame.width / 2
            img.layer.masksToBounds = true
            img.clipsToBounds = true
            fallbackLabel.layer.cornerRadius = fallbackLabel.frame.width / 2
            fallbackLabel.layer.masksToBounds = true
            fallbackLabel.clipsToBounds = true
        }
        // Show fallback image with the first letter of the name
            func showFallbackImage(for name: String) {
                img.image = nil
                let firstLetter = name.prefix(1).uppercased()
                
                // Create a label inside the icon to show the first letter
                fallbackLabel.text = firstLetter
                fallbackLabel.font = UIFont.boldSystemFont(ofSize: 18)
                fallbackLabel.textAlignment = .center
                fallbackLabel.textColor = .white
                img.backgroundColor = UIColor.link
            
                // Ensure label's text is centered within the circle
                fallbackLabel.frame = img.bounds
                img.addSubview(fallbackLabel)
            }

    func configure(with attendance: Attendance) {
        if attendance.attendanceTaken, let attendanceStatus = attendance.attendanceStatus, !attendanceStatus.isEmpty {
            let formattedAttendance = attendanceStatus.map { "\($0.type): \($0.present)/\($0.present + $0.absent)" }
            let attendanceText = formattedAttendance.joined(separator: ", ")
            print("✅ Attendance Text: \(attendanceText)")

            periodLabel.text = attendanceText
            periodLabel.isHidden = false  // Show label when attendanceTaken is true and has data
        } else {
            print("❌ No attendance data available for this cell")
            periodLabel.isHidden = true   // Hide label when attendanceTaken is false or data is empty
        }
    }
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
    }
