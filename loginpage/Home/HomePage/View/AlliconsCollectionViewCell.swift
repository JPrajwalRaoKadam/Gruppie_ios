import UIKit

class AlliconsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconLabel: UILabel! {
        didSet {
            iconLabel.numberOfLines = 1
            iconLabel.lineBreakMode = .byTruncatingTail
        }
    }
    
    @IBOutlet weak var iconImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with featureIcon: FeatureIcon) {
        iconLabel.text = featureIcon.name.count > 10 ? String(featureIcon.name.prefix(10)) + "..." : featureIcon.name
        if let imageUrl = URL(string: featureIcon.image) {
            iconImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
