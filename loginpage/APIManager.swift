//
//  APIManager.swift
//  loginpage
//
//  Created by apple on 11/02/25.
//

import Foundation

enum APIError: Error {
    case networkError(String)
    case decodingError(String)
    case unknown
}


enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

class APIManager {
    static let shared = APIManager()
    
    enum Server: String, CaseIterable {
//        case gcc = "https://gcc.gruppie.in/api/v1/"
//        case gcc6 = "https://gcc6.gruppie.in/api/v1/"
        case newServer = "https://dev.gruppie.in/api/v1/"
        
        var priority: Int {
            switch self {
//            case .gcc: return 0
//            case .gcc6: return 1
            case .newServer: return 0
            }
        }
    }
    
    // Endpoint paths (without base URL)
    enum Endpoints {
        static let parent = "my/kids"
        static let teacher = "my/class/teams"
        static let admin = "class/get"
        static let userExist = "user/exist/category/app?category=school&appName=GC2"
    }
    
    // Backward-compatible properties
    var baseURL: String {
        return getActiveBaseURL()
    }
    
    var parentEndPoint: String { Endpoints.parent }
    var teacherEndPoint: String { Endpoints.teacher }
    var adminEndPoint: String { Endpoints.admin }
    
    private(set) var activeServer: Server = .newServer
    
    // MARK: - Server Checking Methods
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        queryParams: [String: String]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Only add body for POST/PUT
        if let body = body, method != .get {
            do {
                request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.unknown(error))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }


    
    func checkUserAcrossServers(phoneData: PhoneData, completion: @escaping (Result<(response: [String: Any], server: Server), Error>) -> Void) {
        let servers = Server.allCases.sorted { $0.priority < $1.priority }
        var responses: [(server: Server, response: [String: Any]?)] = []
        let dispatchGroup = DispatchGroup()

        for server in servers {
            dispatchGroup.enter()

            let endpoint = server.rawValue + Endpoints.userExist
            guard let url = URL(string: endpoint) else {
                dispatchGroup.leave()
                continue
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 8

            do {
                request.httpBody = try JSONEncoder().encode(phoneData)
            } catch {
                print("Encoding error: \(error)")
                dispatchGroup.leave()
                continue
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("❌ Server \(server) error: \(error.localizedDescription)")
                    responses.append((server, nil))
                    return
                }

                guard let data = data else {
                    print("❌ No data from \(server)")
                    responses.append((server, nil))
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📥 \(server) response: \(json)")

                        if let responseData = json["data"] as? [String: Any],
                           let isAllowedToAccessApp = responseData["isAllowedToAccessApp"] as? Bool,
                           isAllowedToAccessApp {
                            responses.append((server, responseData))
                            return
                        } else if let isAllowedToAccessApp = json["isAllowedToAccessApp"] as? Bool,
                                  isAllowedToAccessApp {
                            responses.append((server, json))
                            return
                        }
                    }

                    // response is invalid or access not allowed
                    responses.append((server, nil))
                } catch {
                    print("Parsing error from \(server): \(error)")
                    responses.append((server, nil))
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            // Check for first valid allowed response
            for server in servers {
                if let response = responses.first(where: { $0.server == server && $0.response != nil })?.response {
                    print("✅ Final selected server: \(server)")
                    APIManager.shared.setActiveServer(server)
                    completion(.success((response, server)))
                    return
                }
            }

            // All failed
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not allowed or all servers failed."])))
        }
    }

    struct AnyEncodable: Encodable {
        private let encodeFunc: (Encoder) throws -> Void

        init<T: Encodable>(_ value: T) {
            self.encodeFunc = value.encode
        }

        func encode(to encoder: Encoder) throws {
            try encodeFunc(encoder)
        }
    }
    
    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
        case encodingError
        case serverError(Int)
        case unknown(Error?)
    }
    
    // MARK: - Existing Methods
    
    func setActiveServer(_ server: Server) {
        activeServer = server
        UserDefaults.standard.set(server.rawValue, forKey: "activeServer")
    }
    
    func getActiveBaseURL() -> String {
        if let savedServer = UserDefaults.standard.string(forKey: "activeServer"),
           let server = Server(rawValue: savedServer) {
            return server.rawValue
        }
        return activeServer.rawValue
    }
    
    // Helper method to build complete URLs
    func buildURL(for endpoint: String) -> URL? {
        return URL(string: baseURL + endpoint)
    }
    
    private init() {
        if let savedServer = UserDefaults.standard.string(forKey: "activeServer"),
           let server = Server(rawValue: savedServer) {
            activeServer = server
        }
    }
}


class APIProdManager {
    static let shared = APIProdManager()
    
    // Define the base URL here
    let baseURL = "https://prod.gruppie.in/api/v1/"
    
    private init() {} // Prevents others from creating another instance
}
