//
//  Admission InformationCell.swift
//  loginpage
//
//  Created by apple on 20/01/26.
//

//import UIKit
//
//class AdmissionInformationCell: UITableViewCell {
//    @IBOutlet weak var omrno: UITextField!
//    @IBOutlet weak var date: UITextField!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//}
import UIKit
class AdmissionInformationCell: UITableViewCell {
    
    @IBOutlet weak var omrno: UITextField!
    @IBOutlet weak var date: UITextField!
    
    // MARK: - Variables
    weak var delegate: AdmissionInfoCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDatePicker()
        setupTextFields()
    }
    
    // MARK: - Setup Methods
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date() // Cannot select future date
        
        // Set minimum date (e.g., 5 years ago)
        let calendar = Calendar.current
        if let minDate = calendar.date(byAdding: .year, value: -5, to: Date()) {
            datePicker.minimumDate = minDate
        }
        
        date.inputView = datePicker
        
        // Add toolbar with done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDoneTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, doneButton]
        date.inputAccessoryView = toolbar
        
        // Set date picker action
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func setupTextFields() {
        // Add target for real-time updates
        omrno.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        date.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Set delegates
        omrno.delegate = self
        date.delegate = self
        
        // Set placeholders
        omrno.attributedPlaceholder = NSAttributedString(
            string: "OMR Number",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        
        date.attributedPlaceholder = NSAttributedString(
            string: "Admission Date *",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
    }
    
    // MARK: - Date Picker Actions
    @objc private func dateChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        date.text = formatter.string(from: sender.date)
        notifyDelegate()
    }
    
    @objc private func datePickerDoneTapped() {
        date.resignFirstResponder()
    }
    
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        notifyDelegate()
    }
    
    // MARK: - Notify Delegate
    private func notifyDelegate() {
        let data = AdmissionInfoData(
            omrNumber: omrno.text ?? "",
            dateOfAdmission: date.text ?? ""
        )

        delegate?.admissionInfoDidUpdate(data)
    }
    
    // MARK: - Populate with Data
    func populate(with data: AdmissionInfoData?) {
        guard let data = data else {
            omrno.text = ""
            date.text = ""
            return
        }
        
        omrno.text = data.omrNumber
        date.text = data.dateOfAdmission

    }
    
    // MARK: - Collect Data
    func collectAdmissionData() -> AdmissionInfoData {
        return AdmissionInfoData(
            omrNumber: omrno.text ?? "",
            dateOfAdmission: date.text ?? ""
        )

    }
    
    // MARK: - Validation
    func validateFields() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // Admission date is required
        if date.text?.isEmpty ?? true {
            errors.append("Admission date is required")
        }
        
        // Validate date format if provided
        if let dateText = date.text, !dateText.isEmpty {
            if !isValidDate(dateText) {
                errors.append("Invalid date format. Use DD/MM/YYYY")
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors.joined(separator: "\n"))
        }
    }
    
    private func isValidDate(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString) != nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UITextFieldDelegate
extension AdmissionInformationCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Date field auto-format (DD/MM/YYYY)
        if textField == date {
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
            
            // Trigger delegate notification
            notifyDelegate()
            
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        notifyDelegate()
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
