////
////  GuardianInformationCell.swift
////  loginpage
////
////  Created by apple on 20/01/26.
////
//
//import UIKit
//
//class GuardianInformationCell: UITableViewCell {
//    
//    // MARK: - IBOutlets
//    @IBOutlet weak var relationLabel: UITextField!
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var phoneTextField: UITextField!
//    @IBOutlet weak var aadharTextField: UITextField!
//    @IBOutlet weak var occupationTextField: UITextField!
//    @IBOutlet weak var incomeTextField: UITextField!
//    @IBOutlet weak var educationTextField: UITextField!
//    
//    // MARK: - Variables
//    private var pickerView = UIPickerView()
//    private let educationOptions = ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate", "Other"]
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupEducationPicker()
//        setupTextFields()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupEducationPicker() {
//        // Configure picker view
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        
//        // Set picker as input view for education text field
//        educationTextField.inputView = pickerView
//        
//        // Create toolbar with done button
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
//        
//        toolbar.items = [cancelButton, flexibleSpace, doneButton]
//        educationTextField.inputAccessoryView = toolbar
//    }
//    
//    private func setupTextFields() {
//        // Set delegates for validation
//        phoneTextField.delegate = self
//        aadharTextField.delegate = self
//        incomeTextField.delegate = self
//        
//        // Set keyboard types
//        phoneTextField.keyboardType = .phonePad
//        aadharTextField.keyboardType = .numberPad
//        incomeTextField.keyboardType = .decimalPad
//        
//        // Add tap gesture to education text field to show picker
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(educationFieldTapped))
//        educationTextField.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc private func educationFieldTapped() {
//        educationTextField.becomeFirstResponder()
//    }
//    
//    @objc private func doneButtonTapped() {
//        // Select the current picker row when done is tapped
//        let selectedRow = pickerView.selectedRow(inComponent: 0)
//        educationTextField.text = educationOptions[selectedRow]
//        educationTextField.resignFirstResponder()
//    }
//    
//    @objc private func cancelButtonTapped() {
//        educationTextField.resignFirstResponder()
//    }
//    
//    // MARK: - Populate Data
//    func populate(with guardian: GuardianInfoData?) {
//        guard let guardian = guardian else {
//            clearFields()
//            return
//        }
//        
//        relationLabel.text = guardian.relation
//        nameTextField.text = guardian.name
//        phoneTextField.text = guardian.phone
//        aadharTextField.text = guardian.aadharNo
//        occupationTextField.text = guardian.occupation
//        incomeTextField.text = guardian.annualIncome
//        educationTextField.text = guardian.education
//    }
//    
//    func clearFields() {
//        nameTextField.text = ""
//        phoneTextField.text = ""
//        aadharTextField.text = ""
//        occupationTextField.text = ""
//        incomeTextField.text = ""
//        educationTextField.text = ""
//    }
//    
//    // MARK: - Collect Data
//    func collectGuardianData() -> GuardianInfoData {
//        return GuardianInfoData(
//            relation: relationLabel.text ?? "",
//            name: nameTextField.text ?? "",
//            phone: phoneTextField.text ?? "",
//            aadharNo: aadharTextField.text ?? "",
//            occupation: occupationTextField.text ?? "",
//            annualIncome: incomeTextField.text ?? "",
//            education: educationTextField.text ?? ""
//        )
//    }
//    
//    // MARK: - Validation
//    func validate() -> (isValid: Bool, errorMessage: String?) {
//        var errors: [String] = []
//        
//        // Name validation
//        if let name = nameTextField.text, name.isEmpty {
//            errors.append("Name is required")
//        }
//        
//        // Phone validation (if provided)
//        if let phone = phoneTextField.text, !phone.isEmpty, phone.count != 10 {
//            errors.append("Phone number must be 10 digits")
//        }
//        
//        // Aadhar validation (if provided)
//        if let aadhar = aadharTextField.text, !aadhar.isEmpty, aadhar.count != 12 {
//            errors.append("Aadhar number must be 12 digits")
//        }
//        
//        if errors.isEmpty {
//            return (true, nil)
//        } else {
//            return (false, errors.joined(separator: "\n"))
//        }
//    }
//}
//
//// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
//extension GuardianInformationCell: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return educationOptions.count
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return educationOptions[row]
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // Update text field immediately as user scrolls
//        educationTextField.text = educationOptions[row]
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 44.0
//    }
//}
//
//// MARK: - UITextFieldDelegate for Validation
//extension GuardianInformationCell: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        // Phone number validation
//        if textField == phoneTextField {
//            // Allow only numbers
//            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
//                return false
//            }
//            
//            let currentText = textField.text ?? ""
//            let newLength = currentText.count + string.count - range.length
//            return newLength <= 10
//        }
//        
//        // Aadhar number validation
//        if textField == aadharTextField {
//            // Allow only numbers
//            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
//                return false
//            }
//            
//            let currentText = textField.text ?? ""
//            let newLength = currentText.count + string.count - range.length
//            return newLength <= 12
//        }
//        
//        // Income validation - allow numbers and decimal point
//        if textField == incomeTextField {
//            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
//            let characterSet = CharacterSet(charactersIn: string)
//            
//            // Check for multiple decimal points
//            if string == "." {
//                let currentText = textField.text ?? ""
//                if currentText.contains(".") {
//                    return false
//                }
//            }
//            
//            return allowedCharacters.isSuperset(of: characterSet)
//        }
//        
//        return true
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
//        case nameTextField:
//            phoneTextField.becomeFirstResponder()
//        case phoneTextField:
//            aadharTextField.becomeFirstResponder()
//        case aadharTextField:
//            occupationTextField.becomeFirstResponder()
//        case occupationTextField:
//            incomeTextField.becomeFirstResponder()
//        case incomeTextField:
//            educationTextField.becomeFirstResponder()
//        default:
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//}
//
//// MARK: - Guardian Info Data Model
//struct GuardianInfoData {
//    let relation: String
//    let name: String
//    let phone: String
//    let aadharNo: String
//    let occupation: String
//    let annualIncome: String
//    let education: String
//    
//    init(relation: String = "", name: String = "", phone: String = "", aadharNo: String = "",
//         occupation: String = "", annualIncome: String = "", education: String = "") {
//        self.relation = relation
//        self.name = name
//        self.phone = phone
//        self.aadharNo = aadharNo
//        self.occupation = occupation
//        self.annualIncome = annualIncome
//        self.education = education
//    }
//}
import UIKit

class GuardianInformationCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var relationLabel: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var aadharTextField: UITextField!
    @IBOutlet weak var occupationTextField: UITextField!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var educationTextField: UITextField!
    // MARK: - Emergency Contact Checkbox Outlets
    @IBOutlet weak var emergencyContactCheckbox: UIButton!
    @IBOutlet weak var emergencyContactLabel: UILabel!
    
    // MARK: - Variables
    private var pickerView = UIPickerView()
    private let educationOptions = ["Below 10th", "10th", "12th", "Diploma", "Graduate", "Post Graduate", "Doctorate", "Other"]
    
    // FIX: Start with true (checked) by default to match API requirement
    private var isEmergencyContact = true
    
    // MARK: - Delegate
    weak var delegate: GuardianInfoCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEducationPicker()
        setupTextFields()
        setupEmergencyContactUI()
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
        
        // Initially checked (true by default)
        updateEmergencyContactAppearance()
        emergencyContactLabel.text = "Is Emergency Contact"
    }
    
    private func setupEducationPicker() {
        // Configure picker view
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Set picker as input view for education text field
        educationTextField.inputView = pickerView
        
        // Create toolbar with done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        toolbar.items = [cancelButton, flexibleSpace, doneButton]
        educationTextField.inputAccessoryView = toolbar
    }
    
    private func setupTextFields() {
        // Set delegates for validation
        phoneTextField.delegate = self
        aadharTextField.delegate = self
        incomeTextField.delegate = self
        relationLabel.delegate = self
        nameTextField.delegate = self
        occupationTextField.delegate = self
        educationTextField.delegate = self
        
        // Set keyboard types
        phoneTextField.keyboardType = .phonePad
        aadharTextField.keyboardType = .numberPad
        incomeTextField.keyboardType = .decimalPad
        
        // Add targets for real-time updates
        let textFields = [relationLabel, nameTextField, phoneTextField, aadharTextField,
                         occupationTextField, incomeTextField, educationTextField]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    // MARK: - Emergency Contact Checkbox Action
    @IBAction func emergencyContactToggled(_ sender: UIButton) {
        // Toggle the value when user taps
        isEmergencyContact.toggle()
        updateEmergencyContactAppearance()
        notifyDelegate()
        
        // Print for debugging
        print("📞 Guardian emergency contact toggled: \(isEmergencyContact)")
    }
    
    private func updateEmergencyContactAppearance() {
        UIView.animate(withDuration: 0.2) {
            if self.isEmergencyContact {
                // When checked: Show checkmark with blue color
                let checkmarkImage = UIImage(systemName: "checkmark")?
                    .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
                self.emergencyContactCheckbox.setImage(checkmarkImage, for: .normal)
                self.emergencyContactCheckbox.tintColor = .systemBlue
                self.emergencyContactCheckbox.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                self.emergencyContactLabel.text = "Emergency Contact: Yes"
            } else {
                // When unchecked: Hide checkmark
                self.emergencyContactCheckbox.setImage(nil, for: .normal)
                self.emergencyContactCheckbox.backgroundColor = .clear
                self.emergencyContactLabel.text = "Emergency Contact: No"
            }
        }
    }
    
    @objc private func educationFieldTapped() {
        educationTextField.becomeFirstResponder()
    }
    
    @objc private func doneButtonTapped() {
        // Select the current picker row when done is tapped
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        educationTextField.text = educationOptions[selectedRow]
        educationTextField.resignFirstResponder()
        notifyDelegate()
    }
    
    @objc private func cancelButtonTapped() {
        educationTextField.resignFirstResponder()
    }
    
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        notifyDelegate()
    }
    
    // MARK: - Notify Delegate
    private func notifyDelegate() {
        let data = GuardianInfoData(
            guardianRelation: relationLabel.text ?? "",
            guardianName: nameTextField.text ?? "",
            guardianPhoneNumber: phoneTextField.text ?? "",
            guardianAadhaarNumber: aadharTextField.text ?? "",
            guardianOccupation: occupationTextField.text ?? "",
            guardianAnnualIncome: incomeTextField.text ?? "",
            guardianIsEmergencyContact: isEmergencyContact,
            guardianEducation: educationTextField.text ?? ""
        )
        delegate?.guardianInfoDidUpdate(data)
    }
    
    // MARK: - Populate Data
    func populate(with guardian: GuardianInfoData?) {
        guard let guardian = guardian else {
            clearFields()
            return
        }
        
        relationLabel.text = guardian.guardianRelation
        nameTextField.text = guardian.guardianName
        phoneTextField.text = guardian.guardianPhoneNumber
        aadharTextField.text = guardian.guardianAadhaarNumber
        occupationTextField.text = guardian.guardianOccupation
        incomeTextField.text = guardian.guardianAnnualIncome
        educationTextField.text = guardian.guardianEducation
        
        // Set emergency contact status from the data
        isEmergencyContact = guardian.guardianIsEmergencyContact
        updateEmergencyContactAppearance()
        
        notifyDelegate()
    }
    
    func clearFields() {
        relationLabel.text = ""
        nameTextField.text = ""
        phoneTextField.text = ""
        aadharTextField.text = ""
        occupationTextField.text = ""
        incomeTextField.text = ""
        educationTextField.text = ""
        
        // Reset to default true when clearing
        isEmergencyContact = true
        updateEmergencyContactAppearance()
        
        notifyDelegate()
    }
    
    // MARK: - Collect Data
    func collectGuardianData() -> GuardianInfoData {
        return GuardianInfoData(
            guardianRelation: relationLabel.text ?? "",
            guardianName: nameTextField.text ?? "",
            guardianPhoneNumber: phoneTextField.text ?? "",
            guardianAadhaarNumber: aadharTextField.text ?? "",
            guardianOccupation: occupationTextField.text ?? "",
            guardianAnnualIncome: incomeTextField.text ?? "",
            guardianIsEmergencyContact: isEmergencyContact,
            guardianEducation: educationTextField.text ?? ""
        )
    }
    
    // MARK: - Validation
    func validate() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // Name validation
        if let name = nameTextField.text, name.isEmpty {
            errors.append("Guardian name is required")
        }
        
        // Phone validation (if provided)
        if let phone = phoneTextField.text, !phone.isEmpty, phone.count != 10 {
            errors.append("Guardian phone number must be 10 digits")
        }
        
        // Aadhaar validation (if provided)
        if let aadhar = aadharTextField.text, !aadhar.isEmpty, aadhar.count != 12 {
            errors.append("Guardian Aadhaar number must be 12 digits")
        }
        
        // Income validation (if provided)
        if let income = incomeTextField.text, !income.isEmpty {
            if !isValidNumber(income) {
                errors.append("Guardian annual income must be a valid number")
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

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension GuardianInformationCell: UIPickerViewDelegate, UIPickerViewDataSource {
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
        // Update text field immediately as user scrolls
        educationTextField.text = educationOptions[row]
        notifyDelegate()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44.0
    }
}

// MARK: - UITextFieldDelegate for Validation
extension GuardianInformationCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Phone number validation
        if textField == phoneTextField {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            return newLength <= 10
        }
        
        // Aadhaar number validation
        if textField == aadharTextField {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            return newLength <= 12
        }
        
        // Income validation - allow numbers and decimal point
        if textField == incomeTextField {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case relationLabel:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            phoneTextField.becomeFirstResponder()
        case phoneTextField:
            aadharTextField.becomeFirstResponder()
        case aadharTextField:
            occupationTextField.becomeFirstResponder()
        case occupationTextField:
            incomeTextField.becomeFirstResponder()
        case incomeTextField:
            educationTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        notifyDelegate()
    }
}
