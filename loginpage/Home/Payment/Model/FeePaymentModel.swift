//
//  FeePaymentModel.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 06/02/25.
//

import Foundation

// MARK: - Classwise Fee Response
struct ClasswiseFeeResponse: Decodable {
    let success: Bool
    let totals: FeeTotals
    let data: [ClasswiseFeeData]
}

struct FeeTotals: Decodable {
    let totalDemand: Double
    let totalConcession: Double
    let totalCollection: Double
    let totalBalance: Double
}

struct ClasswiseFeeData: Decodable {
    let slNo: Int
    let classId: String
    let className: String
    let demand: Double
    let concession: Double
    let collection: Double
    let balance: Double
}

// MARK: - API Response Model
struct StudentFeeSummaryResponse: Codable {
    let success: Bool
    let data: [StudentFeeSummary]
    let meta: Meta?
}

struct StudentFeeSummary: Codable {
    let slNo: Int?
    let studentId: String?
    let studentName: String?
    let fatherName: String?
    let phone: String?
    let demand: Double?
    let concession: Double?
    let fine: Double?
    let collection: Double?
    let balance: Double?
    let overdue: Double?
    let photo: String?
}

struct Meta: Codable {
    let totalRecords: Int?
    let currentPage: Int?
    let totalPages: Int?
}

struct StudentFeeSummaryDetailResponse: Codable {
    let success: Bool?
    let data: StudentFeeSummaryDetail?
}

struct StudentFeeSummaryDetail: Codable {
    let student: StudentInfo?
    let breakdown: FeeBreakdown?
    let feeDetails: [FeeDetail]?
    let paidDetails: [PaidDetail]?
    let installments: [FeeSummaryInstallment]?
}

struct StudentInfo: Codable {
    let fullName: String?
    let studentId: String?
    let className: String?
}

struct FeeBreakdown: Codable {
    let totalDue: Double?
    let totalPaid: Double?
    let totalConcession: Double?
    let totalCollectedFine: Double?
    let totalOutstandingFine: Double?
    let totalArrearsDue: Double?
    let totalArrearsPaid: Double?
    let arrearsBalance: Double?
    let balance: Double?
}

struct FeeDetail: Codable {
    let demandId: String?
    let demandSourceType: String?
    let demandSourceId: String?
    let fee: String?
    let demand: Double?
    let concession: Double?
    let collected: Double?
    let balance: Double?
    let dueAmount: Double?
    let upcomingAmount: Double?
    let payable: Double?
    let fine: Double?
    let paidFine: Double?
    let fineRuleId: String?
    let hasInstalments: Bool?
}

struct PaidDetail: Codable {
    let slNo: Int?
    let rcptNo: String?
    let amountPaid: Double?
    let fineAmount: Double?
    let mode: String?
    let status: String?
    let date: String?
}

struct FeeSummaryInstallment: Codable {
    let name: String?
    let dueDate: String?
    let amount: Double?
    let fine: Double?
    let status: String?
    let feeType: String?
}

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

struct FeeIds: Codable {
    let feeId: String?
    let categoryId: String?
    let categoryFeeDetails: CategoryFeeDetails?
}

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

struct EasebuzzPaymentResponse: Codable {
    let status: Int
    let redirectionUrl: String
    let data: String
}

// MARK: - Root
struct PaymentViewResponse: Codable {
    let success: Bool?
    let data: PaymentViewData?
}

// MARK: - Data
struct PaymentViewData: Codable {
    let student: PaymentStudent?
    let demands: [PaymentDemand]?
}

// MARK: - Student (RENAMED)
struct PaymentStudent: Codable {
    let studentId: String?
    let fullName: String?
    let classId: String?
    let className: String?
}

// MARK: - Demand
struct PaymentDemand: Codable {
    let studentFeeDemandId: String?
    let feeType: String?
    let total: Double?
    let concession: Double?
    let netAmount: Double?
    let paid: Double?
    let balance: Double?
    let dueAmount: Double?
    let payable: Double?
    let fine: Double?
    let status: String?
}

struct CommonResponse<T: Decodable>: Decodable {
    let success: Int?
    let message: String?
    let data: T?
}

struct PaymentRequest: Encodable {
    let data: [PaymentData]
}

struct PaymentData: Encodable {
    let advanceAmounts: [String]
    let advancePayment: Int
    let allocations: [Allocation]
    let amount: Double
    let classId: Int
    let groupAcademicYearId: String
    let idempotencyKey: String?
    let paymentMode: String
    let studentId: Int
    let useAdvance: Bool
}

struct Allocation: Encodable {
    let amount: Double
    let fineAmount: Double
    let studentFeeDemandId: Int
}

struct PaymentGatewayResponse: Decodable {
    let status: String?
    let message: String?
    let data: PaymentGatewayData?
}

struct PaymentGatewayData: Decodable {
    let redirectUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case redirectUrl = "redirectUrl" // if backend sends redirect_url → change here
    }
}

struct PaymentSuccessResponse: Decodable {
    let status: String?
    let message: String?
    let data: PaymentSuccessData?
}

struct PaymentSuccessData: Decodable {
    let receiptNumber: String?
    let amount: Double?
}

struct PaymentStatusResponse: Codable {
    let success: Bool?
    let data: PaymentStatusData?
}

struct PaymentStatusData: Codable {
    let transactionId: String?
    let gatewayOrderId: String?
    let status: String?
    let errorMessage: String?
    let paymentRecordId: String?
}

struct GenericResponse: Codable {
    let success: Bool?
    let message: String?
}
