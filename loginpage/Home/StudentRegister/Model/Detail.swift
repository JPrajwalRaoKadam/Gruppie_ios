//
//  Detail.swift
//  loginpage
//
//  Created by Apple on 04/02/25.
//

import Foundation

struct Student: Codable {
    let teamId: String// Ensure this exists
    let studentId: String
    let name: String
    let designation: String
    let teacherName: String?
    let phone: String?
    let decodedImageUrl: String?
}

// Model for the response containing student details
struct StudentDetailsResponse: Codable {
    let data: [Student] // Array of students' details
}
