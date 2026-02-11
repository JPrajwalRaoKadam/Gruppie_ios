//
//  FeedModel.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 30/12/24.
//

import Foundation

// MARK: - Root Response
struct FeedResponse: Decodable {
    let success: Bool
    let pagination: FeedPagination?
    let data: [FeedPost]
}

// MARK: - Pagination
struct FeedPagination: Decodable {
    let totalRecords: Int
    let totalPages: Int
    let currentPage: Int
    let pageSize: Int?

    enum CodingKeys: String, CodingKey {
        case totalRecords
        case totalPages
        case currentPage
        case pageSize
    }
}

// MARK: - Post
struct FeedPost: Decodable {

    let postId: String
    let postType: String?
    let title: String?
    let body: String?
    let attachments: [FeedAttachment]
    let shareInternal: Bool?
    let shareExternal: Bool?
    let commentCount: Int
    var likeCount: Int

    // Local only
    var isLiked: Bool = false

    let createdAt: String?
    let updatedAt: String?
    let fromUser: FeedUser
    let toUser: FeedUser?
    let team: FeedTeam?

    enum CodingKeys: String, CodingKey {
        case postId
        case postType
        case title
        case body
        case attachments
        case shareInternal
        case shareExternal
        case commentCount
        case likeCount
        case createdAt
        case updatedAt
        case fromUser
        case toUser
        case team
    }
}



// MARK: - Attachment
struct FeedAttachment: Decodable {
    let fileId: Int?
    let fileUrl: String?
    let fileName: String?
    let fileType: String?
}

// MARK: - User
struct FeedUser: Decodable {
    let id: String
    let name: String?
}

// MARK: - Team
struct FeedTeam: Decodable {
    let id: String
    let name: String?
}

struct LikePostRequest: Encodable {
    let postId: Int
}

struct LikePostResponse: Decodable {
    let success: Bool
    let message: String?
    let likeCount: Int?
}

//struct LikeStatus: Codable {
//    let status: String
//}

//// MARK: - PostResponse
//struct PostResponse: Codable {
//    let totalNumberOfPages: Int
//    var data: [Post]
//}
//
//// MARK: - Post
//struct Post: Codable {
//    let updatedAt: String
//    let type: String
//    let title: String?
//    let text: String?
//    let teamName: String?
//    let teamId: String?
//    let postViewedCount: String?
//    var likes: Int
//    var isLiked: Bool
//    let isFavourited: Bool
//    let id: String
//    let groupId: String
//    let fileType: String?
//    let fileName: [String]?
//    let createdByImage: String?
//    let createdById: String
//    let createdBy: String
//    let createdAt: String
//    let commentsEnabled: Bool?
//    var comments: Int
//    let canEdit: Bool
//    let video: String?
//    let thumbnail: String?
//    let thumbnailImage: [String]?
//
//    // Coding keys to handle JSON keys that don't follow Swift naming conventions
//    enum CodingKeys: String, CodingKey {
//        case updatedAt
//        case type
//        case title
//        case text
//        case teamName
//        case teamId
//        case postViewedCount
//        case likes
//        case isLiked
//        case isFavourited
//        case id
//        case groupId
//        case fileType
//        case fileName
//        case createdByImage
//        case createdById
//        case createdBy
//        case createdAt
//        case commentsEnabled
//        case comments
//        case canEdit
//        case video
//        case thumbnail
//        case thumbnailImage
//    }
//}
//
//// Define the Comment model
//struct Comment: Codable {
//    let text: String
//    let replies: Int
//    let likes: Int
//    let insertedAt: String
//    let id: String
//    let createdByPhone: String
//    let createdByName: String
//    let createdByImage: String?
//    let createdById: String
//    let canEdit: Bool
//}
//
//// Define the Response model which includes totalNumberOfPages and data
//struct CommentResponse: Codable {
//    let totalNumberOfPages: Int
//    var data: [Comment]
//}
//
//struct AddCommentRequest: Codable {
//    let text: String
//}
//
//struct AddCommentResponse: Codable {
//    let success: Bool
//    let message: String
//}
//
//
//struct LikeStatus: Codable {
//    let status: String
//}
//
//struct TeamPost: Codable {
//    let type: String
//    let postType: String
//    let name: String
//    let image: String?
//    let id: String
//}
//
//struct ResponseData: Codable {
//    let totalNumberOfPages: Int
//    let data: [TeamPost]
//}
//
//// Model for selectedArray
//struct SelectedItem: Codable {
//    let id: String
//    let name: String
//    let type: String
//}
//
//// Request Model
//struct AddPostRequest: Codable {
//    let fileName: [String]
//    let fileType: String
//    let selectedArray: [AddFeedVC.SelectedItem]
//    let text: String
//    let thumbnailImage: [String]
//    let title: String
//    let video: String
//}
//
//// Response Model
//// Add these structs before your AddFeedVC class
//struct AddPostResponse: Codable {
//    let success: Bool
//    let message: String?
//    
//    init(success: Bool, message: String? = nil) {
//        self.success = success
//        self.message = message
//    }
//}
//
//struct ErrorResponse: Codable {
//    let message: String?
//    let success: Bool?
//}
