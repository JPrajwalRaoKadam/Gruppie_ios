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
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
        
        whatsAppImageView.layer.cornerRadius = whatsAppImageView.frame.height / 2
        callImageView.layer.cornerRadius = callImageView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
        imageLabel.clipsToBounds = true
        whatsAppImageView.clipsToBounds = true
        callImageView.clipsToBounds = true
        
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
        whatsAppImageView.layer.cornerRadius = whatsAppImageView.frame.height / 2
        callImageView.layer.cornerRadius = callImageView.frame.height / 2

        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        imageLabel.textColor = .black
        
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
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .black // Better contrast
            imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false
        }
                setNeedsLayout()
    }

    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
