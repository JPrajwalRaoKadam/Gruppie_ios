import UIKit

class Member_TableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var whatsApp: UIImageView!
    @IBOutlet weak var call: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure circular corners after layout is complete
        icon.layer.cornerRadius = icon.frame.size.width / 2
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        // Configure icon image view
        icon.layer.cornerRadius = icon.frame.size.width / 2
        icon.clipsToBounds = true
        
        // Configure image label for fallback
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.isHidden = true
        imageLabel.textAlignment = .center
        imageLabel.textColor = .black
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
//        imageLabel.backgroundColor = .link
        imageLabel.adjustsFontSizeToFitWidth = true
        imageLabel.minimumScaleFactor = 0.5
    }
    
    func configureCell(with member: Member) {
        name.text = member.name
        designation.text = member.designation
        
        // Reset both views
        icon.image = nil
        icon.backgroundColor = nil
        imageLabel.isHidden = true
        
        if let imageURL = member.image, let url = URL(string: imageURL) {
            // Load image from URL
            loadImage(from: url)
        } else {
            // Show fallback with first letter in imageLabel
            showFallbackImage(with: member.name ?? "")
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil, let image = UIImage(data: data) {
                    // Successfully loaded image
                    self.icon.image = image
                    self.icon.backgroundColor = nil
                    self.imageLabel.isHidden = true
                } else {
                    // Failed to load image, show fallback
                    self.showFallbackImage(with: self.name.text ?? "")
                }
            }
        }.resume()
    }
    
    private func showFallbackImage(with name: String) {
        let letter = name.prefix(1).uppercased()
        
        // Hide icon and show imageLabel with the letter
        icon.image = nil
        icon.backgroundColor = .link
        imageLabel.text = letter
        imageLabel.isHidden = false
        
        // Ensure circular layout
        setNeedsLayout()
        layoutIfNeeded()
    }
}
