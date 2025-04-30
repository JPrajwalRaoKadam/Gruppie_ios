import Foundation

struct GroupResponse: Codable {
    var data: [Group]
    var token: String?
}

struct Group: Codable {
    var id: String
    var name: String
}
