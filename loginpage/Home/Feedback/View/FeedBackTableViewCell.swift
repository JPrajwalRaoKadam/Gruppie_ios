import UIKit

class FeedBackTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCircularAppearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupCircularAppearance() {
        // Make both imageLabel and icon circular
        imageLabel.layer.cornerRadius = imageLabel.frame.size.height / 2
        imageLabel.layer.masksToBounds = true
        imageLabel.clipsToBounds = true
        
        icon.layer.cornerRadius = icon.frame.size.height / 2
        icon.layer.masksToBounds = true
        icon.clipsToBounds = true
        
        // Center text in the label and set styling
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.systemFont(ofSize: 17)
        imageLabel.textColor = .black
    }
    
    func configure(with image: UIImage?, name: String) {
        self.name.text = name
        
        if let image = image {
            // Image is present - show icon and hide label
            icon.image = image
            icon.isHidden = false
            imageLabel.isHidden = true
        } else {
            // Image is not present - show fallback with first letter
            icon.isHidden = true
            imageLabel.isHidden = false
            
            // Get first letter of name (or "?" if empty)
            let firstLetter = name.first.map { String($0) }?.uppercased() ?? "?"
            imageLabel.text = firstLetter
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update corner radius after layout changes to ensure perfect circles
        imageLabel.layer.cornerRadius = imageLabel.frame.size.height / 2
        icon.layer.cornerRadius = icon.frame.size.height / 2
    }
}
