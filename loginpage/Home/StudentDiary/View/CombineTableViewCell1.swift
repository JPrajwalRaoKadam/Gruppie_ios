import UIKit

class CombineTableViewCell1: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel! // Label for fallback text

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Basic setup
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = .link
        iconImageView.contentMode = .scaleAspectFill

        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.textColor = .black
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        imageLabel.clipsToBounds = true
//        imageLabel.backgroundColor = .link // Add background color to match
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update corner radius after layout is complete
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"
        
        if let image = icon {
            iconImageView.image = image
            iconImageView.backgroundColor = .clear
            imageLabel.isHidden = true
        } else {
            iconImageView.image = nil
            iconImageView.backgroundColor = .link
            
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .black // Changed to white for better contrast
            imageLabel.font = UIFont.boldSystemFont(ofSize: 17) // Keep consistent size
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false
//            imageLabel.backgroundColor = .link // Ensure background matches
        }
        
        // Ensure corner radius is updated
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
    }
}
