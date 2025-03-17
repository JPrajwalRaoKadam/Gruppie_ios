//
//  AddFeedBackTableViewCell.swift
//  loginpage
//
//  Created by apple on 10/03/25.
//

import UIKit

class AddFeedBackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var QuestionNo: UILabel!
    @IBOutlet weak var Question: UITextField!
    @IBOutlet weak var Marks:  UITextField!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
