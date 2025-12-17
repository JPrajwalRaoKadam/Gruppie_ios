

import Foundation
struct ExamResponse1: Codable {
    let scheduleData: [ExamData1]
}

struct ExamData1: Codable {
    let year: String?
    let testType: String?
    let testName: String?
    let testId: String
    let month: String?
    let enable: Bool?
    let disabled: Bool?
    let aliasName: String?
}

// MARK: - Root Response
struct MarksCardResponse: Codable {
    let noteForMarksCardHeader: String?
    let noteForMarksCardFooter: String?
    let data: [StudentMarksData]
}

struct StudentMarksData: Codable {
    let testExamIds: [String]
    let dob: String?
    let teamId: String?
    let attendanceString: String?
    let duration: String?
    let isPublished: Bool
    let admissionNumber: String?
    let studentName: String?
    let attendanceEndDate: String?
    let gender: String?
    let attendanceStartDate: String?
    var subjectMarksDetails: [SubjectMarksDetails] // ✅ Changed to var
    let testId: String?
    let gradeRange: [String]
    let satsNo: String?
    let isApproved: Bool
    var overallPercentage: Double?
    let studentImage: String?
    let fatherName: String?
    let resultDate: String?
    let omrNO: String?
    let updatedBy: String?
    let numberOfWorkingDays: FlexibleString?
    let status: String?
    let averageMarks: Int?
    let totalMaxMarks: Int?
    let noteForMarkscard: String?
    let address: String?
    let totalMinMarks: Int?
    let rollNumber: String?
    let motherName: String?
    let studentId: String?
    let result: String?
    let groupId: String?
    var actualTotalMarks: Double? // ✅ Changed to var
    let satsNumber: String?
    let userId: String?
    let gruppieRollNumber: String?
    let partB: [String]
    let presentDays: FlexibleString?
    let testExamTitle: String?
    var overallGrade: String? // ✅ Changed to var
}

struct SubjectMarksDetails: Codable {
    let type: String?
    let submarkslength: Int?
    let subjectSort: Int?
    let subjectPriority: Int?
    let subjectName: String?
    let subjectId: String?
    var subjectGrade: String? // ✅ Changed to var
    var subjectAverageMarks: Double? // ✅ Changed to var
    var subMarks: [SubMarks] // ✅ Changed to var
    let startTime: String?
    let shortName: String?
    let minMarks: String
    let maxMarks: String
    let inwords: String?
    let gradeRange: [String]
    let endTime: String?
    let enable: Bool?
    let date: String?
    let attendance: String?
    var actualMarks: String? // ✅ Already var
}

struct SubMarks: Codable {
    let type: String?
    let splitName: String?
    let shortName: String?
    let minMarks: String?
    let maxMarks: String?
    let attendance: String?
    let applyAttendance: Bool?
    var actualMarks: String? // ✅ Already var
}

// MARK: - FlexibleString
struct FlexibleString: Codable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            value = str
        } else if let intVal = try? container.decode(Int.self) {
            value = String(intVal)
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Root Response
struct EditAllMarksResponse: Codable {
    let title: String?
    let message: String?
    let data: [EditAllMarksStudent]
    let code: Int?
}

// MARK: - Student Marks Model
struct EditAllMarksStudent: Codable {
    let subjectPriority: Int?
    let subjectName: String?
    let subjectId: String?
    let subMarks: [SubMark]?   // ✅ FIXED
    let studentName: String?
    let studentImage: String?
    let rollNumber: String?
    let minMarks: String?
    let maxMarks: String?
    let inwords: String?
    let gruppieRollNumber: String?
    let attendance: String?
    var actualMarks: String?
}

struct SubMark: Codable {
    let type: String?
    let splitName: String?
    let shortName: String?
    let minMarks: String?
    let maxMarks: String?
    let attendance: String?
    let applyAttendance: Bool?
    let actualMarks: String?
}
struct EditAllMarksUpdateRequest: Codable {
    let studentMarksUpdates: [EditAllMarksStudentUpdate]
}
struct EditAllMarksStudentUpdate: Codable {
    let actualMarks: String
    let attendance: String
    let gruppieRollNumber: String
    let inwords: String
    let maxMarks: String
    let minMarks: String
    let rollNumber: String
    let studentImage: String
    let studentName: String
    let subMarks: [SubMark]
    let subjectId: String
    let subjectName: String
    let subjectPriority: Int
}
