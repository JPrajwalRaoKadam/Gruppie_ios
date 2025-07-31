import Foundation

struct StudentDiaryResponse: Codable {
    let data: [StudentDiaryData]
}

struct StudentDiaryData: Codable {
    let userId: String
    let studentName: String
    let studentImage: String?
    let rollNumber: String?
    var diaryItems: [StudentDiaryItem]
    let diaryDate: String
}

struct StudentDiaryItem: Codable {
    let time: String
    let text: String
    let isEditable: Bool
}
