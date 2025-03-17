//
//  SubjectNameDetailsTableViewCell.swift
//  loginpage
//
//  Created by apple on 13/03/25.
//

import UIKit

class SubjectNameDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var subName: UILabel!
        
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var obtainedMarksTextFeild: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
