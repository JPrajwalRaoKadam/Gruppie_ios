//
//  HomeWorkModel.swift
//  loginpage
//
//  Created by apple on 02/04/26.
//

import Foundation
struct AssignmentsResponse: Codable {
    let success: Bool?
    let message: String?
    let data: AssignmentData?
}

struct AssignmentData: Codable {
    let totalRecords: Int?
    let totalPages: Int?
    let currentPage: Int?
    let pageSize: Int?
    let data: [AssignmentItem]?
}

struct AssignmentItem: Codable {
    let assignmentId: String?
    let groupAcademicYearId: String?
    let classId: String?
    let subjectId: String?
    let chapterId: String?
    let staffId: String?
    let managementId: String?
    let userId: String?
    let description: String?
    let assignmentType: String?
    let attachmentLinks: [AssignmentAttachment]?
    let fileType: String?
    let isDeleted: Bool?
    let createdAt: String?
    let updatedAt: String?
    let teacher: String?
    let management: String?
    let user: AssignmentUser?
    let staff: String?
    let submissionSummary: SubmissionSummary?
}

struct AssignmentAttachment: Codable {
    let fileId: Int?
    let fileUrl: String?
    let fileName: String?
    let fileType: String?
}

struct AssignmentUser: Codable {
    let id: String?
    let name: String?
}

struct SubmissionSummary: Codable {
    let totalStudents: Int?
    let submittedCount: Int?
    let submittedCorrectCount: Int?
    let pendingCount: Int?
}

// MARK: - Create Assignment Response
struct CreateAssignmentResponse: Codable {
    let success: Bool?
    let message: String?
    let data: CreatedAssignment?
}

struct CreatedAssignment: Codable {
    let isDeleted: Bool?
    let assignmentId: String?
    let groupAcademicYearId: String?
    let classId: String?
    let subjectId: String?
    let chapterId: String?
    let staffId: String?
    let managementId: String?
    let userId: String?
    let fileType: String?
    let description: String?
    let assignmentType: String?
    let attachmentLinks: [AssignmentAttachment]?
    let createdAt: String?
    let updatedAt: String?
}
