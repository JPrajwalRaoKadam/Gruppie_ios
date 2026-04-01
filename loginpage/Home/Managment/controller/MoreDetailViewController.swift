
import UIKit

class MoreDetailViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var moreDetailsTableView: UITableView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var number: UILabel!

    var userId: Int?
    var token: String?
    var member: ManagementMember?
    var isEditingEnabled = false

    var selectedAadharURL: URL?
    var aadharIndexPath: IndexPath?
    var editableManagement = EditableManagement()
    private var selectedCell: BasicInfoTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerCells()
        preloadEditableData()
        enableKeyboardDismissOnTap()
    }

    private func setupUI() {
    editButton.layer.cornerRadius = 10
    addUserButton.layer.cornerRadius = 10
    customView.layer.cornerRadius = 10
    backButton.layer.cornerRadius = backButton.frame.height / 2

    moreDetailsTableView.layer.cornerRadius = 10
    moreDetailsTableView.clipsToBounds = true

    moreDetailsTableView.delegate = self
    moreDetailsTableView.dataSource = self
    moreDetailsTableView.separatorStyle = .none

    moreDetailsTableView.rowHeight = UITableView.automaticDimension
    moreDetailsTableView.estimatedRowHeight = 250
}

    
    private func registerCells() {

        moreDetailsTableView.register(
            UINib(nibName: "BasicInfoTableViewCell", bundle: nil),
            forCellReuseIdentifier: "BasicInfoCell"
        )

        moreDetailsTableView.register(
            UINib(nibName: "Education2TableViewCell", bundle: nil),
            forCellReuseIdentifier: "Education2TableViewCell"
        )

        moreDetailsTableView.register(
            UINib(nibName: "AcoountInfo2TableViewCell", bundle: nil),
            forCellReuseIdentifier: "AcoountInfo2TableViewCell"
        )

        moreDetailsTableView.register(
            UINib(nibName: "AchievementsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "AchievementsTableViewCell"
        )

        moreDetailsTableView.register(
            UINib(nibName: "bankDetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "bankDetailsTableViewCell"
        )

        moreDetailsTableView.register(
            UINib(nibName: "additionalAchievementTableViewCell", bundle: nil),
            forCellReuseIdentifier: "additionalAchievementTableViewCell"
        )
    }
    
    private func openAadharFilePicker() {
           let picker = UIDocumentPickerViewController(
               forOpeningContentTypes: [.pdf, .image],
               asCopy: true
           )
           picker.delegate = self
           picker.allowsMultipleSelection = false
           present(picker, animated: true)
       }

       func documentPicker(_ controller: UIDocumentPickerViewController,
                           didPickDocumentsAt urls: [URL]) {

           guard let url = urls.first else { return }
           selectedAadharURL = url

           print("✅  selected:", url.lastPathComponent)

           if let indexPath = aadharIndexPath,
              let cell = moreDetailsTableView.cellForRow(at: indexPath)
                   as? BasicInfoTableViewCell {
               cell.showAadharSelected()
           }
       }

       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           print("⚠️ Aadhar picker cancelled")
       }

    private func openGallery() {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            picker.dismiss(animated: true)

            guard let selectedImage = info[.editedImage] as? UIImage ??
                                      info[.originalImage] as? UIImage else { return }

        selectedCell?.ImageView.image = selectedImage
        selectedCell?.ImageView.contentMode = .scaleAspectFill
        selectedCell?.ImageView.clipsToBounds = true

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

    private func preloadEditableData() {
        guard let member = member else { return }

        editableManagement.fullName = member.fullName
        editableManagement.mobileNumber = member.mobileNumber
        editableManagement.dateOfBirth = member.dateOfBirth ?? ""
        editableManagement.email = member.email ?? ""
        editableManagement.designation = member.professionalDetails?.designation ?? ""
    }
    @IBAction func addUserButtonTapped(_ sender: UIButton) {

        isEditingEnabled = true
        moreDetailsTableView.reloadData()

        guard !editableManagement.fullName.isEmpty,
              !editableManagement.mobileNumber.isEmpty else {

            showError("Name and Phone number are required")
            return
        }

        print("👤 Name:", editableManagement.fullName)
        print("📞 Phone:", editableManagement.mobileNumber)

        callAddManagementAPI()
    }
    func callAddManagementAPI() {

        guard let token = token else {
            showError("Token missing")
            return
        }

        let requestBody = AddManagementRequest(
            fullName: editableManagement.fullName,
            dateOfBirth: editableManagement.dateOfBirth,
            mobileNumber: editableManagement.mobileNumber
        )

        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        print("🚀 Add User Request")
        print("Name:", editableManagement.fullName)
        print("Phone:", editableManagement.mobileNumber)
        print("DOB:", editableManagement.dateOfBirth)

        APIManager.shared.request(
            endpoint: "management",
            method: .post,
            body: requestBody,
            headers: headers
        ) { (result: Result<AddManagementResponse, APIManager.APIError>) in

            DispatchQueue.main.async {
                switch result {

                case .success(let response):
                    if response.success {
                        self.showAlert(
                            message: response.message ?? "User added successfully",
                            success: true
                        )
                    } else {
                        self.showError(response.message ?? "Something went wrong")
                    }

                case .failure(let error):
                    print("❌ API Error:", error)
                    self.showError("Failed to add user")
                }
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {

        if isEditingEnabled {
            callEditManagementAPI()
            return
        }

        isEditingEnabled = true
        editButton.setTitle("Save", for: .normal)
        moreDetailsTableView.reloadData()
    }

    
    func callEditManagementAPI() {
        
        guard let token = SessionManager.useRoleToken,
              let userId = userId else {
            showError("Token or User ID missing")
            return
        }

        let url = URL(string: "https://dev.gruppie.in/api/v1/management/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "accept")

        var body = Data()

        func appendIfPresent(_ name: String, value: String?) {
            guard let value = value, !value.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            body.appendFormField(name, value: value, boundary: boundary)
        }

        appendIfPresent("fullName", value: editableManagement.fullName)
        appendIfPresent("gender", value: editableManagement.gender)
        appendIfPresent("dateOfBirth", value: editableManagement.dateOfBirth)
        appendIfPresent("mobileNumber", value: editableManagement.mobileNumber)
        appendIfPresent("alternateMobileNumber", value: editableManagement.alternativeNumber)
        appendIfPresent("email", value: editableManagement.email)
        appendIfPresent("aadhaarNumber", value: editableManagement.aadharNumber)
        appendIfPresent("address", value: editableManagement.address)
        appendIfPresent("city", value: editableManagement.city)
        appendIfPresent("state", value: editableManagement.state)
        appendIfPresent("country", value: editableManagement.country)
        appendIfPresent("pinCode", value: editableManagement.pincode)
        appendIfPresent("roleId", value: editableManagement.role)
        appendIfPresent("designation", value: editableManagement.designation)
        appendIfPresent("organizationName", value: editableManagement.organizationName)
        appendIfPresent("totalExperienceYears", value: editableManagement.totalExperience)
        appendIfPresent("industry", value: editableManagement.industry)
        appendIfPresent("workAddress", value: editableManagement.workAddress)
        appendIfPresent("workEmail", value: editableManagement.workEmail)
        appendIfPresent("workPhoneNumber", value: editableManagement.workPhoneNo)

        appendIfPresent("qualification", value: editableManagement.Qualification)
        appendIfPresent("universityOrBoard", value: editableManagement.Univesity)
        appendIfPresent("yearOfCompletion", value: editableManagement.yearOfCompletion)

        appendIfPresent("accountHolderName", value: editableManagement.accountHolderName)
        appendIfPresent("bankName", value: editableManagement.bankName)
        appendIfPresent("accountNumber", value: editableManagement.accountNumber)
        appendIfPresent("branchName", value: editableManagement.branchName)
        appendIfPresent("ifscCode", value: editableManagement.IFSCCode)
        appendIfPresent("panNumber", value: editableManagement.PANNumber)

        appendIfPresent("achievementId1", value: "631")
        appendIfPresent("title1", value: editableManagement.achievementTitle1)
        appendIfPresent("description1", value: editableManagement.achievementDescription1)
        
        appendIfPresent("achievementId2", value: "632")
        appendIfPresent("title2", value: editableManagement.achievementTitle2)
        appendIfPresent("description2", value: editableManagement.achievementDescription2)

        appendIfPresent("achievementId3", value: "633")
        appendIfPresent("title3", value: editableManagement.achievementTitle3)
        appendIfPresent("description3", value: editableManagement.achievementDescription3)

        appendIfPresent("attachmentId1", value: "631")
        appendIfPresent("attachmentType1", value: editableManagement.attachment1)
        appendIfPresent("attachmentId2", value: "632")
        appendIfPresent("attachmentType2", value: editableManagement.attachment2)
        appendIfPresent("attachmentId3", value: "633")
        appendIfPresent("attachmentType3", value: editableManagement.attachment3)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("📦 Request Body:\n", bodyString)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showError(error.localizedDescription)

                    return
                }

                if let http = response as? HTTPURLResponse {
                    print("✅ Status Code:", http.statusCode)
                }

                if let data = data,
                   let result = try? JSONDecoder().decode(EditManagementResponse.self, from: data) {

                    if result.success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showError(result.message ?? "Update failed")
                    }
                } else {
                    print("⚠️ Raw response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
                }
            }
        }.resume()
    }

  private func saveUpdatedData() {
        print("🔵 saveUpdatedData called")
        print("🔵 Current editableManagement values:")
        print("  fullName: '\(editableManagement.fullName)'")
        print("  mobileNumber: '\(editableManagement.mobileNumber)'")
        
        guard !editableManagement.fullName.isEmpty,
              !editableManagement.mobileNumber.isEmpty else {
            print("🔴 VALIDATION FAILED:")
            print("  fullName is empty: \(editableManagement.fullName.isEmpty)")
            print("  mobileNumber is empty: \(editableManagement.mobileNumber.isEmpty)")
            showError("Name and Mobile are required")
            return
        }
        
        print("✅ Validation passed, calling API")
        callEditManagementAPI()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String, success: Bool) {
        let alert = UIAlertController(
            title: success ? "Success" : "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            ) { _ in
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        )

        present(alert, animated: true)
    }

    
    @objc private func achievementChanged(_ textField: UITextField) {
        guard let cell = textField.superview?.superview as? AchievementsTableViewCell else {
            return
        }

        editableManagement.achievementTitle1 = cell.Title1.text ?? ""
        editableManagement.achievementTitle2 = cell.Title2.text ?? ""
        editableManagement.achievementTitle3 = cell.Title3.text ?? ""
        editableManagement.achievementDescription1 = cell.Description1.text ?? ""
        editableManagement.achievementDescription2 = cell.Description2.text ?? ""
        editableManagement.achievementDescription3 = cell.Description3.text ?? ""
    }
    @objc private func additionalAchievementChanged(_ textField: UITextField) {
        guard let cell = textField.superview?.superview as? additionalAchievementTableViewCell else {
            return
        }

        editableManagement.attachment1 = cell.attachment1.text ?? ""
        editableManagement.attachment2 = cell.attachment2.text ?? ""
        editableManagement.attachment3 = cell.attachment3.text ?? ""
    }



}

extension MoreDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    @objc private func bankDetailsChanged(_ textField: UITextField) {
        guard let cell = textField.superview?.superview as? bankDetailsTableViewCell else { return }

        editableManagement.accountHolderName = cell.accountHolderName.text ?? ""
        editableManagement.bankName = cell.bankName.text ?? ""
        editableManagement.branchName = cell.branchName.text ?? ""
        editableManagement.accountNumber = cell.accountNumber.text ?? ""
        editableManagement.IFSCCode = cell.IFSCCode.text ?? ""
        editableManagement.PANNumber = cell.PANNumber.text ?? ""
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BasicInfoCell",
                for: indexPath
            ) as! BasicInfoTableViewCell

            if let member = member {
                cell.populate(with: editableManagement,
                              isEditingEnabled: isEditingEnabled)
            }

            // MARK: - Aadhar button tap callback
            cell.onUploadAadharTapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            
            // Image Upload
            cell.onUploadImageTapped = { [weak self, weak cell] in
                guard let self = self, let cell = cell else { return }
                self.selectedCell = cell
                self.openGallery()
                    
            }

            // MARK: - Sync cell data back to VC
            cell.onDataChange = { [weak self] data in
                guard let self = self else { return }

                self.editableManagement.fullName = data.fullName
                self.editableManagement.gender = data.gender
                self.editableManagement.dateOfBirth = data.dateOfBirth
                self.editableManagement.mobileNumber = data.mobileNumber
                self.editableManagement.alternativeNumber = data.alternativeNumber
                self.editableManagement.email = data.email
                self.editableManagement.aadharNumber = data.aadharNumber
                self.editableManagement.address = data.address
                self.editableManagement.city = data.city
                self.editableManagement.state = data.state
                self.editableManagement.country = data.country
                self.editableManagement.pincode = data.pincode
                self.editableManagement.role = data.role
            }

            cell.selectionStyle = .none
            return cell

        // MARK: - Education
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Education2TableViewCell",
                for: indexPath
            ) as! Education2TableViewCell

            cell.populate(with: editableManagement,
                          isEditingEnabled: isEditingEnabled)
            
            cell.onUploadCertificateTapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }

            cell.onEducationChange = { [weak self] data in
                guard let self = self else { return }

                self.editableManagement.Qualification = data.Qualification
                self.editableManagement.Univesity = data.Univesity
                self.editableManagement.yearOfCompletion = data.yearOfCompletion
            }

            cell.selectionStyle = .none
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AcoountInfo2TableViewCell",
                for: indexPath
            ) as! AcoountInfo2TableViewCell

            cell.populate(with: editableManagement,
                          isEditingEnabled: isEditingEnabled)
            
            cell.onUploadExperianceTapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }

            cell.onAccountChange = { [weak self] data in
                guard let self = self else { return }

                self.editableManagement.designation = data.designation
                self.editableManagement.organizationName = data.organizationName
                self.editableManagement.totalExperience = data.totalExperience
                self.editableManagement.industry = data.industry
                self.editableManagement.workEmail = data.workEmail
                self.editableManagement.workPhoneNo = data.workPhoneNo
            }

            cell.selectionStyle = .none
            return cell
            
        case 3:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "AchievementsTableViewCell",
                    for: indexPath
                ) as! AchievementsTableViewCell
            
            cell.onUploadCertificate1Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            cell.onUploadCertificate2Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            cell.onUploadCertificate3Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }

                // populate existing values
                cell.Title1.text = editableManagement.achievementTitle1
                cell.Title2.text = editableManagement.achievementTitle2
                cell.Title3.text = editableManagement.achievementTitle3
                cell.Description1.text = editableManagement.achievementDescription1
                cell.Description2.text = editableManagement.achievementDescription2
                cell.Description3.text = editableManagement.achievementDescription3

                let isEditable = isEditingEnabled
                [cell.Title1, cell.Title2, cell.Title3,
                 cell.Description1, cell.Description2, cell.Description3]
                    .forEach { $0?.isUserInteractionEnabled = isEditable }

                // save back to model
                cell.Title1.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)
                cell.Title2.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)
                cell.Title3.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)
                cell.Description1.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)
                cell.Description2.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)
                cell.Description3.addTarget(self, action: #selector(achievementChanged(_:)), for: .editingChanged)

                cell.selectionStyle = .none
                return cell
            
            case 4:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "bankDetailsTableViewCell",
                    for: indexPath
                ) as! bankDetailsTableViewCell
            
            cell.onUploadpassBookTapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            cell.onUploadotherDocumentTapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }

                // Populate existing data
                cell.accountHolderName.text = editableManagement.accountHolderName
                cell.bankName.text = editableManagement.bankName
                cell.branchName.text = editableManagement.branchName
                cell.accountNumber.text = editableManagement.accountNumber
                cell.IFSCCode.text = editableManagement.IFSCCode
                cell.PANNumber.text = editableManagement.PANNumber

                // Enable/disable editing
                let isEditable = isEditingEnabled
                [cell.accountHolderName, cell.bankName, cell.branchName,
                 cell.accountNumber, cell.IFSCCode, cell.PANNumber]
                    .forEach { $0?.isUserInteractionEnabled = isEditable }

                // Save changes back to model
                cell.accountHolderName.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)
                cell.bankName.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)
                cell.branchName.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)
                cell.accountNumber.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)
                cell.IFSCCode.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)
                cell.PANNumber.addTarget(self, action: #selector(bankDetailsChanged(_:)), for: .editingChanged)

                cell.selectionStyle = .none
                return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "additionalAchievementTableViewCell",
                for: indexPath
            ) as! additionalAchievementTableViewCell
            
            cell.onUploadCertificate1Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            cell.onUploadCertificate2Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }
            cell.onUploadCertificate3Tapped = { [weak self] in
                guard let self = self else { return }
                self.aadharIndexPath = indexPath
                self.openAadharFilePicker()
            }

            cell.attachment1.text = editableManagement.attachment1
            cell.attachment2.text = editableManagement.attachment2
            cell.attachment3.text = editableManagement.attachment3

            let isEditable = isEditingEnabled
            [cell.attachment1, cell.attachment2, cell.attachment3]
                .forEach { $0?.isUserInteractionEnabled = isEditable }

            cell.attachment1.addTarget(self, action: #selector(additionalAchievementChanged(_:)), for: .editingChanged)
            cell.attachment2.addTarget(self, action: #selector(additionalAchievementChanged(_:)), for: .editingChanged)
            cell.attachment3.addTarget(self, action: #selector(additionalAchievementChanged(_:)), for: .editingChanged)

            cell.selectionStyle = .none
            return cell




        default:
            return UITableViewCell()
        }
    }

}

extension Data {
    mutating func appendFormField(
        _ name: String,
        value: String,
        boundary: String
    ) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
}
extension Data {
    mutating func appendIfNotEmpty(
        _ name: String,
        value: String,
        boundary: String
    ) {
        guard !value.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        appendFormField(name, value: value, boundary: boundary)
    }
}
