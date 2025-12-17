import Foundation

struct GateResponse: Codable {
    let data: [GateData]
}

struct GateData: Codable {
    let gateId: String
    let gateNumber: String
    let location: String?
    let image: [String]?
}

struct VisitorListResponse: Codable {
    let data: [VisitorResponseModel]
}

struct VisitorResponseModel: Codable {
    let visitorsId: String
    let day: Int
    let checkOut: Bool?
    let visitorIdCardImage: [String]?
    let visitorImage: String?
    let gateName: String
    let visitorVehicleNo: String?
    let visitorApproved: Bool?
    let reason: String?
    let gateId: String
    let visitorAddress: String?
    let personToVisit: String?
    let securityApproved: Bool?
    let onDutyUserId: String?
    let visitorName: String
    let visitorComments: String?
    let receptionistComments: String?
    let personToVisitTeamId: String?
    let personToVisitUserId: String?
    let visitorMobileNo: String?
    let groupId: String
    let visitorAccepted: Bool? 
    let personToVisitImage: String?
    let year: Int
    let onDutyName: String?
    let deviceToken: String?
    let month: Int
    let building: String?
    let purposeOfVisit: String?
    let receptionistApproved: Bool?
}
