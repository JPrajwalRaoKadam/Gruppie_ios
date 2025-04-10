import UIKit

class EducationInfoCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nationality: UITextField!
    @IBOutlet weak var bloodGroup: UITextField!
    @IBOutlet weak var religion: UITextField!
    @IBOutlet weak var caste: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var disability: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var admissionNo: UITextField!
    @IBOutlet weak var satsNumber: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var aadharNo: UITextField!

    private let nationalityPicker = UIPickerView()
    private let disabilityPicker = UIPickerView()
    private let dobPicker = UIDatePicker()
    
    private let disabilityOptions = ["Yes", "No"]
    
    private let countries: [String] = {
        var list = Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
        list.sort()
        if let index = list.firstIndex(of: "India") {
            list.remove(at: index)
            list.insert("India", at: 0)
        }
        return list
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPickers()
    }

    private func setupPickers() {
        // Nationality Picker
        nationalityPicker.delegate = self
        nationalityPicker.dataSource = self
        nationality.inputView = nationalityPicker
        nationality.inputAccessoryView = createToolbar(selector: #selector(doneSelectingNationality))

        // Disability Picker
        disabilityPicker.delegate = self
        disabilityPicker.dataSource = self
        disability.inputView = disabilityPicker
        disability.inputAccessoryView = createToolbar(selector: #selector(doneSelectingDisability))

        // DOB DatePicker
        dobPicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            dobPicker.preferredDatePickerStyle = .wheels
        }
        dob.inputView = dobPicker
        dob.inputAccessoryView = createToolbar(selector: #selector(doneSelectingDOB))
    }

    private func createToolbar(selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: selector)
        toolbar.setItems([doneButton], animated: false)
        return toolbar
    }

    @objc private func doneSelectingNationality() {
        let selectedRow = nationalityPicker.selectedRow(inComponent: 0)
        nationality.text = countries[selectedRow]
        nationality.resignFirstResponder()
    }

    @objc private func doneSelectingDisability() {
        let selectedRow = disabilityPicker.selectedRow(inComponent: 0)
        disability.text = disabilityOptions[selectedRow]
        disability.resignFirstResponder()
    }

    @objc private func doneSelectingDOB() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        dob.text = formatter.string(from: dobPicker.date)
        dob.resignFirstResponder()
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == nationalityPicker ? countries.count : disabilityOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == nationalityPicker ? countries[row] : disabilityOptions[row]
    }

    // ✅ Function to populate fields with student data
    func populate(with educationInfo: EducationInfo?, isEditingEnabled: Bool) {
        guard let educationInfo = educationInfo else { return }

        nationality.text = educationInfo.nationality
        bloodGroup.text = educationInfo.bloodGroup
        religion.text = educationInfo.religion
        caste.text = educationInfo.caste
        category.text = educationInfo.category
        disability.text = educationInfo.disability
        dob.text = educationInfo.dateOfBirth
        admissionNo.text = educationInfo.admissionNumber
        satsNumber.text = educationInfo.satsNumber
        address.text = educationInfo.address
        aadharNo.text = educationInfo.aadharNumber

        let fields: [UITextField] = [
            nationality, bloodGroup, religion, caste, category, disability, dob,
            admissionNo, satsNumber, address, aadharNo
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    // ✅ Function to collect updated data from fields
    func collectUpdatedData() -> EducationInfo {
        let nationalityText = nationality.text ?? ""
        let bloodGroupText = bloodGroup.text ?? ""
        let religionText = religion.text ?? ""
        let casteText = caste.text ?? ""
        let categoryText = category.text ?? ""
        let disabilityText = disability.text ?? ""
        let dateOfBirthText = dob.text ?? ""
        let admissionNumberText = admissionNo.text ?? ""
        let satsNumberText = satsNumber.text ?? ""
        let addressText = address.text ?? ""
        let aadharNumberText = aadharNo.text ?? ""

        return EducationInfo(
            nationality: nationalityText,
            bloodGroup: bloodGroupText,
            religion: religionText,
            caste: casteText,
            category: categoryText,
            disability: disabilityText,
            dateOfBirth: dateOfBirthText,
            admissionNumber: admissionNumberText,
            satsNumber: satsNumberText,
            aadharNumber: aadharNumberText, address: addressText
        )
    }
}
