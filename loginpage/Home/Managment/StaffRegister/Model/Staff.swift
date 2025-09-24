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
    var status: String?
    var data: StaffDetailsData
}

struct StaffDetailsData: Codable {
    var staffId: String?
    var aadharNumber: String?
    var address: String?
    var bankAccountNumber: String?
    var bankIfscCode: String?
    var bloodGroup: String?
    var caste: String?
    var designation: String?
    var disability: String?
    var dob: String?
    var doj: String?
    var email: String?
//    var emergencyContactNumber: String
//    var fatherName: String
    var gender: String?
    var image: String?
//    var motherName: String
    var name: String?
    var panNumber: String?
    var phone: String?
//    var profession: String
    var qualification: String?
    var religion: String?
    var staffCategory: String?
    var type: String?
    var uanNumber: String?
    var classType: String?
    var country: String?
    
    var className: String?
    var emailId: String?
    var aadharNo: String?
    
    var bankAccount: String?
    var bankIfsc: String?
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
