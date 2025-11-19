import Foundation

// MARK: - API Response Models
struct AttendanceResponse: Codable {
    let data: [APIStaffAttendance]
}

struct APIStaffAttendance: Codable {
    let userId: String
    let name: String
    let leave: Bool
    let attendance: [AttendanceDetail]
}

struct AttendanceDetail: Codable {
    let time: String
    let session: String
    let ood: Bool
    let day: Int
    let dateString: String
    let date: String
    let attendanceTakenByName: String
    let attendanceTakenById: String
    let attendanceId: String
    let attendance: String
    
    enum CodingKeys: String, CodingKey {
        case time
        case session
        case ood
        case day
        case dateString
        case date
        case attendanceTakenByName
        case attendanceTakenById
        case attendanceId
        case attendance
    }
}

// MARK: - API Request Models
struct AttendanceRequest: Codable {
    let attendanceData: [SessionAttendanceData]
}

struct SessionAttendanceData: Codable {
    let attendance: [AttendanceStatus]
    let session: String
}

struct AttendanceStatus: Codable {
    let status: String
    let userIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case status
        case userIds = "userIds"
    }
}

// MARK: - Local Data Model
struct StaffAttendance {
    var id: String
    var name: String
    var attendanceStatus: String?
    var isOOD: Bool = false
    
    // Helper computed property to determine if staff is effectively on leave
    var isOnLeave: Bool {
        return isOOD || attendanceStatus == "On Leave"
    }
}

// MARK: - Helper Extension for APIStaffAttendance
extension APIStaffAttendance {
    func getAttendanceStatus(for session: String) -> (status: String?, isOOD: Bool) {
        // Check if staff is on leave
        if leave {
            return ("On Leave", false)
        }
        
        // Find attendance for the specific session
        let sessionAttendance = attendance.first { $0.session == session }
        
        // Check if OOD (Out of Duty) is true
        if let sessionAttendance = sessionAttendance, sessionAttendance.ood {
            return ("On Leave", true)
        }
        
        // Check attendance status
        if let sessionAttendance = sessionAttendance {
            switch sessionAttendance.attendance.lowercased() {
            case "present":
                return ("Present", false)
            case "absent":
                return ("Absent", false)
            case "on leave", "leave":
                return ("On Leave", false)
            default:
                return (nil, false)
            }
        }
        
        return (nil, false)
    }
}
