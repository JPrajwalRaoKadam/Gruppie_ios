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
        
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        
        imageLabel.layer.cornerRadius = iconImageView.frame.width / 2
        imageLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupUI() {
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor.systemBlue

        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 24)
        imageLabel.textColor = .white
        imageLabel.backgroundColor = .clear
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

            imageLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
                imageLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
                imageLabel.widthAnchor.constraint(equalTo: iconImageView.widthAnchor),
                imageLabel.heightAnchor.constraint(equalTo: iconImageView.heightAnchor)
            ])
        }
    }

    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
