import Foundation

// MARK: - Subject Register Response
struct SubjectRegisterResponse: Decodable {
    let data: [SubjectDetail]
}

// MARK: - Subject Detail
struct SubjectDetail: Decodable, Hashable {
    let universityCode: String?
    let totalNoOfStudents: Int?
    let subjectPriority: Int?
    let subjectName: String
    let subjectId: String?
    let staffName: [SubjectStaffMember]?
    let partSubject: String?
    let parentSubject: String?
    let optional: Bool?
    let noOfStudentsUnAssigned: Int?
    let noOfStudentsAssigned: Int?
    let manual: String?
    let isLanguage: Bool
    let canPost: Bool?

    enum CodingKeys: String, CodingKey {
        case universityCode, totalNoOfStudents, subjectPriority, subjectName, subjectId, staffName
        case partSubject, parentSubject, optional, noOfStudentsUnAssigned, noOfStudentsAssigned, manual, isLanguage, canPost
    }

    init(
        universityCode: String?,
        totalNoOfStudents: Int?,
        subjectPriority: Int?,
        subjectName: String,
        subjectId: String?,
        staffName: [SubjectStaffMember]?,
        partSubject: String?,
        parentSubject: String?,
        optional: Bool?,
        noOfStudentsUnAssigned: Int?,
        noOfStudentsAssigned: Int?,
        manual: String?,
        isLanguage: Bool,
        canPost: Bool?
    ) {
        self.universityCode = universityCode
        self.totalNoOfStudents = totalNoOfStudents
        self.subjectPriority = subjectPriority
        self.subjectName = subjectName
        self.subjectId = subjectId
        self.staffName = staffName
        self.partSubject = partSubject
        self.parentSubject = parentSubject
        self.optional = optional
        self.noOfStudentsUnAssigned = noOfStudentsUnAssigned
        self.noOfStudentsAssigned = noOfStudentsAssigned
        self.manual = manual
        self.isLanguage = isLanguage
        self.canPost = canPost
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        universityCode = try container.decodeIfPresent(String.self, forKey: .universityCode)
        totalNoOfStudents = try container.decodeIfPresent(Int.self, forKey: .totalNoOfStudents)
        subjectPriority = try container.decodeIfPresent(Int.self, forKey: .subjectPriority)
        subjectName = try container.decode(String.self, forKey: .subjectName)
        subjectId = try container.decodeIfPresent(String.self, forKey: .subjectId)
        staffName = try container.decodeIfPresent([SubjectStaffMember].self, forKey: .staffName)
        partSubject = try container.decodeIfPresent(String.self, forKey: .partSubject)
        parentSubject = try container.decodeIfPresent(String.self, forKey: .parentSubject)
        noOfStudentsUnAssigned = try container.decodeIfPresent(Int.self, forKey: .noOfStudentsUnAssigned)
        noOfStudentsAssigned = try container.decodeIfPresent(Int.self, forKey: .noOfStudentsAssigned)

        optional = Self.decodeBool(from: container, forKey: .optional)
        canPost = Self.decodeBool(from: container, forKey: .canPost)
        isLanguage = Self.decodeBool(from: container, forKey: .isLanguage) ?? false

        // Handle manual field as String or Bool
        if let stringValue = try? container.decode(String.self, forKey: .manual) {
            manual = stringValue
        } else if let boolValue = try? container.decode(Bool.self, forKey: .manual) {
            manual = boolValue ? "true" : "false"
        } else {
            manual = nil
        }
    }

    private static func decodeBool(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Bool? {
        if let boolValue = try? container.decode(Bool.self, forKey: key) {
            return boolValue
        }
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue.lowercased() == "true"
        }
        return nil
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(subjectId)
    }

    static func == (lhs: SubjectDetail, rhs: SubjectDetail) -> Bool {
        return lhs.subjectId == rhs.subjectId
    }
}

struct SubjectStaffMember: Decodable {
    let staffName: String
    let staffId: String
}

struct APIStaffListResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: [APIStaffMember]
    let totalStaff: Int?
}

struct APIStaffMember: Decodable {
    let staffId: String?
    let fullName: String?
    let id: String?
    let userId: String?
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let gender: String?
    let dateOfBirth: String?
    let nationality: String?
    let religion: String?
    let bloodGroup: String?
    let maritalStatus: String?
    let contactNumber: String?
    let alternateContactNumber: String?
    let email: String?
    let nationalId: String?
    let emergencyContactName: String?
    let emergencyContactNumber: String?
    let profilePhotoUrl: String?
    let staffCategory: String?
    let staffType: String?
    let staffDepartment: String?
    let designation: String?
    let reportingManager: String?
    let jobGrade: String?
    let workLocation: String?
    let staffCode: String?
    let employeeStatus: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case staffId
        case fullName
        case id
        case userId
        case firstName
        case middleName
        case lastName
        case gender
        case dateOfBirth
        case nationality
        case religion
        case bloodGroup
        case maritalStatus
        case contactNumber
        case alternateContactNumber
        case email
        case nationalId
        case emergencyContactName
        case emergencyContactNumber
        case profilePhotoUrl
        case staffCategory
        case staffType
        case staffDepartment
        case designation
        case reportingManager
        case jobGrade
        case workLocation
        case staffCode
        case employeeStatus
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to get ID from different possible fields
        if let idValue = try? container.decode(String.self, forKey: .staffId) {
            staffId = idValue
        } else if let idValue = try? container.decode(String.self, forKey: .id) {
            staffId = idValue
        } else if let idValue = try? container.decode(String.self, forKey: .userId) {
            staffId = idValue
        } else {
            staffId = nil
        }
        
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        middleName = try container.decodeIfPresent(String.self, forKey: .middleName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        dateOfBirth = try container.decodeIfPresent(String.self, forKey: .dateOfBirth)
        nationality = try container.decodeIfPresent(String.self, forKey: .nationality)
        religion = try container.decodeIfPresent(String.self, forKey: .religion)
        bloodGroup = try container.decodeIfPresent(String.self, forKey: .bloodGroup)
        maritalStatus = try container.decodeIfPresent(String.self, forKey: .maritalStatus)
        contactNumber = try container.decodeIfPresent(String.self, forKey: .contactNumber)
        alternateContactNumber = try container.decodeIfPresent(String.self, forKey: .alternateContactNumber)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        nationalId = try container.decodeIfPresent(String.self, forKey: .nationalId)
        emergencyContactName = try container.decodeIfPresent(String.self, forKey: .emergencyContactName)
        emergencyContactNumber = try container.decodeIfPresent(String.self, forKey: .emergencyContactNumber)
        profilePhotoUrl = try container.decodeIfPresent(String.self, forKey: .profilePhotoUrl)
        staffCategory = try container.decodeIfPresent(String.self, forKey: .staffCategory)
        staffType = try container.decodeIfPresent(String.self, forKey: .staffType)
        staffDepartment = try container.decodeIfPresent(String.self, forKey: .staffDepartment)
        designation = try container.decodeIfPresent(String.self, forKey: .designation)
        reportingManager = try container.decodeIfPresent(String.self, forKey: .reportingManager)
        jobGrade = try container.decodeIfPresent(String.self, forKey: .jobGrade)
        workLocation = try container.decodeIfPresent(String.self, forKey: .workLocation)
        staffCode = try container.decodeIfPresent(String.self, forKey: .staffCode)
        employeeStatus = try container.decodeIfPresent(String.self, forKey: .employeeStatus)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    // Computed property to get display name (cleaned up)
    var displayName: String {
        // Try to use fullName first (from API)
        if let fullName = fullName, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Clean up extra spaces and optionally remove middle name
            let cleaned = fullName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            return cleaned
        }
        
        // Fallback to constructing from components (first + last only, skip middle)
        let firstName_ = firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName_ = lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !firstName_.isEmpty && !lastName_.isEmpty {
            return "\(firstName_) \(lastName_)"
        } else if !firstName_.isEmpty {
            return firstName_
        } else if !lastName_.isEmpty {
            return lastName_
        }
        
        return "Unknown"
    }
}

// Keep the original StaffListResponse and Staffs for backward compatibility
// MARK: - Staff List Response (Legacy)
struct StaffListResponse: Codable {
    let totalNumberOfPages: Int?
    let data: [Staffs]
    let subjectPriority: String?
}

// MARK: - Staffs (Legacy)
struct Staffs: Codable {
    let subjectPriority: String?
    let permanent: Bool?
    let accountant: Bool?
    let staffId: String?
    let designation: String?
    let type: String?
    let phone: String?
    let name: String?
    let userId: String?
    let payRollApprover: Bool?
    let admissionApprover: Bool?
    let examiner: Bool?
    let bankIfscCode: String?
    let bankAddress: String?
    let bankName: String?
    let category: String?
    let motherName: String?
    let aadharNumber: String?
    let subjectName: String?
    let studentName: String?

    enum CodingKeys: String, CodingKey {
        case subjectPriority, permanent, accountant, staffId, designation, type, phone, name, userId
        case payRollApprover, admissionApprover, examiner
        case bankIfscCode, bankAddress, bankName, category, motherName, aadharNumber
        case subjectName, studentName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        subjectPriority = try container.decodeIfPresent(String.self, forKey: .subjectPriority)
        permanent = Self.decodeBool(from: container, forKey: .permanent)
        accountant = Self.decodeBool(from: container, forKey: .accountant)
        payRollApprover = Self.decodeBool(from: container, forKey: .payRollApprover)
        admissionApprover = Self.decodeBool(from: container, forKey: .admissionApprover)
        examiner = Self.decodeBool(from: container, forKey: .examiner)

        staffId = try container.decodeIfPresent(String.self, forKey: .staffId)
        designation = try container.decodeIfPresent(String.self, forKey: .designation)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        bankIfscCode = try container.decodeIfPresent(String.self, forKey: .bankIfscCode)
        bankAddress = try container.decodeIfPresent(String.self, forKey: .bankAddress)
        bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        motherName = try container.decodeIfPresent(String.self, forKey: .motherName)
        aadharNumber = try container.decodeIfPresent(String.self, forKey: .aadharNumber)
        studentName = try container.decodeIfPresent(String.self, forKey: .studentName)
        subjectName = try container.decodeIfPresent(String.self, forKey: .subjectName)
    }

    private static func decodeBool(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Bool? {
        if let boolValue = try? container.decode(Bool.self, forKey: key) {
            return boolValue
        }
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue.lowercased() == "true"
        }
        return nil
    }
}

// MARK: - Student Subject Response (UPDATED)
struct StudentSubjectResponse: Codable {
    let success: Bool
    let classId: String
    let className: String
    let subjectType: String
    let subjectsCount: Int
    let totalNoOfStudents: Int
    let data: [StudentSubjectData]
}

struct StudentSubjectData: Codable {
    let subjectId: String
    let subjectName: String
    let type: String
    let subjectPriority: Int
    let students: [StudentSubjectStudent]
    let totalStudents: Int
}

struct StudentSubjectStudent: Codable {
    let studentId: String
    let firstName: String
    let middleName: String?
    let lastName: String?
    let omrNumber: String?
    
    // Computed property to get full name
    var studentName: String {
        let components = [firstName, middleName, lastName].compactMap { $0 }
        return components.joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
    
    // Computed property to maintain compatibility with existing code that expects userId
    var userId: String? {
        return studentId
    }
}

// MARK: - Assigned Staff Response
struct AssignedStaffResponse: Decodable {
    let success: Bool?
    let subject: SubjectInfo?
    let data: [AssignedStaffData]
}

struct SubjectInfo: Decodable {
    let id: String?
    let groupAcademicYearId: String?
    let courseId: String?
    let classId: String?
    let masterSubjectId: String?
    let subjectName: String?
    let code: String?
    let type: String?
    let isCustom: Bool?
    let subjectPriority: Int?
    let isActive: Bool?
    let groupAcademicYear: GroupAcademicYear?
}

struct GroupAcademicYear: Decodable {
    let id: String?
}

struct AssignedStaffData: Decodable {
    let mappingId: String?
    let staffId: String
    let staffName: String?
    let staffCode: String?
    let profilePhoto: String?
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case mappingId
        case staffId
        case staffName
        case staffCode
        case profilePhoto
        case startDate
        case endDate
    }
}

// MARK: - Class Subjects API Response
struct ClassSubjectsAPIResponse: Decodable {
    let success: Bool
    let data: ClassSubjectsData
}

struct ClassSubjectsData: Decodable {
    let `class`: ClassDetails
    let subjectGroups: [ClassSubjectGroup]
}

struct ClassDetails: Decodable {
    let classId: Int
    let className: String
    let totalStudents: Int
}

struct ClassSubjectGroup: Decodable {
    let type: String // "L-I", "L-II", "O-1", etc.
    let subjects: [ClassSubject]
}

struct ClassSubject: Decodable {
    let isActive: Bool
    let assignedStaffCount: Int
    let assignedStaff: [AssignedStaff1]
    let code: String
    let subjectId: Int
    let subjectName: String
    let assignedStudentsCount: Int
    let isCustom: Bool
    let subjectPriority: Int
}

struct AssignedStaff1: Decodable {
    let staffId: Int
    let staffName: String
    let profilePhoto: String?
}
