import UIKit
class Medical_Sports_InformationCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - IBOutlets for TextFields
    @IBOutlet weak var describeDisabilityTextField: UITextField!
    @IBOutlet weak var sportsLevelTextField: UITextField!
    @IBOutlet weak var medicalConditionTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var emergencyMedicationTextField: UITextField!
    @IBOutlet weak var chronicDiseasesTextField: UITextField!
    @IBOutlet weak var medicalNotesTextField: UITextField!
    @IBOutlet weak var pickupAddressTextField: UITextField!
    @IBOutlet weak var dropAddressTextField: UITextField!
    
    // MARK: - Checkbox Buttons
    @IBOutlet weak var physicalDisabilityCheckbox: UIButton!
    @IBOutlet weak var sportsParticipationCheckbox: UIButton!
    @IBOutlet weak var transportRequiredCheckbox: UIButton!
    @IBOutlet weak var hostelRequiredCheckbox: UIButton!
    
    // MARK: - Container Views for Address Fields
    @IBOutlet weak var transportView: UIView! // Main container view
    @IBOutlet weak var pickupAddressContainer: UIView! // Inside transportView
    @IBOutlet weak var dropAddressContainer: UIView! // Inside transportView
    
    // MARK: - Variables
    private var isPhysicalDisabilityChecked = false
    private var isSportsParticipationChecked = false
    private var isTransportRequiredChecked = false
    private var isHostelRequiredChecked = false
    
    private let sportsLevels = ["School", "District", "State", "National", "International"]
    
    // MARK: - Delegate
    weak var delegate: MedicalSportsCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize checkbox appearance
        setupCheckboxAppearance()
        setupSportsLevelPicker()
        setupTextFields()
        
        // Initially hide dependent fields
        describeDisabilityTextField.isHidden = true
        sportsLevelTextField.isHidden = true
        transportView?.isHidden = true
        
        // Set up checkbox initial state (unchecked appearance)
        updateCheckboxAppearance(button: physicalDisabilityCheckbox, isChecked: isPhysicalDisabilityChecked)
        updateCheckboxAppearance(button: sportsParticipationCheckbox, isChecked: isSportsParticipationChecked)
        updateCheckboxAppearance(button: transportRequiredCheckbox, isChecked: isTransportRequiredChecked)
        updateCheckboxAppearance(button: hostelRequiredCheckbox, isChecked: isHostelRequiredChecked)
    }
    
    // MARK: - Setup Methods
    private func setupTextFields() {
        // Add target for real-time updates
        let textFields = [describeDisabilityTextField, sportsLevelTextField,
                         medicalConditionTextField, allergiesTextField,
                         emergencyMedicationTextField, chronicDiseasesTextField,
                         medicalNotesTextField, pickupAddressTextField,
                         dropAddressTextField]
        
        textFields.forEach { textField in
            textField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupSportsLevelPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 1 // Tag for sports level picker
        
        sportsLevelTextField.inputView = picker
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action: #selector(doneSportsLevelPicker))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        
        toolBar.items = [space, done]
        sportsLevelTextField.inputAccessoryView = toolBar
    }
    
    @objc private func doneSportsLevelPicker() {
        sportsLevelTextField.resignFirstResponder()
        notifyDelegate()
    }
    // In Medical_Sports_InformationCell.swift or wherever you need current date
    func getCurrentDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    
    // MARK: - Setup Checkbox Appearance
    private func setupCheckboxAppearance() {
        let checkboxes = [physicalDisabilityCheckbox, sportsParticipationCheckbox,
                         transportRequiredCheckbox, hostelRequiredCheckbox]
        
        checkboxes.forEach { checkbox in
            checkbox?.layer.borderWidth = 2
            checkbox?.layer.borderColor = UIColor.systemBlue.cgColor
            checkbox?.layer.cornerRadius = 4
            checkbox?.backgroundColor = .clear
            checkbox?.setTitle("", for: .normal)
            checkbox?.tintColor = .clear
            checkbox?.imageView?.contentMode = .scaleAspectFit
            checkbox?.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
            
            // Ensure checkbox maintains its background
            checkbox?.clipsToBounds = true
        }
    }
    
    // MARK: - Checkbox Actions
    @IBAction func physicalDisabilityToggled(_ sender: UIButton) {
        isPhysicalDisabilityChecked.toggle()
        updateCheckboxAppearance(button: sender, isChecked: isPhysicalDisabilityChecked)
        describeDisabilityTextField.isHidden = !isPhysicalDisabilityChecked
        
        // Animate the appearance
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        notifyDelegate()
    }
    
    @IBAction func sportsParticipationToggled(_ sender: UIButton) {
        isSportsParticipationChecked.toggle()
        updateCheckboxAppearance(button: sender, isChecked: isSportsParticipationChecked)
        sportsLevelTextField.isHidden = !isSportsParticipationChecked
        
        // Animate the appearance
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        notifyDelegate()
    }
    
    @IBAction func transportRequiredToggled(_ sender: UIButton) {
        isTransportRequiredChecked.toggle()
        updateCheckboxAppearance(button: sender, isChecked: isTransportRequiredChecked)
        
        // Show/hide the entire transport view (which contains both address containers)
        transportView?.isHidden = !isTransportRequiredChecked
        
        // Animate the appearance
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        notifyDelegate()
    }
    
    @IBAction func hostelRequiredToggled(_ sender: UIButton) {
        isHostelRequiredChecked.toggle()
        updateCheckboxAppearance(button: sender, isChecked: isHostelRequiredChecked)
        notifyDelegate()
    }
    
    // MARK: - Update Checkbox UI
    private func updateCheckboxAppearance(button: UIButton, isChecked: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isChecked {
                // When checked: Show checkmark with blue color
                let checkmarkImage = UIImage(systemName: "checkmark")?
                    .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
                button.setImage(checkmarkImage, for: .normal)
                button.tintColor = .systemBlue
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            } else {
                // When unchecked: Hide checkmark
                button.setImage(nil, for: .normal)
                button.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        notifyDelegate()
    }
    
    // MARK: - Notify Delegate
    private func notifyDelegate() {

        let data = MedicalSportsData(
            physicalDisability: isPhysicalDisabilityChecked,
            disabilityDescription: describeDisabilityTextField.text ?? "",

            sportsParticipation: isSportsParticipationChecked,
            sportsLevel: sportsLevelTextField.text ?? "",

            medicalCondition: medicalConditionTextField.text ?? "",
            emergencyMedication: emergencyMedicationTextField.text ?? "",
            chronicDiseases: chronicDiseasesTextField.text ?? "",
            allergies: allergiesTextField.text ?? "",
            medicalNotes: medicalNotesTextField.text ?? "",

            transportRequired: isTransportRequiredChecked,
            hostelRequired: isHostelRequiredChecked,

            pickupAddress: pickupAddressTextField.text ?? "",
            dropAddress: dropAddressTextField.text ?? ""
        )

        delegate?.medicalSportsInfoDidUpdate(data)
    }

    
    // MARK: - Reset/Configure Methods
    func resetCheckboxes() {
        isPhysicalDisabilityChecked = false
        isSportsParticipationChecked = false
        isTransportRequiredChecked = false
        isHostelRequiredChecked = false
        
        let checkboxes = [physicalDisabilityCheckbox, sportsParticipationCheckbox,
                         transportRequiredCheckbox, hostelRequiredCheckbox]
        
        checkboxes.forEach { checkbox in
            updateCheckboxAppearance(button: checkbox!, isChecked: false)
        }
        
        // Hide dependent fields
        describeDisabilityTextField.isHidden = true
        sportsLevelTextField.isHidden = true
        transportView?.isHidden = true
        
        // Clear text fields
        describeDisabilityTextField.text = ""
        sportsLevelTextField.text = ""
        medicalConditionTextField.text = ""
        allergiesTextField.text = ""
        emergencyMedicationTextField.text = ""
        chronicDiseasesTextField.text = ""
        medicalNotesTextField.text = ""
        pickupAddressTextField.text = ""
        dropAddressTextField.text = ""
        
        notifyDelegate()
    }
    
    // MARK: - Populate with Data
    func populate(with data: MedicalSportsData?) {
        guard let data = data else {
            resetCheckboxes()
            return
        }
        
        // Set checkbox states
        isPhysicalDisabilityChecked = data.physicalDisability
        updateCheckboxAppearance(button: physicalDisabilityCheckbox, isChecked: data.physicalDisability)
        describeDisabilityTextField.isHidden = !data.physicalDisability
        
        isSportsParticipationChecked = data.sportsParticipation
        updateCheckboxAppearance(button: sportsParticipationCheckbox, isChecked: data.sportsParticipation)
        sportsLevelTextField.isHidden = !data.sportsParticipation
        
        isTransportRequiredChecked = data.transportRequired
        updateCheckboxAppearance(button: transportRequiredCheckbox, isChecked: data.transportRequired)
        transportView?.isHidden = !data.transportRequired
        
        isHostelRequiredChecked = data.hostelRequired
        updateCheckboxAppearance(button: hostelRequiredCheckbox, isChecked: data.hostelRequired)
        
        // Set text field values
        describeDisabilityTextField.text = data.disabilityDescription
        sportsLevelTextField.text = data.sportsLevel
        medicalConditionTextField.text = data.medicalCondition
        allergiesTextField.text = data.allergies
        emergencyMedicationTextField.text = data.emergencyMedication
        chronicDiseasesTextField.text = data.chronicDiseases
        medicalNotesTextField.text = data.medicalNotes
        pickupAddressTextField.text = data.pickupAddress
        dropAddressTextField.text = data.dropAddress
        
        notifyDelegate()
    }
    
    // MARK: - Get Data Method (for backward compatibility)
    func getMedicalSportsData() -> [String: Any] {
        return [
            "physical_disability": isPhysicalDisabilityChecked,
            "disability_description": describeDisabilityTextField.text ?? "",
            "sports_participation": isSportsParticipationChecked,
            "sports_level": sportsLevelTextField.text ?? "",
            "medical_condition": medicalConditionTextField.text ?? "",
            "allergies": allergiesTextField.text ?? "",
            "emergency_medication": emergencyMedicationTextField.text ?? "",
            "chronic_diseases": chronicDiseasesTextField.text ?? "",
            "medical_notes": medicalNotesTextField.text ?? "",
            "transport_required": isTransportRequiredChecked,
            "pickup_address": pickupAddressTextField.text ?? "",
            "drop_address": dropAddressTextField.text ?? "",
            "hostel_required": isHostelRequiredChecked
        ]
    }
    
    // MARK: - Configure with existing data (for backward compatibility)
    func configure(with data: [String: Any]) {
        if let physicalDisability = data["physical_disability"] as? Bool {
            isPhysicalDisabilityChecked = physicalDisability
            updateCheckboxAppearance(button: physicalDisabilityCheckbox, isChecked: physicalDisability)
            describeDisabilityTextField.isHidden = !physicalDisability
        }
        
        if let sportsParticipation = data["sports_participation"] as? Bool {
            isSportsParticipationChecked = sportsParticipation
            updateCheckboxAppearance(button: sportsParticipationCheckbox, isChecked: sportsParticipation)
            sportsLevelTextField.isHidden = !sportsParticipation
        }
        
        if let transportRequired = data["transport_required"] as? Bool {
            isTransportRequiredChecked = transportRequired
            updateCheckboxAppearance(button: transportRequiredCheckbox, isChecked: transportRequired)
            transportView?.isHidden = !transportRequired
        }
        
        if let hostelRequired = data["hostel_required"] as? Bool {
            isHostelRequiredChecked = hostelRequired
            updateCheckboxAppearance(button: hostelRequiredCheckbox, isChecked: hostelRequired)
        }
        
        describeDisabilityTextField.text = data["disability_description"] as? String ?? ""
        sportsLevelTextField.text = data["sports_level"] as? String ?? ""
        medicalConditionTextField.text = data["medical_condition"] as? String ?? ""
        allergiesTextField.text = data["allergies"] as? String ?? ""
        emergencyMedicationTextField.text = data["emergency_medication"] as? String ?? ""
        chronicDiseasesTextField.text = data["chronic_diseases"] as? String ?? ""
        medicalNotesTextField.text = data["medical_notes"] as? String ?? ""
        pickupAddressTextField.text = data["pickup_address"] as? String ?? ""
        dropAddressTextField.text = data["drop_address"] as? String ?? ""
        
        notifyDelegate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - TextField Connections Helper
    func setupTextFieldDelegates(delegate: UITextFieldDelegate) {
        let textFields = [describeDisabilityTextField, sportsLevelTextField,
                         medicalConditionTextField, allergiesTextField,
                         emergencyMedicationTextField, chronicDiseasesTextField,
                         medicalNotesTextField, pickupAddressTextField,
                         dropAddressTextField]
        
        textFields.forEach { textField in
            textField?.delegate = delegate
        }
    }
    
    // MARK: - PickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sportsLevels.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return sportsLevels[row]
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        sportsLevelTextField.text = sportsLevels[row]
        notifyDelegate()
    }
    
    // MARK: - Validation Method
    func validateFields() -> (isValid: Bool, errorMessage: String?) {
        var errors: [String] = []
        
        // If physical disability is checked, description is required
        if isPhysicalDisabilityChecked && (describeDisabilityTextField.text?.isEmpty ?? true) {
            errors.append("Disability description is required when physical disability is checked")
        }
        
        // If sports participation is checked, level is required
        if isSportsParticipationChecked && (sportsLevelTextField.text?.isEmpty ?? true) {
            errors.append("Sports level is required when sports participation is checked")
        }
        
        // If transport is required, pickup and drop addresses are required
        if isTransportRequiredChecked {
            if pickupAddressTextField.text?.isEmpty ?? true {
                errors.append("Pickup address is required when transport is required")
            }
            if dropAddressTextField.text?.isEmpty ?? true {
                errors.append("Drop address is required when transport is required")
            }
        }
        
        if errors.isEmpty {
            return (true, nil)
        } else {
            return (false, errors.joined(separator: "\n"))
        }
    }
}

//import UIKit
//
//class Medical_Sports_InformationCell: UITableViewCell,UIPickerViewDelegate,UIPickerViewDataSource {
//
//
//    // MARK: - IBOutlets for TextFields
//    @IBOutlet weak var describeDisabilityTextField: UITextField!
//    @IBOutlet weak var sportsLevelTextField: UITextField!
//    @IBOutlet weak var medicalConditionTextField: UITextField!
//    @IBOutlet weak var allergiesTextField: UITextField!
//    @IBOutlet weak var emergencyMedicationTextField: UITextField!
//    @IBOutlet weak var chronicDiseasesTextField: UITextField!
//    @IBOutlet weak var medicalNotesTextField: UITextField!
//    @IBOutlet weak var pickupAddressTextField: UITextField!
//    @IBOutlet weak var dropAddressTextField: UITextField!
//    
//    // MARK: - Checkbox Buttons
//    @IBOutlet weak var physicalDisabilityCheckbox: UIButton!
//    @IBOutlet weak var sportsParticipationCheckbox: UIButton!
//    @IBOutlet weak var transportRequiredCheckbox: UIButton!
//    @IBOutlet weak var hostelRequiredCheckbox: UIButton!
//    
//    // MARK: - Container Views for Address Fields
//    @IBOutlet weak var transportView: UIView! // Main container view
//    @IBOutlet weak var pickupAddressContainer: UIView! // Inside transportView
//    @IBOutlet weak var dropAddressContainer: UIView! // Inside transportView
//    
//    // MARK: - Variables
//    private var isPhysicalDisabilityChecked = false
//    private var isSportsParticipationChecked = false
//    private var isTransportRequiredChecked = false
//    private var isHostelRequiredChecked = false
//    
//    private let sportsLevels = ["School", "District", "State", "National", "International"]
//
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        // Initialize checkbox appearance
//        setupCheckboxAppearance()
//        setupSportsLevelPicker()
//        // Initially hide dependent fields
//        describeDisabilityTextField.isHidden = true
//        sportsLevelTextField.isHidden = true
//        transportView?.isHidden = true
//        
//        // Set up checkbox initial state (unchecked appearance)
//        updateCheckboxAppearance(button: physicalDisabilityCheckbox, isChecked: isPhysicalDisabilityChecked)
//        updateCheckboxAppearance(button: sportsParticipationCheckbox, isChecked: isSportsParticipationChecked)
//        updateCheckboxAppearance(button: transportRequiredCheckbox, isChecked: isTransportRequiredChecked)
//        updateCheckboxAppearance(button: hostelRequiredCheckbox, isChecked: isHostelRequiredChecked)
//    }
//    
//    private func setupSportsLevelPicker() {
//
//        let picker = UIPickerView()
//        picker.delegate = self
//        picker.dataSource = self
//
//        sportsLevelTextField.inputView = picker
//
//        let toolBar = UIToolbar()
//        toolBar.sizeToFit()
//
//        let done = UIBarButtonItem(title: "Done",
//                                   style: .done,
//                                   target: self,
//                                   action: #selector(doneSportsLevelPicker))
//
//        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//                                    target: nil,
//                                    action: nil)
//
//        toolBar.items = [space, done]
//        sportsLevelTextField.inputAccessoryView = toolBar
//    }
//    
//    @objc private func doneSportsLevelPicker() {
//        sportsLevelTextField.resignFirstResponder()
//    }
//
//    // MARK: - Setup Checkbox Appearance
//    private func setupCheckboxAppearance() {
//        let checkboxes = [physicalDisabilityCheckbox, sportsParticipationCheckbox,
//                         transportRequiredCheckbox, hostelRequiredCheckbox]
//        
//        checkboxes.forEach { checkbox in
//            checkbox?.layer.borderWidth = 2
//            checkbox?.layer.borderColor = UIColor.systemBlue.cgColor
//            checkbox?.layer.cornerRadius = 4
//            checkbox?.backgroundColor = .clear
//            checkbox?.setTitle("", for: .normal)
//            checkbox?.tintColor = .clear
//            checkbox?.imageView?.contentMode = .scaleAspectFit
//            checkbox?.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//            
//            // Ensure checkbox maintains its background
//            checkbox?.clipsToBounds = true
//        }
//    }
//    
//    // MARK: - Checkbox Actions
//    @IBAction func physicalDisabilityToggled(_ sender: UIButton) {
//        isPhysicalDisabilityChecked.toggle()
//        updateCheckboxAppearance(button: sender, isChecked: isPhysicalDisabilityChecked)
//        describeDisabilityTextField.isHidden = !isPhysicalDisabilityChecked
//        
//        // Animate the appearance
//        UIView.animate(withDuration: 0.3) {
//            self.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func sportsParticipationToggled(_ sender: UIButton) {
//        isSportsParticipationChecked.toggle()
//        updateCheckboxAppearance(button: sender, isChecked: isSportsParticipationChecked)
//        sportsLevelTextField.isHidden = !isSportsParticipationChecked
//        
//        // Animate the appearance
//        UIView.animate(withDuration: 0.3) {
//            self.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func transportRequiredToggled(_ sender: UIButton) {
//        isTransportRequiredChecked.toggle()
//        updateCheckboxAppearance(button: sender, isChecked: isTransportRequiredChecked)
//        
//        // Show/hide the entire transport view (which contains both address containers)
//        transportView?.isHidden = !isTransportRequiredChecked
//        
//        // Animate the appearance
//        UIView.animate(withDuration: 0.3) {
//            self.layoutIfNeeded()
//        }
//    }
//    
//    @IBAction func hostelRequiredToggled(_ sender: UIButton) {
//        isHostelRequiredChecked.toggle()
//        updateCheckboxAppearance(button: sender, isChecked: isHostelRequiredChecked)
//    }
//    
//    // MARK: - Update Checkbox UI
//    private func updateCheckboxAppearance(button: UIButton, isChecked: Bool) {
//        UIView.animate(withDuration: 0.2) {
//            if isChecked {
//                // When checked: Show checkmark with blue color
//                let checkmarkImage = UIImage(systemName: "checkmark")?
//                    .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
//                button.setImage(checkmarkImage, for: .normal)
//                button.tintColor = .systemBlue
//                button.backgroundColor = .clear
//            } else {
//                // When unchecked: Hide checkmark
//                button.setImage(nil, for: .normal)
//                button.backgroundColor = .clear
//            }
//        }
//    }
//    
//    // MARK: - Reset/Configure Methods
//    func resetCheckboxes() {
//        isPhysicalDisabilityChecked = false
//        isSportsParticipationChecked = false
//        isTransportRequiredChecked = false
//        isHostelRequiredChecked = false
//        
//        let checkboxes = [physicalDisabilityCheckbox, sportsParticipationCheckbox,
//                         transportRequiredCheckbox, hostelRequiredCheckbox]
//        
//        checkboxes.forEach { checkbox in
//            updateCheckboxAppearance(button: checkbox!, isChecked: false)
//        }
//        
//        // Hide dependent fields
//        describeDisabilityTextField.isHidden = true
//        sportsLevelTextField.isHidden = true
//        transportView?.isHidden = true
//        
//        // Clear text fields
//        describeDisabilityTextField.text = ""
//        sportsLevelTextField.text = ""
//        medicalConditionTextField.text = ""
//        allergiesTextField.text = ""
//        emergencyMedicationTextField.text = ""
//        chronicDiseasesTextField.text = ""
//        medicalNotesTextField.text = ""
//        pickupAddressTextField.text = ""
//        dropAddressTextField.text = ""
//    }
//    
//    // MARK: - Get Data Method
//    func getMedicalSportsData() -> [String: Any] {
//        return [
//            "physical_disability": isPhysicalDisabilityChecked,
//            "disability_description": describeDisabilityTextField.text ?? "",
//            "sports_participation": isSportsParticipationChecked,
//            "sports_level": sportsLevelTextField.text ?? "",
//            "medical_condition": medicalConditionTextField.text ?? "",
//            "allergies": allergiesTextField.text ?? "",
//            "emergency_medication": emergencyMedicationTextField.text ?? "",
//            "chronic_diseases": chronicDiseasesTextField.text ?? "",
//            "medical_notes": medicalNotesTextField.text ?? "",
//            "transport_required": isTransportRequiredChecked,
//            "pickup_address": pickupAddressTextField.text ?? "",
//            "drop_address": dropAddressTextField.text ?? "",
//            "hostel_required": isHostelRequiredChecked
//        ]
//    }
//    
//    // MARK: - Configure with existing data
//    func configure(with data: [String: Any]) {
//        if let physicalDisability = data["physical_disability"] as? Bool {
//            isPhysicalDisabilityChecked = physicalDisability
//            updateCheckboxAppearance(button: physicalDisabilityCheckbox, isChecked: physicalDisability)
//            describeDisabilityTextField.isHidden = !physicalDisability
//        }
//        
//        if let sportsParticipation = data["sports_participation"] as? Bool {
//            isSportsParticipationChecked = sportsParticipation
//            updateCheckboxAppearance(button: sportsParticipationCheckbox, isChecked: sportsParticipation)
//            sportsLevelTextField.isHidden = !sportsParticipation
//        }
//        
//        if let transportRequired = data["transport_required"] as? Bool {
//            isTransportRequiredChecked = transportRequired
//            updateCheckboxAppearance(button: transportRequiredCheckbox, isChecked: transportRequired)
//            transportView?.isHidden = !transportRequired
//        }
//        
//        if let hostelRequired = data["hostel_required"] as? Bool {
//            isHostelRequiredChecked = hostelRequired
//            updateCheckboxAppearance(button: hostelRequiredCheckbox, isChecked: hostelRequired)
//        }
//        
//        describeDisabilityTextField.text = data["disability_description"] as? String ?? ""
//        sportsLevelTextField.text = data["sports_level"] as? String ?? ""
//        medicalConditionTextField.text = data["medical_condition"] as? String ?? ""
//        allergiesTextField.text = data["allergies"] as? String ?? ""
//        emergencyMedicationTextField.text = data["emergency_medication"] as? String ?? ""
//        chronicDiseasesTextField.text = data["chronic_diseases"] as? String ?? ""
//        medicalNotesTextField.text = data["medical_notes"] as? String ?? ""
//        pickupAddressTextField.text = data["pickup_address"] as? String ?? ""
//        dropAddressTextField.text = data["drop_address"] as? String ?? ""
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
//    
//    // MARK: - TextField Connections Helper
//    func setupTextFieldDelegates(delegate: UITextFieldDelegate) {
//        let textFields = [describeDisabilityTextField, sportsLevelTextField,
//                         medicalConditionTextField, allergiesTextField,
//                         emergencyMedicationTextField, chronicDiseasesTextField,
//                         medicalNotesTextField, pickupAddressTextField,
//                         dropAddressTextField]
//        
//        textFields.forEach { textField in
//            textField?.delegate = delegate
//        }
//    }
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return sportsLevels.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    titleForRow row: Int,
//                    forComponent component: Int) -> String? {
//        return sportsLevels[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    didSelectRow row: Int,
//                    inComponent component: Int) {
//
//        sportsLevelTextField.text = sportsLevels[row]
//    }
//
//}
