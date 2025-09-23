//
//  classNameTableViewCell.swift
//  loginpage
//
//  Created by apple on 10/04/25.
//

import UIKit

class classNameTableViewCell: UITableViewCell {

    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fallbackLabel: UILabel!

override func awakeFromNib() {
    super.awakeFromNib()

    // Make iconImageView circular
    iconImageView.backgroundColor = .blue
    iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
    iconImageView.clipsToBounds = true

    // Make imageLabel circular
    fallbackLabel.layer.cornerRadius = fallbackLabel.frame.size.width / 2
    fallbackLabel.clipsToBounds = true
    fallbackLabel.textAlignment = .center
   // fallbackLabel.backgroundColor = .link  // Set background color
    fallbackLabel.textColor = .black
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
}
 func configure(with subject: SubjectData) {
        classLabel.text = subject.name

//        if let imageURL = subject.image, let url = URL(string: imageURL) {
//            loadImage(from: url)
//            fallbackLabel.isHidden = true
//            iconImageView.isHidden = false
//        } else {
            // Use label fallback
            fallbackLabel.text = String(subject.name.prefix(1)).uppercased()
            fallbackLabel.isHidden = false
            iconImageView.isHidden = true

           // fallbackLabel.backgroundColor = .link
            fallbackLabel.textColor = .black   // 👈 set any color you want here
//        }
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
//                    self.iconImageView.image = self.generateImage(from: self.classLabel.text ?? "")
                }
            }
        }.resume()
    }

    private func generateImage(from name: String) -> UIImage? {
        let letter = name.prefix(1).uppercased()
        
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set background color to system mint
        let mintColor = UIColor.link
        context?.setFillColor(mintColor.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 23),
            .foregroundColor: UIColor.white // Set text color to white
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
