//
//  LoginModel.swift
//  loginpage
//
//  Created by apple on 17/12/25.
//

import Foundation

struct UserExistResponse: Decodable {
    let success: Bool
    let isUserExist: Bool
    let isValid: Bool
    let message: String
}

// VerifyOTPModel.swift
struct VerifyOTPRequest: Encodable {
    let phone: String
    let otp: String
}

struct VerifyOTPResponse: Decodable {
    let success: Bool
    let isValid: Bool
    let message: String
}
struct ResendOTPResponse: Decodable {
    let success: Bool
    let message: String
}

struct CreatePasswordRequest: Encodable {
    let phoneNumber: String
    let password: String
    let otp: String
    let deviceToken: String
    let countryCode: String
    let deviceId: String
    let deviceType: String
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    let appName: String
}

struct CreatePasswordResponse: Decodable {
    let success: Bool
    let token: String?
    let message: String?
}

struct LoginRequest: Encodable {
    let phoneNumber: String
    let password: String
    let deviceToken: String
    let countryCode: String
    let deviceId: String
    let deviceType: String
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    let appName: String
}

struct LoginResponse: Decodable {
    let success: Bool?
    let message: String?
    let token: String?
    let name: String?
    let status: String?
    let ispin: Bool?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case token
        case name
        case status
        case ispin = "is_pin"
    }
}


