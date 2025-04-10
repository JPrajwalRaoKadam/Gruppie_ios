import UIKit

class CombineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel! // Label for fallback text

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make the iconImageView circular and setup fallback appearance
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = .link // System link color for fallback

        // Configure fallback text label
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.textColor = .white
        imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Configure method with fallback for icon
    func configure(name: String, designation: String, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = designation
        
        // If icon is available, display it
        if let image = icon {
            iconImageView.image = image
            imageLabel.isHidden = true // Hide fallback text if image is available
        } else {
            // Remove any previous image and set a fallback background color
            iconImageView.image = nil
            iconImageView.backgroundColor = .link // System link color for fallback
            
            // Set the first letter of name as fallback text
            imageLabel.text = String(name.prefix(1)).uppercased() // Display first letter of name
            imageLabel.textColor = .white // White text color for fallback
            imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            imageLabel.textAlignment = .center // Ensure text is centered
            imageLabel.isHidden = false // Show fallback text
        }
    }
}
