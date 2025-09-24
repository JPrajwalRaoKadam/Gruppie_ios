

import Foundation

struct EditStaffRequestModel: Codable {
    var aadharNumber: String
    var address: String
    var bankAccountNumber: String
    var bankIfscCode: String
    var bloodGroup: String
    var caste: String
    var designation: String
    var disability: String
    var dob: String
    var doj: String
    var email: String
    var emergencyContactNumber: String
    var fatherName: String
    var gender: String
    var image: String
    var motherName: String
    var name: String
    var panNumber: String
    var phone: String
    var profession: String
    var qualification: String
    var religion: String
    var staffCategory: String
    var type: String
    var uanNumber: String
}
struct EditStaffResponse: Codable {
    let success: Bool?
    let message: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? "No message from server"
    }
}
