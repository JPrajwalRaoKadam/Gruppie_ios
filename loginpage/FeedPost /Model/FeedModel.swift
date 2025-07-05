//
//  FeedModel.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 30/12/24.
//

import Foundation



// MARK: - PostResponse
struct PostResponse: Codable {
    let totalNumberOfPages: Int
    var data: [Post]
}

// MARK: - Post
struct Post: Codable {
    let updatedAt: String
    let type: String
    let title: String?
    let text: String?
    let teamName: String?
    let teamId: String?
    let postViewedCount: String?
    var likes: Int
    var isLiked: Bool
    let isFavourited: Bool
    let id: String
    let groupId: String
    let fileType: String?
    let fileName: [String]?
    let createdByImage: String?
    let createdById: String
    let createdBy: String
    let createdAt: String
    let commentsEnabled: Bool?
    var comments: Int
    let canEdit: Bool
    let video: String?
    let thumbnail: String?
    let thumbnailImage: [String]?

    // Coding keys to handle JSON keys that don't follow Swift naming conventions
    enum CodingKeys: String, CodingKey {
        case updatedAt
        case type
        case title
        case text
        case teamName
        case teamId
        case postViewedCount
        case likes
        case isLiked
        case isFavourited
        case id
        case groupId
        case fileType
        case fileName
        case createdByImage
        case createdById
        case createdBy
        case createdAt
        case commentsEnabled
        case comments
        case canEdit
        case video
        case thumbnail
        case thumbnailImage
    }
}

// Define the Comment model
struct Comment: Codable {
    let text: String
    let replies: Int
    let likes: Int
    let insertedAt: String
    let id: String
    let createdByPhone: String
    let createdByName: String
    let createdByImage: String?
    let createdById: String
    let canEdit: Bool
}

// Define the Response model which includes totalNumberOfPages and data
struct CommentResponse: Codable {
    let totalNumberOfPages: Int
    var data: [Comment]
}

struct AddCommentRequest: Codable {
    let text: String
}

struct AddCommentResponse: Codable {
    let success: Bool
    let message: String
}


struct LikeStatus: Codable {
    let status: String
}

struct TeamPost: Codable {
    let type: String
    let postType: String
    let name: String
    let image: String?
    let id: String
}

struct ResponseData: Codable {
    let totalNumberOfPages: Int
    let data: [TeamPost]
}

// Model for selectedArray
struct SelectedItem: Codable {
    let id: String
    let name: String
    let type: String
}

// Request Model
struct AddPostRequest: Codable {
    let fileName: [String]
    let fileType: String
    let selectedArray: [SelectedItem]
    let text: String
    let thumbnailImage: [String]
    let title: String
    let video: String
}

// Response Model
struct AddPostResponse: Codable {
    let success: Bool
    let message: String
}
