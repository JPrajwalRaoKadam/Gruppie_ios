//
//  FeePaymentModel.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 06/02/25.
//

import Foundation

// MARK: - PaymentResponse
struct PaymentResponse: Codable {
    let totalPaidList: [PaymentItem]?
    let totalOverDueList: [PaymentItem]?
    let totalOverDue: Double?
    let totalFeeList: [PaymentItem]?
    let totalFee: Double?
    let totalConcession: Double?
    let totalConcessionList: [Double]?
    let totalBalanceList: [PaymentItem]?
    let totalBalance: Double?
    let totalAmountPaid: Double?
    let teamData: [TeamData]?
    let studentData: [StudentDataa]?
    let installments: [Installments]?
    let fineAmount: Double?
    let excessAmount: Double?

    enum CodingKeys: String, CodingKey {
        case totalPaidList
        case totalOverDueList
        case totalOverDue
        case totalFeeList
        case totalFee
        case totalConcession
        case totalConcessionList = "totalConcesionList" // Matches JSON spelling
        case totalBalanceList
        case totalBalance
        case totalAmountPaid
        case teamData
        case studentData
        case installments = "installements" // Map to JSON key "installements"
        case fineAmount
        case excessAmount
    }
}


struct PaymentItem: Codable {
    let title: String?
    let feeId: String?  // Optional: present in studentData payment lists
    let amount: Double?
}

// MARK: - TeamData
struct TeamData: Codable {
    let totalOverDueAmount: Double?
    let totalFee: Double?
    let totalConcessionAmount: Double?
    let totalBalance: Double?
    let totalAmountPaid: Double?
    let installment: [Installment]?
    let installments: [Installments]?
    let image: String?
    let fineAmount: Double?
    let excessAmount: Double?
    let className: String?
    let classId: String?
    let bus: Bool?
    let admissionTeam: String?

    enum CodingKeys: String, CodingKey {
        case totalOverDueAmount
        case totalFee
        case totalConcessionAmount
        case totalBalance
        case totalAmountPaid
        case installment = "installement"
        case installments = "installments"
        case image
        case fineAmount
        case excessAmount
        case className
        case classId
        case bus
        case admissionTeam
    }
}

// MARK: - Installment
// Define properties as needed. Currently, this is a placeholder model.
struct Installment: Codable {
    let sortDate: Int?
    let installmentTotalAmount: Int?
    let installmentBalanceAmount: Int?
    let installmentAmountPaid: Int?
    let date: String?
}

struct Installments: Codable {
    let sortDate: Int?
    let installmentTotalAmount: Int?
    let installmentBalanceAmount: Int?
    let installmentAmountPaid: Int?
    let date: String?
}

// MARK: - StudentData
// Define properties as needed. Currently, this is a placeholder model.
struct StudentDataa: Codable {
    let teamId: String?
    let rollNumber: String?
    let phone: String?
    let name: String?
    let gruppieRollNumber: String?
    let feeIds: [FeeId]?
    let className: String?
    let totalPaidList: [PaymentItem]?
    let totalOverDueList: [PaymentItem]?
    let totalOverDue: Double?
    let totalFeeList: [PaymentItem]?
    let totalFee: Double?
    let totalConcession: Double?
    let totalConcesionList: [PaymentItem]?
    let totalBalanceList: [PaymentItem]?
    let totalBalance: Double?
    let totalAmountPaid: Double?
    let installments: [StudentInstallment]?
    let fineAmount: Double?
    let excessAmount: Double?

    enum CodingKeys: String, CodingKey {
        case teamId
        case rollNumber
        case phone
        case name
        case gruppieRollNumber
        case feeIds
        case className
        case totalPaidList
        case totalOverDueList
        case totalOverDue
        case totalFeeList
        case totalFee
        case totalConcession
        case totalConcesionList
        case totalBalanceList
        case totalBalance
        case totalAmountPaid
        case installments
        case fineAmount
        case excessAmount
    }
}

// MARK: - FeeId
struct FeeIds: Codable {
    let feeId: String?
    let categoryId: String?
    let categoryFeeDetails: CategoryFeeDetails?
}

// MARK: - CategoryFeeDetails
struct CategoryFeeDetails: Codable {
    let totalFee: Double?
    let studentFeeDetails: [StudentFeeDetail]?
    let gruppieCategory: Bool?
    let feeId: String?
    let dueDates: [DueDate]?
    let categoryName: String?
    let categoryId: String?
    let bankData: [BankData]?
}

// MARK: - StudentFeeDetail
struct StudentFeeDetail: Codable {
    let subHeads: [SubHead]?
    let feeTypeId: String?
    let feeType: String?
    let feeAmount: Double?
    let accountId: String?
}

// MARK: - SubHead
struct SubHead: Codable {
    let subHeadType: String?
    let subHeadId: String?
    let subHeadAmount: Double?
}

// MARK: - DueDate
struct DueDate: Codable {
    let reverseDate: String?
    let date: String?
    let amount: String?
}

// MARK: - BankData
struct BankData: Codable {
    let ifScCode: String?
    let bankName: String?
    let bankMId: String?
    let bankBranch: String?
    let bankAddress: String?
    let bankAccountNumber: String?
    let bankAccountHolderName: String?
    let accountId: String?
    let slNumber: Int? // Optional: not all objects include this field
}

// MARK: - StudentInstallment
struct StudentInstallment: Codable {
    let status: String?
    let reverseDate: String?
    let paidAmount: Double?
    let date: String?
    let amount: String?
}

struct StudentFinancialData: Decodable {
    let userId: String
    let totalOverDueAmount: Int
    let totalFineAmount: Int
    let totalFee: Int
    let totalConcessionAmount: Int
    let totalBalanceAmount: Int
    let totalAmountPaid: Int
    let teamId: String
    let rollNumber: String?
    let phone: String
    let name: String
    let installments: [PaymentInstallment]
    let gruppieRollNumber: String
    let excessAmount: Int
    let categoryName: String?
    let category: String?
    let admissionType: String?
}

struct PaymentInstallment: Decodable {
    let status: String
    let sortDate: Int
    let reverseDate: String
    let paidAmount: Int
    let date: String
    let amount: String
}

struct Response: Decodable {
    let data: [StudentFinancialData]
}


// MARK: - Root Model
struct FeePaymentData: Codable {
    let userId: String
    let phone: String
    let name: String
    let gruppieRollNumber: String
    let feeIds: [FeeID]
    let feeData: FeeData
    let challanIssued: Bool
    let admissionType: String?
}

// MARK: - Fee ID Model
struct FeeID: Codable {
    let feeId: String
    let categoryId: String
}

// MARK: - Fee Data Model
struct FeeData: Codable {
    let totalOverDueList: [FeeItem]
    let totalOverDueAmount: Int
    let totalFineAmount: Int
    let totalFeeList: [FeeItem]
    let totalFee: Int
    let totalConcessionAmount: Int
    let totalBalanceList: [FeeItem]
    let totalBalanceAmount: Int
    let totalAmountPaidList: [FeeItem]
    let totalAmountPaid: Int
    let studentFeeDetails: [StudentFeeDetaill]
    let fineList: [FeeItem]
    let feePaidDetails: [FeePaidDetail]
    let dueDates: [DueeDate]
    let concessionList: [FeeItem]
}

// MARK: - Fee Item (Used for multiple lists)
struct FeeItem: Codable {
    let feeTitle: String
    let amount: Int
}

// MARK: - Student Fee Detail
struct StudentFeeDetaill: Codable {
    let feeTypeId: String
    let feeType: String
    let feeAmount: Int
}

// MARK: - Fee Paid Detail
struct FeePaidDetail: Codable {
    let updatedAt: String
    let totalConcessionAmount: Int
    let thirdParty: Bool
    let studentName: String
    let status: String
    let reverted: Bool
    let referencePaymentId: String
    let receiptNumber: String
    let paymentStatus: String
    let paymentReverted: Bool
    let paymentMode: String
    let paymentId: String
    let paidReverseDate: String
    let paidDate: String
    let isActive: Bool
    let insertedAt: String
    let gruppieRollNumber: String
    let fineAmount: Int
    let feeTitle: String
    let feeId: String
    let concessionList: [Concession]
    let concessionApproved: Bool
    let className: String
    let challanApprovedUserId: String
    let approverName: String?
    let approvedUserId: String
    let approvedDate: String
    let approvedAt: String
    let amountPaidWithFine: Int
    let amountPaid: Int
}

// MARK: - Concession Detail
struct Concession: Codable {
    let type: String
    let amount: String
}

// MARK: - Due Date Detail
struct DueeDate: Codable {
    let status: String
    let sortDate: Int
    let reverseDate: String
    let paidAmount: Int
    let date: String
    let amount: String
}
