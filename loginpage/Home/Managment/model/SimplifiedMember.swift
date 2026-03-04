import Foundation

// MARK: - Management Response Models

struct ManagementResponse: Decodable {
    let data: [ManagementMember]
    let pagination: ManagementPagination
}

struct ManagementPagination: Decodable {
    let totalItems: Int
    let totalPages: Int
    let currentPage: Int
}

struct ManagementMember: Decodable {
    let id: Int
    let fullName: String
    let mobileNumber: String
    let email: String?
    let profilePhotoPath: String?
    let gender: String?
    let dateOfBirth: String?
    let professionalDetails: ProfessionalDetails?
}

struct ProfessionalDetails: Decodable {
    let designation: String?
}

// MARK: - Editable Management Request/Response

struct EditManagementRequest: Encodable {
    let fullName: String
    let gender: String
    let dateOfBirth: String
    let mobileNumber: String
    let alternativeNumber: String
    let email: String
    let aadharNumber: String
    let address: String
    let city: String
    let state: String
    let country: String
    let pincode: String
    let role: String

    let qualification: String
    let university: String
    let yearOfCompletion: String

    let designation: String
    let organizationName: String
    let totalExperience: String
    let industry: String
    let workAddress: String
    let workEmail: String
    let workPhoneNo: String
    
    let achievementTitle1: String
    let achievementTitle2: String
    let achievementTitle3: String

    let achievementDescription1: String
    let achievementDescription2: String
    let achievementDescription3: String
    
    let accountHolderName: String
    let bankName: String
    let branchName: String
    let accountNumber: String
    let IFSCCode: String
    let PANNumber: String

    let attachment1: String
    let attachment2: String
    let attachment3: String
}

struct EditManagementResponse: Decodable {
    let success: Bool
    let message: String?
}

struct EditableManagement {

    var fullName: String = ""
    var gender: String = ""
    var dateOfBirth: String = ""
    var mobileNumber: String = ""
    var alternativeNumber: String = ""
    var email: String = ""
    var aadharNumber: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var country: String = ""
    var pincode: String = ""
    var role: String = ""
    var roleId: String = ""
    
    var aadharFileData: Data?
    var aadharFileName: String?
    var aadharMimeType: String?


    var Qualification: String = ""
    var Univesity: String = ""
    var yearOfCompletion: String = ""

    var designation: String = ""
    var organizationName: String = ""
    var totalExperience: String = ""
    var industry: String = ""
    var workAddress: String = ""
    var workEmail: String = ""
    var workPhoneNo: String = ""
    
    var achievementTitle1: String = ""
    var achievementTitle2: String = ""
    var achievementTitle3: String = ""

    var achievementDescription1: String = ""
    var achievementDescription2: String = ""
    var achievementDescription3: String = ""
    
    var accountHolderName: String = ""
    var bankName: String = ""
    var branchName: String = ""
    var accountNumber: String = ""
    var IFSCCode: String = ""
    var PANNumber: String = ""
    
    var attachment1: String = ""
    var attachment2: String = ""
    var attachment3: String = ""
}

// MARK: - Role Models with Decoding Fix

struct RoleResponse: Codable {
    let data: [Role]
}

struct Role: Codable {
    let id: Int
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id, name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode ID as string first, then convert to Int
        let idString = try container.decode(String.self, forKey: .id)
        guard let idInt = Int(idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "ID string could not be converted to Int"
            )
        }
        self.id = idInt
        self.name = try container.decode(String.self, forKey: .name)
    }
}

// MARK: - Mutable Management Models

struct MutableManagementMember {
    var id: Int
    var fullName: String
    var mobileNumber: String
    var email: String?
    var profilePhotoPath: String?
    var gender: String?
    var dateOfBirth: String?
    var professionalDetails: MutableProfessionalDetails?
    
    init(from member: ManagementMember) {
        self.id = member.id
        self.fullName = member.fullName
        self.mobileNumber = member.mobileNumber
        self.email = member.email
        self.profilePhotoPath = member.profilePhotoPath
        self.gender = member.gender
        self.dateOfBirth = member.dateOfBirth
        self.professionalDetails = MutableProfessionalDetails(from: member.professionalDetails)
    }
}

struct MutableProfessionalDetails {
    var designation: String?
    
    init(from details: ProfessionalDetails?) {
        self.designation = details?.designation
    }
}
