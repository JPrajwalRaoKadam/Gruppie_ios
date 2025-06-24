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

    func populate(with basicInfo: StaffDetailsData, isEditingEnabled: Bool) {
        name.text = basicInfo.name
        country.text = basicInfo.country
        phone.text = basicInfo.phone
        staffId.text = basicInfo.staffId
        doj.text = basicInfo.doj
        Class.text = basicInfo.className
        gender.text = basicInfo.gender
        qualification.text = basicInfo.qualification
        dob.text = basicInfo.dob
        address.text = basicInfo.address
        religion.text = basicInfo.religion
        caste.text = basicInfo.caste
        bloodgroup.text = basicInfo.bloodGroup
        emailId.text = basicInfo.emailId
        aadharNo.text = basicInfo.aadharNo
        type.text = basicInfo.type

        allTextFields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> StaffDetailsData {
        return StaffDetailsData(
            staffId: staffId.text ?? "",
            aadharNumber: aadharNo.text ?? "",
            address: address.text ?? "",
            bankAccountNumber: nil,
            bankIfscCode: nil,
            bloodGroup: bloodgroup.text ?? "",
            caste: caste.text ?? "",
            designation: Class.text ?? "",
            disability: "Select Disability",
            dob: dob.text ?? "",
            doj: doj.text ?? "",
            email: emailId.text ?? "",
            gender: gender.text ?? "",
            image: nil,
            name: name.text ?? "",
            panNumber: nil,
            phone: phone.text ?? "",
            qualification: qualification.text ?? "",
            religion: religion.text ?? "",
            staffCategory: "Category",
            type: type.text ?? "",
            uanNumber: nil,
            classType: nil,
            country: country.text ?? "",
            className: Class.text ?? "",
            emailId: emailId.text ?? "",
            aadharNo: aadharNo.text ?? "",
            bankAccount: nil,
            bankIfsc: nil
        )
    }

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
