import Foundation

struct UserProfile {
    var name: String
    var phone: String
    var staffId: String?
    var designation: String
    var dob: String?
    var address: String?
    var religion: String?
    var bloodGroup: String?
    var emailId: String?
    var aadharNo: String?
    var fatherName: String?
    var motherName: String?
    var emerContact: String?
    var disability: String?
    var uanNumber: String?
    var panNumber: String?
    var bankAccount: String?
    var bankIfsc: String?
    var image: String?
}

protocol EditableCell {
    func setEditable(_ isEditable: Bool)
    func collectUpdatedData() -> [String: String]
}
