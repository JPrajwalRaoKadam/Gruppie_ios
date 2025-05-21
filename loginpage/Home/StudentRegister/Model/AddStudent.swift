import Foundation

struct StudentDataResponse: Codable {
    let data: [StudentData]
}

struct FeeId: Codable {
    let feeType: String?
    let feeAmount: Double?
}

struct StudentData: Codable {
    var userId: String?
    var userDownloadedApp: Bool?
    var teamId: String?
    var studentDbId: String?
    var studentRegId: String?
    var groupId: String?
    var searchName: String?
    var searchName2: String?
    var name: String?
    var phone: String?
    var alternativePhone: String?
    var countryCode: String?
    var country: String?
    var admissionType: String?
    var admissionNumber: String?
    var satsNo: String?
    var satsNumber: String?
    var rollNumber: String?
    var gruppieRollNumber: String?
    var className: String?
    var section: String?
    var category: String?
    var caste: String?
    var subCaste: String?
    var religion: String?
    var gender: String?
    var nationality: String?
    var disability: String?
    var bloodGroup: String?
    var dob: String?
    var dateOfBirth: String?
    var doj: String?
    var dateOfJoining: String?
    var aadharNumber: String?
    var panNumber: String?
    var email: String?
    var address: String?
    var district: String?
    var taluk: String?
    var familyIncome: String?
    
    var fatherName: String?
    var fatherPhone: String?
    var fatherNumber: String?
    var fatherEmail: String?
    var fatherAadhar: String?
    var fatherAadharNumber: String?
    var fatherOccupation: String?
    var fatherEducation: String?
    
    var motherName: String?
    var motherPhone: String?
    var motherNumber: String?
    var motherEmail: String?
    var motherAadharNumber: String?
    var motherOccupation: String?
    var motherEducation: String?
    
    var isMotherDownloaded: Bool?
    var isFatherDownloaded: Bool?
    
    var designation: String?
    var numberOfKids: String?
    var feeIds: [FeeId]?
    var marksCard: [String]?
    var rte: Bool?
    var image: String?
    var isSelected: Bool?
    
    var educationInfo: EducationInfo?
    var accountInfo: AccountInfo?
}

struct EducationInfo: Codable {
    var className: String?
    var section: String?
    var rollNumber: String?

    var nationality: String?
    var bloodGroup: String?
    var religion: String?
    var caste: String?
    var category: String?
    var disability: String?
    var dateOfBirth: String?
    var admissionNumber: String?
    var satsNumber: String?
    var aadharNumber: String?
    var address: String?

    var education: String?
    var profession: String?
    var achievement: String?
}

struct AccountInfo: Codable {
    var email: String?
    var phone: String?
    var admissionType: String?

    var fatherName: String?
    var motherName: String?
    var fatherPhone: String?
    var motherPhone: String?
    var fatherEmail: String?
    var motherEmail: String?
    var fatherQualification: String?
    var motherQualification: String?
    var fatherOccupation: String?
    var motherOccupation: String?
    var fatherAadharNo: String?
    var motherAadharNo: String?
    var fatherIncome: String?
    var motherIncome: String?

    var bankAccount: String?
    var accountType: String?
    var bankIfsc: String?
    var bankName: String?
    var branch: String?
    var address: String?
}

struct StudentRegisterRequest: Codable {
    var studentData: [StudentData]
}

struct BasicInfoModel {
    var name: String
    var designation: String
    var country: String
    var phoneNo: String
    var alternativeNo: String
    var email: String
    var gender: String
    var dob: String
    var doj: String
    var aadharNo: String
    var bloodGroup: String
    var panNo: String
    var address: String
}
struct StaffDataResponse: Codable {
    let totalNumberOfPages: Int?
    let data: [StaffMember]?
}

struct StaffMember: Codable {
    let permanent: StringOrBool
    let accountant: Bool?
    let qualification: String?
    let religion: String?
    let panNumber: String?
    let designation: String?
    let staffRegId: String?
    let homeAddress: String?
    let achievements: String?
    let management: Bool?
    let seniorSerialNumber: String?
    let seniorNumber: String?
    let bankAccountNumber: String?
    let classTypeId: String?
    let motherName: String?
    let dob: String?
    let doj: String?
    let address: String?
    let alternatePhoneNumber: String?
    let bankBranch: String?
    let bloodGroup: String?
    let biometric: Bool?
    let education: String?
    let userDownloadedApp: Bool?
    let bankIfscCode: String?
    let type: String?
    let bitmapData: String?
    let aadharNumber: String?
    let officeAddress: String?
    let fatherName: String?
    let className: String? 
    let caste: String?
    let gender: String?
    let emergencyContactNumber: String?
    let email: String?
    let country: String?
    let phone: String?
    let teaching: Bool?
    let staffId: String?
    let disability: String?
    let inventoryApprover: Bool?
    let name: String?
    let staffCategory: String?
    let isoTemplate: String?
    let uanNumber: String?
    let nonteaching: Bool?
    let isAllowedToPost: Bool?
    let userId: String?
    let librarian: Bool?
    let profession: String?
    let image: String?
    let payRollApprover: Bool?
    let accountType: String?
    let category: String?
    let admissionApprover: Bool?
    let bankAddress: String?
    let bankName: String?
    let examiner: Bool?

    enum CodingKeys: String, CodingKey {
        case permanent, accountant, qualification, religion, panNumber, designation, staffRegId
        case homeAddress, achievements, management, seniorSerialNumber, seniorNumber, bankAccountNumber
        case classTypeId, motherName, dob, doj, address, alternatePhoneNumber, bankBranch
        case bloodGroup, biometric, education, userDownloadedApp, bankIfscCode, type
        case bitmapData = "BitmapData"
        case aadharNumber, officeAddress, fatherName
        case className = "class"
        case caste, gender, emergencyContactNumber, email, country, phone, teaching
        case staffId, disability, inventoryApprover, name, staffCategory
        case isoTemplate = "IsoTemplate"
        case uanNumber, nonteaching, isAllowedToPost, userId, librarian, profession
        case image, payRollApprover, accountType, category, admissionApprover, bankAddress
        case bankName, examiner
    }
}

// Custom Enum to Handle Mixed Bool & String Types
enum StringOrBool: Codable {
    case string(String)
    case bool(Bool)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                StringOrBool.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or Bool but found another type."
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .bool(let boolValue):
            try container.encode(boolValue)
        }
    }
}

// Helper Function to Get Permanent Value as String
func getPermanentValue(_ permanent: StringOrBool) -> String {
    switch permanent {
    case .string(let value):
        return value // Already a string
    case .bool(let value):
        return value ? "Yes" : "No" // Convert boolean to string
    }
}
