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

        // Set default background color for imageView
        iconImageView.backgroundColor = .systemGray // Set it to grey for fallback
        imageLabel.isHidden = true // Hide text by default
    }

    // MARK: - Gesture Recognizers
    private func setupGestureRecognizers() {
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callImageView.addGestureRecognizer(callTapGesture)

        let whatsAppTapGesture = UITapGestureRecognizer(target: self, action: #selector(whatsAppTapped))
        whatsAppImageView.addGestureRecognizer(whatsAppTapGesture)
    }

    // MARK: - Configuration Method
    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
        nameLabel.text = name
        designationLabel.text = "\(designation)"

        // If icon is available, display it
        if let image = icon {
            iconImageView.image = image
            imageLabel.isHidden = true // Hide fallback text if image is available
        } else {
            // Remove any previous image and set a fallback background color
            iconImageView.image = nil
            iconImageView.backgroundColor = .systemGray // Grey background for fallback
            imageLabel.text = String(name.prefix(1)).uppercased() // Display first letter of name
            imageLabel.textColor = .white // White text color for fallback
            imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
            imageLabel.isHidden = false // Show fallback text
        }
    }

    // MARK: - Actions
    @objc private func callTapped() {
        print("Call button tapped")
        // You can open dialer with a valid phone number
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
        // Implement WhatsApp opening logic
    }
}
