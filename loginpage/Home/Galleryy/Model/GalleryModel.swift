import Foundation
import AVFoundation
import UIKit

struct AlbumResponse: Codable {
    let totalNumberOfPages: Int
    let data: [AlbumData]
}

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
        case updatedAt, groupId, description, createdAt, canEdit, albumName, albumId, fileType, fileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        groupId = try container.decode(String.self, forKey: .groupId)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        canEdit = try container.decode(Bool.self, forKey: .canEdit)
        albumName = try container.decode(String.self, forKey: .albumName)
        albumId = try container.decode(String.self, forKey: .albumId)
        fileType = try container.decodeIfPresent(String.self, forKey: .fileType)
        
        // Handle fileName being either a single String or an array of Strings
        if let singleFileName = try? container.decode(String.self, forKey: .fileName) {
            fileName = [singleFileName]
        } else {
            fileName = try container.decodeIfPresent([String].self, forKey: .fileName)
        }
    }
}

enum MediaType {
    case image(UIImage)
    case videoThumbnail(UIImage, URL)
    case video(URL, AVPlayerItem)
}


struct MediaItem {
    let type: MediaType
}
