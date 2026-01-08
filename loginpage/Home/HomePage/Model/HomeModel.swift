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

