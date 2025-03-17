import Foundation

// Feedback Response Model
struct FeedBackResponse: Codable {
    let data: [FeedBackItem]
}

// Feedback Item Model
struct FeedBackItem: Codable {
    let feedbackId: String?
    let title: String
    let startDate: String?
    let lastDate: String?
    let isActive: Bool?
    let options: [FeedbackOption]
    var question: String?  // ✅ Change 'let' to 'var' to make it mutable
    let noOfQuestions: String?
    let noOfOptions: String?
    let groupId: String?
    let updatedAt: String?
    let insertedAt: String?

    enum CodingKeys: String, CodingKey {
        case feedbackId, title, startDate, lastDate, isActive, options, question
        case noOfQuestions, noOfOptions, groupId, updatedAt, insertedAt
    }
}

// Feedback Option Model
struct FeedbackOption: Codable {
    let optionNo: String
    let option: String
    let marks: String
    let answer: Bool

    enum CodingKeys: String, CodingKey {
        case optionNo, option, marks, answer
    }
}

// Feedback Question Model
struct FeedbackQuestion: Codable {
    let question: String
    let marks: String
}

// Feedback Request Model
struct FeedBackRequest: Codable {
    let groupId: String
    let isActive: Bool
    let lastDate: String
    let noOfOptions: String
    let noOfQuestions: String
    let options: [FeedbackOption]
    let questionsArray: [FeedbackQuestion]
    let startDate: String
    let title: String
    let updatedAt: String
}

struct FeedClass: Codable {
    let data: [FeedClassItem]
}

struct FeedClassItem: Codable {
    let teamId: String
    let teacherName: String
    let subjectRequired: Bool
    let subjectId: Bool
    let studentAssignedStatus: String
    let staffAssignedStatus: String
    let role: String
    let phone: String
    let numberOfTimeAttendance: Int
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
    let classSort: Int
    let category: String?
    let admissionTeam: Bool
    let adminName: String
}
