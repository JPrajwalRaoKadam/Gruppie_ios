import UIKit

class DetailTableViewCell: UITableViewCell {
    
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
    func configure(with student: StudentRegistration) {
        
        nameLabel.text = student.firstName
        designationLabel.text = student.fatherName ?? "N/A"

        // Profile image (if available later)
        iconImageView.image = nil
        iconImageView.backgroundColor = UIColor.systemBlue

        let firstLetter = String(student.firstName.prefix(1)).uppercased()
        imageLabel.text = firstLetter
        imageLabel.isHidden = false
    }


    @objc private func callTapped() {
        print("Call button tapped")
    }

    @objc private func whatsAppTapped() {
        print("WhatsApp button tapped")
    }
}
