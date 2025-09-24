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
        iconImageView.backgroundColor = .clear // Set clear background for icon

        // Make imageLabel circular
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.textAlignment = .center
        imageLabel.backgroundColor = .clear
        imageLabel.textColor = .black
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
            showFallback(with: subject.name)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    self.iconImageView.image = UIImage(data: data)
                    self.iconImageView.backgroundColor = .clear // Clear background when image is shown
                    self.imageLabel.isHidden = true
                } else {
                    self.showFallback(with: self.nameLabel.text ?? "")
                }
            }
        }.resume()
    }

    private func showFallback(with name: String) {
        let letter = name.prefix(1).uppercased()
        
        // Clear both background and image
        iconImageView.image = nil
        iconImageView.backgroundColor = .clear // Clear background
        
        // Configure and show the imageLabel
        imageLabel.text = letter
        imageLabel.textColor = .black // Black text color
        imageLabel.backgroundColor = .clear // No background color
        imageLabel.isHidden = false
        
        // Ensure the icon image view is visible but transparent
        iconImageView.isHidden = false
    }
}
