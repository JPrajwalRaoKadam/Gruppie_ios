//
//  SubDetailsTableViewCell.swift
//  loginpage
//
//  Created by apple on 17/04/25.
//

import UIKit

class SubDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var topicName: UILabel!
    
    @IBOutlet weak var createdOn: UILabel!
    
    @IBOutlet weak var datacontainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func threeDots(_ sender: Any) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
