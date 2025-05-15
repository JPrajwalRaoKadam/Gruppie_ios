import Foundation

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
}

struct MediaItemModel {
    let type: MediaType
}
