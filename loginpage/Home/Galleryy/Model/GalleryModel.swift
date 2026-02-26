import Foundation
import AVFoundation
import UIKit

// MARK: - API Response

struct AlbumResponse: Codable {
    let success: Bool
    let message: String
    let data: [AlbumData]
    let meta: AlbumMeta
}

struct AlbumMeta: Codable {
    let totalRecords: Int
    let currentPage: Int
    let totalPages: Int
}

// MARK: - Album Data

struct AlbumData: Codable {
    let updatedAt: String
    let groupId: String
    let description: String?
    let createdAt: String
    let canEdit: Bool
    let albumName: String
    let albumId: String
    let fileType: String?
    let fileName: [String]?

    enum CodingKeys: String, CodingKey {
        case updatedAt
        case groupId
        case description
        case createdAt
        case canEdit
        case albumName
        case albumId
        case fileType

        // API-only keys
        case attachments
        case albumDate
        case name
        case id
    }

    // MARK: - Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Defaults (not sent by API)
        updatedAt = ""
        groupId = ""
        canEdit = true
        fileType = nil

        // API fields
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decodeIfPresent(String.self, forKey: .albumDate) ?? ""
        albumName = try container.decode(String.self, forKey: .name)
        albumId = String(try container.decode(Int.self, forKey: .id))

        // Attachments → fileName[]
        if let attachments = try? container.decode([AlbumAttachment].self, forKey: .attachments) {
            let urls = attachments.map { $0.fileUrl }
            fileName = urls.isEmpty ? nil : urls
        } else {
            fileName = nil
        }
    }

    // MARK: - Encoding (required because of custom init)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(groupId, forKey: .groupId)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(canEdit, forKey: .canEdit)
        try container.encode(albumName, forKey: .albumName)
        try container.encode(albumId, forKey: .albumId)
        try container.encodeIfPresent(fileType, forKey: .fileType)
    }
}

// MARK: - Attachment Model

struct AlbumAttachment: Codable {
    let id: Int
    let fileUrl: String
    let fileSizeKb: Int
    let attachmentType: String
}

// MARK: - Media Models

enum MediaType {
    case image(UIImage)
    case videoThumbnail(UIImage, URL)
    case video(URL, AVPlayerItem)
}

struct MediaItem {
    let type: MediaType
}
