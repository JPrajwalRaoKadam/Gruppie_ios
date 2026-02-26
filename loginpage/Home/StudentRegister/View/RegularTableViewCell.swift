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
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        designationLabel.text = nil
        iconImageView.image = nil
        imageLabel.text = nil
        imageLabel.isHidden = true
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

//    private func setupUI() {
//        iconImageView.clipsToBounds = true
//        imageLabel.clipsToBounds = true
//        whatsAppImageView.clipsToBounds = true
//        callImageView.clipsToBounds = true
//        
//        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
//        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
//        whatsAppImageView.layer.cornerRadius = whatsAppImageView.frame.height / 2
//        callImageView.layer.cornerRadius = callImageView.frame.height / 2
//
//        imageLabel.isHidden = true
//        imageLabel.textAlignment = .center
//        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
//        imageLabel.textColor = .black
//        
//    }
    private func setupUI() {
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        imageLabel.textColor = .black
       // imageLabel.backgroundColor = .clear
    }

    private func setupGestureRecognizers() {
        let callTapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callImageView.addGestureRecognizer(callTapGesture)
        callImageView.isUserInteractionEnabled = true

        let whatsAppTapGesture = UITapGestureRecognizer(target: self, action: #selector(whatsAppTapped))
        whatsAppImageView.addGestureRecognizer(whatsAppTapGesture)
        whatsAppImageView.isUserInteractionEnabled = true
    }

//    func configure(name: String, designation: Int, icon: UIImage?, phoneNumber: String) {
//        nameLabel.text = name
//        designationLabel.text = "Students: \(designation)"
//
//        if let image = icon {
//            iconImageView.image = image
//            imageLabel.isHidden = true
//        } else {
//            iconImageView.image = nil
//            imageLabel.text = String(name.prefix(1)).uppercased()
//            imageLabel.textColor = .black // Better contrast
//            imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
//            imageLabel.textAlignment = .center
//            imageLabel.isHidden = false
//        }
//                setNeedsLayout()
//    }
    func configure(name: String, studentCount: Int) {
        nameLabel.text = name
        designationLabel.text = "Students: \(studentCount)"

        iconImageView.image = UIImage(named: "default_profile")
        imageLabel.isHidden = true
    }


    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
