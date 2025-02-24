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
        @IBOutlet weak var iconImageView: UIImageView!
        @IBOutlet weak var fallbackLabel: UILabel!

        override func awakeFromNib() {
            super.awakeFromNib()
        }
        // Show fallback image with the first letter of the name
            private func showFallbackImage(for name: String) {
                iconImageView.image = nil
                let firstLetter = name.prefix(1).uppercased()
                
                // Create a label inside the icon to show the first letter
                fallbackLabel.text = firstLetter
                fallbackLabel.textAlignment = .center
                fallbackLabel.textColor = .white
                iconImageView.backgroundColor = UIColor.gray
                
                // Ensure label's text is centered within the circle
                fallbackLabel.frame = iconImageView.bounds
                iconImageView.addSubview(fallbackLabel)
            }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
    }
