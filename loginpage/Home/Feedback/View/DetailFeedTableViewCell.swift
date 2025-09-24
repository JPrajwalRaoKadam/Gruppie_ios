import UIKit

class DetailFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        imageLabel.textAlignment = .center
//        imageLabel.backgroundColor = UIColor.lightGray
        imageLabel.textColor = UIColor.black
        imageLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with classData: FeedClassItem) {
        name.text = classData.name
        imageLabel.isHidden = false
        imageLabel.text = String(classData.name.prefix(1)).uppercased()

//        imageLabel.backgroundColor = .link
        imageLabel.textColor = .black
        imageLabel.clipsToBounds = true
        imageLabel.layer.cornerRadius = imageLabel.frame.height / 2

        if let imageUrlString = classData.image, !imageUrlString.isEmpty, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.icon.image = image
                        self.imageLabel.isHidden = true
                    }
                }
            }
        } else {
            icon.image = UIImage(named: "placeholder")
            imageLabel.isHidden = false 
        }
    }
}
