//
//  TimetableTableViewCell.swift
//  loginpage
//
//  Created by apple on 13/03/25.
//

import UIKit

class TimetableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        // ✅ Hide imageLabel by default
        imageLabel.isHidden = true
        imageLabel.layer.cornerRadius = imageLabel.frame.size.width / 2
        imageLabel.clipsToBounds = true
        
        // ✅ Set font and alignment
        imageLabel.textAlignment = .center
        imageLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // ✅ Handle Image Fallback
    func configureCell(with name: String, icon: UIImage?) {
        self.name.text = name
        
        if let image = icon {
            self.icon.image = image
            imageLabel.isHidden = true
        } else {
            self.icon.image = nil
            imageLabel.isHidden = false
            imageLabel.text = String(name.prefix(1)).uppercased()
            imageLabel.backgroundColor = .link
            imageLabel.textColor = .white  // Set text color to white

        }
    }
}
