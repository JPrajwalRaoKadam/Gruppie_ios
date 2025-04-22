import UIKit

class SubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Make iconImageView circular
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true

        // Make imageLabel circular
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.textAlignment = .center // Center the text inside the imageLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with subject: SubjectData) {
        nameLabel.text = subject.name

        if let imageURL = subject.image, let url = URL(string: imageURL) {
            loadImage(from: url)
            imageLabel.isHidden = true
            iconImageView.isHidden = false
        } else {
            iconImageView.image = generateImage(from: subject.name)  // This triggers the fallback image
            iconImageView.isHidden = false
            imageLabel.isHidden = true  // Optionally, hide the label
        }
    }

    // Method to load image from URL (you can use libraries like SDWebImage or use URLSession for this)
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.iconImageView.image = UIImage(data: data)
                }
            } else {
                DispatchQueue.main.async {
                    self.iconImageView.image = self.generateImage(from: self.nameLabel.text ?? "")
                }
            }
        }.resume()
    }

    // Method to generate a circular image with the first letter of the name as fallback
    private func generateImage(from name: String) -> UIImage? {
        let letter = name.prefix(1).uppercased()
        
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.link.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 30),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = letter.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        letter.draw(in: textRect, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
