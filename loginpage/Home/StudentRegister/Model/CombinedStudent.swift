import Foundation

struct CombinedStudentTeamResponse: Codable {
    let data: [CombinedStudentTeam]
}

struct CombinedStudentTeam: Codable {
    let teamId: String
    let teacherName: String?
    let name: String
    let members: Int
    let phone: String
    let image: String?
    let gruppieClassName: String?
    let adminName: String?
    
    var decodedImageUrl: String? {
        guard let image = image,
              let decodedData = Data(base64Encoded: image),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
