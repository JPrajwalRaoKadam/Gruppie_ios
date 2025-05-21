
import Foundation

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
// MARK: - Top-level response
struct SubjectResponseAtten: Codable {
    let data: [SubjectDataAtten]
}

// MARK: - Each subject item
struct SubjectDataAtten: Codable {
    let subjectName: String
    let subjectId : String
    // Add others if needed like subjectId, canPost, etc.
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
