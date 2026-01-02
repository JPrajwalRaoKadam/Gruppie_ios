//
//  GrpModel.swift
//  loginpage
//
//  Created by apple on 09/04/25.
//

import Foundation

struct GroupsResponsee: Decodable {
    let status: String
    let data: [GroupItem]
}

struct GroupItem: Decodable {
    let groupName: String
    let token: String
    let gruppieCategory: String
    let roleName: String
}

struct UserRoleResponse: Codable {
    let data: [UserRole]
}

struct UserRole: Codable {
    let token: String
    let roleName: String
}
