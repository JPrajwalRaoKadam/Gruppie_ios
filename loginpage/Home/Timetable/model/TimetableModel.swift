

import Foundation
struct TimetableResponse: Codable {
    let data: [ClassData]
}

struct ClassData: Codable {
    let id: String
    let className: String
    let classTeacher: String
}



struct AcademicScheduleResponse: Codable {
    let data: [DaySchedule]
}

struct DaySchedule: Codable {
    let day: String   // Changed from Int to String
    let sessions: [Session]
}

struct Session: Codable {
    var teacherName: String?
    var subjectName: String
    var subjectId: String?
    var startTime: String
    var staffId: String?
    var period: String
    var endTime: String
    var day: String?
}

struct EditTimetableResponse: Codable {
    let data: [SubjectDatas]
}

struct SubjectDatas: Codable {
    let subjectWithStaffs: [StaffDatas]
    let subjectWithStaffId: String
    let subjectName: String
    let period: String
    let day: String
}

struct StaffDatas: Codable {
    let staffName: String
    let staffId: String
}
struct PeriodResponse: Codable {
    let data: [PeriodData]
}

struct PeriodData: Codable {
    let staffId: String?
    let period: String?
    let name: String?
    let day: String?
    let subjectsHandled: [SubjectsData]?
}

struct SubjectsData: Codable {
    let subjectName: String?
    let subjectId: String?
    let optional: Bool?
    let className: String?
}

// MARK: - Root
struct TimeTableResponse: Codable {
    let data: [TimeTableData]
}

// MARK: - Data
struct TimeTableData: Codable {
    let examTimeTable: [ExamTimeTable]
    let academicTimeTable: [AcademicTimeTable]
}

// MARK: - ExamTimeTable (empty for now)
struct ExamTimeTable: Codable {
    // Define later when structure is available
}

// MARK: - AcademicTimeTable
struct AcademicTimeTable: Codable {
    let teamId: String
    let name: String
    let classTimeTable: [ClassTimeTable]
}

// MARK: - ClassTimeTable
struct ClassTimeTable: Codable {
    let subjectWithStaffId: String
    let subjectName: String
    let startTime: String
    let period: String
    let endTime: String
}
