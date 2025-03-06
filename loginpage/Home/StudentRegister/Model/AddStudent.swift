import Foundation

struct StudentDataResponse: Codable {
    let data: [StudentData]
}

struct FeeId: Codable {
    let feeType: String?
    let feeAmount: Double?
}

struct StudentData: Codable {
    var userId: String?
    var userDownloadedApp: Bool?
    var teamId: String?
    var studentDbId: String?
    var searchName: String?
    var satsNo: String?
    var rte: Bool?
    var phone: String?
    var name: String?
    var motherNumber: String?
    var marksCard: [String]?
    var isMotherDownloaded: Bool?
    var isFatherDownloaded: Bool?
    var gruppieRollNumber: String?
    var groupId: String?
    var fatherNumber: String?
    var fatherName: String?
    var fatherEmail: String?
    var className: String?
    var category: String?
    var admissionType: String?
    var fatherAadharNumber: String?
    var motherOccupation: String?
    var dob: String?
    var caste: String?
    var fatherEducation: String?
    var doj: String?
    var feeIds: [FeeId]?
    var aadharNumber: String?
    var admissionNumber: String?
    var gender: String?
    var nationality: String?  // ✅ Changed to `var`
    var bloodGroup: String?   // ✅ Changed to `var`
    var email: String?
    var disability: String?
    var familyIncome: String?
    var motherAadharNumber: String?
    var religion: String?     // ✅ Changed to `var`
    var subCaste: String?     // ✅ Changed to `var`
    var address: String?      // ✅ Changed to `var`
    var rollNumber: String?
    var motherEducation: String?
    var motherEmail: String?
    var searchName2: String?
    var district: String?
    var taluk: String?
    var fatherOccupation: String?
    var motherName: String?
    var numberOfKids: String?
    var image: String?
    var section: String?
    var studentRegId: String?
    var countryCode: String?
    var satsNumber: String?
    var fatherPhone: String?
    var fatherAadhar: String?
    var motherPhone: String?
    var isSelected: Bool?
}


struct StudentRegisterRequest: Codable {
    var studentData: [StudentData]
}

struct OtherInfoModel {
    let nationality: String
    let bloodGroup: String
    let religion: String
    let caste: String
    let subCaste: String
    let category: String
    let address: String
    let aadharNo: String
}

struct FamilyInfoModel {
    let fatherName: String
    let fatherPhone: String
    let fatherEducation: String
    let fatherOccupation: String
    let fatherAadhar: String
    let motherName: String
    let motherPhone: String
    let motherOccupation: String
}


struct BasicInfoModel {
    let name: String
    let country: String
    let phone: String
    let satsNumber: String
    let admissionNumber: String
    let rollNo: String
    let dob: String
    let doj: String
}
