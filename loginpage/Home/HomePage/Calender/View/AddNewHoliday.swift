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


class AddNewHoliday: UITableViewCell, UITextFieldDelegate {
 
    @IBOutlet weak var addholidayStack: UIStackView!
    @IBOutlet weak var holidayTitle: UITextField!
    @IBOutlet weak var addMore: UIButton!
    @IBOutlet weak var holidaydate: UITextField!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var addMoreHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: AddNewHolidayDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        holidaydate.delegate = self
    }
    
    @IBAction func addMoreButtonAction(_ sender: Any) {
        delegate?.didTapAddMore()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == holidaydate {
            delegate?.didTapDateField(textField: textField)
            return false
        }
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
