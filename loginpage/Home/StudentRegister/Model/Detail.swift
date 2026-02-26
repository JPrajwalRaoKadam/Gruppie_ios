import Foundation

struct StudentFullRegistrationResponse: Decodable {
    let success: Bool
    let message: String
    let data: [StudentRegistration]
    let pagination: StudentPagination?
}



struct StudentRegistration: Decodable {

    let studentId: String
    let firstName: String
    let middleName: String?
    let lastName: String?

    let fullName: String

    let gender: String
    let dateOfBirth: String?
    let placeOfBirth: String?

    let nationality: String?
    let religion: String?
    let caste: String?
    let category: String?

    let aadhaarNumber: String?
    let bloodGroup: String?

    let physicalDisability: Bool?
    let disabilityDescription: String?

    let sportsParticipation: Bool?
    let sportsLevel: String?

    let omrNumber: String?
    let rollNumber: String?
    let satsNumber: String?

    let dateOfAdmission: String?

    let fatherMobileNumber: String?
    let motherMobileNumber: String?
    let studentMobileNumber: String?

    let fatherName: String?

    let startDate: String?
    let endDate: String?

    let status: String
    let remarks: String?
    let motherTongue: String?

    let updatedAt: String
    let profilePhoto: String?
}


// MARK: - Pagination Model
struct StudentPagination: Decodable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
}
