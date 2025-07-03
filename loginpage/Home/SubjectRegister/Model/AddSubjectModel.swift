import Foundation

struct AddSubjectRegisterResponse: Decodable {
    let data: [AddSubjectDetail]
}

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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AddSubjectDetail, rhs: AddSubjectDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
