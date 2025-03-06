import Foundation

struct StaffData: Codable {
    let countryCode: String
    let designation: String
    let name: String
    let permanent: Bool
    let phone: String
}

struct StaffRequest: Codable {
    let staffData: [StaffData]
}
