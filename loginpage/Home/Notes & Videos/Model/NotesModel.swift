//
//  staffFModel.swift
//  loginpage
//
//  Created by apple on 12/04/25.
//



import Foundation

// MARK: - Root

struct SubjectRegisterAPIResponse: Decodable {
    let success: Bool
    let data: SubjectRegisterPayload
}

// MARK: - Main Payload

struct SubjectRegisterPayload: Decodable {

    let classInfo: SubjectRegisterClassInfo
    let subjectGroups: [SubjectRegisterGroup]

    enum CodingKeys: String, CodingKey {
        case classInfo = "class"
        case subjectGroups
    }
}

// MARK: - Class Info

struct SubjectRegisterClassInfo: Decodable {
    let classId: Int
    let className: String
    let totalStudents: Int
}

// MARK: - Group

struct SubjectRegisterGroup: Decodable {
    let type: String
    let subjects: [SubjectRegisterSubjectDetail]
}

// MARK: - Subject Detail

struct SubjectRegisterSubjectDetail: Decodable {

    let subjectId: Int
    let subjectName: String
    let code: String
    let subjectPriority: Int
    let isActive: Bool
    let isCustom: Bool
    let assignedStaffCount: Int
    let assignedStudentsCount: Int
    let assignedStaff: [SubjectRegisterAssignedStaff]
}

// MARK: - Assigned Staff

struct SubjectRegisterAssignedStaff: Decodable {
    let staffId: Int
    let staffName: String
    let profilePhoto: String?
}
//old model 3/3/26
struct Stafff: Codable {
    let name: String?
    let staffId: String?
}

// MARK: - Root Response


struct SyllabusResponse: Codable {
    let data: [Chapter]
}

struct Chapter: Codable {
    let chapterName: String
    let chapterId: String
    let totalTopicsCount: Int
    let topicsList: [TopicAdd]
}

struct TopicAdd: Codable {
    let topicName: String
    let topicId: String
}
struct NotesResponse: Decodable {
    let success: Bool?
    let pagination: NotesPagination?
    let data: [NoteItem]?
}
struct NotesPagination: Decodable {
    let totalRecords: Int?
    let totalPages: Int?
    let currentPage: Int?
    let pageSize: Int?
}
struct NoteItem: Decodable {
    let noteId: String?
    let groupId: String?
    let classId: String?
    let subjectId: String?
    let chapterId: String?
    let title: String?
    let description: String?
    let attachmentLinks: [AttachmentLink]?
    let groupAcademicYearId: String?
    let isDeleted: Bool?
    let createdAt: String?
    let updatedAt: String?
}
struct AttachmentLink: Decodable {
    let fileId: Int?
    let fileUrl: String?
    let fileName: String?
    let fileType: String?
    let createdAt: String?
}

// MARK: - Model Definitions
struct SubjectPostRequest: Codable {
    let chapterName: String
    let fileName: [String]
    let fileType: String
    let thumbnailImage: [String]
    let topicName: String
    let video: String
}

struct SubjectPostResponse: Codable {
    let success: Bool
    let message: String?
}

struct DeleteNoteResponse: Decodable {
    let success: Bool?
    let message: String?
}
    struct AddNoteResponse: Decodable {
        let success: Bool?
        let message: String?
    }
