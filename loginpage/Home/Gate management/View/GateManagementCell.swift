import UIKit

class GateManagementCell: UITableViewCell {
    
    @IBOutlet weak var fallbackLabel: UILabel!
    @IBOutlet weak var visitorName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var personToVisit: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true
        
        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.size.width / 2
        fallbackLabel.clipsToBounds = true
        fallbackLabel.textAlignment = .center
        fallbackLabel.backgroundColor = .link
        fallbackLabel.textColor = .white
        print("cell")
    }

    func configure(with gate: GateData) {
        visitorName.text = gate.gateNumber

        if let images = gate.image, let firstImage = images.first {
            if firstImage.hasPrefix("http"), let url = URL(string: firstImage) {
                loadImage(from: url)
                fallbackLabel.isHidden = true
                iconImageView.isHidden = false
            } else if let decoded = Data(base64Encoded: firstImage), let img = UIImage(data: decoded) {
                iconImageView.image = img
                fallbackLabel.isHidden = true
                iconImageView.isHidden = false
            } else {
                iconImageView.image = generateImage(from: gate.gateNumber)
                fallbackLabel.isHidden = true
                iconImageView.isHidden = false
            }
        } else {
            iconImageView.image = generateImage(from: gate.gateNumber)
            fallbackLabel.isHidden = true
            iconImageView.isHidden = false
        }
    }

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.iconImageView.image = self.generateImage(from: self.visitorName.text ?? "")
                }
                return
            }
            DispatchQueue.main.async {
                self.iconImageView.image = image
            }
        }.resume()
    }

    func generateImage(from name: String) -> UIImage? {
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
