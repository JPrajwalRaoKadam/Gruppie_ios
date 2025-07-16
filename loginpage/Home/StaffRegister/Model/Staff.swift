import Foundation

struct StaffResponse: Decodable {
    let totalNumberOfPages: Int
    let data: [Staff]
}

struct Staff: Decodable {
    var userId: String
    let name: String
    let designation: String?
    let imageURL: String?
    let bloodGroup: String?
    let panNumber: String?
    let caste: String?
    let doj: String?
    let dob: String?
    let address: String?
    let phone: String?
    let gender: String?
    let religion: String?
    let email: String?
    let bankAccountNumber: String?

    enum CodingKeys: String, CodingKey {
        case name, designation, imageURL = "image", bloodGroup = "bloodGroup", panNumber = "panNumber", caste, doj, dob, address, phone, gender, religion, email, bankAccountNumber = "bankAccountNumber", userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let decodedUserId = try? container.decode(String.self, forKey: .userId) {
            self.userId = decodedUserId
        } else {
            throw DecodingError.dataCorruptedError(forKey: .userId, in: container, debugDescription: "userId is required but missing.")
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.designation = try container.decodeIfPresent(String.self, forKey: .designation)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.bloodGroup = try container.decodeIfPresent(String.self, forKey: .bloodGroup)
        self.panNumber = try container.decodeIfPresent(String.self, forKey: .panNumber)
        self.caste = try container.decodeIfPresent(String.self, forKey: .caste)
        self.doj = try container.decodeIfPresent(String.self, forKey: .doj)
        self.dob = try container.decodeIfPresent(String.self, forKey: .dob)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.religion = try container.decodeIfPresent(String.self, forKey: .religion)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.bankAccountNumber = try container.decodeIfPresent(String.self, forKey: .bankAccountNumber)
    }
}


struct StaffDetailsResponse: Codable {
    let status: String?
    let data: StaffDetailsData
}

struct StaffDetailsData: Codable {
    let staffId: String
    let aadharNumber: String
    let address: String
    let bankAccountNumber: String
    let bankIfscCode: String
    let bloodGroup: String
    let caste: String
    let designation: String
    let disability: String
    let dob: String
    let doj: String
    let email: String
//    let emergencyContactNumber: String
//    let fatherName: String
    let gender: String
    let image: String?
//    let motherName: String
    let name: String
    let panNumber: String
    let phone: String
//    let profession: String
    let qualification: String
    let religion: String
    let staffCategory: String
    let type: String
    let uanNumber: String
    let classType: String?
}

struct StaffBasicInfoModel {
    let name: String
    let country: String
    let phone: String
    let staffId: String
    let doj: String
    let className: String
    let gender: String
    let qualification: String
    let dob: String
    let address: String
    let religion: String
    let caste: String
    let bloodGroup: String
    let emailId: String
    let aadharNo: String
    let type: String
//    let emergencyContact: String // Added
//    let fatherName: String // Added
//    let motherName: String // Added
//    let profession: String // Added
}

struct StaffAccountInfoModel {
    let uanNumber: String?
    let panNumber: String?
    let bankAccount: String?
    let bankIfsc: String?
}
