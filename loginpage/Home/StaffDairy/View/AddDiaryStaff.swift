import UIKit

class AddDiaryStaff: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var permanent: UITextField!

    private let permanentOptions = ["Permanent", "Non-Permanent"]
    private let permanentPicker = UIPickerView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up the permanent field with the picker view
        permanent.inputView = permanentPicker
        permanentPicker.delegate = self
        permanentPicker.dataSource = self
        
        // Default value
        permanent.text = permanentOptions[0]
        
        // Add Done button to picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        permanent.inputAccessoryView = toolbar
    }

    // MARK: - UIPickerView Delegate and DataSource

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

    // MARK: - Refresh Fields on Add More Button Tap

    @IBAction func AddMore(_ sender: UIButton) {
        resetFields()
    }

    func resetFields() {
        name.text = ""
        country.text = ""
        phone.text = ""
        designation.text = ""
        permanent.text = permanentOptions[0] // Reset to default
    }
}
