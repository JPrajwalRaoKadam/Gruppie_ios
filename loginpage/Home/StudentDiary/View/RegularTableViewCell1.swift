import UIKit

class RegularTableViewCell1: UITableViewCell {

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
        // Update corner radius after layout is complete
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupUI() {
        // Configure iconImageView
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = UIColor.link
        
        // Configure imageLabel
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        imageLabel.clipsToBounds = true
//        imageLabel.backgroundColor = UIColor.link // Or any color you prefer
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
            iconImageView.backgroundColor = UIColor.clear
        } else {
            iconImageView.image = nil
            iconImageView.backgroundColor = UIColor.link

            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.textColor = .black // Changed to white for better contrast
            imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            imageLabel.textAlignment = .center
            imageLabel.isHidden = false
//            imageLabel.backgroundColor = UIColor.link
        }
        
        // Ensure corner radius is updated
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
    }

    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
