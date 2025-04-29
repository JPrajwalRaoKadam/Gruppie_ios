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


