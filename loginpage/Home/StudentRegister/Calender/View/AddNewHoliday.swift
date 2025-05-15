//
//  HolidayTableViewCell.swift
//  loginpage
//
//  Created by Apple on 21/01/25.
//
import UIKit

protocol AddNewHolidayDelegate: AnyObject {
    func didTapAddMore()
    func didTapDateField(textField: UITextField)
}


class AddNewHoliday: UITableViewCell {
 
    @IBOutlet weak var addholidayStack: UIStackView!
    @IBOutlet weak var holidayTitle: UITextField!
    @IBOutlet weak var addMore: UIButton!
    @IBOutlet weak var holidaydate: UITextField!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var addMoreHeightConstraint: NSLayoutConstraint!
    weak var delegate: AddNewHolidayDelegate? // Delegate property
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func newHolidayDate(_ sender: Any) {
        delegate?.didTapDateField(textField: holidaydate)
       
    }
    
    
    @IBAction func addMoreButtonAction(_ sender: Any) {
        delegate?.didTapAddMore()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
