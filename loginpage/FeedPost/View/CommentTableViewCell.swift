//
//  CommentTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 01/01/25.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var adminImage: UIImageView!
    @IBOutlet weak var noOfReply: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var adminName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure corner radius is applied after layout
        adminImage.layer.cornerRadius = adminImage.frame.height / 2
    }
    
    private func setupImageView() {
        adminImage.layer.cornerRadius = adminImage.frame.height / 2
        adminImage.clipsToBounds = true
        adminImage.contentMode = .scaleAspectFill
        adminImage.backgroundColor = UIColor(hex: "#F5F3EF")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with commentInfo: Comment) {
        adminName.text = commentInfo.createdByName
        updateImageViewWithFirstLetter(from: commentInfo.createdByName)
        timeLabel.text = timeAgo(from: commentInfo.insertedAt)
        noOfReply.text = "\(commentInfo.replies)"
        commentText.text = commentInfo.text
    }
    
    private func updateImageViewWithFirstLetter(from name: String) {
        guard let firstLetter = name.first else {
            adminImage.image = nil
            return
        }
        
        let letterImage = generateLetterImage(from: String(firstLetter).uppercased())
        adminImage.image = letterImage
    }
    
    private func generateLetterImage(from letter: String) -> UIImage? {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw background
            let customColor = UIColor(hex: "#F5F3EF")
            customColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw letter
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 25),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]
            
            let letterRect = CGRect(x: 0, y: 12, width: size.width, height: size.height)
            letter.draw(in: letterRect, withAttributes: attributes)
        }
    }
    
    private func timeAgo(from dateTimeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Try multiple date formats
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        
        var date: Date?
        for format in formats {
            dateFormatter.dateFormat = format
            if let parsedDate = dateFormatter.date(from: dateTimeString) {
                date = parsedDate
                break
            }
        }
        
        guard let commentDate = date else {
            return "Unknown"
        }
        
        let currentDate = Date()
        let difference = currentDate.timeIntervalSince(commentDate)
        
        let secondsInMinute: TimeInterval = 60
        let secondsInHour: TimeInterval = 3600
        let secondsInDay: TimeInterval = 86400
        let secondsInWeek: TimeInterval = 604800
        let secondsInMonth: TimeInterval = 2592000
        let secondsInYear: TimeInterval = 31536000
        
        if difference < secondsInMinute {
            return "just now"
        } else if difference < secondsInHour {
            let minutes = Int(difference / secondsInMinute)
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        } else if difference < secondsInDay {
            let hours = Int(difference / secondsInHour)
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else if difference < secondsInWeek {
            let days = Int(difference / secondsInDay)
            return "\(days) \(days == 1 ? "day" : "days") ago"
        } else if difference < secondsInMonth {
            let weeks = Int(difference / secondsInWeek)
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
        } else if difference < secondsInYear {
            let months = Int(difference / secondsInMonth)
            return "\(months) \(months == 1 ? "month" : "months") ago"
        } else {
            let years = Int(difference / secondsInYear)
            return "\(years) \(years == 1 ? "year" : "years") ago"
        }
    }
}
