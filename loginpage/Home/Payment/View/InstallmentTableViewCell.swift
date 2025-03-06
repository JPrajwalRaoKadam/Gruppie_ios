//
//  InstallmentTableViewCell.swift
//  loginpage
//
//  Created by apple on 19/02/25.
//

import UIKit

class InstallmentTableViewCell: UITableViewCell {

    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
