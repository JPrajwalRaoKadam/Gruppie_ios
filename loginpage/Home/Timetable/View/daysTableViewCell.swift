//
//  daysTableViewCell.swift
//  loginpage
//
//  Created by apple on 29/04/25.
//

import UIKit

class daysTableViewCell: UITableViewCell {

    
    @IBOutlet weak var periodNo: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
