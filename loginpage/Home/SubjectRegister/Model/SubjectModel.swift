import Foundation

struct SubjectResponse: Decodable {
    let data: [SubjectData]  // This is the array of subjects inside "data"
    let teamId: String?
    let groupId: String?// Added to store the teamId
}

struct SubjectData: Decodable {
    let totalNoOfStaffAssigned: Int?
    let teamId: String
    let teacherName: String
    let subjectRequired: Bool
    let subjectId: Bool
    let studentAssignedStatus: String?
    let staffAssignedStatus: String?
    let sortBy: String
    let role: String
    let phone: String
    let numberOfTimeAttendance: Int // Updated to handle both types
    let name: String
    let members: Int
    let jitsiToken: Bool
    let image: String?
    let gruppieClassName: String
    let enableAttendance: Bool
    let ebookId: Bool
    let downloadedCount: Int
    let departmentUserId: String
    let departmentHeadName: String
    let department: String
    let classTypeId: String
    let classTeacherId: String
    let classSort: String?
    let category: String?
    let admissionTeam: Bool
    let adminName: String
}

enum StringOrInt: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value for numberOfTimeAttendance")
        }
    }
}

enum CodableClassSort: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value for classSort")
        }
    }
}
