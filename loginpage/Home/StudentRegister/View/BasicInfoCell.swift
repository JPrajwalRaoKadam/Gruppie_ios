//import UIKit
////
//class BasicInfoCell: UITableViewCell {
//    
//    // MARK: - IBOutlets
//    @IBOutlet weak var firstNameTF: UITextField!
//    @IBOutlet weak var middleNameTF: UITextField!
//    @IBOutlet weak var lastNameTF: UITextField!
//    @IBOutlet weak var genderTF: UITextField!
//    @IBOutlet weak var dobTF: UITextField!
//    @IBOutlet weak var placeOfBirthTF: UITextField!
//    @IBOutlet weak var motherTongueTF: UITextField!
//    @IBOutlet weak var bloodGroupTF: UITextField!
//    @IBOutlet weak var aadhaarTF: UITextField!
//    @IBOutlet weak var nationalityTF: UITextField!
//    @IBOutlet weak var religionTF: UITextField!
//    @IBOutlet weak var casteTF: UITextField!
//    @IBOutlet weak var feeCategoryTF: UITextField!
//    @IBOutlet weak var emailTF: UITextField!
//    @IBOutlet weak var studentMobileTF: UITextField!
//    @IBOutlet weak var maritalStatusTF: UITextField!
//    @IBOutlet weak var bhagyalakshmiTF: UITextField!
//    
//    // MARK: - Variables
//    private let genderOptions = ["MALE", "FEMALE", "OTHER"]
//    private let maritalStatusOptions = ["MARRIED", "UNMARRIED"]
//    private let bloodGroupOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
//    weak var delegate: BasicInfoCellDelegate?
//      
//    
//    // MARK: - Validation States
//    private var firstNameValid: Bool = false
//    private var genderValid: Bool = false
//    private var mobileValid: Bool = false
//    
//    // MARK: - Lifecycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupDropdowns()
//        setupTextFields()
//        setupValidationUI()
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//    
//    // MARK: - Setup Methods
//    private func setupTextFields() {
//        studentMobileTF.delegate = self
//        emailTF.delegate = self
//        firstNameTF.delegate = self
//        genderTF.delegate = self
//        
//        // Force lowercase for email
//        emailTF.autocapitalizationType = .none
//        
//        // Add target for real-time validation
//        firstNameTF.addTarget(self, action: #selector(firstNameDidChange), for: .editingChanged)
//        genderTF.addTarget(self, action: #selector(genderDidChange), for: .editingChanged)
//        studentMobileTF.addTarget(self, action: #selector(mobileDidChange), for: .editingChanged)
//    }
//    
//    private func setupDropdowns() {
//        setupGenderPicker()
//        setupMaritalStatusPicker()
//        setupBloodGroupPicker()
//    }
//    
//    private func setupGenderPicker() {
//        let picker = UIPickerView()
//        picker.delegate = self
//        picker.dataSource = self
//        picker.tag = 1
//        genderTF.inputView = picker
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        toolbar.items = [
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//        ]
//        genderTF.inputAccessoryView = toolbar
//    }
//    
//    private func setupMaritalStatusPicker() {
//        let picker = UIPickerView()
//        picker.delegate = self
//        picker.dataSource = self
//        picker.tag = 2
//        maritalStatusTF.inputView = picker
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        toolbar.items = [
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//        ]
//        maritalStatusTF.inputAccessoryView = toolbar
//    }
//    
//    private func setupBloodGroupPicker() {
//        let picker = UIPickerView()
//        picker.delegate = self
//        picker.dataSource = self
//        picker.tag = 3
//        bloodGroupTF.inputView = picker
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        toolbar.items = [
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//        ]
//        bloodGroupTF.inputAccessoryView = toolbar
//    }
//    
//    private func setupValidationUI() {
//        // Add placeholder for mandatory fields
//        firstNameTF.attributedPlaceholder = NSAttributedString(
//            string: "First Name *",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
//        )
//        
//        genderTF.attributedPlaceholder = NSAttributedString(
//            string: "Gender *",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
//        )
//        
//        studentMobileTF.attributedPlaceholder = NSAttributedString(
//            string: "Mobile *",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
//        )
//        dobTF.attributedPlaceholder = NSAttributedString(
//            string: "Date of birth *",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
//        )
//    }
//    
//    @objc private func doneButtonTapped() {
//        endEditing(true)
//    }
//    
//    // MARK: - Validation Methods
//    @objc private func firstNameDidChange() {
//        let isValid = !(firstNameTF.text?.isEmpty ?? true)
//        firstNameValid = isValid
//        updateTextFieldAppearance(textField: firstNameTF, isValid: isValid)
//    }
//    
//    @objc private func genderDidChange() {
//        let isValid = !(genderTF.text?.isEmpty ?? true)
//        genderValid = isValid
//        updateTextFieldAppearance(textField: genderTF, isValid: isValid)
//    }
//    
//    @objc private func mobileDidChange() {
//        let mobileText = studentMobileTF.text ?? ""
//        let isValid = mobileText.count == 10
//        mobileValid = isValid
//        updateTextFieldAppearance(textField: studentMobileTF, isValid: isValid)
//    }
//    
//    private func updateTextFieldAppearance(textField: UITextField, isValid: Bool) {
//        UIView.animate(withDuration: 0.3) {
//            if isValid {
//                textField.layer.borderColor = UIColor.systemGreen.cgColor
//                textField.layer.borderWidth = 1.0
//            } else {
//                textField.layer.borderColor = UIColor.red.cgColor
//                textField.layer.borderWidth = 1.0
//            }
//            textField.layer.cornerRadius = 4.0
//        }
//    }
//    
//    // MARK: - Data Methods
//    func populate(with student: StudentDataSR?) {
//        guard let student = student else { return }
//        
//        firstNameTF.text = student.firstName
//        middleNameTF.text = student.middleName
//        lastNameTF.text = student.lastName
//        genderTF.text = student.gender
//        dobTF.text = student.dateOfBirth
//        placeOfBirthTF.text = student.placeOfBirth
//        motherTongueTF.text = student.motherTongue
//        bloodGroupTF.text = student.bloodGroup
//        aadhaarTF.text = student.aadharNumber
//        nationalityTF.text = student.nationality
//        religionTF.text = student.religion
//        casteTF.text = student.caste
//        feeCategoryTF.text = student.feeCategory
//        emailTF.text = student.email
//        studentMobileTF.text = student.mobileNumber
//        maritalStatusTF.text = student.maritalStatus
//        bhagyalakshmiTF.text = student.bhagyalakshmi
//        
//        // Trigger validation after populating
//        firstNameDidChange()
//        genderDidChange()
//        mobileDidChange()
//    }
//    
//    // MARK: - Data Methods
//    func collectData() -> BasicInfoData {
//        return BasicInfoData(
//            firstName: firstNameTF.text ?? "",
//            middleName: middleNameTF.text ?? "",
//            lastName: lastNameTF.text ?? "",
//            gender: genderTF.text ?? "",
//            dateOfBirth: dobTF.text ?? "",
//            placeOfBirth: placeOfBirthTF.text ?? "",
//            motherTongue: motherTongueTF.text ?? "",
//            bloodGroup: bloodGroupTF.text ?? "",
//            aadharNumber: aadhaarTF.text ?? "",
//            nationality: nationalityTF.text ?? "",
//            religion: religionTF.text ?? "",
//            caste: casteTF.text ?? "",
//            feeCategory: feeCategoryTF.text ?? "",
//            email: emailTF.text ?? "",
//            mobileNumber: studentMobileTF.text ?? "",
//            maritalStatus: maritalStatusTF.text ?? "",
//            bhagyalakshmi: bhagyalakshmiTF.text ?? ""
//        )
//    }
//    
//    // MARK: - Validation Check
//    func validateFields() -> (isValid: Bool, errorMessage: String?) {
//        var errors: [String] = []
//        
//        // Check mandatory fields
//        if firstNameTF.text?.isEmpty ?? true {
//            errors.append("First Name is required")
//        }
//        
//        if genderTF.text?.isEmpty ?? true {
//            errors.append("Gender is required")
//        }
//        
//        let mobileText = studentMobileTF.text ?? ""
//        if mobileText.isEmpty {
//            errors.append("Mobile number is required")
//        } else if mobileText.count != 10 {
//            errors.append("Mobile number must be 10 digits")
//        }
//        
//        // Check email format if provided
//        if let email = emailTF.text, !email.isEmpty {
//            if !isValidEmail(email) {
//                errors.append("Invalid email format")
//            }
//        }
//        
//        if errors.isEmpty {
//            return (true, nil)
//        } else {
//            return (false, errors.joined(separator: "\n"))
//        }
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//}
//
//// MARK: - UIPickerViewDelegate & DataSource
//extension BasicInfoCell: UIPickerViewDelegate, UIPickerViewDataSource {
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        switch pickerView.tag {
//        case 1: // Gender
//            return genderOptions.count
//        case 2: // Marital Status
//            return maritalStatusOptions.count
//        case 3: // Blood Group
//            return bloodGroupOptions.count
//        default:
//            return 0
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch pickerView.tag {
//        case 1: // Gender
//            return genderOptions[row]
//        case 2: // Marital Status
//            return maritalStatusOptions[row]
//        case 3: // Blood Group
//            return bloodGroupOptions[row]
//        default:
//            return nil
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        switch pickerView.tag {
//        case 1: // Gender
//            genderTF.text = genderOptions[row]
//            genderDidChange() // Trigger validation
//        case 2: // Marital Status
//            maritalStatusTF.text = maritalStatusOptions[row]
//        case 3: // Blood Group
//            bloodGroupTF.text = bloodGroupOptions[row]
//        default:
//            break
//        }
//    }
//}
//
//// MARK: - UITextFieldDelegate
//extension BasicInfoCell: UITextFieldDelegate {
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        // Mobile number validation
//        if textField == studentMobileTF {
//            // Allow only numbers
//            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
//                return false
//            }
//            
//            let currentText = textField.text ?? ""
//            let newLength = currentText.count + string.count - range.length
//            
//            return newLength <= 10 // Max 10 digits
//        }
//        
//        // Email validation - force lowercase
//        if textField == emailTF {
//            let currentText = textField.text ?? ""
//            guard let stringRange = Range(range, in: currentText) else { return false }
//            let updatedText = currentText.replacingCharacters(in: stringRange, with: string.lowercased())
//            
//            // Update the text field with lowercase
//            textField.text = updatedText
//            return false
//        }
//        
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        // Email validation when editing ends
//        if textField == emailTF {
//            if let email = textField.text, !email.isEmpty {
//                if !isValidEmail(email) {
//                    textField.layer.borderColor = UIColor.red.cgColor
//                    textField.layer.borderWidth = 1.0
//                    textField.layer.cornerRadius = 4.0
//                } else {
//                    textField.layer.borderColor = UIColor.systemGray5.cgColor
//                    textField.layer.borderWidth = 0
//                }
//            }
//        }
//    }
//}
//


import UIKit

class BasicInfoCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var middleNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var placeOfBirthTF: UITextField!
    @IBOutlet weak var motherTongueTF: UITextField!
    @IBOutlet weak var bloodGroupTF: UITextField!
    @IBOutlet weak var aadhaarTF: UITextField!
    @IBOutlet weak var nationalityTF: UITextField!
    @IBOutlet weak var religionTF: UITextField!
    @IBOutlet weak var casteTF: UITextField!
    @IBOutlet weak var feeCategoryTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var studentMobileTF: UITextField!
    @IBOutlet weak var maritalStatusTF: UITextField!
    @IBOutlet weak var bhagyalakshmiTF: UITextField!
    
    // MARK: - Variables
    private let genderOptions = ["MALE", "FEMALE", "OTHER"]
    private let maritalStatusOptions = ["MARRIED", "UNMARRIED"]
    private let bloodGroupOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    // MARK: - Validation States
    private var firstNameValid: Bool = false
    private var genderValid: Bool = false
    private var mobileValid: Bool = false
    private var dobValid: Bool = false
    
    // MARK: - Delegate
    weak var delegate: BasicInfoCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDropdowns()
        setupTextFields()
        setupValidationUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupTextFields() {
        studentMobileTF.delegate = self
        emailTF.delegate = self
        firstNameTF.delegate = self
        genderTF.delegate = self
        dobTF.delegate = self
        aadhaarTF.delegate = self
        
        // Force lowercase for email
        emailTF.autocapitalizationType = .none
        
        // Add target for real-time validation
        firstNameTF.addTarget(self, action: #selector(firstNameDidChange), for: .editingChanged)
        genderTF.addTarget(self, action: #selector(genderDidChange), for: .editingChanged)
        studentMobileTF.addTarget(self, action: #selector(mobileDidChange), for: .editingChanged)
        dobTF.addTarget(self, action: #selector(dobDidChange), for: .editingChanged)
        
        // Add targets for other text fields to notify delegate
        let otherFields = [middleNameTF, lastNameTF, placeOfBirthTF, motherTongueTF,
                          nationalityTF, religionTF, casteTF, feeCategoryTF,
                          maritalStatusTF, bhagyalakshmiTF]
        
        otherFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupDropdowns() {
        setupGenderPicker()
        setupMaritalStatusPicker()
        setupBloodGroupPicker()
        setupDatePicker()
    }
    
    private func setupGenderPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 1
        genderTF.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        ]
        genderTF.inputAccessoryView = toolbar
    }
    
    private func setupMaritalStatusPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 2
        maritalStatusTF.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        ]
        maritalStatusTF.inputAccessoryView = toolbar
    }
    
    private func setupBloodGroupPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 3
        bloodGroupTF.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        ]
        bloodGroupTF.inputAccessoryView = toolbar
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date() // Cannot select future date
        
        // Set minimum date (e.g., 100 years ago)
        let calendar = Calendar.current
        if let minDate = calendar.date(byAdding: .year, value: -100, to: Date()) {
            datePicker.minimumDate = minDate
        }
        
        dobTF.inputView = datePicker
        
        // Add toolbar with done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDoneTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, doneButton]
        dobTF.inputAccessoryView = toolbar
        
        // Set date picker action
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func setupValidationUI() {
        // Add placeholder for mandatory fields
        firstNameTF.attributedPlaceholder = NSAttributedString(
            string: "First Name *",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        
        genderTF.attributedPlaceholder = NSAttributedString(
            string: "Gender *",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        
        studentMobileTF.attributedPlaceholder = NSAttributedString(
            string: "Mobile *",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        
        dobTF.attributedPlaceholder = NSAttributedString(
            string: "Date of birth *",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
    }
    
    @objc private func doneButtonTapped() {
        endEditing(true)
    }
    
    @objc private func datePickerDoneTapped() {
        endEditing(true)
    }
    
    @objc private func dateChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobTF.text = formatter.string(from: sender.date)
        dobDidChange()
    }
    
    // MARK: - Validation Methods
    @objc private func firstNameDidChange() {
        let isValid = !(firstNameTF.text?.isEmpty ?? true)
        firstNameValid = isValid
        updateTextFieldAppearance(textField: firstNameTF, isValid: isValid)
        notifyDelegate()
    }
    
    @objc private func genderDidChange() {
        let isValid = !(genderTF.text?.isEmpty ?? true)
        genderValid = isValid
        updateTextFieldAppearance(textField: genderTF, isValid: isValid)
        notifyDelegate()
    }
    
    @objc private func mobileDidChange() {
        let mobileText = studentMobileTF.text ?? ""
        let isValid = mobileText.count == 10
        mobileValid = isValid
        updateTextFieldAppearance(textField: studentMobileTF, isValid: isValid)
        notifyDelegate()
    }
    
    @objc private func dobDidChange() {
        let isValid = !(dobTF.text?.isEmpty ?? true)
        dobValid = isValid
        updateTextFieldAppearance(textField: dobTF, isValid: isValid)
        notifyDelegate()
    }
    
    @objc private func textFieldDidChange() {
        notifyDelegate()
    }
    
    private func updateTextFieldAppearance(textField: UITextField, isValid: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isValid {
                textField.layer.borderColor = UIColor.systemGreen.cgColor
                textField.layer.borderWidth = 1.0
            } else {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
            textField.layer.cornerRadius = 4.0
        }
    }
    
    // MARK: - Data Methods
    func populate(with student: StudentDataSR?) {
        guard let student = student else { return }
        
        firstNameTF.text = student.firstName
        middleNameTF.text = student.middleName
        lastNameTF.text = student.lastName
        genderTF.text = student.gender
        dobTF.text = student.dateOfBirth
        placeOfBirthTF.text = student.placeOfBirth
        motherTongueTF.text = student.motherTongue
        bloodGroupTF.text = student.bloodGroup
        aadhaarTF.text = student.aadharNumber
        nationalityTF.text = student.nationality
        religionTF.text = student.religion
        casteTF.text = student.caste
        feeCategoryTF.text = student.feeCategory
        emailTF.text = student.email
        studentMobileTF.text = student.mobileNumber
        maritalStatusTF.text = student.maritalStatus
        bhagyalakshmiTF.text = student.bhagyalakshmi
        
        // Trigger validation after populating
        firstNameDidChange()
        genderDidChange()
        mobileDidChange()
        dobDidChange()
    }
    
    func collectData() -> BasicInfoData {
        return BasicInfoData(
            firstName: firstNameTF.text ?? "",
            middleName: middleNameTF.text ?? "",
            lastName: lastNameTF.text ?? "",
            gender: genderTF.text ?? "",
            dateOfBirth: dobTF.text ?? "",
            placeOfBirth: placeOfBirthTF.text ?? "",
            motherTongue: motherTongueTF.text ?? "",
            bloodGroup: bloodGroupTF.text ?? "",
            aadharNumber: aadhaarTF.text ?? "",
            nationality: nationalityTF.text ?? "",
            religion: religionTF.text ?? "",
            caste: casteTF.text ?? "",
            feeCategory: feeCategoryTF.text ?? "",
            email: emailTF.text ?? "",
            mobileNumber: studentMobileTF.text ?? "",
            maritalStatus: maritalStatusTF.text ?? "",
            bhagyalakshmi: bhagyalakshmiTF.text ?? ""
        )
    }
    
    private func notifyDelegate() {
        let data = collectData()
        delegate?.basicInfoDidUpdate(data)
    }
    
    // MARK: - Validation Check
    func validateFields() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // Check mandatory fields
        if firstNameTF.text?.isEmpty ?? true {
            errors.append("First Name is required")
        }
        
        if genderTF.text?.isEmpty ?? true {
            errors.append("Gender is required")
        }
        
        if dobTF.text?.isEmpty ?? true {
            errors.append("Date of Birth is required")
        }
        
        let mobileText = studentMobileTF.text ?? ""
        if mobileText.isEmpty {
            errors.append("Mobile number is required")
        } else if mobileText.count != 10 {
            errors.append("Mobile number must be 10 digits")
        }
        
        // Validate date format if provided
        if let dob = dobTF.text, !dob.isEmpty {
            if !isValidDate(dob) {
                errors.append("Invalid date format. Use DD/MM/YYYY")
            }
        }
        
        // Check email format if provided
        if let email = emailTF.text, !email.isEmpty {
            if !isValidEmail(email) {
                errors.append("Invalid email format")
            }
        }
        
        // Check Aadhaar format if provided
        if let aadhaar = aadhaarTF.text, !aadhaar.isEmpty {
            if aadhaar.count != 12 {
                errors.append("Aadhaar number must be 12 digits")
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors.joined(separator: "\n"))
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidDate(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: dateString) {
            // Check if date is reasonable (not in future and not too far in past)
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Student should be at least 3 years old and not born in future
            guard let minDate = calendar.date(byAdding: .year, value: -3, to: currentDate),
                  let maxDate = calendar.date(byAdding: .year, value: -100, to: currentDate) else {
                return false
            }
            
            return date <= minDate && date >= maxDate
        }
        return false
    }
    
    private func autoFormatDate(_ text: String) -> String {
        var digits = text.filter { $0.isNumber }
        
        // Limit to 8 digits (DDMMYYYY)
        if digits.count > 8 {
            digits = String(digits.prefix(8))
        }
        
        var result = ""
        
        for (index, char) in digits.enumerated() {
            if index == 2 || index == 4 {
                result.append("/")
            }
            result.append(char)
        }
        
        return result
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension BasicInfoCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: // Gender
            return genderOptions.count
        case 2: // Marital Status
            return maritalStatusOptions.count
        case 3: // Blood Group
            return bloodGroupOptions.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1: // Gender
            return genderOptions[row]
        case 2: // Marital Status
            return maritalStatusOptions[row]
        case 3: // Blood Group
            return bloodGroupOptions[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // Gender
            genderTF.text = genderOptions[row]
            genderDidChange() // Trigger validation
        case 2: // Marital Status
            maritalStatusTF.text = maritalStatusOptions[row]
            notifyDelegate()
        case 3: // Blood Group
            bloodGroupTF.text = bloodGroupOptions[row]
            notifyDelegate()
        default:
            break
        }
    }
}

// MARK: - UITextFieldDelegate
extension BasicInfoCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Mobile number validation
        if textField == studentMobileTF {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return newLength <= 10 // Max 10 digits
        }
        
        // Aadhaar number validation
        if textField == aadhaarTF {
            // Allow only numbers
            if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil && !string.isEmpty {
                return false
            }
            
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            return newLength <= 12 // Max 12 digits for Aadhaar
        }
        
        // Date of Birth auto-format (DD/MM/YYYY)
        if textField == dobTF {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            // Allow only numbers and /
            let allowedCharacters = CharacterSet(charactersIn: "0123456789/")
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) && !string.isEmpty {
                return false
            }
            
            // Auto-format logic
            let formattedText = autoFormatDate(newText)
            textField.text = formattedText
            
            // Trigger validation
            dobDidChange()
            
            return false
        }
        
        // Email validation - force lowercase
        if textField == emailTF {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string.lowercased())
            
            // Update the text field with lowercase
            textField.text = updatedText
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Email validation when editing ends
        if textField == emailTF {
            if let email = textField.text, !email.isEmpty {
                if !isValidEmail(email) {
                    textField.layer.borderColor = UIColor.red.cgColor
                    textField.layer.borderWidth = 1.0
                    textField.layer.cornerRadius = 4.0
                } else {
                    textField.layer.borderColor = UIColor.systemGray5.cgColor
                    textField.layer.borderWidth = 0
                }
            }
        }
        
        // Notify delegate when editing ends
        notifyDelegate()
    }
}
