//
//  staffFModel.swift
//  loginpage
//
//  Created by apple on 12/04/25.
//

import Foundation
struct Stafff: Codable {
    let name: String?
    let staffId: String?
}
struct SubDetailsResponse: Codable {
    let data: [ChapterNV]
}

struct ChapterNV: Codable {
    let chapterName: String
    let topics: [TopicNV]
}

struct TopicNV: Codable {
    let topicName: String
    let createdByName: String
    let insertedAt: String
    let fileName: [String]
    let fileType: String 
}


struct SyllabusResponse: Codable {
    let data: [Chapter]
}

struct Chapter: Codable {
    let chapterName: String
    let chapterId: String
    let totalTopicsCount: Int
    let topicsList: [TopicAdd]
}

struct TopicAdd: Codable {
    let topicName: String
    let topicId: String
}


// MARK: - Model Definitions
struct SubjectPostRequest: Codable {
    let chapterName: String
    let fileName: [String]
    let fileType: String
    let thumbnailImage: [String]
    let topicName: String
    let video: String
}

struct SubjectPostResponse: Codable {
    let success: Bool
    let message: String?
}
