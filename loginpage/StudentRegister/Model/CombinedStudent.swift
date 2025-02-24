//
//  CombinedStudent.swift
//  loginpage
//
//  Created by Apple on 04/02/25.
//

import Foundation

struct CombinedStudentTeamResponse: Codable {
    let data: [CombinedStudentTeam]
}

// Model for each combined student team
struct CombinedStudentTeam: Codable {
    let teamId: String
    let teacherName: String?
    let name: String
    let members: Int
    let phone: String
    let image: String? // Base64 encoded image
    let gruppieClassName: String?
    let adminName: String?
    
    // Custom decoding for Base64 image if necessary
    var decodedImageUrl: String? {
        guard let image = image,
              let decodedData = Data(base64Encoded: image),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
