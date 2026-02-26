import UIKit

// MARK: - Delegate Protocols (Keep these at the top of the file)
protocol ParentsInformationCellDelegate: AnyObject {
    func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool)
    func parentsInfoDidUpdate(_ data: ParentsInfoData)
}

protocol BasicInfoCellDelegate: AnyObject {
    func basicInfoDidUpdate(_ data: BasicInfoData)
}

protocol MedicalSportsCellDelegate: AnyObject {
    func medicalSportsInfoDidUpdate(_ data: MedicalSportsData)
}

protocol AdmissionInfoCellDelegate: AnyObject {
    func admissionInfoDidUpdate(_ data: AdmissionInfoData)
}

protocol AddressInfoCellDelegate: AnyObject {
    func addressInfoDidUpdate(_ data: AddressInfoData)
}

protocol GuardianInfoCellDelegate: AnyObject {
    func guardianInfoDidUpdate(_ data: GuardianInfoData)
}

protocol DocumentAttachmentCellDelegate: AnyObject {
    func documentDidUpload(documentName: String, document: Any, documentIndex: Int)
    func getAllDocuments() -> DocumentData
}

// MARK: - Main ViewController
class AddStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var TableView: UITableView!
    var classId: String = ""
    var newStudent: Student?
    var newStudentDetails: [StudentData] = []
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Data Storage
    private var basicInfoData = BasicInfoData()
    private var admissionInfoData = AdmissionInfoData()
    private var addressInfoData = AddressInfoData()
    private var parentsInfoData = ParentsInfoData()
    private var guardianInfoData = GuardianInfoData()
    private var medicalSportsData = MedicalSportsData()
    private var documentsData = DocumentData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("classId: \(classId)")
        // Register cells
        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil),
                           forCellReuseIdentifier: "BasicInfoCell")
        TableView.register(UINib(nibName: "Medical_Sports_InformationCell", bundle: nil),
                           forCellReuseIdentifier: "Medical_Sports_InformationCell")
        TableView.register(UINib(nibName: "AdmissionInformationCell", bundle: nil),
                           forCellReuseIdentifier: "AdmissionInformationCell")
        TableView.register(UINib(nibName: "AddressInformationCell", bundle: nil),
                           forCellReuseIdentifier: "AddressInformationCell")
        TableView.register(UINib(nibName: "ParentsInformationCell", bundle: nil),
                           forCellReuseIdentifier: "ParentsInformationCell")
        TableView.register(UINib(nibName: "GuardianInformationCell", bundle: nil),
                           forCellReuseIdentifier: "GuardianInformationCell")
        TableView.register(UINib(nibName: "DocumentAttachmentCell", bundle: nil),
                           forCellReuseIdentifier: "DocumentAttachmentCell")

        TableView.delegate = self
        TableView.dataSource = self

        TableView.layer.cornerRadius = 10
        TableView.layer.masksToBounds = true
        TableView.layer.borderWidth = 1
        TableView.layer.shadowColor = UIColor.black.cgColor
        TableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        TableView.layer.shadowOpacity = 0.3
        TableView.layer.shadowRadius = 4
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        TableView.layer.masksToBounds = false
        enableKeyboardDismissOnTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    enum AddStudentRow: Int, CaseIterable {
        case basicInfo
        case medicalSports
        case admission
        case address
        case parents
        case guardian
        case documents
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddStudentRow.allCases.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = AddStudentRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        switch row {
        case .basicInfo:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BasicInfoCell",
                for: indexPath
            ) as! BasicInfoCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .medicalSports:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Medical_Sports_InformationCell",
                for: indexPath
            ) as! Medical_Sports_InformationCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .admission:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AdmissionInformationCell",
                for: indexPath
            ) as! AdmissionInformationCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .address:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddressInformationCell",
                for: indexPath
            ) as! AddressInformationCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .parents:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ParentsInformationCell",
                for: indexPath
            ) as! ParentsInformationCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .guardian:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "GuardianInformationCell",
                for: indexPath
            ) as! GuardianInformationCell
            cell.delegate = self
            cell.populate(with: nil)
            return cell
            
        case .documents:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DocumentAttachmentCell",
                for: indexPath
            ) as! DocumentAttachmentCell
            cell.setParentViewController(self)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = AddStudentRow(rawValue: indexPath.row) else {
            return 100
        }
        
        switch row {
        case .basicInfo: return 650
        case .medicalSports: return 500
        case .admission: return 120
        case .address: return 300
        case .parents: return 550
        case .guardian: return 350
        case .documents: return 400
        }
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        registerStudent()
    }
    
    // MARK: - Registration API Call
    private func registerStudent() {
        guard validateAllData() else {
            return
        }
        
        showLoadingIndicator()
        
        // Prepare the request parameters
        let parameters = prepareRegistrationRequest()
        
        // Get token from SessionManager
        guard let token = SessionManager.useRoleToken else {
            hideLoadingIndicator()
            showAlert(title: "Error", message: "Authentication token not found")
            return
        }
        
        // Prepare headers
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
      APIManager.shared.request(
            endpoint: "student/full-registration",
            method: .post,
            body: parameters,
            headers: headers
        ) { [weak self] (result: Result<StudentRegistrationResponse, APIManager.APIError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }  // Add this line
                self.hideLoadingIndicator()  // Now self is not optional
                
                switch result {
                case .success(let response):
                    print("✅ Registration Response: \(response)")
                    
                    if response.success {
                        self.showSuccessAlert(message: response.message)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self.showAlert(title: "Error", message: response.message)
                    }
                    
                case .failure(let error):
                    print("❌ Registration Error: \(error)")
                    self.handleAPIError(error)
                }
            }
        }
    }
    private func formatDateForAPI(_ dateString: String) -> String {
        // Handle empty or "N/A" strings
        if dateString.isEmpty || dateString.lowercased() == "n/a" {
            return ""
        }
        
        // Try different date formats - prioritize dd-MM-yyyy
        let dateFormats = [
            "dd-MM-yyyy",  // First try with hyphens
            "dd/MM/yyyy",
            "yyyy/MM/dd",
            "yyyy-MM-dd",
            "MM/dd/yyyy"
        ]
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"  // API expects this format
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in dateFormats {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = format
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = inputFormatter.date(from: dateString) {
                return outputFormatter.string(from: date)
            }
        }
        
        // Return empty string if can't parse
        return ""
    }
    
//    private func prepareRegistrationRequest() -> StudentRegistrationRequest {
//        
//        let basic = basicInfoData
//        let medical = medicalSportsData
//        let admission = admissionInfoData
//        let address = addressInfoData
//        let parents = parentsInfoData
//        let guardian = guardianInfoData
//        
//        // Format dates for API
//        let dateOfBirthFormatted = formatDateForAPI(basic.dateOfBirth)
//        let dateOfAdmissionFormatted = admission.dateOfAdmission.isEmpty ?
//            formatDateForAPI(Date().toString(format: "dd/MM/yyyy")) :
//            formatDateForAPI(admission.dateOfAdmission)
//       
//         // Helper function to return empty string instead of "N/A"
//         func optionalValue(_ value: String) -> String {
//             return value.isEmpty ? "" : value
//         }
//         
//         let request = StudentRegistrationRequest(
//           // MARK: Basic Info
//           classId: Int(classId) ?? 0,
//           firstName: basic.firstName,
//           middleName: optionalValue(basic.middleName),  // Use empty string instead of "N/A"
//           lastName: optionalValue(basic.lastName),      // Use empty string instead of "N/A"
//           gender: basic.gender,
//           dateOfBirth: dateOfBirthFormatted,
//           placeOfBirth: optionalValue(basic.placeOfBirth),
//           motherTongue: optionalValue(basic.motherTongue),
//           email: optionalValue(basic.email),
//           bhagyalakshmiNo: optionalValue(basic.bhagyalakshmiNo),
//           studentMobileNumber: basic.studentMobileNumber.isEmpty ? "" : basic.studentMobileNumber,
//           fatherMobileNumber: optionalValue(parents.fatherMobileNumber),
//           motherMobileNumber: optionalValue(parents.motherMobileNumber),
//           nationality: optionalValue(basic.nationality),
//           religion: optionalValue(basic.religion),
//           caste: optionalValue(basic.caste),
//           aadhaarNumber: optionalValue(basic.aadhaarNumber),
//           bloodGroup: optionalValue(basic.bloodGroup),
//           
//           // MARK: Medical / Sports
//           physicalDisability: medical.physicalDisability,
//           disabilityDescription: optionalValue(medical.disabilityDescription),
//           sportsParticipation: medical.sportsParticipation,
//           sportsLevel: optionalValue(medical.sportsLevel),
//           medicalCondition: optionalValue(medical.medicalCondition),
//           emergencyMedication: optionalValue(medical.emergencyMedication),
//           chronicDiseases: optionalValue(medical.chronicDiseases),
//           allergies: optionalValue(medical.allergies),
//           medicalNotes: optionalValue(medical.medicalNotes),
//           
//           // MARK: Admission
//           omrNumber: optionalValue(admission.omrNumber),
//           dateOfAdmission: dateOfAdmissionFormatted,
//           eligible: true,
//           transportRequired: medical.transportRequired,
//           hostelRequired: medical.hostelRequired,
//           pickupAddress: optionalValue(address.permanentArea),
//           dropAddress: optionalValue(address.permanentArea),
//           scholarshipStatus: optionalValue(basic.feeCategory),
//            
//            // MARK: Permanent Address
//            permanentPinCode: optionalValue(address.permanentPinCode),
//            permanentState: optionalValue(address.permanentState),
//            permanentDistrict: optionalValue(address.permanentDistrict),
//            permanentArea: optionalValue(address.permanentArea),
//            permanentTaluk: optionalValue(address.permanentTaluk),
//            
//            // MARK: Correspondence Address
//            correspondenceArea: address.useSameAsPermanent ? optionalValue(address.permanentArea) : optionalValue(address.correspondenceArea),
//            correspondenceTaluk: address.useSameAsPermanent ? optionalValue(address.permanentTaluk) : optionalValue(address.correspondenceTaluk),
//            correspondenceDistrict: address.useSameAsPermanent ? optionalValue(address.permanentDistrict) : optionalValue(address.correspondenceDistrict),
//            correspondenceState: address.useSameAsPermanent ? optionalValue(address.permanentState) : optionalValue(address.correspondenceState),
//            correspondencePinCode: address.useSameAsPermanent ? optionalValue(address.permanentPinCode) : optionalValue(address.correspondencePinCode),
//            
//            // MARK: Father
//            fatherName: optionalValue(parents.fatherName),
//            fatherAadhaarNumber: optionalValue(parents.fatherAadhaarNumber),
//            fatherOccupation: optionalValue(parents.fatherOccupation),
//            fatherAnnualIncome: optionalValue(parents.fatherAnnualIncome),
//            fatherIsEmergencyContact: parents.fatherIsEmergencyContact,
//            fatherEducation: optionalValue(parents.fatherEducation),
//            
//            // MARK: Mother
//            motherName: optionalValue(parents.motherName),
//            motherAadhaarNumber: optionalValue(parents.motherAadhaarNumber),
//            motherOccupation: optionalValue(parents.motherOccupation),
//            motherAnnualIncome: optionalValue(parents.motherAnnualIncome),
//            motherIsEmergencyContact: parents.motherIsEmergencyContact,
//            motherEducation: optionalValue(parents.motherEducation),
//            
//            // MARK: Guardian
//            guardianRelation: optionalValue(guardian.guardianRelation),
//            guardianName: optionalValue(guardian.guardianName),
//            guardianPhoneNumber: optionalValue(guardian.guardianPhoneNumber),
//            guardianAadhaarNumber: optionalValue(guardian.guardianAadhaarNumber),
//            guardianOccupation: optionalValue(guardian.guardianOccupation),
//            guardianAnnualIncome: optionalValue(guardian.guardianAnnualIncome),
//            guardianIsEmergencyContact: guardian.guardianIsEmergencyContact,
//            guardianEducation: optionalValue(guardian.guardianEducation),
//            
//            // MARK: Previous Institution - 1 (empty strings)
//            previousInstitution1: "",
//            previousClass1: "",
//            mediumOfInstitute1: "",
//            board1: "",
//            registrationNumber1: "",
//            yearOfPassing1: "",
//            maxMarks1: "",
//            marksObtained1: "",
//            percentage1: "",
//            
//            // MARK: Previous Institution - 2 (empty strings)
//            previousInstitution2: "",
//            previousClass2: "",
//            mediumOfInstitute2: "",
//            board2: "",
//            registrationNumber2: "",
//            yearOfPassing2: "",
//            maxMarks2: "",
//            marksObtained2: "",
//            percentage2: "",
//            
//            // MARK: Documents (types only)
//            documentType1: "Student Photo",
//            documentType2: "Father Photo",
//            documentType3: "Mother Photo",
//            documentType4: "Guardian Photo",
//            documentType5: "Birth Certificate",
//            documentType6: "Aadhaar Card",
//            documentType7: "Transfer Certificate (TC)",
//            documentType8: "Previous Mark Sheet",
//            documentType9: "Caste Certificate",
//            documentType10: "Income Certificate",
//            documentType11: "Medical Certificate",
//            documentType12: "Address Proof",
//            documentType13: "Other 1",
//            documentType14: "Other 2",
//            documentType15: "Other 3"
//        )
//        
//        // Debug: Print the request
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let jsonData = try encoder.encode(request)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("📤 Request JSON:")
//                print(jsonString)
//            }
//        } catch {
//            print("❌ Error encoding request: \(error)")
//        }
//        
//        return request
//     }

    
    private func prepareRegistrationRequest() -> StudentRegistrationRequest {
        
        let basic = basicInfoData
        let medical = medicalSportsData
        let admission = admissionInfoData
        let address = addressInfoData
        let parents = parentsInfoData
        let guardian = guardianInfoData
        
        // Format dates for API
        let dateOfBirthFormatted = formatDateForAPI(basic.dateOfBirth)
        let dateOfAdmissionFormatted = admission.dateOfAdmission.isEmpty ?
            formatDateForAPI(Date().toString(format: "dd/MM/yyyy")) :
            formatDateForAPI(admission.dateOfAdmission)
       
         // Helper function to return empty string instead of "N/A"
         func optionalValue(_ value: String) -> String {
             return value.isEmpty ? "" : value
         }
         
         let request = StudentRegistrationRequest(
           // MARK: Basic Info
           classId: Int(classId) ?? 0,
           firstName: basic.firstName,
           middleName: optionalValue(basic.middleName),
           lastName: optionalValue(basic.lastName),
           gender: basic.gender,
           dateOfBirth: dateOfBirthFormatted,
           placeOfBirth: optionalValue(basic.placeOfBirth),
           motherTongue: optionalValue(basic.motherTongue),
           email: optionalValue(basic.email),
           bhagyalakshmiNo: optionalValue(basic.bhagyalakshmiNo),
           studentMobileNumber: basic.studentMobileNumber.isEmpty ? "" : basic.studentMobileNumber,
           fatherMobileNumber: optionalValue(parents.fatherMobileNumber),
           motherMobileNumber: optionalValue(parents.motherMobileNumber),
           
           // FIXED: Hardcode nationality to "Indian"
           nationality: "Indian",
           
           religion: optionalValue(basic.religion),
           caste: optionalValue(basic.caste),
           aadhaarNumber: optionalValue(basic.aadhaarNumber),
           bloodGroup: optionalValue(basic.bloodGroup),
           
           // MARK: Medical / Sports
           physicalDisability: medical.physicalDisability,
           disabilityDescription: optionalValue(medical.disabilityDescription),
           sportsParticipation: medical.sportsParticipation,
           sportsLevel: optionalValue(medical.sportsLevel),
           medicalCondition: optionalValue(medical.medicalCondition),
           emergencyMedication: optionalValue(medical.emergencyMedication),
           chronicDiseases: optionalValue(medical.chronicDiseases),
           allergies: optionalValue(medical.allergies),
           medicalNotes: optionalValue(medical.medicalNotes),
           
           // MARK: Admission
           omrNumber: optionalValue(admission.omrNumber),
           dateOfAdmission: dateOfAdmissionFormatted,
           eligible: true,
           transportRequired: medical.transportRequired,
           hostelRequired: medical.hostelRequired,
           pickupAddress: optionalValue(address.permanentArea),
           dropAddress: optionalValue(address.permanentArea),
           
           // FIXED: Hardcode scholarshipStatus to "Not Applied"
           scholarshipStatus: "Not Applied",
            
            // MARK: Permanent Address
            permanentPinCode: optionalValue(address.permanentPinCode),
            permanentState: optionalValue(address.permanentState),
            permanentDistrict: optionalValue(address.permanentDistrict),
            permanentArea: optionalValue(address.permanentArea),
            permanentTaluk: optionalValue(address.permanentTaluk),
            
            // MARK: Correspondence Address
            correspondenceArea: address.useSameAsPermanent ? optionalValue(address.permanentArea) : optionalValue(address.correspondenceArea),
            correspondenceTaluk: address.useSameAsPermanent ? optionalValue(address.permanentTaluk) : optionalValue(address.correspondenceTaluk),
            correspondenceDistrict: address.useSameAsPermanent ? optionalValue(address.permanentDistrict) : optionalValue(address.correspondenceDistrict),
            correspondenceState: address.useSameAsPermanent ? optionalValue(address.permanentState) : optionalValue(address.correspondenceState),
            correspondencePinCode: address.useSameAsPermanent ? optionalValue(address.permanentPinCode) : optionalValue(address.correspondencePinCode),
            
            // MARK: Father
            fatherName: optionalValue(parents.fatherName),
            fatherAadhaarNumber: optionalValue(parents.fatherAadhaarNumber),
            fatherOccupation: optionalValue(parents.fatherOccupation),
            fatherAnnualIncome: optionalValue(parents.fatherAnnualIncome),
            fatherIsEmergencyContact: parents.fatherIsEmergencyContact,
            fatherEducation: optionalValue(parents.fatherEducation),
            
            // MARK: Mother
            motherName: optionalValue(parents.motherName),
            motherAadhaarNumber: optionalValue(parents.motherAadhaarNumber),
            motherOccupation: optionalValue(parents.motherOccupation),
            motherAnnualIncome: optionalValue(parents.motherAnnualIncome),
            motherIsEmergencyContact: parents.motherIsEmergencyContact,
            motherEducation: optionalValue(parents.motherEducation),
            
            // MARK: Guardian
            guardianRelation: optionalValue(guardian.guardianRelation),
            guardianName: optionalValue(guardian.guardianName),
            guardianPhoneNumber: optionalValue(guardian.guardianPhoneNumber),
            guardianAadhaarNumber: optionalValue(guardian.guardianAadhaarNumber),
            guardianOccupation: optionalValue(guardian.guardianOccupation),
            guardianAnnualIncome: optionalValue(guardian.guardianAnnualIncome),
            guardianIsEmergencyContact: guardian.guardianIsEmergencyContact,
            guardianEducation: optionalValue(guardian.guardianEducation),
            
            // MARK: Previous Institution - 1 (empty strings)
            previousInstitution1: "",
            previousClass1: "",
            mediumOfInstitute1: "",
            board1: "",
            registrationNumber1: "",
            yearOfPassing1: "",
            maxMarks1: "",
            marksObtained1: "",
            percentage1: "",
            
            // MARK: Previous Institution - 2 (empty strings)
            previousInstitution2: "",
            previousClass2: "",
            mediumOfInstitute2: "",
            board2: "",
            registrationNumber2: "",
            yearOfPassing2: "",
            maxMarks2: "",
            marksObtained2: "",
            percentage2: "",
            
            // MARK: Documents (types only)
            documentType1: "Student Photo",
            documentType2: "Father Photo",
            documentType3: "Mother Photo",
            documentType4: "Guardian Photo",
            documentType5: "Birth Certificate",
            documentType6: "Aadhaar Card",
            documentType7: "Transfer Certificate (TC)",
            documentType8: "Previous Mark Sheet",
            documentType9: "Caste Certificate",
            documentType10: "Income Certificate",
            documentType11: "Medical Certificate",
            documentType12: "Address Proof",
            documentType13: "Other 1",
            documentType14: "Other 2",
            documentType15: "Other 3"
        )
        
        // Debug: Print the request
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(request)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Request JSON:")
                print(jsonString)
            }
        } catch {
            print("❌ Error encoding request: \(error)")
        }
        
        return request
    }
 private func validateAllData() -> Bool {
    var errors: [String] = []
    
    // MARK: Basic Info Validation - ONLY THESE 4 FIELDS ARE MANDATORY
    if basicInfoData.firstName.isEmpty {
        errors.append("First Name is required")
    }
    
    if basicInfoData.gender.isEmpty {
        errors.append("Gender is required")
    }
    
     if basicInfoData.dateOfBirth.isEmpty {
         errors.append("Date of Birth is required")
     } else {

         let apiDate = formatDateForAPI(basicInfoData.dateOfBirth)

         if apiDate.isEmpty {
             errors.append("Invalid date format. Please use DD-MM-YYYY")
         } else if !isValidDate(basicInfoData.dateOfBirth) {
             errors.append("Student age is not valid")
         }
     }

    
    let mobileText = basicInfoData.studentMobileNumber
    if mobileText.isEmpty {
        errors.append("Student mobile number is required")
    } else if mobileText.count != 10 {
        errors.append("Student mobile number must be 10 digits")
    }
    
    // OPTIONAL FIELDS VALIDATION (only validate format if provided)
    if !basicInfoData.email.isEmpty && !isValidEmail(basicInfoData.email) {
        errors.append("Invalid email format")
    }
    
    if !basicInfoData.aadhaarNumber.isEmpty && basicInfoData.aadhaarNumber.count != 12 {
        errors.append("Aadhaar number must be 12 digits")
    }
    
    // REMOVE ALL OTHER VALIDATION FOR OPTIONAL FIELDS
    
    if errors.isEmpty {
        return true
    } else {
        let errorMessage = errors.joined(separator: "\n")
        showAlert(title: "Validation Error", message: errorMessage)
        return false
    }
}

    // Add this helper method for date validation
 private func isValidDate(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "dd/MM/yyyy"
     dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: dateString) {
            // Check if date is reasonable (not in future and not too far in past)
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Student should be at least 3 years old and not born in future
            guard let minDate = calendar.date(byAdding: .year, value: -3, to: currentDate),
                  let maxDate = calendar.date(byAdding: .year, value: -100, to: currentDate) else {
                return false
            }
            
            return date <= minDate && date >= maxDate
        }
        return false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
//    private func formatDateForAPI(_ dateString: String) -> String {
//        // Convert from DD/MM/YYYY to YYYY-MM-DD
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "dd/MM/yyyy"
//        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        let outputFormatter = DateFormatter()
//        outputFormatter.dateFormat = "yyyy-MM-dd"
//        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        if let date = inputFormatter.date(from: dateString) {
//            return outputFormatter.string(from: date)
//        }
//        
//        // If conversion fails, try other common formats
//        let alternativeFormats = ["dd-MM-yyyy", "yyyy/MM/dd", "yyyy-MM-dd"]
//        for format in alternativeFormats {
//            inputFormatter.dateFormat = format
//            if let date = inputFormatter.date(from: dateString) {
//                return outputFormatter.string(from: date)
//            }
//        }
//        
//        // If all else fails, return the original string
//        return dateString
//    }
    
    
    private func handleAPIError(_ error: APIManager.APIError) {
        let errorMessage: String
        
        switch error {
        case .invalidURL:
            errorMessage = "Invalid URL"
        case .noData:
            errorMessage = "No data received from server"
        case .decodingError:
            errorMessage = "Failed to process server response"
        case .encodingError:
            errorMessage = "Failed to prepare data"
        case .serverError(let statusCode):
            errorMessage = "Server returned status code: \(statusCode)"
        case .unknown(let underlyingError):
            errorMessage = underlyingError?.localizedDescription ?? "Unknown error occurred"
        }
        
        showAlert(title: "Error", message: errorMessage)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.tag = 999
        view.addSubview(activityIndicator)
    }
    
    func hideLoadingIndicator() {
        if let activityIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: - Delegate Conformance
extension AddStudentViewController: BasicInfoCellDelegate,
                                   MedicalSportsCellDelegate,
                                   AdmissionInfoCellDelegate,
                                   AddressInfoCellDelegate,
                                   ParentsInformationCellDelegate,
                                   GuardianInfoCellDelegate,
                                   DocumentAttachmentCellDelegate {
    
    // Basic Info Delegate
    func basicInfoDidUpdate(_ data: BasicInfoData) {
        basicInfoData = data
        print("Basic info updated: \(data.firstName)")
    }
    
    // Medical Sports Info Delegate
    func medicalSportsInfoDidUpdate(_ data: MedicalSportsData) {
        medicalSportsData = data
        print("Medical sports info updated")
    }
    
    // Admission Info Delegate
    func admissionInfoDidUpdate(_ data: AdmissionInfoData) {
        admissionInfoData = data
        print("Admission info updated")
    }
    
    // Address Info Delegate
    func addressInfoDidUpdate(_ data: AddressInfoData) {
        addressInfoData = data
        print("Address info updated")
    }
    
    // Parents Info Delegate
    func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool) {
        parentsInfoData.fatherIsEmergencyContact = fatherIsEmergency
        parentsInfoData.motherIsEmergencyContact = motherIsEmergency
        print("Emergency contact updated")
    }
    
    func parentsInfoDidUpdate(_ data: ParentsInfoData) {
        parentsInfoData = data
        print("Parents info updated: \(data.fatherName)")
    }
    
    // Guardian Info Delegate
    func guardianInfoDidUpdate(_ data: GuardianInfoData) {
        guardianInfoData = data
        print("Guardian info updated: \(data.guardianName)")
    }
    
    // Document Delegate
    func documentDidUpload(documentName: String, document: Any, documentIndex: Int) {
        switch documentIndex {
        case 0: documentsData.studentPhoto = document
        case 1: documentsData.fatherPhoto = document
        case 2: documentsData.motherPhoto = document
        case 3: documentsData.guardianPhoto = document
        case 4: documentsData.birthCertificate = document
        case 5: documentsData.aadhaarCard = document
        case 6: documentsData.transferCertificate = document
        case 7: documentsData.previousMarksheet = document
        case 8: documentsData.casteCertificate = document
        case 9: documentsData.incomeCertificate = document
        case 10: documentsData.medicalCertificate = document
        case 11: documentsData.addressProof = document
        case 12: documentsData.other1 = document
        case 13: documentsData.other2 = document
        case 14: documentsData.other3 = document
        default: break
        }
        print("Document uploaded: \(documentName) at index \(documentIndex)")
    }
    
    func getAllDocuments() -> DocumentData {
        return documentsData
    }
}
// Add this Date extension if you don't have it
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

