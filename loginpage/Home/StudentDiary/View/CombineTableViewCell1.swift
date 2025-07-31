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
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = .link 

        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.textColor = .white
        imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"
        
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


