import Foundation

struct AddManagementResponse: Codable {
    let status: String
    let message: String
    let data: ManagementData?
}

struct ManagementData: Codable {
    let managementId: String
}
