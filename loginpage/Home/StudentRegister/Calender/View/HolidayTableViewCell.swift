//
//  HolidayTableViewCell.swift
//  loginpage
//
//  Created by Apple on 21/01/25.
//

import UIKit

class HolidayTableViewCell: UITableViewCell {

    @IBOutlet weak var cellStack: UIView!
    @IBOutlet weak var holidayList: UITextField!
    @IBOutlet weak var holidayDates: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
