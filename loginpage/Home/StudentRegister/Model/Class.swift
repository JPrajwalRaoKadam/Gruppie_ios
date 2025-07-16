import Foundation

struct ClassListResponse: Codable {
    let data: [ClassList]
}

struct ClassList: Codable {
    let classes: [ClassType] 
}

struct ClassType: Codable {
    let type: String
    let departmentName: String?
    let departmentId: String?
    let classTypeId: String
    var classList: [ClassItem]

    enum CodingKeys: String, CodingKey {
        case type, departmentName, departmentId, classTypeId
        case classList = "class"
    }
}

struct ClassItem: Codable {

    var noOfSections: Int
    let className: String
}
