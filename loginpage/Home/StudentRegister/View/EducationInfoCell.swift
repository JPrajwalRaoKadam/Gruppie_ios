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
        nationalityPicker.delegate = self
        nationalityPicker.dataSource = self
        nationality.inputView = nationalityPicker
        nationality.inputAccessoryView = createToolbar(selector: #selector(doneSelectingNationality))

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

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == nationalityPicker ? countries.count : disabilityOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == nationalityPicker ? countries[row] : disabilityOptions[row]
    }

    func populate(with education: StudentData, isEditingEnabled: Bool) {
        nationality.text = education.nationality
        bloodGroup.text = education.bloodGroup
        religion.text = education.religion
        caste.text = education.caste
        category.text = education.category
        disability.text = education.disability
        dob.text = education.dateOfBirth
        admissionNo.text = education.admissionNumber
        satsNumber.text = education.satsNumber
        address.text = education.address
        aadharNo.text = education.aadharNumber

        [nationality, bloodGroup, religion, caste, category, disability, dob, admissionNo, satsNumber, address, aadharNo].forEach {
            $0?.isUserInteractionEnabled = isEditingEnabled
            $0?.backgroundColor = isEditingEnabled ? .white : .clear
        }
    }

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
