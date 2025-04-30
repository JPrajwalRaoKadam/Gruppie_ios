import Foundation

// MARK: - API Response Model
struct AlbumResponse: Codable {
    let totalNumberOfPages: Int
    let data: [AlbumData]
}

// MARK: - Album Data Model
struct AlbumData: Codable {
    let updatedAt: String
    let groupId: String
    let description: String?
    let createdAt: String
    let canEdit: Bool
    let albumName: String
    let albumId: String // Ensure this matches the actual API response
    let fileType: String?
    let fileName: [String]?
}
