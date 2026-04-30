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
    
    var indexPath: IndexPath?
    var amountChanged: ((IndexPath, Double, Double, Bool) -> Void)?
    
    private var isChecked: Bool = false
    private var balanceAmount: Double = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        fineFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        concessionFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        payableFeild.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fineFeild.text = ""
        concessionFeild.text = ""
        payableFeild.text = ""
        PayLabel.text = "0"
        isChecked = false
        updateCheckboxUI()
    }

    func configureCell(isChecked: Bool, demand: PaymentDemand, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        self.isChecked = isChecked
        
        balanceAmount = demand.balance ?? 0
        
        feeType.text = demand.feeType
        totalLabel.text = "\(demand.total ?? 0)"
        paidLabel.text = "\(demand.paid ?? 0)"
        balanceLabel.text = "\(demand.balance ?? 0)"
        dueLabel.text = "\(demand.dueAmount ?? 0)"
        
        // ✅ Default payable
        payableFeild.text = "\(demand.payable ?? demand.balance ?? 0)"
        
        updateCheckboxUI()
        updateTotal()
    }

    // MARK: - Checkbox
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        
        isChecked.toggle()
        updateCheckboxUI()
        
        // ✅ If checked and empty → fill full balance
        if isChecked && (payableFeild.text ?? "").isEmpty {
            payableFeild.text = "\(balanceAmount)"
        }
        
        updateTotal()
        notifyAmountChange()
    }
    
    private func updateCheckboxUI() {
        let image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        checkBoxButton.setImage(image, for: .normal)
    }

    // MARK: - Text Change
    @objc func textFieldChanged() {
        
        // ✅ FIX: typing means user wants to include this row
        isChecked = true
        updateCheckboxUI()
        
        updateTotal()
        notifyAmountChange()
    }

    // MARK: - Calculation
    private func updateTotal() {
        
        let fine = Double(fineFeild.text ?? "") ?? 0
        let concession = Double(concessionFeild.text ?? "") ?? 0
        var feePayable = Double(payableFeild.text ?? "") ?? 0
        
        // ✅ Validation
        if (feePayable + concession) > balanceAmount {
            
            feePayable = max(0, balanceAmount - concession)
            payableFeild.text = "\(feePayable)"
            
            showToast(message: "Fee + Concession cannot exceed Balance")
        }
        
        let finalTotal = feePayable + fine
        PayLabel.text = "\(finalTotal)"
    }

    private func notifyAmountChange() {
        guard let indexPath = indexPath else { return }
        
        let fine = Double(fineFeild.text ?? "") ?? 0
        let total = currentTotal()
        
        amountChanged?(indexPath, total, fine, isChecked)
    }

    private func currentTotal() -> Double {
        let fine = Double(fineFeild.text ?? "") ?? 0
        let feePayable = Double(payableFeild.text ?? "") ?? 0
        return fine + feePayable
    }

    // MARK: - Toast
    private func showToast(message: String) {
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
