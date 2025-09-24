import UIKit

class RegularTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestureRecognizers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Apply circular corner radius to both views
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
        
        // Optional: Also make WhatsApp and call icons circular
        whatsAppImageView.layer.cornerRadius = whatsAppImageView.frame.height / 2
        callImageView.layer.cornerRadius = callImageView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupUI() {
        // Enable clipping to bounds for both views
        iconImageView.clipsToBounds = true
        imageLabel.clipsToBounds = true
        whatsAppImageView.clipsToBounds = true
        callImageView.clipsToBounds = true
        
        // Set initial corner radius
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
        whatsAppImageView.layer.cornerRadius = whatsAppImageView.frame.height / 2
        callImageView.layer.cornerRadius = callImageView.frame.height / 2

//        iconImageView.backgroundColor = UIColor.link
        
        // Configure imageLabel appearance
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
//        imageLabel.backgroundColor = UIColor.link // Match the background color
        imageLabel.textColor = .black // Better contrast with link color
        
        
    }

    private func setupGestureRecognizers() {
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callImageView.addGestureRecognizer(callTapGesture)
        callImageView.isUserInteractionEnabled = true

        let whatsAppTapGesture = UITapGestureRecognizer(target: self, action: #selector(whatsAppTapped))
        whatsAppImageView.addGestureRecognizer(whatsAppTapGesture)
        whatsAppImageView.isUserInteractionEnabled = true
    }

    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"

        if let image = icon {
            iconImageView.image = image
            imageLabel.isHidden = true
        } else {
            iconImageView.image = nil
//            iconImageView.backgroundColor = UIColor.link

            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .black // Better contrast
            imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            imageLabel.textAlignment = .center
//            imageLabel.backgroundColor = UIColor.link // Ensure background matches
            imageLabel.isHidden = false
        }
        
        // Ensure layout updates after configuration
        setNeedsLayout()
    }

    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
