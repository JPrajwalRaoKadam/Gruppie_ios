import Foundation

struct Student: Codable {
    let teamId: String
    let studentId: String
    let name: String
    let designation: String
    let teacherName: String?
    let phone: String?
    let decodedImageUrl: String?
}

struct StudentDetailsResponse: Codable {
    let data: [Student] 
}
