//
//  busModel.swift
//  loginpage
//
//  Created by apple on 08/09/25.
//

import Foundation

struct BusListResponse: Codable {
    let data: [Bus]?
}

struct Bus: Codable {
    let busNumber: String
    let routeName: String
    let driverName: String?
    let driverPhone: String?
    let busImage: String?
}
