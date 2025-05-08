//
//  MarksCard.swift
//  loginpage
//
//  Created by apple on 12/03/25.
//

// MARK: - Data Models
struct ExamDataResponse: Codable {
    let data: [ExamData]
}

struct ExamData: Codable {
    let updatedAt: String
    let totalMinMarks: String
    let totalMaxMarks: String
    let toAttendance: String?
    let title: String
    let testExamIds: [String]?
    let subjectMarksDetails: [SubjectMarksDetail]?
    let section: [Section]?
    let resultDate: String?
    let offlineTestExamId: String
    let isActive: Bool
    let insertedAt: String?
    let examScheduleId: Bool?
    let fromAttendance: String?
    let averageMarks: Int?  // Made optional
}

struct SubjectMarksDetail: Codable {
    let type: String?
    let subjectPriority: Int?
    let subjectName: String?
    let subjectId: String?
    let subMarks: [SubMark]?
    let startTime: String?
    let sortDate: String?
    let minMarks: String?
    let maxMarks: String?
    let marks: Bool?
    let isLanguage: Bool?
    let gradeRange: [GradeRange]?
    let endTime: String?
    let date: String?
}

struct SubMark: Codable {
    let type: String?
    let subMarksId: String?
    let minMarks: String?
    let maxMarks: String?
}

struct GradeRange: Codable {
    let toMarks: String?
    let gradeRangeId: String?
    let grade: String?
    let fromMarks: String?
}

struct Section: Codable {
    let value: String?
    let title: String?
}



struct ExamMarkDataResponse: Codable {
    let data: [StudentMarksData]?
}

struct StudentMarksData: Codable {
    let dob: String?
    let attendanceString: String?
    let percentage: Double?
    let admissionNumber: String?
    let fatherNumber: String?
    let studentName: String?
    var subjectMarksDetails: [SubjectMarkDetail]?
    let motherNumber: String?
    let sectionHeadings: [String]?
    let totalAttendance: Int?
    let studentImage: String?
    let fatherName: String?
    let optionalSubjects: String?
    let totalNumberOfAbsent: Int?
    let passClass: String?
    let totalMaxMarks: Int?
    let noteForMarkscard: String?
    let address: String?
    let remarks: String?
    let examDuration: String?
    let totalPresent: Int?
    let totalMinMarks: Int?
    let rollNumber: String?
    let totalObtainedMarks: Int?
    let examTitle: String?
    let totalNumberOfPresent: Int?
    let motherName: String?
    let satsNumber: String?
    let section: [Sections]?
    let offlineTestExamId: String?
    let userId: String?
    let phone: String?
    let imageNumber: String?
    let grade: String?
    let hallticketNumber: String?
    let minMarks: String?
    let maxMarks: String?   
}

struct SubjectMarkDetail: Codable {
    let type: String?
    let subjectPriority: Int?
    let subjectName: String?
    let subjectId: String?
    let subMarks: [String]?
    let startTime: String?
    var obtainedMarks: String?
    let isLanguage: Bool?
    let endTime: String?
    let date: String?
    let canPost: Bool?
}

struct Sections: Codable {
    let value: String?
    let title: String?
}
