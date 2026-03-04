import UIKit

class BasicInfoTableViewCell: UITableViewCell,
                              UIPickerViewDelegate,
                              UIPickerViewDataSource,
                              UITextFieldDelegate {
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var uploadImage: UIButton!
    @IBOutlet weak var uploadAadhar: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var alternativeNo: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var aadharNo: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var pincode: UITextField!
    @IBOutlet weak var role: UITextField!
    @IBOutlet weak var photo: UIView!
    @IBOutlet weak var aadharPhoto: UIView!

    var onUploadImageTapped: (() -> Void)?
    var onDataChange: ((EditableManagement) -> Void)?
    var onUploadAadharTapped: (() -> Void)?

    // MARK: - Pickers
    private let rolePicker = UIPickerView()
    private var roles: [Role] = []

    private let countryPicker = UIPickerView()
    private let countries = ["India", "United States", "United Kingdom", "Canada", "Australia"]

    private let dobPicker = UIDatePicker()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        let allFields: [UITextField] = [
            name, gender, dob, phoneNo, alternativeNo,
            email, aadharNo, address, city, state,
            country, pincode, role
        ]

        allFields.forEach {
            $0.addTarget(self,
                         action: #selector(textFieldChanged(_:)),
                         for: .editingChanged)
        }

        // Role Picker
        role.delegate = self
        role.inputView = rolePicker
        rolePicker.delegate = self
        rolePicker.dataSource = self
        addToolbar(to: role)

        // Country Picker
        country.delegate = self
        country.inputView = countryPicker
        countryPicker.delegate = self
        countryPicker.dataSource = self
        addToolbar(to: country)

        // Date Picker
        dob.delegate = self
        if #available(iOS 13.4, *) {
            dobPicker.preferredDatePickerStyle = .wheels
        }
        dobPicker.datePickerMode = .date
        dob.inputView = dobPicker
        dobPicker.addTarget(self,
                            action: #selector(dobChanged(_:)),
                            for: .valueChanged)
        addToolbar(to: dob)

        // Phone fields
        phoneNo.delegate = self
        alternativeNo.delegate = self
        phoneNo.keyboardType = .numberPad
        alternativeNo.keyboardType = .numberPad
    }

    // MARK: - Populate (Editable)
    func populate(with data: EditableManagement, isEditingEnabled: Bool) {

        name.text = data.fullName
        gender.text = data.gender
        dob.text = data.dateOfBirth
        phoneNo.text = data.mobileNumber
        alternativeNo.text = data.alternativeNumber
        email.text = data.email
        aadharNo.text = data.aadharNumber
        address.text = data.address
        city.text = data.city
        state.text = data.state
        country.text = data.country
        pincode.text = data.pincode
        role.text = data.role

        let fields = [
            name, gender, dob, phoneNo, alternativeNo,
            email, aadharNo, address, city, state,
            country, pincode, role
        ]
        fields.forEach { $0?.isUserInteractionEnabled = isEditingEnabled }
    }

    // MARK: - Toolbar
    private func addToolbar(to textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done",
                                  style: .done,
                                  target: self,
                                  action: #selector(doneTapped))
        toolbar.items = [done]
        textField.inputAccessoryView = toolbar
    }

    @objc private func doneTapped() {
        contentView.endEditing(true)
    }

    // MARK: - Text Change
    @objc private func textFieldChanged(_ textField: UITextField) {
        sendUpdatedData()
    }

    // MARK: - DOB
    @objc private func dobChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dob.text = formatter.string(from: sender.date)
        sendUpdatedData()
    }

    // MARK: - Picker Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        pickerView == rolePicker ? roles.count : countries.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        pickerView == rolePicker ? roles[row].name : countries[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if pickerView == rolePicker {
            role.text = roles[row].name
        } else {
            country.text = countries[row]
        }
        sendUpdatedData()
    }

    // MARK: - Phone Validation
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard textField == phoneNo || textField == alternativeNo else { return true }

        let allowed = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard allowed.isSuperset(of: characterSet) else { return false }

        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString)
            .replacingCharacters(in: range, with: string)
        return prospectiveText.count <= 10
    }

    // MARK: - Fetch Roles
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == role { fetchRoles() }
        return true
    }

    private func fetchRoles() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else { return }
        let urlString = APIManager.shared.baseURL + "master/getroles?page=1&limit=20"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            if let decoded = try? JSONDecoder().decode(RoleResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.roles = decoded.data
                    self.rolePicker.reloadAllComponents()
                }
            }
        }.resume()
    }

    // MARK: - Data Sync
    private func sendUpdatedData() {
        var data = EditableManagement()
        data.fullName = name.text ?? ""
        data.gender = gender.text ?? ""
        data.dateOfBirth = dob.text ?? ""
        data.mobileNumber = phoneNo.text ?? ""
        data.alternativeNumber = alternativeNo.text ?? ""
        data.email = email.text ?? ""
        data.aadharNumber = aadharNo.text ?? ""
        data.address = address.text ?? ""
        data.city = city.text ?? ""
        data.state = state.text ?? ""
        data.country = country.text ?? ""
        data.pincode = pincode.text ?? ""
        data.role = role.text ?? ""

        onDataChange?(data)
    }

    // MARK: - Upload Aadhar
    @IBAction func uploadAadharTapped(_ sender: UIButton) {
        print("📤 Upload Aadhar button tapped")
        onUploadAadharTapped?()
    }

    // MARK: - Show Tick after Aadhaar Upload
    func showAadharSelected() {
        print("✅ Aadhar file selected successfully")
        
        // Use SF Symbol for tick
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        uploadAadhar.setImage(tickImage, for: .normal)
        uploadAadhar.setTitle("", for: .normal) 
        uploadAadhar.imageView?.contentMode = .scaleAspectFit
        uploadAadhar.backgroundColor = .clear
    }
    @IBAction func uploadImageTapped(_ sender: UIButton) {
        onUploadImageTapped?()
    }

}
