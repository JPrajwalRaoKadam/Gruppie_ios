//
//  ClassTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 16/01/25.
//

import UIKit

class ClassTableViewCell: UITableViewCell {

    @IBOutlet weak var classImageView: UIImageView!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var classLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        classImageView.layer.cornerRadius = classImageView.bounds.width / 2
            classImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(teamPost: TeamPost) {
        classLabel.text = teamPost.name
    }
    
    func setFirstLetterAsImage() {
        guard let text = classLabel.text, !text.isEmpty else {
            classImageView.image = nil // Clear image if no text
            return
        }
        
        // Get the first letter of the text
        let firstLetter = String(text.prefix(1))
        
        // Set up the text attributes
        let size = classImageView.bounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Set the background color
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Configure text attributes
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.width / 2, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            // Calculate text size and position
            let textSize = firstLetter.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            // Draw the text
            firstLetter.draw(in: textRect, withAttributes: attributes)
        }
        
        // Assign the generated image to the image view
        classImageView.image = image
    }
}
