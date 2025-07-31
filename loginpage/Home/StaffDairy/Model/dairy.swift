import Foundation

// MARK: - DiaryResponse
struct DiaryResponse: Codable, Equatable {
    let data: [DiaryData]?
}

// MARK: - DiaryData
struct DiaryData: Codable, Equatable {
    var diaryItems: [DiaryItem]
    let userId: String?
    let staffName: String?
    let staffImage: String?
    let diaryDate: String?

    enum CodingKeys: String, CodingKey {
        case diaryItems
        case userId
        case staffName
        case staffImage
        case diaryDate
    }

    static func == (lhs: DiaryData, rhs: DiaryData) -> Bool {
        return lhs.diaryItems == rhs.diaryItems &&
               lhs.userId == rhs.userId &&
               lhs.staffName == rhs.staffName &&
               lhs.staffImage == rhs.staffImage &&
               lhs.diaryDate == rhs.diaryDate
    }
}

// MARK: - DiaryItem
struct DiaryItem: Codable, Equatable {
    let time: String
    let text: String
    let isEditable: Bool

    static func == (lhs: DiaryItem, rhs: DiaryItem) -> Bool {
        return lhs.time == rhs.time &&
               lhs.text == rhs.text &&
               lhs.isEditable == rhs.isEditable
    }
}

struct DiarySubmitRequest: Codable {
    let date: String
    let diaryItems: [DiaryItem]
    
    enum CodingKeys: String, CodingKey {
        case date
        case diaryItems
    }
}




