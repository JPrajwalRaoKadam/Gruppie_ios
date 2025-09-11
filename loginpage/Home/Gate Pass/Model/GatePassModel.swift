//
//  GatePassModel.swift
//  
//
//  Created by apple on 04/09/25.
//

import Foundation

struct KidProfileResponse: Codable {
    let data: [KidProfile]
}

struct KidProfile: Codable {
    let userId: String
    let teamId: String
    let role: String
    let name: String
    let image: String?
    let groupId: String
    let classTeacherId: String
}

struct GatePassStatusSResponse: Codable {
    let data: [GatePassStatus]?
}

struct GatePassStatus: Codable {
    let userId: String?
    let name: String?
    let status: String
    let className: String
    let gatepassId: String
}


struct GatePassResponse: Codable {
    let totalUserCount: Int
    let data: [GatePassData]
}

struct GatePassData: Codable {
    let userId: String
    let time: String
    let teamId: String
    let status: String
    let phone: String
    let parentActionAt: String?
    let onDutyUserId: String
    let onDutyName: String
    let name: String
    let groupId: String
    let gatepassId: String
    let description: String
    let date: String
    let className: String
}


struct SearchStudentResponse: Codable {
    let totalNumberOfPages: Int
    let totalCount: Int
    let data: [SearchStudentList]
}

struct SearchStudentList: Codable {
    let userId: String
    let teamId: String
    let phone: String?
    let omrNo: String?
    let name: String
    let image: String?
    let groupId: String
    let fatherName: String?
    let className: String
    let applicationId: String?
}

