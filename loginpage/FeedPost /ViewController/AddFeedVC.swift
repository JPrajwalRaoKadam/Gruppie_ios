//
//  AddFeedVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 16/01/25.
//

import UIKit

class AddFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddFeedInfoCellDelegate {
    
    @IBOutlet weak var addFeedTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var postName : String = ""
    var postDescription: String?
    var contentImage: UIImage?
    var documentURL: URL?
    
    var selectedIndexPath: IndexPath? // Keeps track of the selected index
    var groupID: String?
    var teamPosts: [TeamPost] = []
    var currentPage: Int = 1
    var isLoading: Bool = false // To prevent multiple API calls at the same time
    var response: PostResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Register table view cells
        addFeedTableView.register(UINib(nibName: "AddFeedInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFeedInfoTableViewCell")
        addFeedTableView.register(UINib(nibName: "ClassTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTableViewCell")
        
        // Fetch initial team data
        loadTeams()
        
        submitButton.layer.cornerRadius = 10
        // Set delegate and data source
        addFeedTableView.delegate = self
        addFeedTableView.dataSource = self
        
        // Enable dynamic row height
        addFeedTableView.estimatedRowHeight = 100
        addFeedTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        let postName = self.postName
        // Validate if the necessary data is present
        guard let postDescription = self.postDescription else {
            print("Post Name or Post Description is missing")
            return
        }
        
        // Determine the file type based on the document URL
        var fileType: String = ""
        var fileNameArray: [String] = []
        var youTube : URL = URL(fileURLWithPath: "")
        
        if let documentURL = self.documentURL {
            let absoluteString = documentURL.absoluteString.lowercased()

            if absoluteString.contains("youtube.com") || absoluteString.contains("youtu.be") {
                fileType = "youtube"
            } else {
                let pathExtension = documentURL.pathExtension.lowercased()
                
                switch pathExtension {
                case "jpg", "jpeg", "png", "gif":
                    fileType = "image"
                case "mp4", "mov", "avi":
                    fileType = "video"
                case "pdf":
                    fileType = "pdf"
                case "mp3", "aac", "wav":
                    fileType = "audio"
                default:
                    fileType = "unknown"
                }
            }

            // Convert URL to Base64
            if let base64URL = documentURL.absoluteString.data(using: .utf8)?.base64EncodedString() {
                youTube = documentURL
                fileNameArray.append(base64URL)
            }
        }


        // Get selected items from the team post (assuming `teamPosts` has selected item)
        var selectedArray: [SelectedItem] = []
        if let selectedIndexPath = self.selectedIndexPath {
            let selectedTeamPost = teamPosts[selectedIndexPath.row]
            let selectedItem = SelectedItem(
                id: selectedTeamPost.id,
                name: selectedTeamPost.name,
                type: selectedTeamPost.type
            )
            selectedArray.append(selectedItem)
        }

        // Construct the AddPostRequest
        let postRequest = AddPostRequest(
            fileName: fileNameArray,         // Assign the fileName (document URL)
            fileType: fileType,             // Assign the file type based on the document URL
            selectedArray: selectedArray,   // Selected items from team posts
            text: postDescription,                 // Post Name as text
            thumbnailImage: [],             // Can be populated with actual thumbnail if required
            title: postName,         // Post Description as title
            video: ("\(youTube)")                      // Video URL or identifier (if available)
        )

        // Proceed with the API call to add the post
        if let bearerToken = TokenManager.shared.getToken() {
            addPost(token: bearerToken, groupId: self.groupID ?? "", postRequest: postRequest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseData):
                        print("✅ Post Added Successfully")
                        
                        // Construct a new Post object from postRequest
                        let newPost = Post(
                            updatedAt: Date().iso8601String, // Generate current timestamp
                            type: postRequest.selectedArray.first?.type ?? "", // Adjust according to API response
                            title: postRequest.title,
                            text: postRequest.text,
                            teamName: postRequest.selectedArray.first?.name,
                            teamId: postRequest.selectedArray.first?.id,
                            postViewedCount: "0",
                            likes: 0,
                            isLiked: false,
                            isFavourited: false,
                            id: UUID().uuidString, // Temporary ID until real one is fetched
                            groupId: self.groupID ?? "", // Replace with actual group ID
                            fileType: postRequest.fileType,
                            fileName: postRequest.fileName,
                            createdByImage: nil,
                            createdById: "CURRENT_USER_ID", // Replace with actual user ID
                            createdBy: "CURRENT_USER_NAME", // Replace with actual user name
                            createdAt: Date().iso8601String,
                            commentsEnabled: true,
                            comments: 0,
                            canEdit: true,
                            video: postRequest.video,
                            thumbnail: postRequest.thumbnailImage.first
                        )
                        
                        // Append new post to local response data
                        self.response?.data.insert(newPost, at: 0) // Adds at the top
                        
                        print("🆕 Updated Feed: \(self.response?.data.count ?? 0) posts")
                        self.navigationController?.popViewController(animated: true)

                    case .failure(let error):
                        print("❌ Error Adding Post: \(error.localizedDescription)")
                    }
                }
            }
        }

    }
    
    func assignFinalUrl(finalUrl: URL) {
        self.documentURL = finalUrl
    }
    
    func assignPostName(postName: String) {
        self.postName = postName
    }
    
    func assignPostDescription(postDescription: String) {
        self.postDescription = postDescription
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Two sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : teamPosts.count // First section: 1 row, Second section: 15 rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // First section: AddFeedInfoTableViewCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedInfoTableViewCell", for: indexPath) as? AddFeedInfoTableViewCell else {
                return UITableViewCell()
            }
            cell.parentViewController = self
            cell.delegate = self
            return cell
        } else {
            // Second section: ClassTableViewCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTableViewCell", for: indexPath) as? ClassTableViewCell else {
                return UITableViewCell()
            }
            let teamPost = teamPosts[indexPath.row]
            cell.configure(teamPost: teamPost)
            cell.setFirstLetterAsImage()
            
            // Configure checkbox state
            let isSelected = selectedIndexPath == indexPath
            let imageName = isSelected ? "checkmark.rectangle.fill" : "rectangle"
            cell.checkBox.setImage(UIImage(systemName: imageName), for: .normal)
            
            // Add target for the button
            cell.checkBox.tag = indexPath.row
            cell.checkBox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // MARK: - Checkbox Action
    
    @objc func checkboxTapped(_ sender: UIButton) {
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 1)
        
        // Toggle selection state
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil // Deselect if already selected
        } else {
            let previousIndexPath = selectedIndexPath // Save the previously selected index
            selectedIndexPath = indexPath // Update to the new selection
            
            // Reload the previously selected row (if any) and the new selected row
            var indexPathsToReload: [IndexPath] = [indexPath]
            if let previousIndexPath = previousIndexPath {
                indexPathsToReload.append(previousIndexPath)
            }
            addFeedTableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
    }
    
    
    func loadTeams() {
        guard !isLoading else { return } // Prevent multiple API calls
        isLoading = true
        getTeams(groupId: groupID ?? "", page: currentPage) { result in
            switch result {
            case .success(let responseData):
                self.teamPosts.append(contentsOf: responseData.data) // Append the new data
                self.currentPage += 1 // Increment the page number for next request
                
                // Update the UI
                DispatchQueue.main.async {
                    self.addFeedTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching teams: \(error)")
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Pagination
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        
        // Check if the user has scrolled to the bottom of the table view
        if offsetY > contentHeight - height - 100 { // 100 is a buffer to trigger the load
            loadTeams() // Load more data
        }
    }
    
    // MARK: - API Request
    
    func getTeams(groupId: String, page: Int, completion: @escaping (Result<ResponseData, Error>) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/feeder/teams/get?page=\(page)"
        
        // Create URL from the string
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // Retrieve the authentication token (replace with your token management method)
        guard let authToken = TokenManager.shared.getToken() else {
            completion(.failure(NSError(domain: "Missing Auth Token", code: 401, userInfo: nil)))
            return
        }
        
        // Create a URLRequest and set the Authorization header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 400, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(ResponseData.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func addPost(token: String, groupId: String, postRequest: AddPostRequest, completion: @escaping (Result<AddPostResponse, Error>) -> Void) {
        let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/feeder/post/add")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(postRequest)
            request.httpBody = jsonData
            // Debugging: Print JSON Body Before Sending
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Final JSON Body Sent:\n\(jsonString)")
            }
            
            request.httpBody = jsonData
        } catch {
            print("❌ JSON Encoding Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(AddPostResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("❌ Decoding Error: \(error.localizedDescription)")
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                        completion(.success(AddPostResponse(success: true, message: "Post added successfully")))
                    } else {
                        completion(.failure(error))
                    }
                }
            } else {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    completion(.success(AddPostResponse(success: true, message: "Post added successfully")))
                } else {
                    completion(.failure(NSError(domain: "No Data", code: 1001, userInfo: nil)))
                }
            }
        }
        
        task.resume()
    }

}


extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
