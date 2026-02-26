////
////  dummyaddstu.swift
////  loginpage
////
////  Created by apple on 05/02/26.
////
//    import UIKit
//    // MARK: - Parents Information Cell Delegate Protocol
//    protocol ParentsInformationCellDelegate: AnyObject {
//        func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool)
//        func parentsInfoDidUpdate(_ data: ParentsInfoData) // Add this new method
//    }
//
//    protocol BasicInfoCellDelegate: AnyObject {
//        func basicInfoDidUpdate(_ data: BasicInfoData)
//    }
//
//    protocol MedicalSportsCellDelegate: AnyObject {
//        func medicalSportsInfoDidUpdate(_ data: MedicalSportsData)
//    }
//
//    protocol AdmissionInfoCellDelegate: AnyObject {
//        func admissionInfoDidUpdate(_ data: AdmissionInfoData)
//    }
//
//    protocol AddressInfoCellDelegate: AnyObject {
//        func addressInfoDidUpdate(_ data: AddressInfoData)
//    }
//
//    protocol GuardianInfoCellDelegate: AnyObject {
//        func guardianInfoDidUpdate(_ data: GuardianInfoData)
//    }
//
//    protocol DocumentAttachmentCellDelegate: AnyObject {
//        func documentDidUpload(documentName: String, document: Any, documentIndex: Int)
//        func getAllDocuments() -> DocumentData
//    }
//
//    class AddStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//        @IBOutlet weak var TableView: UITableView!
//        var token: String = ""
//        var groupId: String = ""
//        var teamId: String = ""
//        var newStudent: Student?
//        var newStudentDetails: [StudentData] = []
//        @IBOutlet weak var backButton: UIButton!
//        @IBOutlet weak var addButton: UIButton!
//        
//        // MARK: - Data Storage
//        private var basicInfoData = BasicInfoData()
//        private var admissionInfoData = AdmissionInfoData()
//        private var addressInfoData = AddressInfoData()
//        private var parentsInfoData = ParentsInfoData()
//        private var guardianInfoData = GuardianInfoData()
//        private var medicalSportsData = MedicalSportsData()
//        private var documentsData = DocumentData()
//        
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            print("groupId: \(groupId), teamId: \(teamId), token: \(token)")
//
//            // Register cells
//            TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil),
//                               forCellReuseIdentifier: "BasicInfoCell")
//            TableView.register(UINib(nibName: "Medical_Sports_InformationCell", bundle: nil),
//                               forCellReuseIdentifier: "Medical_Sports_InformationCell")
//            TableView.register(UINib(nibName: "AdmissionInformationCell", bundle: nil),
//                               forCellReuseIdentifier: "AdmissionInformationCell")
//            TableView.register(UINib(nibName: "AddressInformationCell", bundle: nil),
//                               forCellReuseIdentifier: "AddressInformationCell")
//            TableView.register(UINib(nibName: "ParentsInformationCell", bundle: nil),
//                               forCellReuseIdentifier: "ParentsInformationCell")
//            TableView.register(UINib(nibName: "GuardianInformationCell", bundle: nil),
//                               forCellReuseIdentifier: "GuardianInformationCell")
//            TableView.register(UINib(nibName: "DocumentAttachmentCell", bundle: nil),
//                               forCellReuseIdentifier: "DocumentAttachmentCell")
//
//            TableView.delegate = self
//            TableView.dataSource = self
//
//            TableView.layer.cornerRadius = 10
//            TableView.layer.masksToBounds = true
//            TableView.layer.borderWidth = 1
//            TableView.layer.shadowColor = UIColor.black.cgColor
//            TableView.layer.shadowOffset = CGSize(width: 0, height: 2)
//            TableView.layer.shadowOpacity = 0.3
//            TableView.layer.shadowRadius = 4
//            
//            backButton.layer.cornerRadius = backButton.frame.size.height / 2
//            backButton.clipsToBounds = true
//            backButton.layer.cornerRadius = 10
//            backButton.clipsToBounds = true
//            backButton.layer.masksToBounds = true
//            TableView.layer.masksToBounds = false
//            enableKeyboardDismissOnTap()
//        }
//        
//        override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//            backButton.layer.cornerRadius = backButton.frame.size.height / 2
//        }
//        
//        enum AddStudentRow: Int, CaseIterable {
//            case basicInfo
//            case medicalSports
//            case admission
//            case address
//            case parents
//            case guardian
//            case documents
//        }
//
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return AddStudentRow.allCases.count
//        }
//        
//        func numberOfSections(in tableView: UITableView) -> Int {
//            return 1
//        }
//        
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            guard let row = AddStudentRow(rawValue: indexPath.row) else {
//                return UITableViewCell()
//            }
//
//            switch row {
//            case .basicInfo:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "BasicInfoCell",
//                    for: indexPath
//                ) as! BasicInfoCell
//                cell.delegate = self  // Assign delegate
//                cell.populate(with: nil)  // Populate if needed
//                return cell
//                
//            case .medicalSports:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "Medical_Sports_InformationCell",
//                    for: indexPath
//                ) as! Medical_Sports_InformationCell
//                cell.delegate = self  // Assign delegate
//                cell.populate(with: nil)  // Populate if needed
//                return cell
//                
//            case .admission:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "AdmissionInformationCell",
//                    for: indexPath
//                ) as! AdmissionInformationCell
//                cell.delegate = self  // Assign delegate
//                return cell
//                
//            case .address:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "AddressInformationCell",
//                    for: indexPath
//                ) as! AddressInformationCell
//                cell.delegate = self  // Assign delegate
//                return cell
//                
//            case .parents:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "ParentsInformationCell",
//                    for: indexPath
//                ) as! ParentsInformationCell
//                cell.delegate = self
//                cell.populate(with: nil)  // Populate if needed
//                return cell
//                
//            case .guardian:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "GuardianInformationCell",
//                    for: indexPath
//                ) as! GuardianInformationCell
//                cell.delegate = self  // Assign delegate
//                cell.populate(with: nil)  // Populate if needed
//                return cell
//                
//            case .documents:
//                let cell = tableView.dequeueReusableCell(
//                    withIdentifier: "DocumentAttachmentCell",
//                    for: indexPath
//                ) as! DocumentAttachmentCell
//                cell.setParentViewController(self)
//                cell.delegate = self  // Assign delegate
//                return cell
//            }
//        }
//        
//        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            guard let row = AddStudentRow(rawValue: indexPath.row) else {
//                return 100
//            }
//            
//            switch row {
//            case .basicInfo: return 650
//            case .medicalSports: return 500
//            case .admission: return 120
//            case .address: return 300
//            case .parents: return 550
//            case .guardian: return 350
//            case .documents: return 400
//            }
//        }
//
//        @IBAction func BackButton(_ sender: UIButton) {
//            navigationController?.popViewController(animated: true)
//        }
//        
//        @IBAction func addButtonAction(_ sender: UIButton) {
//            // Collect all data and submit
//            collectAllDataAndSubmit()
//        }
//        
//        // MARK: - Data Collection and API Call
//        private func collectAllDataAndSubmit() {
//            // Validate basic info first
//            guard validateAllData() else {
//                return
//            }
//            
//            // Show loading indicator
//            showLoadingIndicator()
//            
//            // Prepare API request
//            var requestBody = StudentRegisterRequest(data: [])
//            
//            // Create student data
//            var studentData = StudentData(
//                firstName: basicInfoData.firstName,
//                middleName: basicInfoData.middleName,
//                lastName: basicInfoData.lastName,
//                gender: basicInfoData.gender,
//                dateOfBirth: basicInfoData.dateOfBirth,
//                placeOfBirth: basicInfoData.placeOfBirth,
//                motherTongue: basicInfoData.motherTongue,
//                bloodGroup: basicInfoData.bloodGroup,
//                aadharNumber: basicInfoData.aadharNumber,
//                nationality: basicInfoData.nationality,
//                religion: basicInfoData.religion,
//                caste: basicInfoData.caste,
//                feeCategory: basicInfoData.feeCategory,
//                email: basicInfoData.email,
//                mobileNumber: basicInfoData.mobileNumber,
//                maritalStatus: basicInfoData.maritalStatus,
//                bhagyalakshmi: basicInfoData.bhagyalakshmi,
//                
//                // Parents Info
//                fatherName: parentsInfoData.fatherName,
//                motherName: parentsInfoData.motherName,
//                fatherPhone: parentsInfoData.fatherPhone,
//                motherPhone: parentsInfoData.motherPhone,
//                fatherOccupation: parentsInfoData.fatherOccupation,
//                motherOccupation: parentsInfoData.motherOccupation,
//                fatherAadharNo: parentsInfoData.fatherAadharNo,
//                motherAadharNo: parentsInfoData.motherAadharNo,
//                fatherIncome: parentsInfoData.fatherIncome,
//                motherIncome: parentsInfoData.motherIncome,
//                fatherEducation: parentsInfoData.fatherEducation,
//                motherEducation: parentsInfoData.motherEducation,
//                
//                // Emergency contacts
//                fatherIsEmergencyContact: parentsInfoData.fatherIsEmergencyContact,
//                motherIsEmergencyContact: parentsInfoData.motherIsEmergencyContact,
//                
//                // Guardian Info
//                relation: guardianInfoData.relation,
//                name: guardianInfoData.name,
//                phone: guardianInfoData.phone,
//                aadharNo: guardianInfoData.aadharNo,
//                occupation: guardianInfoData.occupation,
//                annualIncome: guardianInfoData.annualIncome,
//                education: guardianInfoData.education,
//                
//                // Medical & Sports Info (You'll need to add these to your StudentData model)
//                // physicalDisability: medicalSportsData.physicalDisability,
//                // disabilityDescription: medicalSportsData.disabilityDescription,
//                // ... etc.
//                
//                // Additional fields
//                omrNo: admissionInfoData.omrNo,
//                admissionDate: admissionInfoData.admissionDate
//                // Add other fields as needed
//            )
//            
//            requestBody.data = [studentData]
//            
//            // Call API
//            sendStudentDataToAPI(requestBody: requestBody)
//        }
//        
//        private func validateAllData() -> Bool {
//            // Validate basic info
//            if basicInfoData.firstName.isEmpty {
//                showAlert(title: "Validation Error", message: "First Name is required")
//                return false
//            }
//            
//            if basicInfoData.gender.isEmpty {
//                showAlert(title: "Validation Error", message: "Gender is required")
//                return false
//            }
//            
//            if basicInfoData.dateOfBirth.isEmpty {
//                showAlert(title: "Validation Error", message: "Date of Birth is required")
//                return false
//            }
//            
//            if basicInfoData.mobileNumber.isEmpty {
//                showAlert(title: "Validation Error", message: "Mobile number is required")
//                return false
//            } else if basicInfoData.mobileNumber.count != 10 {
//                showAlert(title: "Validation Error", message: "Mobile number must be 10 digits")
//                return false
//            }
//            
//            if !basicInfoData.email.isEmpty && !isValidEmail(basicInfoData.email) {
//                showAlert(title: "Validation Error", message: "Invalid email format")
//                return false
//            }
//            
//            // Validate at least one emergency contact
//            if !parentsInfoData.fatherIsEmergencyContact && !parentsInfoData.motherIsEmergencyContact {
//                showAlert(title: "Validation Error", message: "At least one emergency contact must be selected")
//                return false
//            }
//            
//            return true
//        }
//        
//        private func isValidEmail(_ email: String) -> Bool {
//            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//            return emailPred.evaluate(with: email)
//        }
//        
//        private func showAlert(title: String, message: String) {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//        
//        func sendStudentDataToAPI(requestBody: StudentRegisterRequest) {
//            guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/multiple/student/register") else {
//                print("Invalid URL")
//                hideLoadingIndicator()
//                return
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            
//            do {
//                let jsonData = try JSONEncoder().encode(requestBody)
//                request.httpBody = jsonData
//            } catch {
//                print("Error encoding data: \(error.localizedDescription)")
//                hideLoadingIndicator()
//                return
//            }
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                DispatchQueue.main.async {
//                    self.hideLoadingIndicator()
//                }
//                
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: error.localizedDescription)
//                    }
//                    return
//                }
//                
//                guard let data = data else {
//                    print("No data received")
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "No data received from server")
//                    }
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("HTTP Status Code: \(httpResponse.statusCode)")
//                    
//                    if !(200...299).contains(httpResponse.statusCode) {
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Error", message: "Server returned status code: \(httpResponse.statusCode)")
//                        }
//                        return
//                    }
//                }
//                
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Raw response: \(jsonString)")
//                }
//                
//                do {
//                    let responseModel = try JSONDecoder().decode(StudentDataResponse.self, from: data)
//                    print("Decoded Response: \(responseModel)")
//                    
//                    DispatchQueue.main.async {
//                        if !responseModel.data.isEmpty {
//                            self.showAlert(title: "Success", message: "Student registered successfully!")
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        }
//                    }
//                } catch {
//                    print("Error decoding response: \(error.localizedDescription)")
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Error", message: "Failed to process server response")
//                    }
//                }
//            }
//            
//            task.resume()
//        }
//
//        func showLoadingIndicator() {
//            let activityIndicator = UIActivityIndicatorView(style: .large)
//            activityIndicator.center = view.center
//            activityIndicator.startAnimating()
//            view.addSubview(activityIndicator)
//        }
//        
//        func hideLoadingIndicator() {
//            for subview in view.subviews {
//                if let activityIndicator = subview as? UIActivityIndicatorView {
//                    activityIndicator.stopAnimating()
//                    activityIndicator.removeFromSuperview()
//                }
//            }
//        }
//    }
//
//    // MARK: - Delegate Conformance
//    extension AddStudentViewController:
//        BasicInfoCellDelegate,
//        MedicalSportsCellDelegate,
//        AdmissionInfoCellDelegate,
//        AddressInfoCellDelegate,
//        ParentsInformationCellDelegate,
//        GuardianInfoCellDelegate,
//        DocumentAttachmentCellDelegate {
//        
//        // Basic Info Delegate
//        func basicInfoDidUpdate(_ data: BasicInfoData) {
//            basicInfoData = data
//            print("Basic info updated: \(data.firstName) \(data.lastName)")
//        }
//        
//        // Medical Sports Info Delegate
//        func medicalSportsInfoDidUpdate(_ data: MedicalSportsData) {
//            medicalSportsData = data
//            print("Medical sports info updated")
//        }
//        
//        // Admission Info Delegate
//        func admissionInfoDidUpdate(_ data: AdmissionInfoData) {
//            admissionInfoData = data
//            print("Admission info updated: OMR \(data.omrNo), Date: \(data.admissionDate)")
//        }
//        
//        // Address Info Delegate
//        func addressInfoDidUpdate(_ data: AddressInfoData) {
//            addressInfoData = data
//            print("Address info updated")
//        }
//        
//        // Parents Info Delegate
//        func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool) {
//            parentsInfoData.fatherIsEmergencyContact = fatherIsEmergency
//            parentsInfoData.motherIsEmergencyContact = motherIsEmergency
//            print("Emergency contact updated: Father: \(fatherIsEmergency), Mother: \(motherIsEmergency)")
//        }
//        
//        // You'll need to add another delegate method for ParentsInfoCell to update all data
//        // Add this protocol in your ParentsInformationCell file:
//        // protocol ParentsInfoCellDelegate: AnyObject {
//        //     func parentsInfoDidUpdate(_ data: ParentsInfoData)
//        // }
//        
//        // Guardian Info Delegate
//        func guardianInfoDidUpdate(_ data: GuardianInfoData) {
//            guardianInfoData = data
//            print("Guardian info updated: \(data.name)")
//        }
//        
//        // Document Delegate
//        func documentDidUpload(documentName: String, document: Any) {
//            // Store document based on name
//            switch documentName {
//            case "Student Photo":
//                documentsData.studentPhoto = document
//            case "Father Photo":
//                documentsData.fatherPhoto = document
//            case "Mother Photo":
//                documentsData.motherPhoto = document
//            case "Guardian Photo":
//                documentsData.guardianPhoto = document
//            case "Birth Certificate":
//                documentsData.birthCertificate = document
//            case "Aadhaar Card":
//                documentsData.aadhaarCard = document
//            case "Transfer Certificate":
//                documentsData.transferCertificate = document
//            case "Previous Marksheet":
//                documentsData.previousMarksheet = document
//            case "Caste Certificate":
//                documentsData.casteCertificate = document
//            case "Income Certificate":
//                documentsData.incomeCertificate = document
//            case "Medical Certificate":
//                documentsData.medicalCertificate = document
//            case "Address Proof":
//                documentsData.addressProof = document
//            case "Other Document 1":
//                documentsData.otherDocument1 = document
//            case "Other Document 2":
//                documentsData.otherDocument2 = document
//            case "Other Document 3":
//                documentsData.otherDocument3 = document
//            default:
//                print("Unknown document: \(documentName)")
//            }
//            
//            print("Document uploaded: \(documentName)")
//        }
//        
//        // This is for backward compatibility - remove if you update ParentsInformationCell
//        func didSelectEmergencyContact(isMother: Bool) {
//            print("Emergency contact selected: \(isMother ? "Mother" : "Father")")
//            // This method signature is different from what you have
//            // You need to update your ParentsInformationCell to use the correct delegate method
//        }
//    }
//
//    // MARK: - Delegate Conformance
//    extension AddStudentViewController:
//        BasicInfoCellDelegate,
//        MedicalSportsCellDelegate,
//        AdmissionInfoCellDelegate,
//        AddressInfoCellDelegate,
//        ParentsInformationCellDelegate,
//        GuardianInfoCellDelegate,
//        DocumentAttachmentCellDelegate {
//        
//        // Basic Info Delegate
//        func basicInfoDidUpdate(_ data: BasicInfoData) {
//            basicInfoData = data
//            print("Basic info updated")
//        }
//        
//        // Medical Sports Info Delegate
//        func medicalSportsInfoDidUpdate(_ data: MedicalSportsData) {
//            medicalSportsData = data
//            print("Medical sports info updated")
//        }
//        
//        // Admission Info Delegate
//        func admissionInfoDidUpdate(_ data: AdmissionInfoData) {
//            admissionInfoData = data
//            print("Admission info updated")
//        }
//        
//        // Address Info Delegate
//        func addressInfoDidUpdate(_ data: AddressInfoData) {
//            addressInfoData = data
//            print("Address info updated")
//        }
//        
//        // Parents Info Delegate - Update this method
//        func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool) {
//            parentsInfoData.fatherIsEmergencyContact = fatherIsEmergency
//            parentsInfoData.motherIsEmergencyContact = motherIsEmergency
//            print("Emergency contact updated")
//        }
//        
//        // Guardian Info Delegate
//        func guardianInfoDidUpdate(_ data: GuardianInfoData) {
//            guardianInfoData = data
//            print("Guardian info updated")
//        }
//        
//        // Document Delegate
//        func documentDidUpload(documentName: String, document: Any) {
//            // Store documents
//            switch documentName {
//            case "Student Photo": documentsData.studentPhoto = document
//            case "Father Photo": documentsData.fatherPhoto = document
//            case "Mother Photo": documentsData.motherPhoto = document
//            case "Guardian Photo": documentsData.guardianPhoto = document
//            case "Birth Certificate": documentsData.birthCertificate = document
//            case "Aadhaar Card": documentsData.aadhaarCard = document
//            case "Transfer Certificate": documentsData.transferCertificate = document
//            case "Previous Marksheet": documentsData.previousMarksheet = document
//            case "Caste Certificate": documentsData.casteCertificate = document
//            case "Income Certificate": documentsData.incomeCertificate = document
//            case "Medical Certificate": documentsData.medicalCertificate = document
//            case "Address Proof": documentsData.addressProof = document
//            case "Other Document 1": documentsData.other1 = document
//            case "Other Document 2": documentsData.other2 = document
//            case "Other Document 3": documentsData.other3 = document
//            default: break
//            }
//        }
//    }
//
//    // MARK: - API Payload Preparation
//    extension AddStudentViewController {
//        private func prepareAPIPayload() -> [String: Any] {
//            var payload: [String: Any] = [:]
//            
//            // Basic Info
//            payload["firstName"] = basicInfoData.firstName
//            payload["middleName"] = basicInfoData.middleName
//            payload["lastName"] = basicInfoData.lastName
//            payload["gender"] = basicInfoData.gender
//            payload["dateOfBirth"] = basicInfoData.formattedDate()
//            payload["placeOfBirth"] = basicInfoData.placeOfBirth
//            payload["motherTongue"] = basicInfoData.motherTongue
//            payload["email"] = basicInfoData.email
//            payload["bhagyalakshmiNo"] = basicInfoData.bhagyalakshmiNo
//            payload["studentMobileNumber"] = basicInfoData.studentMobileNumber
//            payload["fatherMobileNumber"] = basicInfoData.fatherMobileNumber
//            payload["motherMobileNumber"] = basicInfoData.motherMobileNumber
//            payload["nationality"] = basicInfoData.nationality
//            payload["religion"] = basicInfoData.religion
//            payload["caste"] = basicInfoData.caste
//            payload["aadhaarNumber"] = basicInfoData.aadhaarNumber
//            payload["bloodGroup"] = basicInfoData.bloodGroup
//            payload["scholarshipStatus"] = basicInfoData.scholarshipStatus
//            payload["eligible"] = basicInfoData.eligible
//            
//            // Medical & Sports Info
//            payload["physicalDisability"] = medicalSportsData.physicalDisability
//            payload["disabilityDescription"] = medicalSportsData.disabilityDescription
//            payload["sportsParticipation"] = medicalSportsData.sportsParticipation
//            payload["sportsLevel"] = medicalSportsData.sportsLevel
//            payload["medicalCondition"] = medicalSportsData.medicalCondition
//            payload["emergencyMedication"] = medicalSportsData.emergencyMedication
//            payload["chronicDiseases"] = medicalSportsData.chronicDiseases
//            payload["allergies"] = medicalSportsData.allergies
//            payload["medicalNotes"] = medicalSportsData.medicalNotes
//            payload["transportRequired"] = medicalSportsData.transportRequired
//            payload["hostelRequired"] = medicalSportsData.hostelRequired
//            
//            // Admission Info
//            payload["omrNumber"] = admissionInfoData.omrNumber
//            payload["dateOfAdmission"] = admissionInfoData.dateOfAdmission
//            
//            // Address Info
//            payload["permanentPinCode"] = addressInfoData.permanentPinCode
//            payload["permanentState"] = addressInfoData.permanentState
//            payload["permanentDistrict"] = addressInfoData.permanentDistrict
//            payload["permanentArea"] = addressInfoData.permanentArea
//            payload["permanentTaluk"] = addressInfoData.permanentTaluk
//            payload["correspondenceArea"] = addressInfoData.correspondenceArea
//            payload["correspondenceTaluk"] = addressInfoData.correspondenceTaluk
//            payload["correspondenceDistrict"] = addressInfoData.correspondenceDistrict
//            payload["correspondenceState"] = addressInfoData.correspondenceState
//            payload["correspondencePinCode"] = addressInfoData.correspondencePinCode
//            
//            // Parents Info
//            payload["fatherName"] = parentsInfoData.fatherName
//            payload["fatherAadhaarNumber"] = parentsInfoData.fatherAadhaarNumber
//            payload["fatherOccupation"] = parentsInfoData.fatherOccupation
//            payload["fatherAnnualIncome"] = parentsInfoData.fatherAnnualIncome
//            payload["fatherIsEmergencyContact"] = parentsInfoData.fatherIsEmergencyContact
//            payload["fatherEducation"] = parentsInfoData.fatherEducation
//            payload["motherName"] = parentsInfoData.motherName
//            payload["motherAadhaarNumber"] = parentsInfoData.motherAadhaarNumber
//            payload["motherOccupation"] = parentsInfoData.motherOccupation
//            payload["motherAnnualIncome"] = parentsInfoData.motherAnnualIncome
//            payload["motherIsEmergencyContact"] = parentsInfoData.motherIsEmergencyContact
//            payload["motherEducation"] = parentsInfoData.motherEducation
//            
//            // Guardian Info
//            payload["guardianRelation"] = guardianInfoData.guardianRelation
//            payload["guardianName"] = guardianInfoData.guardianName
//            payload["guardianPhoneNumber"] = guardianInfoData.guardianPhoneNumber
//            payload["guardianAadhaarNumber"] = guardianInfoData.guardianAadhaarNumber
//            payload["guardianOccupation"] = guardianInfoData.guardianOccupation
//            payload["guardianAnnualIncome"] = guardianInfoData.guardianAnnualIncome
//            payload["guardianIsEmergencyContact"] = guardianInfoData.guardianIsEmergencyContact
//            payload["guardianEducation"] = guardianInfoData.guardianEducation
//            
//            // Documents (you'll need to handle file uploads separately)
//            payload["documentType1"] = "Student Photo"
//            payload["documentType2"] = "Father Photo"
//            payload["documentType3"] = "Mother Photo"
//            payload["documentType4"] = "Guardian Photo"
//            payload["documentType5"] = "Birth Certificate"
//            payload["documentType6"] = "Aadhaar Card"
//            payload["documentType7"] = "Transfer Certificate (TC)"
//            payload["documentType8"] = "Previous Mark Sheet"
//            payload["documentType9"] = "Caste Certificate"
//            payload["documentType10"] = "Income Certificate"
//            payload["documentType11"] = "Medical Certificate"
//            payload["documentType12"] = "Address Proof"
//            payload["documentType13"] = "Other 1"
//            payload["documentType14"] = "Other 2"
//            payload["documentType15"] = "Other 3"
//            
//            return payload
//        }
//        
//        @IBAction func addButtonAction(_ sender: UIButton) {
//            // Validate all data
//            guard validateAllData() else {
//                return
//            }
//            
//            // Prepare API payload
//            let payload = prepareAPIPayload()
//            print("API Payload: \(payload)")
//            
//            // Call your API
//            sendDataToAPI(payload: payload)
//        }
//        
//        private func sendDataToAPI(payload: [String: Any]) {
//            guard let url = URL(string: "YOUR_API_ENDPOINT") else {
//                showAlert(title: "Error", message: "Invalid URL")
//                return
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
//                request.httpBody = jsonData
//                
//                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                    // Handle response
//                    DispatchQueue.main.async {
//                        if let error = error {
//                            self.showAlert(title: "Error", message: error.localizedDescription)
//                            return
//                        }
//                        
//                        if let httpResponse = response as? HTTPURLResponse {
//                            if (200...299).contains(httpResponse.statusCode) {
//                                self.showAlert(title: "Success", message: "Student added successfully!")
//                                self.navigationController?.popViewController(animated: true)
//                            } else {
//                                self.showAlert(title: "Error", message: "Server returned status: \(httpResponse.statusCode)")
//                            }
//                        }
//                    }
//                }
//                task.resume()
//                
//            } catch {
//                showAlert(title: "Error", message: "Failed to prepare data")
//            }
//        }
//    }
//    extension AddStudentViewController: ParentsInformationCellDelegate {
//        func didSelectEmergencyContact(fatherIsEmergency: Bool, motherIsEmergency: Bool) {
//            parentsInfoData.fatherIsEmergencyContact = fatherIsEmergency
//            parentsInfoData.motherIsEmergencyContact = motherIsEmergency
//            print("Emergency contact updated")
//        }
//        
//        func parentsInfoDidUpdate(_ data: ParentsInfoData) {
//            parentsInfoData = data
//            print("Parents info fully updated: \(data.fatherName), \(data.motherName)")
//        }
//    }
//    extension AddStudentViewController {
//        private func prepareAPIPayload() -> [String: Any] {
//            var payload: [String: Any] = [:]
//            
//            // ... other fields ...
//            
//            // Add document types (as per your API payload)
//            payload["documentType1"] = "Student Photo"
//            payload["documentType2"] = "Father Photo"
//            payload["documentType3"] = "Mother Photo"
//            payload["documentType4"] = "Guardian Photo"
//            payload["documentType5"] = "Birth Certificate"
//            payload["documentType6"] = "Aadhaar Card"
//            payload["documentType7"] = "Transfer Certificate (TC)"
//            payload["documentType8"] = "Previous Mark Sheet"
//            payload["documentType9"] = "Caste Certificate"
//            payload["documentType10"] = "Income Certificate"
//            payload["documentType11"] = "Medical Certificate"
//            payload["documentType12"] = "Address Proof"
//            payload["documentType13"] = "Other 1"
//            payload["documentType14"] = "Other 2"
//            payload["documentType15"] = "Other 3"
//            
//            // Note: documentUrl1, documentUrl2, etc. would need to be uploaded
//            // as multipart form data or as base64 strings
//            
//            return payload
//        }
//    }
//    extension AddStudentViewController: DocumentAttachmentCellDelegate {
//        func documentDidUpload(documentName: String, document: Any, documentIndex: Int) {
//            // Update documentsData based on index
//            switch documentIndex {
//            case 0: documentsData.studentPhoto = document
//            case 1: documentsData.fatherPhoto = document
//            case 2: documentsData.motherPhoto = document
//            case 3: documentsData.guardianPhoto = document
//            case 4: documentsData.birthCertificate = document
//            case 5: documentsData.aadhaarCard = document
//            case 6: documentsData.transferCertificate = document
//            case 7: documentsData.previousMarksheet = document
//            case 8: documentsData.casteCertificate = document
//            case 9: documentsData.incomeCertificate = document
//            case 10: documentsData.medicalCertificate = document
//            case 11: documentsData.addressProof = document
//            case 12: documentsData.other1 = document
//            case 13: documentsData.other2 = document
//            case 14: documentsData.other3 = document
//            default: break
//            }
//            
//            print("Document uploaded: \(documentName) at index \(documentIndex)")
//        }
//        
//        func getAllDocuments() -> DocumentData {
//            return documentsData
//        }
//    }
