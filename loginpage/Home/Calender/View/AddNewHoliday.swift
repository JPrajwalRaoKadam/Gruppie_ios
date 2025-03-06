//
//  HolidayTableViewCell.swift
//  loginpage
//
//  Created by Apple on 21/01/25.
//

import UIKit

protocol AddNewHolidayDelegate: AnyObject {
    func didTapAddMore()
}


class AddNewHoliday: UITableViewCell {
 
    @IBOutlet weak var holidayTitle: UITextField!
    @IBOutlet weak var addMore: UIButton!
    @IBOutlet weak var holidaydate: UITextField!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    weak var delegate: AddNewHolidayDelegate? // Delegate property
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    
    @IBAction func addMoreButtonAction(_ sender: Any) {
        delegate?.didTapAddMore()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
