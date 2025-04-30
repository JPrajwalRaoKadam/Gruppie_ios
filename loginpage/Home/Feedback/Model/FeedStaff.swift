import Foundation

struct FeedbackStudentResponse: Codable {
    let data: [FeedbackStudent]
}

struct FeedbackStudent: Codable {
    let userId: String
    let name: String
    let isSubmitted: Bool
}
