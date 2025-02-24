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
    let baseURL = "https://gcc.gruppie.in/api/v1/"
    
    private init() {} // Prevents others from creating another instance
}
