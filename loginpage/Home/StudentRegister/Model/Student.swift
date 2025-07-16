import Foundation

struct StudentTeamResponse: Codable {
    let data: [StudentTeam]
}

struct StudentTeam: Codable {
    let teamId: String
    let teacherName: String?
    let name: String
    let members: Int
    let phone: String
    let image: String?
    let gruppieClassName: String?

    enum CodingKeys: String, CodingKey {
        case teamId, teacherName, name, members, phone, image, gruppieClassName
    }

    var decodedImageUrl: String? {
        guard let image = image,
              let decodedData = Data(base64Encoded: image),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
