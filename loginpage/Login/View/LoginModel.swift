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
