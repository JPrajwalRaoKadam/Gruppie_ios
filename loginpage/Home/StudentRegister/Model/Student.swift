import Foundation

struct StudentTeamResponse: Codable {
    let data: [StudentTeam]
}

struct StudentTeam: Codable {
    let teamId: String
    let teacherName: String?
    let name: String
    let members: Int
    let phone: String
    let image: String?
    let gruppieClassName: String?

    enum CodingKeys: String, CodingKey {
        case teamId, teacherName, name, members, phone, image, gruppieClassName
    }

    var decodedImageUrl: String? {
        guard let image = image,
              let decodedData = Data(base64Encoded: image),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
struct StudentRegistrationRequest: Encodable {

    // MARK: Basic Info
    let classId: Int
    let firstName: String
    let middleName: String
    let lastName: String
    let gender: String
    let dateOfBirth: String
    let placeOfBirth: String
    let motherTongue: String
    let email: String
    let bhagyalakshmiNo: String
    let studentMobileNumber: String
    let fatherMobileNumber: String
    let motherMobileNumber: String
    let nationality: String
    let religion: String
    let caste: String
    let aadhaarNumber: String
    let bloodGroup: String

    // MARK: Medical / Sports
    let physicalDisability: Bool
    let disabilityDescription: String
    let sportsParticipation: Bool
    let sportsLevel: String
    let medicalCondition: String
    let emergencyMedication: String
    let chronicDiseases: String
    let allergies: String
    let medicalNotes: String

    // MARK: Admission
    let omrNumber: String
    let dateOfAdmission: String
    let eligible: Bool
    let transportRequired: Bool
    let hostelRequired: Bool
    let pickupAddress: String
    let dropAddress: String
    let scholarshipStatus: String

    // MARK: Permanent Address
    let permanentPinCode: String
    let permanentState: String
    let permanentDistrict: String
    let permanentArea: String
    let permanentTaluk: String

    // MARK: Correspondence Address
    let correspondenceArea: String
    let correspondenceTaluk: String
    let correspondenceDistrict: String
    let correspondenceState: String
    let correspondencePinCode: String

    // MARK: Father
    let fatherName: String
    let fatherAadhaarNumber: String
    let fatherOccupation: String
    let fatherAnnualIncome: String
    let fatherIsEmergencyContact: Bool
    let fatherEducation: String

    // MARK: Mother
    let motherName: String
    let motherAadhaarNumber: String
    let motherOccupation: String
    let motherAnnualIncome: String
    let motherIsEmergencyContact: Bool
    let motherEducation: String

    // MARK: Guardian
    let guardianRelation: String
    let guardianName: String
    let guardianPhoneNumber: String
    let guardianAadhaarNumber: String
    let guardianOccupation: String
    let guardianAnnualIncome: String
    let guardianIsEmergencyContact: Bool
    let guardianEducation: String

    // MARK: Previous Institution - 1
    let previousInstitution1: String
    let previousClass1: String
    let mediumOfInstitute1: String
    let board1: String
    let registrationNumber1: String
    let yearOfPassing1: String
    let maxMarks1: String
    let marksObtained1: String
    let percentage1: String

    // MARK: Previous Institution - 2
    let previousInstitution2: String
    let previousClass2: String
    let mediumOfInstitute2: String
    let board2: String
    let registrationNumber2: String
    let yearOfPassing2: String
    let maxMarks2: String
    let marksObtained2: String
    let percentage2: String

    // MARK: Documents (types only – as per your log)
    let documentType1: String
    let documentType2: String
    let documentType3: String
    let documentType4: String
    let documentType5: String
    let documentType6: String
    let documentType7: String
    let documentType8: String
    let documentType9: String
    let documentType10: String
    let documentType11: String
    let documentType12: String
    let documentType13: String
    let documentType14: String
    let documentType15: String
}

struct BasicInfoData {
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var gender: String = ""
    var dateOfBirth: String = ""
    var placeOfBirth: String = ""
    var motherTongue: String = ""
    var bloodGroup: String = ""
    var aadharNumber: String = ""
    var nationality: String = ""
    var religion: String = ""
    var caste: String = ""
    var feeCategory: String = ""
    var email: String = ""
    var mobileNumber: String = ""
    var maritalStatus: String = ""
    var bhagyalakshmi: String = ""
    
    // Additional properties for API
    var studentMobileNumber: String { return mobileNumber }
    var aadhaarNumber: String { return aadharNumber }
    var bhagyalakshmiNo: String { return bhagyalakshmi }
}

// In your model file, update the MedicalSportsData struct:
struct MedicalSportsData {
    var physicalDisability: Bool = false
    var disabilityDescription: String = ""
    var sportsParticipation: Bool = false
    var sportsLevel: String = ""
    var medicalCondition: String = ""
    var emergencyMedication: String = ""
    var chronicDiseases: String = ""
    var allergies: String = ""
    var medicalNotes: String = ""
    var transportRequired: Bool = false
    var hostelRequired: Bool = false
    var pickupAddress: String = ""  // Add this
    var dropAddress: String = ""    // Add this
}

struct AdmissionInfoData {
    var omrNumber: String = ""
    var dateOfAdmission: String = ""
}

struct AddressInfoData {
    var permanentPinCode: String = ""
    var permanentState: String = ""
    var permanentDistrict: String = ""
    var permanentArea: String = ""
    var permanentTaluk: String = ""
    
    // ORDER: correspondencePinCode comes BEFORE correspondenceArea
    var correspondencePinCode: String = ""
    var correspondenceState: String = ""
    var correspondenceDistrict: String = ""
    var correspondenceArea: String = ""
    var correspondenceTaluk: String = ""
    
    var useSameAsPermanent: Bool = false
}

struct ParentsInfoData {
    var fatherName: String = ""
    var fatherAadhaarNumber: String = ""
    var fatherOccupation: String = ""
    var fatherAnnualIncome: String = ""
    var fatherIsEmergencyContact: Bool = false
    var fatherEducation: String = ""
    var fatherMobileNumber: String = ""
    
    var motherName: String = ""
    var motherAadhaarNumber: String = ""
    var motherOccupation: String = ""
    var motherAnnualIncome: String = ""
    var motherIsEmergencyContact: Bool = false
    var motherEducation: String = ""
    var motherMobileNumber: String = ""
}

struct GuardianInfoData {
    var guardianRelation: String = ""
    var guardianName: String = ""
    var guardianPhoneNumber: String = ""
    var guardianAadhaarNumber: String = ""
    var guardianOccupation: String = ""
    var guardianAnnualIncome: String = ""
    var guardianIsEmergencyContact: Bool = false
    var guardianEducation: String = ""
}

struct DocumentData {
    var studentPhoto: Any?
    var fatherPhoto: Any?
    var motherPhoto: Any?
    var guardianPhoto: Any?
    var birthCertificate: Any?
    var aadhaarCard: Any?
    var transferCertificate: Any?
    var previousMarksheet: Any?
    var casteCertificate: Any?
    var incomeCertificate: Any?
    var medicalCertificate: Any?
    var addressProof: Any?
    var other1: Any?
    var other2: Any?
    var other3: Any?
}

// MARK: - Student Data for Cell Population
struct StudentDataSR {
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var gender: String = ""
    var dateOfBirth: String = ""
    var placeOfBirth: String = ""
    var motherTongue: String = ""
    var bloodGroup: String = ""
    var aadharNumber: String = ""
    var nationality: String = ""
    var religion: String = ""
    var caste: String = ""
    var feeCategory: String = ""
    var email: String = ""
    var mobileNumber: String = ""
    var maritalStatus: String = ""
    var bhagyalakshmi: String = ""
}

// MARK: - API Response Models
struct StudentRegistrationResponse: Decodable {
    let success: Bool
    let message: String
    let data: StudentRegistrationData?
    
    struct StudentRegistrationData: Decodable {
        let studentId: String?
        let registrationNumber: String?
        let name: String?
    }
}
