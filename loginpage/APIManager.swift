//
//  APIManager.swift
//  loginpage
//
//  Created by apple on 11/02/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    // Define the base URL here
    let baseURL = "https://api.gruppie.in/api/v1/"
    
    let parentEndPoint = "my/kids"
    
    let teacherEndPoint = "my/class/teams"
    
    let adminEndPoint = "class/get"
    
    private init() {} // Prevents others from creating another instance
}

class APIProdManager {
    static let shared = APIProdManager()
    
    // Define the base URL here
    let baseURL = "https://prod.gruppie.in/api/v1/"
    
    private init() {} // Prevents others from creating another instance
}
