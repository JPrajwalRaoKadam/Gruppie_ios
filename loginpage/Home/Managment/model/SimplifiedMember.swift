import Foundation

struct Member: Decodable {
    let userId: String
    var name: String
    var phone: String?
    var alternativePhone: String?
    var email: String?
    var country: String?
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
    var aadharNumber: String?
    var panNumber: String?
    var fatherName: String?
    var motherName: String?
    var emergencyContact: String?
    var disability: String?
    var image: String?
    var education: String?
    var achievement: String?
}

struct MemberResponse: Decodable {
    let status: String?
    let data: [Member]
}

struct MemberDetailsResponse: Decodable {
    let status: String?
    let data: MemberDetails
}

struct MemberDetails: Decodable {
    let userId: String
    let details: MemberDetailsData
    let profileImageURL: String?
}

struct MemberDetailsData: Decodable {
    let name: String
    let phone: String
    let designation: String
}

struct APIResponse: Decodable {
    let status: String?
    let data: [Member]
}
