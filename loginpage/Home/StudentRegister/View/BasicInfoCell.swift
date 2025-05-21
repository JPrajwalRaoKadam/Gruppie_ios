import UIKit

class BasicInfoCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var studentClass: UITextField!
    @IBOutlet weak var section: UITextField!
    @IBOutlet weak var rollNo: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var doj: UITextField!

    private let genderOptions = ["Male", "Female", "Other"]
    private var genderPicker = UIPickerView()
    private var datePicker = UIDatePicker()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGenderPicker()
        setupDatePicker()
    }

    private func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        gender.inputView = genderPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneSelectingGender))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        gender.inputAccessoryView = toolbar
    }

    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        doj.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneSelectingDate))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        doj.inputAccessoryView = toolbar
    }

    @objc private func doneSelectingGender() {
        let selectedRow = genderPicker.selectedRow(inComponent: 0)
        gender.text = genderOptions[selectedRow]
        gender.resignFirstResponder()
    }

    @objc private func doneSelectingDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        doj.text = formatter.string(from: datePicker.date)
        doj.resignFirstResponder()
    }

    func populate(with student: StudentData, isEditingEnabled: Bool) {
        name.text = student.name
        gender.text = student.gender
        studentClass.text = student.className
        section.text = student.section
        rollNo.text = student.rollNumber
        email.text = student.email
        phone.text = student.phone
        doj.text = student.dateOfJoining

        let fields: [UITextField] = [
            name, gender, studentClass, section, rollNo, email, phone, doj
        ]
        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    func collectUpdatedData() -> [String: Any] {
        return [
            "name": name.text ?? "",
            "gender": gender.text ?? "",
            "className": studentClass.text ?? "",
            "section": section.text ?? "",
            "rollNumber": rollNo.text ?? "",
            "email": email.text ?? "",
            "phone": phone.text ?? "",
            "dateOfJoining": doj.text ?? ""
        ]
    }

    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = genderOptions[row]
    }
}
