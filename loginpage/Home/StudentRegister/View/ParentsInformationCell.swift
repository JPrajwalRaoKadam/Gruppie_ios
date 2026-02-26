//    import UIKit
//
//    class ParentsInformationCell: UITableViewCell {
//        
//        // MARK: - IBOutlets
//        @IBOutlet weak var fatherName: UITextField!
//        @IBOutlet weak var motherName: UITextField!
//        @IBOutlet weak var fatherPhone: UITextField!
//        @IBOutlet weak var motherPhone: UITextField!
//        @IBOutlet weak var fatherOccupation: UITextField!
//        @IBOutlet weak var motherOccupation: UITextField!
//        @IBOutlet weak var fatherAadharNo: UITextField!
//        @IBOutlet weak var motherAadharNo: UITextField!
//        @IBOutlet weak var fatherIncome: UITextField!
//        @IBOutlet weak var motherIncome: UITextField!
//        @IBOutlet weak var fatherEducation: UITextField!
//        @IBOutlet weak var motherEducation: UITextField!
//        
//        // MARK: - Emergency Contact Outlets
//        @IBOutlet weak var emergencyContactCheckbox: UIButton!
//        @IBOutlet weak var emergencyContactLabel: UILabel!
//        
//        // MARK: - Variables
//        private var fatherIsEmergencyContact = false
//        private var motherIsEmergencyContact = false
//        weak var delegate: ParentsInformationCellDelegate?
//        
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            setupEmergencyContactUI()
//            setupTextFields()
//        }
//        
//        // MARK: - Setup Methods
//        private func setupEmergencyContactUI() {
//            // Setup checkbox appearance
//            emergencyContactCheckbox.layer.borderWidth = 2
//            emergencyContactCheckbox.layer.borderColor = UIColor.systemBlue.cgColor
//            emergencyContactCheckbox.layer.cornerRadius = 4
//            emergencyContactCheckbox.backgroundColor = .clear
//            emergencyContactCheckbox.setTitle("", for: .normal)
//            emergencyContactCheckbox.tintColor = .clear
//            
//            // Initially unchecked
//            updateEmergencyContactAppearance()
//            emergencyContactLabel.text = "Is Emergency Contact"
//        }
//        
//        private func setupTextFields() {
//            // Add input accessory views for education fields
//            setupEducationPicker(for: fatherEducation)
//            setupEducationPicker(for: motherEducation)
//            
//            // Phone number validation
//            fatherPhone.delegate = self
//            motherPhone.delegate = self
//            
//            // Aadhaar number validation
//            fatherAadharNo.delegate = self
//            motherAadharNo.delegate = self
//        }
//
//        private func setupEducationPicker(for textField: UITextField) {
//            let educationOptions = ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate"]
//            let picker = UIPickerView()
//            picker.delegate = self
//            picker.dataSource = self
//            picker.tag = textField == fatherEducation ? 1 : 2
//            
//            textField.inputView = picker
//            
//            let toolbar = UIToolbar()
//            toolbar.sizeToFit()
//            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//            toolbar.items = [flexibleSpace, doneButton]
//            textField.inputAccessoryView = toolbar
//        }
//        
//        @objc private func doneButtonTapped() {
//            endEditing(true)
//        }
//        
//        // MARK: - Emergency Contact Checkbox Action
//        // MARK: - Emergency Contact Checkbox Action
//        @IBAction func emergencyContactToggled(_ sender: UIButton) {
//            print("Emergency contact button tapped!") // Add this for debugging
//            
//            // Toggle the checkbox state
//            let isCurrentlyChecked = fatherIsEmergencyContact || motherIsEmergencyContact
//            
//            if isCurrentlyChecked {
//                // If already checked, uncheck it
//                fatherIsEmergencyContact = false
//                motherIsEmergencyContact = false
//                updateEmergencyContactUI()
//                notifyDelegate()
//            } else {
//                // If not checked, show dropdown
//                showEmergencyContactSelectionPopup()
//            }
//        }
//        
//        // MARK: - Show Emergency Contact Selection Popup
//        private func showEmergencyContactSelectionPopup() {
//            let alertController = UIAlertController(
//                title: "Select Emergency Contact", message: "",
//                preferredStyle: .actionSheet
//            )
//            
//            // Father only option
//            let fatherOnlyAction = UIAlertAction(
//                title: "Father Only",
//                style: .default
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.fatherIsEmergencyContact = true
//                self.motherIsEmergencyContact = false
//                self.updateEmergencyContactUI()
//                self.notifyDelegate()
//            }
//            
//            // Mother only option
//            let motherOnlyAction = UIAlertAction(
//                title: "Mother Only",
//                style: .default
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.fatherIsEmergencyContact = false
//                self.motherIsEmergencyContact = true
//                self.updateEmergencyContactUI()
//                self.notifyDelegate()
//            }
//            
//            // Both option
//            let bothAction = UIAlertAction(
//                title: "Both Father and Mother",
//                style: .default
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.fatherIsEmergencyContact = true
//                self.motherIsEmergencyContact = true
//                self.updateEmergencyContactUI()
//                self.notifyDelegate()
//            }
//            
//            // Cancel option
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
//                // If canceled, keep checkbox unchecked
//                guard let self = self else { return }
//                self.fatherIsEmergencyContact = false
//                self.motherIsEmergencyContact = false
//                self.updateEmergencyContactUI()
//            }
//            
//            alertController.addAction(fatherOnlyAction)
//            alertController.addAction(motherOnlyAction)
//            alertController.addAction(bothAction)
//            alertController.addAction(cancelAction)
//            
//            // Present the alert from the view controller
//            if let viewController = self.getParentViewController() {
//                // For iPad, set the popover source
//                if let popoverController = alertController.popoverPresentationController {
//                    popoverController.sourceView = emergencyContactCheckbox
//                    popoverController.sourceRect = emergencyContactCheckbox.bounds
//                }
//                
//                viewController.present(alertController, animated: true)
//            }
//        }
//        
//        // MARK: - Update Emergency Contact UI
//        private func updateEmergencyContactUI() {
//            updateEmergencyContactAppearance()
//            updateEmergencyContactLabel()
//        }
//        
//        private func updateEmergencyContactLabel() {
//            if fatherIsEmergencyContact && motherIsEmergencyContact {
//                emergencyContactLabel.text = "Emergency Contact: Both"
//            } else if fatherIsEmergencyContact {
//                emergencyContactLabel.text = "Emergency Contact: Father"
//            } else if motherIsEmergencyContact {
//                emergencyContactLabel.text = "Emergency Contact: Mother"
//            } else {
//                emergencyContactLabel.text = "Is Emergency Contact"
//            }
//        }
//        
//        private func notifyDelegate() {
//            delegate?.didSelectEmergencyContact(
//                fatherIsEmergency: fatherIsEmergencyContact,
//                motherIsEmergency: motherIsEmergencyContact
//            )
//        }
//        
//        // MARK: - Update Checkbox Appearance
//        private func updateEmergencyContactAppearance() {
//            let isAnySelected = fatherIsEmergencyContact || motherIsEmergencyContact
//            
//            UIView.animate(withDuration: 0.2) {
//                if isAnySelected {
//                    let checkmarkImage = UIImage(systemName: "checkmark")?
//                        .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
//                    self.emergencyContactCheckbox.setImage(checkmarkImage, for: .normal)
//                    self.emergencyContactCheckbox.tintColor = .systemBlue
//                    self.emergencyContactCheckbox.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
//                } else {
//                    self.emergencyContactCheckbox.setImage(nil, for: .normal)
//                    self.emergencyContactCheckbox.backgroundColor = .clear
//                }
//            }
//        }
//        
//        // MARK: - Helper to get parent view controller
//        private func getParentViewController() -> UIViewController? {
//            var responder: UIResponder? = self
//            while responder != nil {
//                if let viewController = responder as? UIViewController {
//                    return viewController
//                }
//                responder = responder?.next
//            }
//            return nil
//        }
//        
//        // MARK: - Populate Data
//        func populate(with data: ParentsInfoData?, isEditingEnabled: Bool = true) {
//            guard let data = data else {
//                clearAllFields()
//                return
//            }
//            
//            fatherName.text = data.fatherName
//            motherName.text = data.motherName
//            fatherPhone.text = data.fatherPhone
//            motherPhone.text = data.motherPhone
//            fatherOccupation.text = data.fatherOccupation
//            motherOccupation.text = data.motherOccupation
//            fatherAadharNo.text = data.fatherAadharNo
//            motherAadharNo.text = data.motherAadharNo
//            fatherIncome.text = data.fatherIncome
//            motherIncome.text = data.motherIncome
//            fatherEducation.text = data.fatherEducation
//            motherEducation.text = data.motherEducation
//            
//            // Set emergency contact status
//            fatherIsEmergencyContact = data.fatherIsEmergencyContact
//            motherIsEmergencyContact = data.motherIsEmergencyContact
//            updateEmergencyContactUI()
//            
//            // Enable/disable editing
//            setEditingEnabled(isEditingEnabled)
//        }
//        
//        func clearAllFields() {
//            fatherName.text = ""
//            motherName.text = ""
//            fatherPhone.text = ""
//            motherPhone.text = ""
//            fatherOccupation.text = ""
//            motherOccupation.text = ""
//            fatherAadharNo.text = ""
//            motherAadharNo.text = ""
//            fatherIncome.text = ""
//            motherIncome.text = ""
//            fatherEducation.text = ""
//            motherEducation.text = ""
//            
//            fatherIsEmergencyContact = false
//            motherIsEmergencyContact = false
//            updateEmergencyContactUI()
//        }
//        
//        func setEditingEnabled(_ enabled: Bool) {
//            let textFields = [
//                fatherName, motherName, fatherPhone, motherPhone, fatherOccupation, motherOccupation,
//                fatherAadharNo, motherAadharNo, fatherIncome, motherIncome, fatherEducation, motherEducation
//            ]
//            
//            textFields.forEach {
//                $0?.isUserInteractionEnabled = enabled
//                $0?.backgroundColor = enabled ? .white : .clear
//                $0?.textColor = enabled ? .black : .darkGray
//            }
//            
//            emergencyContactCheckbox.isEnabled = enabled
//            emergencyContactCheckbox.alpha = enabled ? 1.0 : 0.6
//        }
//        
//        // MARK: - Collect Updated Data
//        func collectUpdatedData() -> ParentsInfoData {
//            return ParentsInfoData(
//                fatherName: fatherName.text ?? "",
//                motherName: motherName.text ?? "",
//                fatherPhone: fatherPhone.text ?? "",
//                motherPhone: motherPhone.text ?? "",
//                fatherOccupation: fatherOccupation.text ?? "",
//                motherOccupation: motherOccupation.text ?? "",
//                fatherAadharNo: fatherAadharNo.text ?? "",
//                motherAadharNo: motherAadharNo.text ?? "",
//                fatherIncome: fatherIncome.text ?? "",
//                motherIncome: motherIncome.text ?? "",
//                fatherEducation: fatherEducation.text ?? "",
//                motherEducation: motherEducation.text ?? "",
//                fatherIsEmergencyContact: fatherIsEmergencyContact,
//                motherIsEmergencyContact: motherIsEmergencyContact
//            )
//        }
//        
//        // MARK: - Validation
//        func validateFields() -> (isValid: Bool, errorMessage: String?) {
//            var errors: [String] = []
//            
//            // Check if at least one emergency contact is selected
//            if !fatherIsEmergencyContact && !motherIsEmergencyContact {
//                errors.append("At least one emergency contact must be selected")
//            }
//            
//            // Validate phone numbers if provided
//            if let fatherPhoneText = fatherPhone.text, !fatherPhoneText.isEmpty {
//                if fatherPhoneText.count != 10 {
//                    errors.append("Father's phone number must be 10 digits")
//                }
//            }
//            
//            if let motherPhoneText = motherPhone.text, !motherPhoneText.isEmpty {
//                if motherPhoneText.count != 10 {
//                    errors.append("Mother's phone number must be 10 digits")
//                }
//            }
//            
//            // Validate Aadhaar numbers if provided
//            if let fatherAadhaar = fatherAadharNo.text, !fatherAadhaar.isEmpty {
//                if fatherAadhaar.count != 12 {
//                    errors.append("Father's Aadhaar number must be 12 digits")
//                }
//            }
//            
//            if let motherAadhaar = motherAadharNo.text, !motherAadhaar.isEmpty {
//                if motherAadhaar.count != 12 {
//                    errors.append("Mother's Aadhaar number must be 12 digits")
//                }
//            }
//            
//            if errors.isEmpty {
//                return (true, nil)
//            } else {
//                return (false, errors.joined(separator: "\n"))
//            }
//        }
//    }
//
//    // MARK: - UITextFieldDelegate for Phone & Aadhaar Number Validation
//    extension ParentsInformationCell: UITextFieldDelegate {
//        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            
//            // Phone number validation for father and mother phone
//            if textField == fatherPhone || textField == motherPhone {
//                // Allow only numbers
//                if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
//                    return false
//                }
//                
//                let currentText = textField.text ?? ""
//                let newLength = currentText.count + string.count - range.length
//                
//                return newLength <= 10 // Max 10 digits
//            }
//            
//            // Aadhaar number validation for father and mother aadhaar
//            if textField == fatherAadharNo || textField == motherAadharNo {
//                // Allow only numbers
//                if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
//                    return false
//                }
//                
//                let currentText = textField.text ?? ""
//                let newLength = currentText.count + string.count - range.length
//                
//                return newLength <= 12 // Max 12 digits for Aadhaar
//            }
//            
//            return true
//        }
//    }
//
//    // MARK: - UIPickerViewDelegate & DataSource for Education
//    extension ParentsInformationCell: UIPickerViewDelegate, UIPickerViewDataSource {
//        
//        func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            return educationOptions.count
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            return educationOptions[row]
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            switch pickerView.tag {
//            case 1: // Father education
//                fatherEducation.text = educationOptions[row]
//            case 2: // Mother education
//                motherEducation.text = educationOptions[row]
//            default:
//                break
//            }
//        }
//        
//        private var educationOptions: [String] {
//            return ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate", "Other"]
//        }
//    }
//
import UIKit
class ParentsInformationCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fatherName: UITextField!
    @IBOutlet weak var motherName: UITextField!
    @IBOutlet weak var fatherPhone: UITextField!
    @IBOutlet weak var motherPhone: UITextField!
    @IBOutlet weak var fatherOccupation: UITextField!
    @IBOutlet weak var motherOccupation: UITextField!
    @IBOutlet weak var fatherAadharNo: UITextField!
    @IBOutlet weak var motherAadharNo: UITextField!
    @IBOutlet weak var fatherIncome: UITextField!
    @IBOutlet weak var motherIncome: UITextField!
    @IBOutlet weak var fatherEducation: UITextField!
    @IBOutlet weak var motherEducation: UITextField!
    
    // MARK: - Emergency Contact Outlets
    @IBOutlet weak var emergencyContactCheckbox: UIButton!
    @IBOutlet weak var emergencyContactLabel: UILabel!
    
    // MARK: - Variables
    private var fatherIsEmergencyContact = false
    private var motherIsEmergencyContact = false
    weak var delegate: ParentsInformationCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEmergencyContactUI()
        setupTextFields()
    }
    
    // MARK: - Setup Methods
    private func setupEmergencyContactUI() {
        // Setup checkbox appearance
        emergencyContactCheckbox.layer.borderWidth = 2
        emergencyContactCheckbox.layer.borderColor = UIColor.systemBlue.cgColor
        emergencyContactCheckbox.layer.cornerRadius = 4
        emergencyContactCheckbox.backgroundColor = .clear
        emergencyContactCheckbox.setTitle("", for: .normal)
        emergencyContactCheckbox.tintColor = .clear
        
        // Initially unchecked
        updateEmergencyContactAppearance()
        emergencyContactLabel.text = "Is Emergency Contact"
    }
    
    private func setupTextFields() {
        // Add input accessory views for education fields
        setupEducationPicker(for: fatherEducation)
        setupEducationPicker(for: motherEducation)
        
        // Phone number validation
        fatherPhone.delegate = self
        motherPhone.delegate = self
        
        // Aadhaar number validation
        fatherAadharNo.delegate = self
        motherAadharNo.delegate = self
        
        // Income validation
        fatherIncome.delegate = self
        motherIncome.delegate = self
        
        // Add targets for real-time updates
        let textFields = [fatherName, motherName, fatherPhone, motherPhone,
                         fatherOccupation, motherOccupation, fatherAadharNo, motherAadharNo,
                         fatherIncome, motherIncome, fatherEducation, motherEducation]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupEducationPicker(for textField: UITextField) {
        let educationOptions = ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate"]
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = textField == fatherEducation ? 1 : 2
        
        textField.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        endEditing(true)
        notifyFullDataUpdate() // Notify when education picker is done
    }
    
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        notifyFullDataUpdate()
    }
    
    // MARK: - Emergency Contact Checkbox Action
    @IBAction func emergencyContactToggled(_ sender: UIButton) {
        print("Emergency contact button tapped!")
        
        // Toggle the checkbox state
        let isCurrentlyChecked = fatherIsEmergencyContact || motherIsEmergencyContact
        
        if isCurrentlyChecked {
            // If already checked, uncheck it
            fatherIsEmergencyContact = false
            motherIsEmergencyContact = false
            updateEmergencyContactUI()
            notifyEmergencyContactUpdate()
            notifyFullDataUpdate()
        } else {
            // If not checked, show dropdown
            showEmergencyContactSelectionPopup()
        }
    }
    
    // MARK: - Show Emergency Contact Selection Popup
    private func showEmergencyContactSelectionPopup() {
        let alertController = UIAlertController(
            title: "Select Emergency Contact", message: "",
            preferredStyle: .actionSheet
        )
        
        // Father only option
        let fatherOnlyAction = UIAlertAction(
            title: "Father Only",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.fatherIsEmergencyContact = true
            self.motherIsEmergencyContact = false
            self.updateEmergencyContactUI()
            self.notifyEmergencyContactUpdate()
            self.notifyFullDataUpdate()
        }
        
        // Mother only option
        let motherOnlyAction = UIAlertAction(
            title: "Mother Only",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.fatherIsEmergencyContact = false
            self.motherIsEmergencyContact = true
            self.updateEmergencyContactUI()
            self.notifyEmergencyContactUpdate()
            self.notifyFullDataUpdate()
        }
        
        // Both option
        let bothAction = UIAlertAction(
            title: "Both Father and Mother",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.fatherIsEmergencyContact = true
            self.motherIsEmergencyContact = true
            self.updateEmergencyContactUI()
            self.notifyEmergencyContactUpdate()
            self.notifyFullDataUpdate()
        }
        
        // Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // If canceled, keep checkbox unchecked
            guard let self = self else { return }
            self.fatherIsEmergencyContact = false
            self.motherIsEmergencyContact = false
            self.updateEmergencyContactUI()
        }
        
        alertController.addAction(fatherOnlyAction)
        alertController.addAction(motherOnlyAction)
        alertController.addAction(bothAction)
        alertController.addAction(cancelAction)
        
        // Present the alert from the view controller
        if let viewController = self.getParentViewController() {
            // For iPad, set the popover source
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = emergencyContactCheckbox
                popoverController.sourceRect = emergencyContactCheckbox.bounds
            }
            
            viewController.present(alertController, animated: true)
        }
    }
    
    // MARK: - Update Emergency Contact UI
    private func updateEmergencyContactUI() {
        updateEmergencyContactAppearance()
        updateEmergencyContactLabel()
    }
    
    private func updateEmergencyContactLabel() {
        if fatherIsEmergencyContact && motherIsEmergencyContact {
            emergencyContactLabel.text = "Emergency Contact: Both"
        } else if fatherIsEmergencyContact {
            emergencyContactLabel.text = "Emergency Contact: Father"
        } else if motherIsEmergencyContact {
            emergencyContactLabel.text = "Emergency Contact: Mother"
        } else {
            emergencyContactLabel.text = "Is Emergency Contact"
        }
    }
    
    // MARK: - Notify Delegates
    private func notifyEmergencyContactUpdate() {
        delegate?.didSelectEmergencyContact(
            fatherIsEmergency: fatherIsEmergencyContact,
            motherIsEmergency: motherIsEmergencyContact
        )
    }
    
    private func notifyFullDataUpdate() {
        let data = ParentsInfoData(
            fatherName: fatherName.text ?? "",
            fatherAadhaarNumber: fatherAadharNo.text ?? "",
            fatherOccupation: fatherOccupation.text ?? "",
            fatherAnnualIncome: fatherIncome.text ?? "",
            fatherIsEmergencyContact: fatherIsEmergencyContact,
            fatherEducation: fatherEducation.text ?? "",
            motherName: motherName.text ?? "",
            motherAadhaarNumber: motherAadharNo.text ?? "",
            motherOccupation: motherOccupation.text ?? "",
            motherAnnualIncome: motherIncome.text ?? "",
            motherIsEmergencyContact: motherIsEmergencyContact,
            motherEducation: motherEducation.text ?? ""
        )
        delegate?.parentsInfoDidUpdate(data)
    }
    
    // MARK: - Update Checkbox Appearance
    private func updateEmergencyContactAppearance() {
        let isAnySelected = fatherIsEmergencyContact || motherIsEmergencyContact
        
        UIView.animate(withDuration: 0.2) {
            if isAnySelected {
                let checkmarkImage = UIImage(systemName: "checkmark")?
                    .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
                self.emergencyContactCheckbox.setImage(checkmarkImage, for: .normal)
                self.emergencyContactCheckbox.tintColor = .systemBlue
                self.emergencyContactCheckbox.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            } else {
                self.emergencyContactCheckbox.setImage(nil, for: .normal)
                self.emergencyContactCheckbox.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - Helper to get parent view controller
    private func getParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
    
    // MARK: - Populate Data
    func populate(with data: ParentsInfoData?, isEditingEnabled: Bool = true) {
        guard let data = data else {
            clearAllFields()
            return
        }
        
        fatherName.text = data.fatherName
        motherName.text = data.motherName
        fatherPhone.text = "" // Note: API doesn't have these fields in ParentsInfoData
        motherPhone.text = "" // Note: API doesn't have these fields in ParentsInfoData
        fatherOccupation.text = data.fatherOccupation
        motherOccupation.text = data.motherOccupation
        fatherAadharNo.text = data.fatherAadhaarNumber
        motherAadharNo.text = data.motherAadhaarNumber
        fatherIncome.text = data.fatherAnnualIncome
        motherIncome.text = data.motherAnnualIncome
        fatherEducation.text = data.fatherEducation
        motherEducation.text = data.motherEducation
        
        // Set emergency contact status
        fatherIsEmergencyContact = data.fatherIsEmergencyContact
        motherIsEmergencyContact = data.motherIsEmergencyContact
        updateEmergencyContactUI()
        
        // Enable/disable editing
        setEditingEnabled(isEditingEnabled)
        
        // Notify delegate after populating
        notifyFullDataUpdate()
    }
    
    func clearAllFields() {
        fatherName.text = ""
        motherName.text = ""
        fatherPhone.text = ""
        motherPhone.text = ""
        fatherOccupation.text = ""
        motherOccupation.text = ""
        fatherAadharNo.text = ""
        motherAadharNo.text = ""
        fatherIncome.text = ""
        motherIncome.text = ""
        fatherEducation.text = ""
        motherEducation.text = ""
        
        fatherIsEmergencyContact = false
        motherIsEmergencyContact = false
        updateEmergencyContactUI()
        
        notifyFullDataUpdate()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        let textFields = [
            fatherName, motherName, fatherPhone, motherPhone, fatherOccupation, motherOccupation,
            fatherAadharNo, motherAadharNo, fatherIncome, motherIncome, fatherEducation, motherEducation
        ]
        
        textFields.forEach {
            $0?.isUserInteractionEnabled = enabled
            $0?.backgroundColor = enabled ? .white : .clear
            $0?.textColor = enabled ? .black : .darkGray
        }
        
        emergencyContactCheckbox.isEnabled = enabled
        emergencyContactCheckbox.alpha = enabled ? 1.0 : 0.6
    }
    
    // MARK: - Collect Updated Data
    func collectUpdatedData() -> ParentsInfoData {
        return ParentsInfoData(
            fatherName: fatherName.text ?? "",
            fatherAadhaarNumber: fatherAadharNo.text ?? "",
            fatherOccupation: fatherOccupation.text ?? "",
            fatherAnnualIncome: fatherIncome.text ?? "",
            fatherIsEmergencyContact: fatherIsEmergencyContact,
            fatherEducation: fatherEducation.text ?? "",
            motherName: motherName.text ?? "",
            motherAadhaarNumber: motherAadharNo.text ?? "",
            motherOccupation: motherOccupation.text ?? "",
            motherAnnualIncome: motherIncome.text ?? "",
            motherIsEmergencyContact: motherIsEmergencyContact,
            motherEducation: motherEducation.text ?? ""
        )
    }
    
    // MARK: - Validation
    func validateFields() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // Check if at least one emergency contact is selected
        if !fatherIsEmergencyContact && !motherIsEmergencyContact {
            errors.append("At least one emergency contact must be selected")
        }
        
        // Validate father's Aadhaar number if provided
        if let fatherAadhaar = fatherAadharNo.text, !fatherAadhaar.isEmpty {
            if fatherAadhaar.count != 12 {
                errors.append("Father's Aadhaar number must be 12 digits")
            }
        }
        
        // Validate mother's Aadhaar number if provided
        if let motherAadhaar = motherAadharNo.text, !motherAadhaar.isEmpty {
            if motherAadhaar.count != 12 {
                errors.append("Mother's Aadhaar number must be 12 digits")
            }
        }
        
        // Validate income fields if provided
        if let fatherIncomeText = fatherIncome.text, !fatherIncomeText.isEmpty {
            if !isValidNumber(fatherIncomeText) {
                errors.append("Father's income must be a valid number")
            }
        }
        
        if let motherIncomeText = motherIncome.text, !motherIncomeText.isEmpty {
            if !isValidNumber(motherIncomeText) {
                errors.append("Mother's income must be a valid number")
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors.joined(separator: "\n"))
        }
    }
    
    private func isValidNumber(_ text: String) -> Bool {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.number(from: text) != nil
    }
}

// MARK: - UITextFieldDelegate for Phone, Aadhaar & Income Validation
extension ParentsInformationCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Phone number validation for father and mother phone
        if textField == fatherPhone || textField == motherPhone {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return newLength <= 10 // Max 10 digits
        }
        
        // Aadhaar number validation for father and mother aadhaar
        if textField == fatherAadharNo || textField == motherAadharNo {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return newLength <= 12 // Max 12 digits for Aadhaar
        }
        
        // Income validation - allow numbers and decimal point
        if textField == fatherIncome || textField == motherIncome {
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            
            // Check for multiple decimal points
            if string == "." {
                let currentText = textField.text ?? ""
                if currentText.contains(".") {
                    return false
                }
            }
            
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        notifyFullDataUpdate()
    }
}

// MARK: - UIPickerViewDelegate & DataSource for Education
extension ParentsInformationCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return educationOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return educationOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // Father education
            fatherEducation.text = educationOptions[row]
            notifyFullDataUpdate()
        case 2: // Mother education
            motherEducation.text = educationOptions[row]
            notifyFullDataUpdate()
        default:
            break
        }
    }
    
    private var educationOptions: [String] {
        return ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate", "Other"]
    }
}
