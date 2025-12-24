import UIKit
class GroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var anImageIcon: UIImageView! // To display the image
    @IBOutlet weak var aLabelTeamNameIcon: UILabel! // To display the shortName
    @IBOutlet weak var imgTeamNameIcon: UILabel! // To display the first letter of the shortName if no image
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Ensure all subviews are tappable
         self.isUserInteractionEnabled = true
        if let anImageIcon = anImageIcon {
               anImageIcon.isUserInteractionEnabled = false
           }
           if let aLabelTeamNameIcon = aLabelTeamNameIcon {
               aLabelTeamNameIcon.isUserInteractionEnabled = false
           }
           if let imgTeamNameIcon = imgTeamNameIcon {
               imgTeamNameIcon.isUserInteractionEnabled = false
           }

         // Configure subviews (Image and labels)
         configureSubviews()
    }
    
    // Configure subviews (Image and labels)
    private func configureSubviews() {
        // Configuration for image, label, etc.
        if let anImageIcon = anImageIcon {
            anImageIcon.layer.cornerRadius = anImageIcon.frame.size.width / 4
            anImageIcon.clipsToBounds = true
            anImageIcon.contentMode = .scaleAspectFill
            anImageIcon.translatesAutoresizingMaskIntoConstraints = false
        }

        if let imgTeamNameIcon = imgTeamNameIcon {
            imgTeamNameIcon.layer.cornerRadius = imgTeamNameIcon.frame.size.width / 4
            imgTeamNameIcon.clipsToBounds = true
            imgTeamNameIcon.textAlignment = .center
            imgTeamNameIcon.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            imgTeamNameIcon.adjustsFontSizeToFitWidth = true
            imgTeamNameIcon.translatesAutoresizingMaskIntoConstraints = false
        }

        if let aLabelTeamNameIcon = aLabelTeamNameIcon {
            aLabelTeamNameIcon.textAlignment = .center
            aLabelTeamNameIcon.numberOfLines = 0
            aLabelTeamNameIcon.adjustsFontSizeToFitWidth = true
            aLabelTeamNameIcon.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupConstraints()
    }

    // Add Auto Layout constraints programmatically
    private func setupConstraints() {
        guard let anImageIcon = anImageIcon,
              let aLabelTeamNameIcon = aLabelTeamNameIcon,
              let imgTeamNameIcon = imgTeamNameIcon else { return }

        NSLayoutConstraint.activate([
            anImageIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            anImageIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            anImageIcon.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            anImageIcon.heightAnchor.constraint(equalTo: anImageIcon.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            imgTeamNameIcon.centerXAnchor.constraint(equalTo: anImageIcon.centerXAnchor),
            imgTeamNameIcon.centerYAnchor.constraint(equalTo: anImageIcon.centerYAnchor),
            imgTeamNameIcon.widthAnchor.constraint(equalTo: anImageIcon.widthAnchor),
            imgTeamNameIcon.heightAnchor.constraint(equalTo: anImageIcon.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            aLabelTeamNameIcon.topAnchor.constraint(equalTo: anImageIcon.bottomAnchor, constant: 8),
            aLabelTeamNameIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            aLabelTeamNameIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            aLabelTeamNameIcon.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    func configure(with group: GroupItem) {

        // Set group name
        aLabelTeamNameIcon.text = group.groupName

        // ❌ No image for now → hide image
        anImageIcon.image = nil
        anImageIcon.isHidden = true

        // ✅ Show first letter of group name
        imgTeamNameIcon.isHidden = false
        imgTeamNameIcon.text = String(group.groupName.prefix(1)).uppercased()
        imgTeamNameIcon.textColor = .white
    }



    // Display the first letter of `shortName` as a fallback
    private func displayFallback(for group: GroupItem) {
        anImageIcon.image = nil // Clear the image
        anImageIcon.isHidden = true // Hide the image view
        imgTeamNameIcon.isHidden = false // Show the fallback label
        imgTeamNameIcon.text = String(group.groupName.prefix(1)).uppercased() // Set the first letter
    }
}
extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


