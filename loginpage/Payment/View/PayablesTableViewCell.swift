//
//  PayablesTableViewCell.swift
//  loginpage
//
//  Created by apple on 28/02/25.
//

import UIKit

class PayablesTableViewCell: UITableViewCell {

    @IBOutlet weak var feeType: UILabel!
    @IBOutlet weak var PayLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var dueLabel: UILabel!

    var checkBoxAction: (() -> Void)? // Callback for button tap

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell(isChecked: false)
    }

    func configureCell(isChecked: Bool, payAmount: String = "", dueAmount: String = "") {
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        checkBoxButton.setImage(image, for: .normal)
        PayLabel.text = payAmount
        dueLabel.text = dueAmount
    }
    @IBAction func checkBoxActionButton(_ sender: UIButton) {
        checkBoxAction?() // Call action in ViewController
    }
}
