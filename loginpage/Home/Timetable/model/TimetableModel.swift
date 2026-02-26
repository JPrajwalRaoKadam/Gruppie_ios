import Foundation

// MARK: - TimetableResponse
struct TimetableResponse: Codable {
    let data: [ClassData]
}

struct ClassData: Codable {
    let id: String
    let className: String
    let classTeacher: String
}

// MARK: - Academic Schedule
struct AcademicScheduleResponse: Codable {
    let data: [DaySchedule]
}

struct DaySchedule: Codable {
    let day: String
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

// MARK: - Edit Timetable
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

// MARK: - Periods
struct PeriodResponse: Codable {
    let data: [PeriodData]
}

struct PeriodData: Codable {
    let staffId: String?
    let period: String?
    let name: String?
    let day: String?
    let subjectsHandled: [SubjectsData]?
    
    // Optional start and end time
    let startTime: String?
    let endTime: String?
    
    // ✅ Extract the first className for convenience
    var className: String? {
        return subjectsHandled?.first?.className
    }
}

struct SubjectsData: Codable {
    let subjectId: String?
    let subjectName: String?
    let className: String? // ✅ Already exists in JSON
    let optional: Bool?
}

// MARK: - TimeTable
struct TimeTableResponse: Codable {
    let data: [TimeTableData]
}

struct TimeTableData: Codable {
    let examTimeTable: [ExamTimeTable]
    let academicTimeTable: [AcademicTimeTable]
}

struct ExamTimeTable: Codable {
}

struct AcademicTimeTable: Codable {
    let teamId: String
    let name: String
    let classTimeTable: [ClassTimeTable]
}

struct ClassTimeTable: Codable {
    let subjectWithStaffId: String
    let subjectName: String
    let startTime: String
    let period: String
    let endTime: String
}

// MARK: - Daily Summary (updated for API response)
struct DailySummaryAPIResponse: Codable {
    let success: Bool
    let message: String
    let data: DailySummaryData
}

struct DailySummaryData: Codable {
    let groupAcademicYearId: String
    let dayId: String
    let dayName: String
    let summary: SummaryData
    let classes: [DailyClass]
}

struct SummaryData: Codable {
    let totalClasses: Int
    let activeClasses: Int
    let totalScheduledPeriods: Int
}
struct DailyClass: Codable {
    let classId: String
    let className: String?
    let totalPeriods: Int?           // Flexible decoding
    let classStartTime: String?
    let classEndTime: String?
    let scheduledPeriods: Int?
    let periods: [PeriodDataAPI]?

    var noOfPeriods: Int {
        return periods?.count ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case classId, className, totalPeriods, classStartTime, classEndTime, scheduledPeriods, periods
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        classId = try container.decode(String.self, forKey: .classId)
        className = try container.decodeIfPresent(String.self, forKey: .className)
        classStartTime = try container.decodeIfPresent(String.self, forKey: .classStartTime)
        classEndTime = try container.decodeIfPresent(String.self, forKey: .classEndTime)
        scheduledPeriods = try container.decodeIfPresent(Int.self, forKey: .scheduledPeriods)
        periods = try container.decodeIfPresent([PeriodDataAPI].self, forKey: .periods)

        // 🔹 Flexible decoding: string or int
        if let intVal = try? container.decode(Int.self, forKey: .totalPeriods) {
            totalPeriods = intVal
        } else if let strVal = try? container.decode(String.self, forKey: .totalPeriods),
                  let intFromStr = Int(strVal) {
            totalPeriods = intFromStr
        } else {
            totalPeriods = nil
        }
    }
}

struct PeriodDataAPI: Codable {
    let periodId: String
    let periodNumber: String
    let startTime: String
    let endTime: String
    let timeTableEntry: TimeTableEntry
}

struct TimeTableEntry: Codable {
    let timeTableEntryId: String
    let subjectId: String
    let subjectName: String
    let staffId: String
    let staffName: String
    let profilePhotoUrl: String?
}

// MARK: - Days API (for fetching day list)
struct DaysResponse: Codable {
    let data: [DayData]
}

struct DayData: Codable {
    let id: Int
    let name: String
}
struct ScheduleAPIResponse: Codable {
    let success: Bool?
    let message: String?
    let data: ScheduleData?
}

struct ScheduleData: Codable {
    let groupAcademicYearId: String?
    let classId: String?
    let days: [ScheduleDay]?
}

struct ScheduleDay: Codable {
    let dayId: String?
    let dayName: String?
    let periods: [PeriodDataAPI]?
}
