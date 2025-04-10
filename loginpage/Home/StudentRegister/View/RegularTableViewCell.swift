import UIKit

class RegularTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - UI Configuration
    private func setupUI() {
        // Make the iconImageView circular
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        iconImageView.clipsToBounds = true

        // Set a system link color background for fallback
        iconImageView.backgroundColor = UIColor.link

        // Configure fallback text label
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center // Center text
        imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }

    // MARK: - Gesture Recognizers
    private func setupGestureRecognizers() {
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callImageView.addGestureRecognizer(callTapGesture)
        callImageView.isUserInteractionEnabled = true // Enable interaction

        let whatsAppTapGesture = UITapGestureRecognizer(target: self, action: #selector(whatsAppTapped))
        whatsAppImageView.addGestureRecognizer(whatsAppTapGesture)
        whatsAppImageView.isUserInteractionEnabled = true // Enable interaction
    }

    // MARK: - Configuration Method
    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "Students: \(designation)"

        if let image = icon {
            iconImageView.image = image
            imageLabel.isHidden = true
        } else {
            // Remove any previous image and set system link color background
            iconImageView.image = nil
            iconImageView.backgroundColor = UIColor.link

            // Display first letter of name as fallback
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .white
            imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false
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
