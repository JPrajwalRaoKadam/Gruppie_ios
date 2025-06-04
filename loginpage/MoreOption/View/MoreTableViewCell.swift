//
//  MoreTableViewCell.swift
//  loginpage
//
//  Created by apple on 29/05/25.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moreOptionLabels: UILabel!
    @IBOutlet weak var moreImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
