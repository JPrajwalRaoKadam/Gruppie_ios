
import Foundation

// Model to represent each school data from the API response
struct SchoolData: Codable {
    let id: String
    let shortName: String? // Matches the API response
    let image: String? // This could be a URL string or a Base64 string
    var bannerData: String? // Optional banner data
    let name: String? // New property to hold the name
}

// Model for the entire API response, which contains an array of SchoolData
struct SchoolResponse: Codable {
    let data: [SchoolData]? // Array of school data
}

struct BannerData: Codable {
    let name: String
}

struct BannerResponse: Decodable {
    struct Data: Decodable {
        struct FileName: Decodable {
            let name: String
        }
        let fileName: [FileName]
    }
    let data: [Data]
}

struct ImageData {
    let imageUrl: String
}

// Updated School model that you use in the app
struct School {
    let id: String
    let shortName: String
    var image: String // Non-optional for easier usage in UI
    var bannerData: String? // Optional banner data
    let name: String // New property for the name

    // Initializer to convert from SchoolData
    init(from schoolData: SchoolData) {
        self.id = schoolData.id
        self.shortName = schoolData.shortName ?? "Unknown School" // Default to "Unknown School" if nil
        self.image = schoolData.image ?? "" // Default to an empty string if image is nil
        self.bannerData = schoolData.bannerData // Banner data can be nil
        self.name = schoolData.name ?? "Unnamed School" // Default to "Unnamed School" if nil
    }
}
struct FeatureIcon: Codable {
    let type: String
    let image: String
}

struct GroupData: Codable {
    let activity: String?
    let featureIcons: [FeatureIcon]
}

struct HomeResponse: Codable {
    let data: [GroupData]
}

struct Event: Codable {
    var eventid: String?
    var title: String
    var startDate: String
    var endDate: String
    var startTime: String
    var endTime: String
    var venue: String
    var reminder: String?
}
struct Holiday {
    let year: Int
    let title: String
    let startDate: String
    let endDate: String
}

