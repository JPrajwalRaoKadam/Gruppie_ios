import UIKit

class FeedBackTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageLabel.clipsToBounds = true
        imageLabel.textAlignment = .center
        imageLabel.backgroundColor = .systemGray4
        imageLabel.textColor = .white
        imageLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        icon.clipsToBounds = true
        icon.layer.cornerRadius = icon.frame.size.width / 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Ensure circular shape after layout
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2
    }

    func configure(with title: String?, imageURL: String?) {
        name.text = title ?? "Untitled"

        if let urlStr = imageURL, let url = URL(string: urlStr) {
            icon.isHidden = false
            imageLabel.isHidden = true
            icon.image = UIImage(named: "defaultProfile") // Replace if needed
        } else {
            icon.isHidden = true
            imageLabel.isHidden = false
            let initial = title?.trimmingCharacters(in: .whitespacesAndNewlines).first?.uppercased() ?? "#"
            imageLabel.text = initial
        }
    }
}
