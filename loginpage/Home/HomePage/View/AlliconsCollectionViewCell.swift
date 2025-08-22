import UIKit

class AlliconsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconLabel: UILabel! {
        didSet {
            iconLabel.numberOfLines = 1
            iconLabel.lineBreakMode = .byTruncatingTail
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImage.layer.cornerRadius = iconImage.frame.size.width / 2
        iconImage.clipsToBounds = true
    }
    func configure(with featureIcon: FeatureIcon) {
        let name = featureIcon.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = name.components(separatedBy: .whitespacesAndNewlines)
        let totalLength = name.count   // includes spaces
        
        var modifiedName = name
        
        if totalLength == 10 {
            // ✅ If total length (including spaces) = 10 → single line
            modifiedName = name
            iconLabel.numberOfLines = 1
        } else if words.count == 2 {
            // ✅ If exactly 2 words → split into 2 lines
            modifiedName = "\(words[0])\n\(words[1])"
            iconLabel.numberOfLines = 2
        } else if totalLength > 10 {
            // ✅ If length > 10 → allow wrapping
            modifiedName = name
            iconLabel.numberOfLines = 0
        } else {
            // ✅ Default → normal single line
            modifiedName = name
            iconLabel.numberOfLines = 1
        }
        
        iconLabel.text = modifiedName
        iconLabel.lineBreakMode = .byWordWrapping
        iconLabel.textAlignment = .center
        
        if let imageUrl = URL(string: featureIcon.image) {
            iconImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
