import UIKit

class SearchStudentCell: UITableViewCell {
    
    @IBOutlet weak var StudentNameClass: UILabel!
    @IBOutlet weak var fallbackLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true
        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.size.width / 2
        fallbackLabel.clipsToBounds = true
        fallbackLabel.textAlignment = .center
        fallbackLabel.textColor = .black
        fallbackLabel.font = UIFont.systemFont(ofSize: 17)
        print("cell")
    }

    func configure(with student: SearchStudentList) {
        StudentNameClass.text = "\(student.name) (\(student.className))"
        
        if let imageString = student.image, !imageString.isEmpty {
            if imageString.hasPrefix("http"), let url = URL(string: imageString) {
                loadImage(from: url)
                fallbackLabel.isHidden = true
                iconImageView.isHidden = false
            } else if let decoded = Data(base64Encoded: imageString),
                      let img = UIImage(data: decoded) {
                iconImageView.image = img
                fallbackLabel.isHidden = true
                iconImageView.isHidden = false
            } else {
                fallbackLabel.text = String(student.name.prefix(1)).uppercased()
                fallbackLabel.isHidden = false
                iconImageView.isHidden = true
            }
        } else {
            fallbackLabel.text = String(student.name.prefix(1)).uppercased()
            fallbackLabel.isHidden = false
            iconImageView.isHidden = true
        }
    }

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.iconImageView.image = self.generateImage(from: self.StudentNameClass.text ?? "")
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
