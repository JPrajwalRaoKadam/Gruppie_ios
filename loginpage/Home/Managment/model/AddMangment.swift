import Foundation

// Model for the API response
struct AddManagementResponse: Codable {
    let status: String
    let message: String
    let data: ManagementData?
}

struct ManagementData: Codable {
    let managementId: String
}
