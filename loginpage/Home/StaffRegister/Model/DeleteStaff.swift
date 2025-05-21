
import Foundation
struct DeleteStaffRequestModel: Codable {
    let type: String
    
    init(type: String = "staff") {
        self.type = type
    }
}
struct DeleteStaffResponse: Codable {
    let success: Bool?
    let message: String?
}
