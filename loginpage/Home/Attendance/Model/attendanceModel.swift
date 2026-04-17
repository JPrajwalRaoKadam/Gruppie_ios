
import Foundation
//AttendanceVC
struct AttendanceSummaryResponse: Decodable {
    let success: Bool
    let message: String
    let data: AttendanceSummaryData
}

struct AttendanceSummaryData: Decodable {
    let groupAcademicYearId: String
    let groupAcademicYear: String
    let date: String
    let classes: [AttendanceClassSummary]
}

struct AttendanceClassSummary: Decodable {
    let classId: String
    let className: String
    let totalStudents: Int
    let sessions: [AttendanceSession]
}

struct AttendanceSession: Decodable {
    let sessionNumber: Int
    let presentStudents: Int
    let subjectName: String
    let staffName: String
}





// MARK: - Student Response Model
struct StudentResponse: Codable {
    let data: [StudentAtten]
}

// MARK: - Student Model
struct StudentAtten: Codable {
    let userId: String
    let studentName: String
    let studentImage: String?  // Handles null, empty, or image URL
    let rollNumber: String
    let fatherName: String?
    let lastDaysAttendance: [StudentAttendance]

    // Custom decoding initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        studentName = try container.decodeIfPresent(String.self, forKey: .studentName) ?? "Unknown"
        studentImage = try container.decodeIfPresent(String.self, forKey: .studentImage) ?? ""
        rollNumber = try container.decodeIfPresent(String.self, forKey: .rollNumber) ?? "N/A"
        fatherName = try container.decodeIfPresent(String.self, forKey: .fatherName) ?? "Unknown"
        lastDaysAttendance = try container.decodeIfPresent([StudentAttendance].self, forKey: .lastDaysAttendance) ?? []
    }
        /// Returns true if *any* recorded attendance for this student is "holiday"
        var hasHolidayAttendance: Bool {
            return lastDaysAttendance.contains {
                $0.attendance?.lowercased() == "holiday"
            }
        }
    

}

// MARK: - Attendance Model
struct StudentAttendance: Codable {
    let time: String?
    let teacherName: String?
    let teacherId: String?
    let subjectName: String?
    let subjectId: String?
    let periodNumber: Int?
    let day: Int?
    let dateString: String?
    let date: String?
    let attendanceId: String?
    let attendanceAt: String?
    let attendance: String?
    
    // Coding keys for mapping
    enum CodingKeys: String, CodingKey {
        case time, teacherName, teacherId, subjectName, subjectId, periodNumber, day, dateString, date, attendanceId, attendanceAt, attendance
    }
}


struct SubjectRegisterResponse1: Decodable {
    let success: Bool
    let data: SubjectRegisterData
}

struct SubjectRegisterData: Decodable {
    let `class`: SubjectRegisterClass
    let subjectGroups: [SubjectGroup]
}

struct SubjectRegisterClass: Decodable {
    let classId: Int
    let className: String
    let totalStudents: Int
}

struct SubjectGroup: Decodable {
    let type: String
    let subjects: [SubjectRegisterSubject]
}

struct SubjectRegisterSubject: Decodable {
    let subjectId: Int
    let subjectName: String
    let code: String
    let subjectPriority: Int
    let isActive: Bool
    let isCustom: Bool
    let assignedStaffCount: Int
    let assignedStudentsCount: Int
    let assignedStaff: [AssignedStaff]
}

struct AssignedStaff: Decodable {
    let staffId: Int
    let staffName: String
    let profilePhoto: String?
}

struct Attendance: Codable {
        let teamId: String
        let numberOfTimeAttendance: String // Change this to String
        let name: String
        let image: String?
        let attendanceTaken: Bool
        let attendanceStatus: [AttendanceStatus]?
        let classSort: Int?
        
        enum CodingKeys: String, CodingKey {
            case teamId
            case numberOfTimeAttendance
            case name
            case image
            case attendanceTaken
            case attendanceStatus
            case classSort
        }
        
        struct AttendanceStatus: Codable {
            let type: String
            let present: Int
            let absent: Int
        }
}//setting
struct AttendanceModel: Codable {
    let teamId: String
    let numberOfTimeAttendance: String
    let name: String
    let image: String
    let enableAttendance: Bool

    init(teamId: String, numberOfTimeAttendance: String, name: String, image: String, enableAttendance: Bool) {
        self.teamId = teamId
        self.numberOfTimeAttendance = numberOfTimeAttendance
        self.name = name
        self.image = image
        self.enableAttendance = enableAttendance
    }
}
struct AttendanceSettingsAllResponse: Decodable {
    let success: Bool
    let message: String
    let data: [AttendanceSettingsClass]
    let meta: AttendanceSettingsMeta
}

struct AttendanceSettingsClass: Decodable {
    let classId: String
    let className: String
    let settings: [AttendanceSettingItem]
}

struct AttendanceSettingItem: Decodable {
    let attendanceSettingsId: String
    let dayOfWeek: String
    let attendanceMode: String
    let sessionsPerDay: Int
    let startTime: String?
    let endTime: String?
    let isHoliday: Bool
    let isActive: Bool
}

struct AttendanceSettingsMeta: Decodable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
}


//StudentVC
struct StudentMinimalListResponse: Decodable {
    let success: Bool
    let message: String
    let data: StudentMinimalListData
    let pagination: Pagination1
}

struct StudentMinimalListData: Decodable {
    let groupAcademicYearId: String
    let classId: String
    let className: String
    let totalStudents: Int
    let studentsList: [StudentMinimal]
}

struct StudentMinimal: Decodable {
    let studentId: String
    let fullName: String
    let gender: String?
    let omrNumber: String?
    let rollNumber: String?
    let satsNumber: String?
    let studentMobileNumber: String?
    let fatherMobileNumber: String?
    let motherMobileNumber: String?
    let fatherName: String?
    let motherName: String?
    let profilePhoto: String?
}

struct Pagination1: Decodable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
}
struct AttendanceSessionsResponse: Decodable {
    let success: Bool
    let message: String
    let data: AttendanceSessionsData
    let meta: AttendanceSessionsMeta
}

struct AttendanceSessionsData: Decodable {
    let classId: String
    let className: String
    let groupAcademicYearId: String
    let sessions: [AttendanceSessionDetail]
}

struct AttendanceSessionDetail: Decodable {
    let sessionId: String
    let sessionDate: String
    let sessionNumber: Int
    let subjectId: String
    let subjectName: String
    let markedBy: String
    let markedByName: String
    let attendanceJson: [String: String]?
    let isLocked: Bool
}

struct AttendanceSessionsMeta: Decodable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
}

struct ClassAttendanceSettingsResponse: Decodable {
    let success: Bool
    let message: String
    let data: ClassAttendanceSettingsData
}

struct ClassAttendanceSettingsData: Decodable {
    let groupAcademicYearId: Int
    let classId: Int
    let className: String
    let attendanceSettings: [ClassAttendanceSettingItem]
}

struct ClassAttendanceSettingItem: Decodable {
    let attendanceSettingsId: String
    let dayOfWeek: String
    let attendanceMode: String
    let sessionsPerDay: Int
    let startTime: String?
    let endTime: String?
    let isHoliday: Bool
    let isActive: Bool
}
struct CommonSuccessResponse: Decodable {
    let success: Bool
    let message: String
}



struct StudentClassResponse: Codable {
    let success: Bool
    let message: String
    let data: [GroupClass1]
}

struct GroupClass1: Codable {
    let id: String
    let name: String
    let classType: String
    let groupAcademicYearId: String
}


struct StudentListResponse: Codable {
    let success: Bool
    let message: String
    let data: [StudentListItem]
}

struct StudentListItem: Codable {
    let studentId: String
    let groupClassId: String
    let className: String
    let name: String
    let gender: String
    let dateOfBirth: String?
    let mobileNumber: String?
}
