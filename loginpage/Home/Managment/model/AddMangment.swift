import Foundation

struct AddManagementRequest: Encodable {
    let fullName: String
    let dateOfBirth: String
    let mobileNumber: String
}

struct AddManagementResponse: Decodable {
    let success: Bool
    let message: String?
}
