//
//  ClassesTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 06/02/25.
//

import UIKit

class ClassesTableViewCell: UITableViewCell {

    
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

    func configure(with student: StudentFinancialData) {
        nameLabel.text = student.name
            iconImageView.image = generateImage(from: student.name)  // This triggers the fallback image
            iconImageView.isHidden = false
            imageLabel.isHidden = true  // Optionally, hide the label
    }
    
    func configurePayment(with sub: SubjectData ) {
        nameLabel.text = sub.name
        iconImageView.image = generateImage(from: sub.name ?? "")  // This triggers the fallback image
            iconImageView.isHidden = false
            imageLabel.isHidden = true  // Optionally, hide the label
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
        
        // Use hex color #FFFFFF
        let hexColor = UIColor(hex: "#F1EFEB")
        context?.setFillColor(hexColor.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 23),
            .foregroundColor: UIColor.black
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

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
