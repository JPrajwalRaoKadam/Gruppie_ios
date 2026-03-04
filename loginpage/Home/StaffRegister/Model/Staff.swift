import Foundation

// MARK: - Main Response
struct StaffRegistrationResponse: Decodable {
    let success: Bool
    let data: [Staff]
    let pagination: StaffPagination
}

// MARK: - Staff Model
struct Staff: Decodable {
    let id: String
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let gender: String?
    let dateOfBirth: String?
    let nationality: String?
    let religion: String?
    let bloodGroup: String?
    let maritalStatus: String?
    let contactNumber: String?
    let alternateContactNumber: String?
    let email: String?
    let currentAddress: String?
    let permanentAddress: String?
    let city: String?
    let state: String?
    let country: String?
    let postalCode: String?
    let nationalId: String?
    let emergencyContactName: String?
    let emergencyContactNumber: String?
    let profilePhotoUrl: String?
    let staffCategory: String?
    let staffType: String?
    let staffDepartment: String?
    let designation: String?
    let reportingManager: String?
    let jobGrade: String?
    let workLocation: String?
    let staffCode: String?
    let employeeStatus: String?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - Pagination
struct StaffPagination: Decodable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
}

// MARK: - Root Response
struct StaffDetailResponse: Decodable {
    let success: Bool
    let data: StaffDetail
}

// MARK: - Staff Detail
struct StaffDetail: Decodable {

    let id: String
    let firstName: String?
    let middleName: String?
    let lastName: String?
    let gender: String?
    let dateOfBirth: String?
    let nationality: String?
    let religion: String?
    let bloodGroup: String?
    let maritalStatus: String?
    let contactNumber: String?
    let alternateContactNumber: String?
    let email: String?
    let currentAddress: String?
    let permanentAddress: String?
    let city: String?
    let state: String?
    let country: String?
    let postalCode: String?
    let nationalId: String?
    let emergencyContactName: String?
    let emergencyContactNumber: String?
    let profilePhotoUrl: String?

    let staffCategory: String?
    let staffType: String?
    let staffDepartment: String?
    let designation: String?
    let reportingManager: String?
    let jobGrade: String?
    let workLocation: String?
    let staffCode: String?
    let employeeStatus: String?

    let additionalInfo: [AdditionalInfo]?
    let hrDetails: [HRDetail]?
    let certifications: [Certification]?
    let documents: [StaffDocument]?
    let userAccounts: [UserAccount]?
}

// MARK: - Additional Info
struct AdditionalInfo: Decodable {
    let id: String
    let staffId: String
    let skills: String?
    let languagesKnown: String?
    let awardsOrRecognitions: String?
    let publications: String?
    let specializations: String?
    let researchProjects: String?
}

// MARK: - HR Details
struct HRDetail: Decodable {
    let id: String
    let staffId: String
    let dateOfApplication: String?
    let applicationSource: String?
    let dateOfInterview: String?
    let interviewer: String?
    let interviewRemarks: String?
    let dateOfAppointment: String?
    let probationPeriodMonths: Int?
    let dateOfConfirmation: String?
    let offerLetterUrl: String?
    let appointmentLetterUrl: String?
    let bankName: String?
    let branchName: String?
    let accountNumber: String?
    let ifscOrSwiftCode: String?
    let accountHolderName: String?
    let panOrTaxId: String?
}

// MARK: - Certification / Education / Experience
struct Certification: Decodable {

    let id: String
    let staffId: String
    let certificationName: String?
    let certifyingBody: String?
    let yearObtained: Int?
    let validTill: Int?
    let certificateUrl: String?

    let qualification: String?
    let specialization: String?
    let institutionName: String?
    let boardOrUniversity: String?
    let yearOfPassing: Int?
    let percentageOrCGPA: String?

    let organizationName: String?
    let certificateDesignation: String?
    let jobType: String?
    let fromDate: String?
    let toDate: String?
    let totalExperienceYears: String?
    let experienceCertificateUrl: String?
}

// MARK: - Documents
struct StaffDocument: Decodable {
    let id: String
    let staffId: String
    let documentType: String?
    let documentName: String?
    let documentUrl: String?
    let verified: Bool
}

// MARK: - User Account
struct UserAccount: Decodable {
    let id: String
    let name: String?
    let email: String?
    let phoneNumber: String?
    let groupUserRoles: [GroupUserRole]?
}

// MARK: - Group User Role
struct GroupUserRole: Decodable {
    let id: String
    let groupId: String
    let roleId: String
    let status: String?
    let role: StaffRole?
}

// MARK: - Role
struct StaffRole: Decodable {
    let id: String
    let name: String?
}



struct StaffBasicInfoModel {
    let name: String
    let country: String
    let phone: String
    let staffId: String
    let doj: String
    let className: String
    let gender: String
    let qualification: String
    let dob: String
    let address: String
    let religion: String
    let caste: String
    let bloodGroup: String
    let emailId: String
    let aadharNo: String
    let type: String
//    let emergencyContact: String // Added
//    let fatherName: String // Added
//    let motherName: String // Added
//    let profession: String // Added
}

struct StaffAccountInfoModel {
    let uanNumber: String?
    let panNumber: String?
    let bankAccount: String?
    let bankIfsc: String?
}

struct StaffUpdateRequest: Encodable {

    let firstName: String
    let lastName: String
    let gender: String?
    let dateOfBirth: String?
    let contactNumber: String?
    let email: String?
    let country: String?
    let religion: String?
    let bloodGroup: String?
    let currentAddress: String?
    let nationalId: String?
    let staffType: String?
    let designation: String?
}
