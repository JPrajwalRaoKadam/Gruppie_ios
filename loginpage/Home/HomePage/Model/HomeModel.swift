//
//  HomeModel.swift
//  loginpage
//
//  Created by apple on 08/01/26.
//

import Foundation

// MARK: - HomeResponse
struct HomeResponse: Decodable {
    let groupId: String
    let groupName: String
    let subscriptionType: String
    let role: String
    let features: [Feature]
}

// MARK: - Feature
struct Feature: Decodable {
    let activity: String
    let featureIcons: [FeatureIcon]
}

// MARK: - FeatureIcon
struct FeatureIcon: Decodable {
    let id: Int
    let name: String
    let logoUrl: String
}

struct GroupAcademicYearResponse: Decodable {
    let success: Bool
    let data: GroupAcademicYearData
    let message: String
}

struct GroupAcademicYearData: Decodable {
    let groupInfo: GroupInfo
    let academicYears: [GroupAcademicYearItem]
}

struct GroupInfo: Decodable {
    let groupName: String
    let shortName: String
    let logo: String?
    let address: String
}

struct GroupAcademicYearItem: Decodable {
    let groupAcademicYearId: String
    let academicYearId: String
    let boardAndUniversityId: String
    let academicLabel: String
}

struct RolePermissionResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [String: [String: PermissionDetails]]?
}

struct PermissionDetails: Codable {
    let fullAccess: Bool?
    let deleteStaffCategories: Bool?
    let delete: Bool?
    let viewStaffCategories: Bool?
    let viewList: Bool?
    let view: Bool?
    let deactivate: Bool?
    let manageStaffCategories: Bool?
}
