//
//  DeleteStaff.swift
//  loginpage
//
//  Created by Apple on 31/01/25.
//

import Foundation
// Model for Delete Staff Request
struct DeleteStaffRequestModel: Codable {
    let type: String
    
    init(type: String = "staff") {
        self.type = type
    }
}
// Model for Delete Staff API Response
struct DeleteStaffResponse: Codable {
    let success: Bool?
    let message: String?
}
