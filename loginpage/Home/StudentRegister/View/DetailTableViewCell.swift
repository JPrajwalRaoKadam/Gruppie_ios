import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel! // Label for fallback text

    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestureRecognizers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - UI Configuration
    private func setupUI() {
        // Make the iconImageView circular
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        
        // Set a system link color background for fallback
        iconImageView.backgroundColor = UIColor.systemBlue

        // Configure fallback text label
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
        imageLabel.textColor = .white
    }

    // MARK: - Gesture Recognizers
    private func setupGestureRecognizers() {
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callImageView.addGestureRecognizer(callTapGesture)
        callImageView.isUserInteractionEnabled = true

        let whatsAppTapGesture = UITapGestureRecognizer(target: self, action: #selector(whatsAppTapped))
        whatsAppImageView.addGestureRecognizer(whatsAppTapGesture)
        whatsAppImageView.isUserInteractionEnabled = true
    }

    // MARK: - Configuration Method
    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "\(designation)"

        if let image = icon {
            iconImageView.image = image
            iconImageView.backgroundColor = .clear
            imageLabel.isHidden = true
        } else {
            // Remove any previous image and set system blue background
            iconImageView.image = nil
            iconImageView.backgroundColor = UIColor.systemBlue
            
            // Display first letter of name as fallback
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.isHidden = false
            imageLabel.textColor = .white
            imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            imageLabel.textAlignment = .center
            
            // Ensure label stays in the center
            imageLabel.frame = iconImageView.bounds
            imageLabel.layer.cornerRadius = iconImageView.frame.width / 2
            imageLabel.clipsToBounds = true
        }
    }

    // MARK: - Actions
    @objc private func callTapped() {
        print("Call button tapped")
        // Open dialer logic can be added here
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
        // Implement WhatsApp opening logic
    }
}
