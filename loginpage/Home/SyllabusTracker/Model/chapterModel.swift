//
//  chapterModel.swift
//  loginpage
//
//  Created by apple on 17/03/25.
//

import Foundation
struct ChapterResponse: Codable {
    let data: [ChapterData]
}

struct ChapterData: Codable {
    let chapterName: String
    let chapterId: String
    let topicsList: [Topic]
}

struct Topic: Codable {
    let topicName: String
    let topicId: String
}

struct ChapterPlanResponse: Codable {
    let planId: String 
    let activities: [Activity]
    let actualEndDate: String
    let actualStartDate: String
    let endDate: String
    let startDate: String
    let sessionAvailable: String
    let sessionPlaned: String
}

struct Activity: Codable {
    let duration: String
    let type: String
}

struct DailySyllabus {
    let topicName: String
    let subjectName: String
    let fromDate: String
    let toDate: String
    let actualStartDate: String
    let actualEndDate: String
}


struct SubjectStaffSyllabus: Decodable {
    let staffName: String
    let subjectName: String
    let subjectId: String
}
struct StaffSub{
    var name: String
    var isSelected: Bool
}
struct StafResponse: Codable {
    let data: [StaffMemberSyllabus]
}

struct StaffMemberSyllabus: Codable {
    let name: String
}
