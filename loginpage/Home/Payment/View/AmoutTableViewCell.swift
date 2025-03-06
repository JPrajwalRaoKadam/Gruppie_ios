//
//  AmoutTableViewCell.swift
//  loginpage
//
//  Created by apple on 19/02/25.
//

import UIKit

class AmoutTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func statusAction(_ sender: Any) {
        
    }
    
    @IBAction func receiptAction(_ sender: Any) {
        
    }
}
