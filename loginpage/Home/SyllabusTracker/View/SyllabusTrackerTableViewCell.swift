//
//  AttendanceTableViewCell.swift
//  loginpage
//
//  Created by apple on 10/02/25.
//

//    import UIKit
//
//class SyllabusTrackerTableViewCell: UITableViewCell {
//        
//        @IBOutlet weak var classLabel: UILabel!
//        @IBOutlet weak var iconImageView: UIImageView!
//        @IBOutlet weak var fallbackLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        // Make iconImageView circular
//        iconImageView.backgroundColor = .blue
//        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
//        iconImageView.clipsToBounds = true
//
//        // Make imageLabel circular
//        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.size.width / 2
//        fallbackLabel.clipsToBounds = true
//        fallbackLabel.textAlignment = .center
//        fallbackLabel.textColor = .black
//
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//
//   func configure(with subject: SubjectData) {
//       classLabel.text = subject.name
//
//       if let imageURL = subject.image, let url = URL(string: imageURL) {
//           loadImage(from: url, fallbackName: subject.name)
//       } else {
//           iconImageView.image = generateImage(from: subject.name)
//       }
//   }
//       
//   private func loadImage(from url: URL, fallbackName: String) {
//       URLSession.shared.dataTask(with: url) { data, _, _ in
//           DispatchQueue.main.async {
//               if let data = data, let image = UIImage(data: data) {
//                   self.iconImageView.image = image
//               } else {
//                   self.iconImageView.image = self.generateImage(from: fallbackName)
//               }
//           }
//       }.resume()
//   }
//
//
//
//
//    // Method to load image from URL (you can use libraries like SDWebImage or use URLSession for this)
//    private func loadImage(from url: URL) {
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let data = data, error == nil {
//                DispatchQueue.main.async {
//                    self.iconImageView.image = UIImage(data: data)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.iconImageView.image = self.generateImage(from: self.classLabel.text ?? "")
//                }
//            }
//        }.resume()
//    }
//    
//    private func generateImage(from name: String) -> UIImage? {
//        let letter = name.prefix(1).uppercased()
//        
//        let size = CGSize(width: 50, height: 50)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        
//        // ✅ No background, only text
//        let textAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.boldSystemFont(ofSize: 30),
//            .foregroundColor: UIColor.black   // 🔹 Black text
//        ]
//        
//        let textSize = letter.size(withAttributes: textAttributes)
//        let textRect = CGRect(
//            x: (size.width - textSize.width) / 2,
//            y: (size.height - textSize.height) / 2,
//            width: textSize.width,
//            height: textSize.height
//        )
//        
//        letter.draw(in: textRect, withAttributes: textAttributes)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
//
//
//}

import UIKit

class SyllabusTrackerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fallbackLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Make iconImageView circular
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.clipsToBounds = true

        // Make fallbackLabel circular
        fallbackLabel.layer.cornerRadius = fallbackLabel.frame.size.width / 2
        fallbackLabel.clipsToBounds = true
        fallbackLabel.textAlignment = .center
        fallbackLabel.textColor = .black   // ✅ black text for fallback
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with subject: SubjectData) {
        classLabel.text = subject.name

        if let imageURL = subject.image, let url = URL(string: imageURL) {
            loadImage(from: url)
        } else {
            showFallback(for: subject.name)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
//                if let data = data, error == nil, let image = UIImage(data: data) {
////                    self.iconImageView.image = image
//                    self.iconImageView.isHidden = false
//                    self.fallbackLabel.isHidden = true
//                } else {
                    self.showFallback(for: self.classLabel.text ?? "")
//                }
            }
        }.resume()
    }

    private func showFallback(for name: String) {
        let initials = !name.isEmpty ? String(name.prefix(1)).uppercased() : "?"
        fallbackLabel.text = initials
        fallbackLabel.isHidden = false
        iconImageView.isHidden = true
    }
}
