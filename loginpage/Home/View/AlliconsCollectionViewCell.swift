import UIKit

class AlliconsCollectionViewCell: UICollectionViewCell {
    var groupDatas: [GroupData] = []
    
    @IBOutlet weak var iconLabel: UILabel! {
        didSet {
            iconLabel.numberOfLines = 1 // Restrict to a single line
            iconLabel.lineBreakMode = .byTruncatingTail // Add ellipsis for long text
        }
    }

    @IBOutlet weak var iconimg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with featureIcon: FeatureIcon) {
        let truncatedText = featureIcon.type.count > 10
            ? String(featureIcon.type.prefix(10)) + "..."
            : featureIcon.type
        iconLabel.text = truncatedText // Use the truncated text for the label
        print("Configuring Cell with Feature Icon Type: \(featureIcon.type)")
        if let imageUrl = URL(string: featureIcon.image) {
            iconimg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
