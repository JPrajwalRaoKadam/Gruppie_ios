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

    // Configure cell with the school data
    func configure(with school: School) {
        aLabelTeamNameIcon.text = school.shortName
                
        // Ensure subviews do not block interactions
        anImageIcon.isUserInteractionEnabled = false
        aLabelTeamNameIcon.isUserInteractionEnabled = false
        
        if !school.image.isEmpty {
            imgTeamNameIcon.isHidden = true // Hide the fallback label
            anImageIcon.isHidden = false // Show the image
            anImageIcon.image = UIImage(named: "placeholder") // Replace with image loading logic
        } else {
            displayFallback(for: school)
        }
    }

    // Display the first letter of `shortName` as a fallback
    private func displayFallback(for school: School) {
        anImageIcon.image = nil // Clear the image
        anImageIcon.isHidden = true // Hide the image view
        imgTeamNameIcon.isHidden = false // Show the fallback label
        imgTeamNameIcon.text = String(school.shortName.prefix(1)).uppercased() // Set the first letter
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


