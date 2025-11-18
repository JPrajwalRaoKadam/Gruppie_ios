import UIKit

class CombineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.textColor = .black
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }

    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"
        
        if let image = icon {
            iconImageView.image = image
            iconImageView.backgroundColor = nil
            imageLabel.isHidden = true
        } else {
            iconImageView.image = nil
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .black
            imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
