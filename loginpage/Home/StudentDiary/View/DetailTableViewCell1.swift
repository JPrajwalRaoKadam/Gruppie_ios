import UIKit

class DetailTableViewCell1: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var whatsAppImageView: UIImageView!
    @IBOutlet weak var callImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel! // Label for fallback text

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGestureRecognizers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make both views circular
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupUI() {
        // Configure iconImageView
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor.systemBlue

        // Configure imageLabel
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        imageLabel.textColor = .black  // Changed to white for better contrast
//        imageLabel.backgroundColor = .systemBlue
        imageLabel.clipsToBounds = true
        
        // Position the imageLabel over the iconImageView in storyboard
        // or set constraints programmatically here (only once)
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
        designationLabel.text = "\(designation)"

        if let image = icon {
            iconImageView.image = image
            iconImageView.backgroundColor = .clear
            imageLabel.isHidden = true
        } else {
            iconImageView.image = nil
            iconImageView.backgroundColor = UIColor.systemBlue

            let firstLetter = String(name.prefix(1)).uppercased()
            print("Fallback Text: \(firstLetter)") // Debug print

            imageLabel.text = firstLetter
            imageLabel.isHidden = false
        }
    }

    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
