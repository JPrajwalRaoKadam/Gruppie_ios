////
////  HomeAPIService.swift
////  loginpage
////
////  Created by apple on 09/04/25.
////
//
//import Foundation
//
//final class HomeAPIService {
//    
//    static let shared = HomeAPIService() // Singleton
//    private init() {}
//    
//    var schools: [School] = []
//    var currentRole: String?
//    var grpCount: Int?
//    
//    func fetchHomeData(groupId: String, completion: @escaping ([GroupData]?) -> Void) {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token not found")
//            completion(nil)
//            return
//        }
//        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/home"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                completion(nil)
//                return
//            }
//            
//            // Print raw response for debugging
//            if let rawResponse = String(data: data, encoding: .utf8) {
//                print("Raw Response of Home API: \(rawResponse)")
//            }
//            
//            do {
//                // Parse JSON using JSONSerialization
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let dataArray = jsonResponse["data"] as? [[String: Any]] {
//                    // Map data array to GroupData model
//                    let groups = dataArray.compactMap { groupDict -> GroupData? in
//                        guard let activity = groupDict["activity"] as? String,
//                              let featureIconsArray = groupDict["featureIcons"] as? [[String: Any]] else {
//                            return nil
//                        }
//                        
//                        // Map featureIcons to FeatureIcon model
//                        let featureIcons = featureIconsArray.compactMap { iconDict -> FeatureIcon? in
//                            guard let type = iconDict["type"] as? String,
//                                  let image = iconDict["image"] as? String,
//                                  let role = iconDict["role"] as? String,
//                                  let details = iconDict["details"] as? [UserDetails],
//                                  let count = iconDict["count"] as? Int else {
//                                return nil
//                            }
//                            self.currentRole = role
//                            print(".....rolee.......\(self.currentRole)")
//                            return FeatureIcon(type: type, image: image, role: role)
////                            print("pooooppppppoooooopopopopo...........\(role)")
////                            self.CurrentRole = role
////                            self.grpCount = count
//////                            return FeatureIcon(type: type, image: image, role: role, details: details, count: count)
//                        }
//                        
//                        return GroupData(activity: activity, featureIcons: featureIcons)
//                    }
//                    // Print fetched data for debugging
//                    print("Fetched Group Data:")
//                    for group in groups {
//                        print("Activity: \(group.activity)")
//                        for icon in group.featureIcons {
//                            print("Type H: \(icon.type), Image H: \(icon.image)")
//                        }
//                    }
//                    
//                    // Pass the parsed data to completion
//                    completion(groups)
//                } else {
//                    print("Unexpected response format or missing data key")
//                    completion(nil)
//                }
//            } catch {
//                print("Error parsing API response: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }.resume()
//    }
//    
//    func fetchBannerImage(groupId: String, completion: @escaping ([String]?) -> Void) {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token not found")
//            completion(nil)
//            return
//        }
//        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/banner/get/new"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                completion(nil)
//                return
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let dataArray = json["data"] as? [[String: Any]] {
//                    var imageUrls: [String] = []
//                    
//                    // If there is no image or fileName is null, use the default image
//                    if let item = dataArray.first, let fileNames = item["fileName"] as? [String?], fileNames.first == nil {
//                        imageUrls = ["new_banner.png"] // Use default image
//                    } else {
//                        // Loop through the file names and append valid image URLs
//                        for item in dataArray {
//                            if let fileNames = item["fileName"] as? [[String: Any]] {
//                                for file in fileNames {
//                                    if let imageUrl = file["name"] as? String {
//                                        imageUrls.append(imageUrl)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
//                    completion(imageUrls.isEmpty ? ["new_banner.png"] : imageUrls) // Ensure default image is passed
//                } else {
//                    completion(["new_banner.png"]) // Default image if no data found
//                }
//            } catch {
//                print("Error parsing API response: \(error.localizedDescription)")
//                completion(["new_banner.png"]) // Default image in case of parsing error
//            }
//        }
//        
//        task.resume()
//    }
//    
//    func fetchUserProfile(groupId: String, completion: @escaping (String?) -> Void) {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token not found")
//            completion(nil)
//            return
//        }
//        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/my/kids/profile"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        print("Sending request to Profile: \(urlString)")
//        print("Using token: \(token)")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received")
//                completion(nil)
//                return
//            }
//            
//            // Print the raw response data
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("Response Data of profile: \(responseString)") // Log raw response
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("Parsed JSON Response: \(json)") // Print parsed JSON response
//                    
//                    // Check if the 'data' key exists in the JSON response
//                    if let dataArray = json["data"] as? [[String: Any]] {
//                        print("Data Array: \(dataArray)") // Log the entire data array to inspect its contents
//                        
//                        if let name = dataArray.first?["name"] as? String {
//                            print("Fetched name: \(name)") // Print the fetched name
//                            completion(name) // Return the name of the user
//                        } else {
//                            print("Name not found in response")
//                            completion(nil)
//                        }
//                    } else {
//                        print("Invalid 'data' format in response")
//                        completion(nil)
//                    }
//                } else {
//                    print("Failed to parse JSON response")
//                    completion(nil)
//                }
//            } catch {
//                print("Error parsing API response: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//    }
//    
//     func callAPIAndNavigate(completion: @escaping () -> Void) {
//        guard let token = TokenManager.shared.getToken() else {
//            print("Token is nil. Cannot proceed with API call.")
//            completion()  // Ensure completion is called even on failure
//            return
//        }
//
//        let urlString = APIManager.shared.baseURL + "groups?category=school"
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL.")
//            completion()
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("API call failed with error: \(error.localizedDescription)")
//                completion()
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                print("API call failed with response: \(response.debugDescription)")
//                completion()
//                return
//            }
//
//            guard let data = data else {
//                print("No data received.")
//                completion()
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let schoolResponse = try decoder.decode(SchoolResponse.self, from: data)
//
//                guard let schoolsData = schoolResponse.data else {
//                    print("No schools data found.")
//                    completion()
//                    return
//                }
//
//                self.schools = schoolsData.compactMap { School(from: $0) }
//                print("Fetched Schools: \(self.schools.map { $0.shortName })")
//
//                DispatchQueue.main.async {
//                    completion()  // Notify when data is ready
//                }
//
//            } catch {
//                print("Failed to decode API response: \(error.localizedDescription)")
//                completion()
//            }
//        }
//
//        task.resume()
//    }
//}
