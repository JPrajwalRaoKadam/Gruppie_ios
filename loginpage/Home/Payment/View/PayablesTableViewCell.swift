import UIKit

class PayablesTableViewCell: UITableViewCell {

    @IBOutlet weak var feeType: UILabel!
    @IBOutlet weak var PayLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var dueLabel: UILabel!

    var checkBoxAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // ✅ Proper config
    func configureCell(isChecked: Bool, title: String, dueAmount: String) {

        // ✅ Checkbox state (dynamic now)
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        checkBoxButton.setImage(image, for: .normal)

        // ✅ Set data
        feeType.text = title
        PayLabel.text = "\(dueAmount)"
        dueLabel.text = "\(dueAmount)"
    }

    @IBAction func checkBoxActionButton(_ sender: UIButton) {
        checkBoxAction?()
    }
}
