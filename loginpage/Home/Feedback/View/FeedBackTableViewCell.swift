//
//  FeedBackTableViewCell.swift
//  loginpage
//
//  Created by apple on 08/03/25.
//

import UIKit

class FeedBackTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var icon: UIImageView! // Ensure this exists
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
