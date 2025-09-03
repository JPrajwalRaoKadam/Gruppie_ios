//
//  GateListVCTableViewCell.swift
//  loginpage
//
//  Created by apple on 24/07/25.
//
import UIKit

protocol GateListVCCellDelegate: AnyObject {
    func didTapCheckButton(gateId: String, gateName: String)
}

class GateListVCTableViewCell: UITableViewCell {

    @IBOutlet weak var gateName: UILabel!
    @IBOutlet weak var checkButton: UIButton!

    weak var delegate: GateListVCCellDelegate?

    var gateId: String = "" // add this to store gateId
    var isChecked: Bool = false {
        didSet {
            let imageName = isChecked ? "checkmark.square.fill" : "square"
            checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.isUserInteractionEnabled = false
        checkButton.tintColor = .black  // ✅ set black color for the checkmark
        isChecked = false
    }

    @objc func checkButtonTapped() {
        isChecked.toggle()
        if let name = gateName.text {
            delegate?.didTapCheckButton(gateId: gateId, gateName: name)
        }
    }
}
