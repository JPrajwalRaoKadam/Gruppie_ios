//import UIKit
//
//class AddressInformationCell: UITableViewCell {
//    
//    @IBOutlet weak var corAddress: UIStackView!
//    @IBOutlet weak var corAddressHeight: NSLayoutConstraint!
//    @IBOutlet weak var correspondenceAddressCheckbox: UIButton!
//    
//    private var isChecked = false
//    private var originalHeight: CGFloat = 0
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        print("✅ Cell loaded")
//        
//        originalHeight = corAddressHeight.constant
//        
//        // Make sure button works
//        correspondenceAddressCheckbox.addTarget(self,
//            action: #selector(checkboxTapped),
//            for: .touchUpInside)
//        
//        // Initial state
//        updateUI()
//    }
//    
//    @objc func checkboxTapped() {
//        print("🔘 Checkbox tapped!")
//        isChecked.toggle()
//        updateUI()
//    }
//    
//    func updateUI() {
//        // Checkbox appearance
//        if isChecked {
//            let checkmarkImage = UIImage(systemName: "checkmark")?
//                .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
//            correspondenceAddressCheckbox.setImage(checkmarkImage, for: .normal)
//            correspondenceAddressCheckbox.tintColor = .white
//        } else {
//            correspondenceAddressCheckbox.setImage(nil, for: .normal)
//        }
//        
//        // Show/hide correspondence address
//        UIView.animate(withDuration: 0.3) {
//            self.corAddress.isHidden = self.isChecked
//            self.corAddressHeight.constant = self.isChecked ? 0 : self.originalHeight
//            self.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func correspondenceAddressToggled(_ sender: UIButton) {
//        print("📞 IBAction called!")
//        checkboxTapped()
//    }
//}

import UIKit

class AddressInformationCell: UITableViewCell {
    
    // MARK: - Permanent Address Outlets
    @IBOutlet weak var permanentPinCode: UITextField!
    @IBOutlet weak var permanentState: UITextField!
    @IBOutlet weak var permanentDistrict: UITextField!
    @IBOutlet weak var permanentArea: UITextField!
    @IBOutlet weak var permanentTaluk: UITextField!
    
    // MARK: - Correspondence Address Outlets
    @IBOutlet weak var correspondencePinCode: UITextField!
    @IBOutlet weak var correspondenceState: UITextField!
    @IBOutlet weak var correspondenceDistrict: UITextField!
    @IBOutlet weak var correspondenceArea: UITextField!
    @IBOutlet weak var correspondenceTaluk: UITextField!
    
    // MARK: - Checkbox and Container
    @IBOutlet weak var corAddress: UIStackView!
    @IBOutlet weak var corAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var correspondenceAddressCheckbox: UIButton!
    
    // MARK: - Variables
    private var isChecked = false
    private var originalHeight: CGFloat = 0
    weak var delegate: AddressInfoCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        originalHeight = corAddressHeight.constant
        
        // Setup checkbox
        correspondenceAddressCheckbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        
        // Setup text fields
        setupTextFields()
        
        // Initial state
        updateUI()
    }
    
    // MARK: - Setup Methods
    private func setupTextFields() {
        // Add targets for real-time updates
        let permanentFields = [permanentPinCode, permanentState, permanentDistrict, permanentArea, permanentTaluk]
        let correspondenceFields = [correspondencePinCode, correspondenceState, correspondenceDistrict, correspondenceArea, correspondenceTaluk]
        
        permanentFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        correspondenceFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        // Setup pin code validation
        permanentPinCode.delegate = self
        correspondencePinCode.delegate = self
    }
    
    // MARK: - Helper Methods
    private func getPermanentValues() -> (pinCode: String, state: String, district: String, area: String, taluk: String) {
        return (
            permanentPinCode.text ?? "",
            permanentState.text ?? "",
            permanentDistrict.text ?? "",
            permanentArea.text ?? "",
            permanentTaluk.text ?? ""
        )
    }
    
    private func getCorrespondenceValues() -> (pinCode: String, state: String, district: String, area: String, taluk: String) {
        if isChecked {
            return ("", "", "", "", "")
        } else {
            return (
                correspondencePinCode.text ?? "",
                correspondenceState.text ?? "",
                correspondenceDistrict.text ?? "",
                correspondenceArea.text ?? "",
                correspondenceTaluk.text ?? ""
            )
        }
    }
    
    // MARK: - Checkbox Actions
    @objc func checkboxTapped() {
        isChecked.toggle()
        updateUI()
        notifyDelegate()
    }
    
    @IBAction func correspondenceAddressToggled(_ sender: UIButton) {
        checkboxTapped()
    }
    
    func updateUI() {
        // Checkbox appearance
        if isChecked {
            let checkmarkImage = UIImage(systemName: "checkmark")?
                .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
            correspondenceAddressCheckbox.setImage(checkmarkImage, for: .normal)
            correspondenceAddressCheckbox.tintColor = .systemBlue
            correspondenceAddressCheckbox.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } else {
            correspondenceAddressCheckbox.setImage(nil, for: .normal)
            correspondenceAddressCheckbox.backgroundColor = .clear
        }
        
        // Show/hide correspondence address
        UIView.animate(withDuration: 0.3) {
            self.corAddress.isHidden = self.isChecked
            self.corAddressHeight.constant = self.isChecked ? 0 : self.originalHeight
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        notifyDelegate()
    }
    
    // MARK: - Notify Delegate
    private func notifyDelegate() {
        let permanent = getPermanentValues()
        let correspondence = getCorrespondenceValues()
        
        let data = AddressInfoData(
            permanentPinCode: permanent.pinCode,
            permanentState: permanent.state,
            permanentDistrict: permanent.district,
            permanentArea: permanent.area,
            permanentTaluk: permanent.taluk,
            correspondencePinCode: correspondence.pinCode,
            correspondenceState: correspondence.state,
            correspondenceDistrict: correspondence.district,
            correspondenceArea: correspondence.area,
            correspondenceTaluk: correspondence.taluk,
            useSameAsPermanent: isChecked
        )
        delegate?.addressInfoDidUpdate(data)
    }
    
    // MARK: - Populate with Data
    func populate(with data: AddressInfoData?) {
        guard let data = data else {
            clearFields()
            return
        }
        
        // Permanent Address
        permanentPinCode.text = data.permanentPinCode
        permanentState.text = data.permanentState
        permanentDistrict.text = data.permanentDistrict
        permanentArea.text = data.permanentArea
        permanentTaluk.text = data.permanentTaluk
        
        // Correspondence Address
        correspondencePinCode.text = data.correspondencePinCode
        correspondenceState.text = data.correspondenceState
        correspondenceDistrict.text = data.correspondenceDistrict
        correspondenceArea.text = data.correspondenceArea
        correspondenceTaluk.text = data.correspondenceTaluk
        
        // Checkbox state
        isChecked = data.useSameAsPermanent
        updateUI()
    }
    
    private func clearFields() {
        permanentPinCode.text = ""
        permanentState.text = ""
        permanentDistrict.text = ""
        permanentArea.text = ""
        permanentTaluk.text = ""
        
        correspondencePinCode.text = ""
        correspondenceState.text = ""
        correspondenceDistrict.text = ""
        correspondenceArea.text = ""
        correspondenceTaluk.text = ""
        
        isChecked = false
        updateUI()
    }
    
    // MARK: - Collect Data
    func collectAddressData() -> AddressInfoData {
        let permanent = getPermanentValues()
        let correspondence = getCorrespondenceValues()
        
        return AddressInfoData(
            permanentPinCode: permanent.pinCode,
            permanentState: permanent.state,
            permanentDistrict: permanent.district,
            permanentArea: permanent.area,
            permanentTaluk: permanent.taluk,
            correspondencePinCode: correspondence.pinCode,
            correspondenceState: correspondence.state,
            correspondenceDistrict: correspondence.district,
            correspondenceArea: correspondence.area,
            correspondenceTaluk: correspondence.taluk,
            useSameAsPermanent: isChecked
        )
    }
    
    // MARK: - Validation
    func validateFields() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // Permanent address validation
        let permanentPinCodeText = permanentPinCode.text ?? ""
        if permanentPinCodeText.isEmpty {
            errors.append("Permanent PIN code is required")
        } else if permanentPinCodeText.count != 6 {
            errors.append("Permanent PIN code must be 6 digits")
        }
        
        if permanentState.text?.isEmpty ?? true {
            errors.append("Permanent state is required")
        }
        
        if permanentDistrict.text?.isEmpty ?? true {
            errors.append("Permanent district is required")
        }
        
        if permanentArea.text?.isEmpty ?? true {
            errors.append("Permanent area is required")
        }
        
        // Correspondence address validation (if not same as permanent)
        if !isChecked {
            let correspondencePinCodeText = correspondencePinCode.text ?? ""
            if correspondencePinCodeText.isEmpty {
                errors.append("Correspondence PIN code is required")
            } else if correspondencePinCodeText.count != 6 {
                errors.append("Correspondence PIN code must be 6 digits")
            }
            
            if correspondenceState.text?.isEmpty ?? true {
                errors.append("Correspondence state is required")
            }
            
            if correspondenceDistrict.text?.isEmpty ?? true {
                errors.append("Correspondence district is required")
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors.joined(separator: "\n"))
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddressInformationCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // PIN code validation - only numbers, max 6 digits
        if textField == permanentPinCode || textField == correspondencePinCode {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return newLength <= 6 // Max 6 digits for PIN code
        }
        
        return true
    }
}
