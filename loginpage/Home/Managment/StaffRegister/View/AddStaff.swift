import UIKit

class AddStaff: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var permanent: UITextField!

    private let permanentOptions = ["Permanent", "Non-Permanent"]
    private let permanentPicker = UIPickerView()

    override func awakeFromNib() {
        super.awakeFromNib()

        permanent.inputView = permanentPicker
        permanentPicker.delegate = self
        permanentPicker.dataSource = self
        permanent.text = permanentOptions[0]

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        permanent.inputAccessoryView = toolbar
        phone.delegate = self
        phone.keyboardType = .numberPad
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phone {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let isNumber = allowedCharacters.isSuperset(of: characterSet)
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            return isNumber && updatedText.count <= 10
        }
        return true
    }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return permanentOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return permanentOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        permanent.text = permanentOptions[row]
    }

    @objc func donePicker() {
        permanent.resignFirstResponder()
    }

    @IBAction func AddMore(_ sender: UIButton) {
        resetFields()
    }

    func resetFields() {
        name.text = ""
        country.text = ""
        phone.text = ""
        designation.text = ""
        permanent.text = permanentOptions[0]
    }
}
