import UIKit

class DetailFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style the image label for better visibility
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.textAlignment = .center
        imageLabel.backgroundColor = UIColor.lightGray
        imageLabel.textColor = UIColor.white
        imageLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with classData: FeedClassItem) {
        name.text = classData.name
        imageLabel.isHidden = false // Ensure it's visible by default
        imageLabel.text = String(classData.name.prefix(1)).uppercased() // First letter of name

        // ✅ Set background to system link color and text to white
        imageLabel.backgroundColor = .link
        imageLabel.textColor = .white
        imageLabel.clipsToBounds = true
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2 // Optional: make it circular

        if let imageUrlString = classData.image, !imageUrlString.isEmpty, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.icon.image = image
                        self.imageLabel.isHidden = true // Hide text if image loads
                    }
                }
            }
        } else {
            icon.image = UIImage(named: "placeholder") // Default placeholder image
            imageLabel.isHidden = false // Show fallback text
        }
    }
}
