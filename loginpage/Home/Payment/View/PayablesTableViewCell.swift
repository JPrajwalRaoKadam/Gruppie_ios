import UIKit

class PayablesTableViewCell: UITableViewCell {

    @IBOutlet weak var feeType: UILabel!
    @IBOutlet weak var PayLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var fineFeild: UITextField!
    @IBOutlet weak var concessionFeild: UITextField!
    @IBOutlet weak var payableFeild: UITextField!
    
    var checkBoxAction: (() -> Void)?
    var amountChanged: ((Double, Bool) -> Void)?
    var isChecked: Bool = true
    var balanceAmount: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fineFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        concessionFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        payableFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    func configureCell(isChecked: Bool = true, demand: PaymentDemand) {
        
        self.isChecked = isChecked
        
        let image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        checkBoxButton.setImage(image, for: .normal)
        balanceAmount = demand.balance ?? 0
        feeType.text = demand.feeType
        
        totalLabel.text = "\(demand.total ?? 0)"
        paidLabel.text = "\(demand.paid ?? 0)"
        balanceLabel.text = "\(demand.balance ?? 0)"
        dueLabel.text = "\(demand.dueAmount ?? 0)"
        
        payableFeild.text = "\(demand.payable ?? 0)"
        
        let total = currentTotal()
        PayLabel.text = "\(total)"
    }

    @IBAction func checkBoxActionButton(_ sender: UIButton) {
        isChecked.toggle()
        
        let image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        checkBoxButton.setImage(image, for: .normal)
        
        let total = currentTotal()
        amountChanged?(total, isChecked)
    }
    
    @objc func textFieldChanged() {
        
        // ❌ Uncheck checkbox when editing
        isChecked = false
        
        let image = UIImage(systemName: "square")
        checkBoxButton.setImage(image, for: .normal)
        
        updateTotal()
        
        // 🔁 Notify VC that this item is now unchecked
        let total = currentTotal()
        amountChanged?(total, isChecked)
    }
    
    func updateTotal() {
        
        let fine = Double(fineFeild.text ?? "") ?? 0
        let concession = Double(concessionFeild.text ?? "") ?? 0
        var feePayable = Double(payableFeild.text ?? "") ?? 0
        
        // ✅ Rule 1: feePayable + concession <= balance
        let totalWithoutFine = feePayable + concession
        
        if totalWithoutFine > balanceAmount {
            
            // Adjust feePayable automatically
            feePayable = max(0, balanceAmount - concession)
            payableFeild.text = "\(feePayable)"
            
            showToast(message: "Fee + Concession cannot exceed Balance")
        }
        
        // ✅ Rule 2: final payable = feePayable + fine
        let finalTotal = feePayable + fine
        
        PayLabel.text = "\(finalTotal)"
    }
    
    func currentTotal() -> Double {
        let fine = Double(fineFeild.text ?? "") ?? 0
        let feePayable = Double(payableFeild.text ?? "") ?? 0
        
        return fine + feePayable
    }
    
    func showToast(message: String) {
        guard let view = self.contentView.superview else { return }
        
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.backgroundColor = .black
        label.textColor = .white
        label.alpha = 0
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        
        label.frame = CGRect(x: 20, y: -40, width: view.frame.width - 40, height: 35)
        view.addSubview(label)
        
        UIView.animate(withDuration: 0.3, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}
