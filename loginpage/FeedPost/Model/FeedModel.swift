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

// MARK: - Request/Response Models
// Add this at the top of the file or in a separate models file
struct ToggleLikeRequest: Codable {
    let postId: Int
    
    enum CodingKeys: String, CodingKey {
        case postId
    }
}

struct ToggleLikeResponse: Codable {
    let success: Bool?
    let message: String?
    let liked: Bool?
    let likesCount: Int?
}

// MARK: - Comment Response - Flexible
struct CommentResponse: Decodable {
    let data: [Comment]
    let totalPages: Int?
    let totalRecords: Int?
    let message: String?
    let success: Bool?
    let status: Bool?
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case totalPages
        case totalRecords
        case message
        case success
        case status
        case statusCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try different possible data structures
        if let dataArray = try? container.decode([Comment].self, forKey: .data) {
            data = dataArray
        } else if let dataDict = try? container.decode([String: [Comment]].self, forKey: .data),
                  let comments = dataDict["comments"] ?? dataDict["data"] ?? dataDict["items"] {
            data = comments
        } else {
            data = []
        }
        
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        totalRecords = try container.decodeIfPresent(Int.self, forKey: .totalRecords)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        status = try container.decodeIfPresent(Bool.self, forKey: .status)
        statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
    }
    
    // Manual initializer for fallback
    init(data: [Comment], totalPages: Int?, totalRecords: Int?, message: String?, success: Bool?, status: Bool?, statusCode: Int?) {
        self.data = data
        self.totalPages = totalPages
        self.totalRecords = totalRecords
        self.message = message
        self.success = success
        self.status = status
        self.statusCode = statusCode
    }
}

// MARK: - Comment
struct Comment: Codable {
    let text: String
    let replies: Int
    let likes: Int
    let insertedAt: String
    let id: String
    let createdByPhone: String?
    let createdByName: String
    let createdByImage: String?
    let createdById: String
    let canEdit: Bool?
    let userId: String?
    let postId: String?
    let createdAt: String?
    let updatedAt: String?
    let content: String?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case replies
        case likes
        case insertedAt
        case id = "_id"
        case createdByPhone
        case createdByName
        case createdByImage
        case createdById
        case canEdit
        case userId
        case postId
        case createdAt
        case updatedAt
        case content
        case comment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle text - could be in different fields
        if let textValue = try? container.decode(String.self, forKey: .text) {
            text = textValue
        } else if let contentValue = try? container.decode(String.self, forKey: .content) {
            text = contentValue
        } else if let commentValue = try? container.decode(String.self, forKey: .comment) {
            text = commentValue
        } else {
            text = ""
        }
        
        replies = try container.decodeIfPresent(Int.self, forKey: .replies) ?? 0
        likes = try container.decodeIfPresent(Int.self, forKey: .likes) ?? 0
        
        // Handle insertedAt
        if let insertedAtValue = try? container.decode(String.self, forKey: .insertedAt) {
            insertedAt = insertedAtValue
        } else if let createdAtValue = try? container.decode(String.self, forKey: .createdAt) {
            insertedAt = createdAtValue
        } else if let updatedAtValue = try? container.decode(String.self, forKey: .updatedAt) {
            insertedAt = updatedAtValue
        } else {
            insertedAt = ISO8601DateFormatter().string(from: Date())
        }
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        createdByPhone = try container.decodeIfPresent(String.self, forKey: .createdByPhone)
        createdByName = try container.decodeIfPresent(String.self, forKey: .createdByName) ?? "Anonymous"
        createdByImage = try container.decodeIfPresent(String.self, forKey: .createdByImage)
        createdById = try container.decodeIfPresent(String.self, forKey: .createdById) ?? ""
        canEdit = try container.decodeIfPresent(Bool.self, forKey: .canEdit)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        postId = try container.decodeIfPresent(String.self, forKey: .postId)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
    
    // Manual initializer for fallback
    init(text: String, replies: Int, likes: Int, insertedAt: String, id: String, createdByPhone: String?, createdByName: String, createdByImage: String?, createdById: String, canEdit: Bool?, userId: String?, postId: String?, createdAt: String?, updatedAt: String?, content: String?, comment: String?) {
        self.text = text
        self.replies = replies
        self.likes = likes
        self.insertedAt = insertedAt
        self.id = id
        self.createdByPhone = createdByPhone
        self.createdByName = createdByName
        self.createdByImage = createdByImage
        self.createdById = createdById
        self.canEdit = canEdit
        self.userId = userId
        self.postId = postId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.content = content
        self.comment = comment
    }
}

// MARK: - Add Comment Request
struct AddCommentRequest: Encodable {
    let postId: Int
    let content: String
}

// MARK: - Add Comment Response
struct AddCommentResponse: Decodable {
    let success: Bool
    let message: String
    let data: Comment?
    let status: Bool?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
        case status
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
        status = try container.decodeIfPresent(Bool.self, forKey: .status)
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        data = try container.decodeIfPresent(Comment.self, forKey: .data)
        error = try container.decodeIfPresent(String.self, forKey: .error)
    }
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
