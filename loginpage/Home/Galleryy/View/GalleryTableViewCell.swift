//
//  GalleryTableViewCell.swift
//  loginpage
//
//  Created by apple on 04/03/25.
//

import UIKit

class GalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var ImageUrl: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var Date: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
