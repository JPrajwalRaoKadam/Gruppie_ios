import UIKit

class TeachingStaff: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var whatsApp: UIImageView!
    @IBOutlet weak var call: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupIcon()
    }

    // Set up the icon to be circular
    private func setupIcon() {
        icon.layer.cornerRadius = icon.frame.size.width / 2
        icon.layer.masksToBounds = true
    }

    func configureCell(with staff: Staff) {
        name.text = staff.name
        designation.text = staff.designation

        if let imageURL = staff.imageURL, let url = URL(string: imageURL) {
            loadImage(from: url)
        } else {
            showFallbackImage(for: staff.name)
        }
    }

    // Load the image from the URL asynchronously
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.icon.image = image
                }
            }
        }.resume()
    }

    // Show fallback image with the first letter of the name
    private func showFallbackImage(for name: String) {
        icon.image = nil
        let firstLetter = name.prefix(1).uppercased()
        
        // Create a label inside the icon to show the first letter
        imageLabel.text = firstLetter
        imageLabel.textAlignment = .center
        imageLabel.textColor = .white
        imageLabel.font = UIFont.boldSystemFont(ofSize: 20) // Increased font size
        icon.backgroundColor = UIColor.link
        
        // Ensure label's text is centered within the circle
        imageLabel.frame = icon.bounds
        icon.addSubview(imageLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
