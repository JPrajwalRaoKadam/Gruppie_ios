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
        configureCell(isChecked: true) // Always checked initially
    }

    func configureCell(isChecked: Bool = true, payAmount: String = "", dueAmount: String = "") {
        // Always show checked image
        let image = UIImage(systemName: "checkmark.square.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        checkBoxButton.setImage(image, for: .normal)

        PayLabel.text = payAmount
        dueLabel.text = dueAmount
    }

    @IBAction func checkBoxActionButton(_ sender: UIButton) {
        checkBoxAction?() // You can still call action if needed
    }
}
