import Foundation

// MARK: - Feedback Response
struct FeedBackResponse: Codable {
    let data: [FeedBackItem]
}

// MARK: - Feedback Item
struct FeedBackItem: Codable {
    let feedbackId: String?
    let title: String?
    let startDate: String?
    let lastDate: String?
    let isActive: Bool?
    var options: [FeedbackOption]?
    var question: String?
    let noOfQuestions: String?
    let noOfOptions: String?
    let groupId: String?
    let updatedAt: String?
    let insertedAt: String?
    let feedbackTo: String?
    let feedbackBy: String?
    let name: String?
    let createdAt: String?

    let questionsArray: [QuestionData]?   // ✅ Updated to new structure

    enum CodingKeys: String, CodingKey {
        case feedbackId, title, startDate, lastDate, isActive, options, question
        case noOfQuestions, noOfOptions, groupId, updatedAt, insertedAt
        case feedbackTo, feedbackBy, name, createdAt, questionsArray
    }
}

// MARK: - Feedback Option
struct FeedbackOption: Codable {
    var optionNo: String
    var option: String
    var marks: String
    var answer: Bool

    enum CodingKeys: String, CodingKey {
        case optionNo, option, marks, answer
    }
}

// MARK: - Feedback Question (Updated)
struct QuestionData: Codable {
    var questionNo: Int?
    var question: String
    var marks: Int?
    var options: [FeedbackOption]
}
// MARK: - Feedback Option for Questions
struct OptionData: Codable {
    let optionNo: String
    let option: String
    let marks: String
    let answer: Bool
}

// MARK: - Feedback Request
struct FeedBackRequest: Codable {
    let groupId: String
    let isActive: Bool
    let lastDate: String?
    let noOfOptions: String?
    let noOfQuestions: String?
    let options: [FeedbackOption]?
    let questionsArray: [QuestionData]?
    let startDate: String?
    let title: String?
    let updatedAt: String
}

// MARK: - Feed Class List
struct FeedClass: Codable {
    let data: [FeedClassItem]
}

// MARK: - Feed Class Item
struct FeedClassItem: Codable {
    let teamId: String
    let teacherName: String?
    let subjectRequired: Bool
    let subjectId: Bool?
    let studentAssignedStatus: String?
    let staffAssignedStatus: String?
    let role: String
    let phone: String
    let numberOfTimeAttendance: String
    let name: String
    let members: Int
    let jitsiToken: Bool
    let image: String?
    let gruppieClassName: String?
    let enableAttendance: Bool
    let ebookId: Bool
    let downloadedCount: Int
    let departmentUserId: String
    let departmentHeadName: String
    let department: String
    let classTypeId: String?
    let classTeacherId: String
    let classSort: Int?
    let category: String?
    let admissionTeam: Bool
    let adminName: String
    let feedbackTo: String?
    let feedbackBy: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case teamId, teacherName, subjectRequired, subjectId, studentAssignedStatus, staffAssignedStatus
        case role, phone, numberOfTimeAttendance, name, members, jitsiToken, image, gruppieClassName
        case enableAttendance, ebookId, downloadedCount, departmentUserId, departmentHeadName, department
        case classTypeId, classTeacherId, classSort, category, admissionTeam, adminName
        case feedbackTo, feedbackBy, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        teamId = try container.decode(String.self, forKey: .teamId)
        teacherName = try container.decodeIfPresent(String.self, forKey: .teacherName)
        subjectRequired = try container.decode(Bool.self, forKey: .subjectRequired)
        subjectId = try container.decodeIfPresent(Bool.self, forKey: .subjectId)
        studentAssignedStatus = try container.decodeIfPresent(String.self, forKey: .studentAssignedStatus)
        staffAssignedStatus = try container.decodeIfPresent(String.self, forKey: .staffAssignedStatus)
        role = try container.decode(String.self, forKey: .role)
        phone = try container.decode(String.self, forKey: .phone)

        // Handle numberOfTimeAttendance safely
        if let numberString = try? container.decode(String.self, forKey: .numberOfTimeAttendance) {
            numberOfTimeAttendance = numberString
        } else if let numberInt = try? container.decode(Int.self, forKey: .numberOfTimeAttendance) {
            numberOfTimeAttendance = String(numberInt)
        } else if let numberDouble = try? container.decode(Double.self, forKey: .numberOfTimeAttendance) {
            numberOfTimeAttendance = String(numberDouble)
        } else {
            numberOfTimeAttendance = ""
        }

        name = try container.decode(String.self, forKey: .name)
        members = try container.decode(Int.self, forKey: .members)
        jitsiToken = try container.decode(Bool.self, forKey: .jitsiToken)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        gruppieClassName = try container.decodeIfPresent(String.self, forKey: .gruppieClassName)
        enableAttendance = try container.decode(Bool.self, forKey: .enableAttendance)
        ebookId = try container.decode(Bool.self, forKey: .ebookId)
        downloadedCount = try container.decode(Int.self, forKey: .downloadedCount)
        departmentUserId = try container.decode(String.self, forKey: .departmentUserId)
        departmentHeadName = try container.decode(String.self, forKey: .departmentHeadName)
        department = try container.decode(String.self, forKey: .department)
        classTypeId = try container.decodeIfPresent(String.self, forKey: .classTypeId)
        classTeacherId = try container.decode(String.self, forKey: .classTeacherId)
        classSort = try container.decodeIfPresent(Int.self, forKey: .classSort)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        admissionTeam = try container.decode(Bool.self, forKey: .admissionTeam)
        adminName = try container.decode(String.self, forKey: .adminName)
        feedbackTo = try container.decodeIfPresent(String.self, forKey: .feedbackTo)
        feedbackBy = try container.decodeIfPresent(String.self, forKey: .feedbackBy)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
