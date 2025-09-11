//
//  ExamListModel.swift
//  loginpage
//
//  Created by apple on 11/09/25.
//

import Foundation

struct ExamResponse1: Codable {
    let scheduleData: [ExamData1]
}

struct ExamData1: Codable {
    let year: String?
    let testType: String?
    let testName: String?
    let testId: String
    let month: String?
    let enable: Bool?
    let disabled: Bool?
    let aliasName: String?
}
