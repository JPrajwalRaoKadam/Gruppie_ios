import Foundation

// Main response model
struct SubjectRegisterResponse: Decodable {
    let data: [SubjectDetail]
}

// SubjectDetail model to reflect each subject's details
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
        subjectId: String,
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

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(subjectId)
    }

    static func == (lhs: SubjectDetail, rhs: SubjectDetail) -> Bool {
        return lhs.subjectId == rhs.subjectId
    }
}

// SubjectStaffMember model for the staff data inside "staffName" array
struct SubjectStaffMember: Decodable {
    let staffName: String
    let staffId: String
}

// Staff List Response
struct StaffListResponse: Codable {
    let totalNumberOfPages: Int?
    let data: [Staffs]
    let subjectPriority: String?  // ✅ Make sure this is Optional
}

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
    let subjectName: String?  // ✅ Add subjectName

    enum CodingKeys: String, CodingKey {
        case subjectPriority, permanent, accountant, staffId, designation, type, phone, name, userId
        case payRollApprover, admissionApprover, examiner
        case bankIfscCode, bankAddress, bankName, category, motherName, aadharNumber
        case subjectName  // ✅ Add this line
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

        subjectName = try container.decodeIfPresent(String.self, forKey: .subjectName)  // ✅ Fix the issue
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
