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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with commentInfo: Comment) {
        adminName.text = commentInfo.createdByName
        // Set adminImageView to show the first letter of the admin's name
        updateImageViewWithFirstLetter(from: adminName, in: adminImage)
        timeLabel.text = timeAgo(from: commentInfo.insertedAt)
        noOfReply.text = ("\(commentInfo.replies)")
        commentText.text = commentInfo.text
        
    }
    
    func updateImageViewWithFirstLetter(from label: UILabel, in imageView: UIImageView) {
        guard let text = label.text, let firstLetter = text.first else {
            imageView.image = nil  // If there's no text or it's empty, clear the image
            return
        }

        // Create an image with the first letter
        let letterImage = generateLetterImage(from: String(firstLetter).uppercased())

        // Set the generated image to the imageView
        imageView.image = letterImage
    }
    
    func generateLetterImage(from letter: String) -> UIImage? {
        // Create a label with the letter
        let letterLabel = UILabel()
        letterLabel.text = letter
        letterLabel.font = UIFont.boldSystemFont(ofSize: 30)  // Adjust size based on your needs
        letterLabel.textColor = .white
        letterLabel.textAlignment = .center
        let customColor = UIColor(hex: "#F5F3EF")
        letterLabel.backgroundColor = customColor // Adjust the color
        letterLabel.layer.cornerRadius = 25  // Adjust for circle size
        letterLabel.layer.masksToBounds = true
        letterLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)  // Size of the circle

        // Render the label into an image
        UIGraphicsBeginImageContextWithOptions(letterLabel.bounds.size, false, 0)
        letterLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    func timeAgo(from dateTimeString: String) -> String? {
        // Define the input date format
        let inputDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        // Create a DateFormatter for the input format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputDateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Convert the date-time string to a Date object
        guard let date = dateFormatter.date(from: dateTimeString) else {
            print("Invalid date-time string.")
            return nil
        }
        
        // Get the current date
        let currentDate = Date()
        
        // Calculate the difference between the dates
        let differenceInSeconds = currentDate.timeIntervalSince(date)
        
        // Calculate days, hours, and minutes
        let secondsInADay: TimeInterval = 86400
        let secondsInAnHour: TimeInterval = 3600
        let secondsInAMinute: TimeInterval = 60
        
        if differenceInSeconds < secondsInAMinute {
            return "just now"
        } else if differenceInSeconds < secondsInAnHour {
            let minutesAgo = Int(differenceInSeconds / secondsInAMinute)
            return "\(minutesAgo) minutes ago"
        } else if differenceInSeconds < secondsInADay {
            let hoursAgo = Int(differenceInSeconds / secondsInAnHour)
            return "\(hoursAgo) hour ago"
        } else {
            let daysAgo = Int(differenceInSeconds / secondsInADay)
            return "\(daysAgo) days ago"
        }
    }

}
