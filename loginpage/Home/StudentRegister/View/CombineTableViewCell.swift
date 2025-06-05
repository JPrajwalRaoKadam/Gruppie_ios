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
        iconImageView.backgroundColor = .link 

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
    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"
        
        // If icon is available, display it
        if let image = icon {
            iconImageView.image = image
            imageLabel.isHidden = true
        } else {
            iconImageView.image = nil
            iconImageView.backgroundColor = .link
            
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .white
            imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false 
        }
    }
}
