import UIKit

class StaffBasicInfo: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var staffId: UITextField!
    @IBOutlet weak var doj: UITextField!
    @IBOutlet weak var Class: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var qualification: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var caste: UITextField!
    @IBOutlet weak var bloodgroup: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var aadharNo: UITextField!
    @IBOutlet weak var type: UITextField!

    private var allTextFields: [UITextField] = []

    // Pickers
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Male", "Female", "Other"]

    private let countryPicker = UIPickerView()
    private var countryOptions: [String] = []

    private let dobPicker = UIDatePicker()
    private let dojPicker = UIDatePicker()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
        setupPickers()
    }

    func setEditingEnabled(_ isEnabled: Bool) {
        allTextFields.forEach { $0.isUserInteractionEnabled = isEnabled }
    }

    private func setupTextFields() {
        allTextFields = [
            name, country, phone, staffId, doj, Class, gender, qualification, dob,
            address, religion, caste, bloodgroup, emailId, aadharNo, type
        ]
        allTextFields.forEach { $0.delegate = self }
    }

    private func setupPickers() {
        // Prepare country options with "India" on top
        countryOptions = ["India"] + Locale.isoRegionCodes.compactMap {
            let name = Locale.current.localizedString(forRegionCode: $0)
            return name == "India" ? nil : name
        }.sorted()

        // Gender Picker
        genderPicker.delegate = self
        genderPicker.dataSource = self
        gender.inputView = genderPicker

        // Country Picker
        countryPicker.delegate = self
        countryPicker.dataSource = self
        country.inputView = countryPicker

        // DOB Picker
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        dobPicker.addTarget(self, action: #selector(dobChanged), for: .valueChanged)
        dob.inputView = dobPicker

        // DOJ Picker
        dojPicker.datePickerMode = .date
        dojPicker.preferredDatePickerStyle = .wheels
        dojPicker.addTarget(self, action: #selector(dojChanged), for: .valueChanged)
        doj.inputView = dojPicker

        // Toolbar with Done
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        toolbar.setItems([done], animated: false)

        gender.inputAccessoryView = toolbar
        country.inputAccessoryView = toolbar
        dob.inputAccessoryView = toolbar
        doj.inputAccessoryView = toolbar
    }

    @objc private func doneTapped() {
        if gender.isFirstResponder {
            let selectedRow = genderPicker.selectedRow(inComponent: 0)
            gender.text = genderOptions[selectedRow]
        } else if country.isFirstResponder {
            let selectedRow = countryPicker.selectedRow(inComponent: 0)
            country.text = countryOptions[selectedRow]
        }
        self.endEditing(true)
    }


    @objc private func dobChanged() {
        dob.text = formatDate(dobPicker.date)
    }

    @objc private func dojChanged() {
        doj.text = formatDate(dojPicker.date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func populate(with basicInfo: StaffDetail, isEditingEnabled: Bool) {

        // Full Name
        let fullName = [
            basicInfo.firstName,
            basicInfo.middleName,
            basicInfo.lastName
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        name.text = fullName

        phone.text = basicInfo.contactNumber
        emailId.text = basicInfo.email
        gender.text = basicInfo.gender
        dob.text = basicInfo.dateOfBirth
        country.text = basicInfo.country
        religion.text = basicInfo.religion
        bloodgroup.text = basicInfo.bloodGroup
        address.text = basicInfo.currentAddress

        staffId.text = basicInfo.staffCode
        type.text = basicInfo.staffType
        Class.text = basicInfo.designation

        aadharNo.text = basicInfo.nationalId

        // Optional / not provided by API (safe to leave empty)
        qualification.text = ""
        caste.text = ""
        doj.text = ""
        
        allTextFields.forEach {
            $0.isUserInteractionEnabled = isEditingEnabled
        }
    }

//    func collectUpdatedData() -> StaffUpdateRequest {
//
//        let nameComponents = (name.text ?? "")
//            .split(separator: " ")
//            .map(String.init)
//
//        let firstName = nameComponents.first ?? ""
//        let lastName = nameComponents.dropFirst().joined(separator: " ")
//
//        return StaffUpdateRequest(
//            firstName: firstName,
//            lastName: lastName,
//            gender: gender.text,
//            dateOfBirth: dob.text,
//            contactNumber: phone.text,
//            email: emailId.text,
//            country: country.text,
//            religion: religion.text,
//            bloodGroup: bloodgroup.text,
//            currentAddress: address.text,
//            nationalId: aadharNo.text,
//            staffType: type.text,
//            designation: Class.text
//        )
//    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phone {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }

            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 10
        }

        return true
    }

    // MARK: - UIPickerView Delegate/DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPicker {
            return genderOptions.count
        } else if pickerView == countryPicker {
            return countryOptions.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPicker {
            return genderOptions[row]
        } else if pickerView == countryPicker {
            return countryOptions[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPicker {
            gender.text = genderOptions[row]
        } else if pickerView == countryPicker {
            country.text = countryOptions[row]
        }
    }
}
