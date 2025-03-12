import Foundation

// MARK: - Main response model
struct AddSubjectRegisterResponse: Decodable {
    let data: [AddSubjectDetail]  // Array of subject details inside "data"
}

// MARK: - SubjectDetail model to reflect each subject's details
struct AddSubjectDetail: Decodable, Hashable {
    let subjectPriority: Int
    let subjectName: String
    let partSubject: String?
    let parentSubject: String?
    let isLanguage: Bool
    let id: String
    let gruppieSubjectId: String

    enum CodingKeys: String, CodingKey {
        case subjectPriority, subjectName, partSubject, parentSubject, isLanguage, id, gruppieSubjectId
    }

    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Using 'id' as a unique identifier
    }

    // MARK: - Equatable Conformance (Required for Hashable)
    static func == (lhs: AddSubjectDetail, rhs: AddSubjectDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
