import Foundation

// Member model to store the details of a member
struct Member: Decodable {
    let userId: String
    var name: String
    var phone: String?
    var staffId: String?
    var designation: String?
    var dateOfJoining: String?
    var profession: String?
    var gender: String?
    var qualification: String?
    var dateOfBirth: String?
    var address: String?
    var religion: String?
    var bloodGroup: String?
    var emailId: String?
    var aadharNumber: String?
    var fatherName: String?
    var motherName: String?
    var emergencyContact: String?
    var disability: String?
    var image: String?
}

// API response containing a list of members
struct MemberResponse: Decodable {
    let status: String?
    let data: [Member]
}

// API response for detailed member information
struct MemberDetailsResponse: Decodable {
    let status: String?
    let data: MemberDetails
}

// MemberDetails contains detailed information about a member
struct MemberDetails: Decodable {
    let userId: String
    let details: MemberDetailsData
    let profileImageURL: String?
}

// MemberDetailsData holds additional details of a member
struct MemberDetailsData: Decodable {
    let name: String
    let phone: String
    let designation: String
}

// API response for general responses
struct APIResponse: Decodable {
    let status: String?
    let data: [Member]
}
