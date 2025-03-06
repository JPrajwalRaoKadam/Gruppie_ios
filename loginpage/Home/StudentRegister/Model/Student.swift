import Foundation

struct StudentTeamResponse: Codable {
    let data: [StudentTeam]
}

struct StudentTeam: Codable {
    let teamId: String
    let teacherName: String?
    let name: String
    let members: Int // Number of members, not an array
    let phone: String
    let image: String? // Base64 encoded URL
    let gruppieClassName: String?

    // Custom decoding for handling Base64 images
    enum CodingKeys: String, CodingKey {
        case teamId, teacherName, name, members, phone, image, gruppieClassName
    }

    // Decode base64 image to a URL string
    var decodedImageUrl: String? {
        guard let image = image,
              let decodedData = Data(base64Encoded: image),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
