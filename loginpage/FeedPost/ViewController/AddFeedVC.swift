//
//  AddFeedVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 16/01/25.
//

import UIKit
import AVFoundation
import PDFKit
import AWSS3

struct MediaUrl: Codable {
    let url: String
    let type: String
}

class AddFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddFeedInfoCellDelegate {
    
    @IBOutlet weak var addFeedTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var postName: String = ""
    var postDescription: String?
    var contentImage: UIImage?
    var documentURL: URL?
    var localVideofilePath: [URL] = []
    var localThumbfilePath: [URL] = []
    
    var selectedIndexPath: IndexPath?
    var groupID: String?
    var teamPosts: [TeamPost] = []
    var currentPage: Int = 1
    var isLoading: Bool = false
    var response: PostResponse?
    
    // Digital Ocean Spaces Configuration
    let spaceName = "gruppiemedia"
    let spaceRegion = AWSRegionType.USEast1
    let endpoint = "https://sgp1.digitaloceanspaces.com"
    let configurationKey = "digitalOceanSpacesConfig"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFeedTableView.layer.cornerRadius = 10
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        addFeedTableView.register(UINib(nibName: "AddFeedInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFeedInfoTableViewCell")
        addFeedTableView.register(UINib(nibName: "ClassTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTableViewCell")
        
        // Configure Digital Ocean Spaces
        configureDigitalOceanSpaces()
        
        loadTeams()
        
        submitButton.layer.cornerRadius = 10
        addFeedTableView.delegate = self
        addFeedTableView.dataSource = self
        
        addFeedTableView.estimatedRowHeight = 100
        addFeedTableView.rowHeight = UITableView.automaticDimension
        enableKeyboardDismissOnTap()
    }
    
    // MARK: - Digital Ocean Spaces Configuration
    // MARK: - Digital Ocean Spaces Configuration
    private func configureDigitalOceanSpaces() {
        // Use the same credentials as SpacesFileRepository
        let accessKey = "NZZPHWUCQLCGPKDSWXHA"
        let secretKey = "0BOBamyRMoWstLoX96aTg92Q9EMOZg9B7dXY/35BMn0"
        
        let credentialsProvider = AWSStaticCredentialsProvider(
            accessKey: accessKey,
            secretKey: secretKey
        )
        
        // Create endpoint configuration for Digital Ocean Spaces
        let configuration = AWSServiceConfiguration(
            region: spaceRegion,
            endpoint: AWSEndpoint(urlString: endpoint),
            credentialsProvider: credentialsProvider
        )
        
        // Register the configuration with a specific key
        AWSS3TransferUtility.register(
            with: configuration!,
            forKey: configurationKey
        )
        
        // Also set as default for other AWS services if needed
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        print("✅ Digital Ocean Spaces configured successfully")
    }
    
    private func getTransferUtility() -> AWSS3TransferUtility? {
        // Use the same configuration key as SpacesFileRepository
        return AWSS3TransferUtility.s3TransferUtility(forKey: "gruppiemedia")
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func submitAction(_ sender: Any) {
//        let postName = self.postName
//        
//        guard let postDescription = self.postDescription else {
//            showAlert(title: "Error", message: "Post description is required")
//            return
//        }
//        
//        guard postName.isEmpty == false else {
//            showAlert(title: "Error", message: "Post name is required")
//            return
//        }
//        
//        // Check if AWS is configured
//        guard getTransferUtility() != nil else {
//            showAlert(title: "Configuration Error", message: "File upload service is not configured properly.")
//            return
//        }
//        
//        // Show loading indicator
//        showLoadingIndicator()
//        
//        // First upload files to Digital Ocean Spaces, then submit post
//        uploadFilesToDigitalOcean { [weak self] success, fileURLs, thumbnailURLs in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                self.hideLoadingIndicator()
//                
//                if success {
//                    self.submitPostWithUploadedURLs(fileURLs: fileURLs, thumbnailURLs: thumbnailURLs)
//                } else {
//                    self.showAlert(title: "Upload Failed", message: "Failed to upload files. Please try again.")
//                }
//            }
//        }
//    }
    
    @IBAction func submitAction(_ sender: Any) {
        let postName = self.postName
        
        guard let postDescription = self.postDescription else {
            showAlert(title: "Error", message: "Post description is required")
            return
        }
        
        guard postName.isEmpty == false else {
            showAlert(title: "Error", message: "Post name is required")
            return
        }
        
        guard let selectedIndexPath = selectedIndexPath else {
            showAlert(title: "Error", message: "Please select a team to post to")
            return
        }
        
        let selectedTeam = teamPosts[selectedIndexPath.row]
        let teamId = selectedTeam.id
        
        // Show loading indicator
        showLoadingIndicator()
        
        // Check if we have a YouTube URL
        if let documentURL = self.documentURL, isYouTubeURL(documentURL) {
            print("🎥 YouTube URL detected: \(documentURL.absoluteString)")
            
            // Extract the clean YouTube URL
            let youtubeURL = cleanYouTubeURL(documentURL.absoluteString)
            print("🎥 Clean YouTube URL: \(youtubeURL)")
            
            // Handle YouTube URL - no need to upload, use directly
            self.submitYouTubePost(teamId: teamId, postName: postName, postDescription: postDescription, youtubeURL: youtubeURL)
        } else {
            print("📁 Regular file detected, proceeding with upload")
            // Handle regular file upload
            uploadFilesToDigitalOcean { [weak self] success, fileURLs, thumbnailURLs in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    
                    if success {
                        self.submitPostWithUploadedURLs(
                            fileURLs: fileURLs,
                            thumbnailURLs: thumbnailURLs,
                            teamId: teamId,
                            postName: postName,
                            postDescription: postDescription
                        )
                    } else {
                        self.showAlert(title: "Upload Failed", message: "Failed to upload files. Please try again.")
                    }
                }
            }
        }
    }

    // Function to clean and standardize YouTube URLs
    // Function to clean and standardize YouTube URLs to the watch format
    private func cleanYouTubeURL(_ urlString: String) -> String {
        var cleanedURL = urlString
        
        // Extract video ID first
        guard let videoID = extractYouTubeVideoID(from: cleanedURL) else {
            return cleanedURL // Return original if we can't extract video ID
        }
        
        // Remove any mobile prefixes
        cleanedURL = cleanedURL.replacingOccurrences(of: "m.youtube.com", with: "youtube.com")
        cleanedURL = cleanedURL.replacingOccurrences(of: "m.youtu.be", with: "youtu.be")
        
        // Convert all formats to standard watch URL
        cleanedURL = "https://www.youtube.com/watch?v=\(videoID)"
        
        return cleanedURL
    }
    
    private func submitYouTubePost(teamId: String, postName: String, postDescription: String, youtubeURL: String) {
        // Clean the YouTube URL to standard format
        let cleanURL = cleanYouTubeURL(youtubeURL)
        print("🎥 Clean YouTube URL: \(cleanURL)")
        
        // For YouTube, we use the URL directly as both file and video
        let fileURLs = [cleanURL]
        
        // Try to get a thumbnail for the YouTube video
        if let videoID = extractYouTubeVideoID(from: cleanURL) {
            let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/0.jpg"
            
            let postRequest = AddPostRequest(
                fileName: fileURLs,
                fileType: "video",
                selectedArray: [SelectedItem(id: teamId, name: teamPosts.first(where: { $0.id == teamId })?.name ?? "")],
                text: postDescription,
                thumbnailImage: [thumbnailURL], // Use YouTube's thumbnail service
                title: postName,
                video: cleanURL
            )
            
            // Debug print the final request
            print("📤 Final JSON Body Sent:")
            if let jsonData = try? JSONEncoder().encode(postRequest),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            
            submitPostRequest(postRequest: postRequest)
        } else {
            // Fallback if we can't extract video ID
            let postRequest = AddPostRequest(
                fileName: fileURLs,
                fileType: "video",
                selectedArray: [SelectedItem(id: teamId, name: teamPosts.first(where: { $0.id == teamId })?.name ?? "")],
                text: postDescription,
                thumbnailImage: [], // No thumbnail
                title: postName,
                video: cleanURL
            )
            
            submitPostRequest(postRequest: postRequest)
        }
    }
    
    private func submitPostWithUploadedURLs(fileURLs: [String], thumbnailURLs: [String], teamId: String, postName: String, postDescription: String) {
        let primaryFileType = getMediaType(from: fileURLs.first ?? "")
        
        // Find the team name safely
        let teamName = teamPosts.first(where: { $0.id == teamId })?.name ?? "Unknown Team"
        
        let postRequest = AddPostRequest(
            fileName: fileURLs,
            fileType: primaryFileType,
            selectedArray: [SelectedItem(id: teamId, name: teamName)],
            text: postDescription,
            thumbnailImage: thumbnailURLs,
            title: postName,
            video: fileURLs.first(where: {
                $0.lowercased().hasSuffix(".mp4") ||
                $0.lowercased().hasSuffix(".mov") ||
                $0.lowercased().hasSuffix(".avi")
            }) ?? ""
        )
        
        submitPostRequest(postRequest: postRequest)
    }

    private func submitPostRequest(postRequest: AddPostRequest) {
        // Show loading indicator for post submission
        showLoadingIndicator()
        
        // Get auth token
        guard let token = TokenManager.shared.getToken() else {
            hideLoadingIndicator()
            showAlert(title: "Error", message: "Authentication token missing")
            return
        }
        
        // Submit the post
        addPost(token: token, groupId: groupID ?? "", postRequest: postRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAndDismiss()
                    } else {
                        // Print the full server response for debugging
                        print("❌ Server Error Response: \(response)")
                        self.showAlert(title: "Error", message: response.message ?? "Failed to submit post")
                    }
                case .failure(let error):
                    // Print the full error details
                    print("❌ Request Failed: \(error.localizedDescription)")
                    if let urlError = error as? URLError {
                        print("URL Error: \(urlError)")
                    }
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    private func submitPostWithUploadedURLs(fileURLs: [String], thumbnailURLs: [String]) {
          guard let selectedIndexPath = selectedIndexPath else {
              showAlert(title: "Error", message: "Please select a team to post to")
              return
          }
          
          let selectedTeam = teamPosts[selectedIndexPath.row]
          let teamId = selectedTeam.id
          
          // Get the post content
          let postName = self.postName
          let postDescription = self.postDescription ?? ""
          
          // Determine file type - handle multiple file types if needed
          let primaryFileType = getMediaType(from: fileURLs.first ?? "")
          
          // Prepare the request according to your backend structure
          let postRequest = AddPostRequest(
              fileName: fileURLs, // Array of file URLs
              fileType: primaryFileType, // Type from first file
              selectedArray: [SelectedItem(id: teamId, name: selectedTeam.name)], // Convert team to selected item
              text: postDescription,
              thumbnailImage: thumbnailURLs, // Array of thumbnail URLs
              title: postName,
              video: fileURLs.first(where: {
                  $0.lowercased().hasSuffix(".mp4") ||
                  $0.lowercased().hasSuffix(".mov") ||
                  $0.lowercased().hasSuffix(".avi")
              }) ?? "" // Video URL if exists
          )
          
          // Debug print
          print("📤 Post Request:")
          print("File Names: \(fileURLs)")
          print("File Type: \(primaryFileType)")
          print("Selected Team: \(selectedTeam.name) - \(teamId)")
          print("Text: \(postDescription)")
          print("Thumbnails: \(thumbnailURLs)")
          print("Title: \(postName)")
          print("Video: \(postRequest.video)")
          
          // Show loading indicator for post submission
          showLoadingIndicator()
          
          // Get auth token
          guard let token = TokenManager.shared.getToken() else {
              hideLoadingIndicator()
              showAlert(title: "Error", message: "Authentication token missing")
              return
          }
          
          // Submit the post
        addPost(token: token, groupId: groupID ?? "", postRequest: postRequest) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAndDismiss()
                    } else {
                        self.showAlert(title: "Error", message: response.message ?? "Failed to submit post")
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
      }
    // You'll also need to add the SelectedItem struct if it doesn't exist
    struct SelectedItem: Codable {
        let id: String
        let name: String
    }
//    private func getMediaType(from url: String) -> String {
//        if url.lowercased().hasSuffix(".mp4") || url.lowercased().hasSuffix(".mov") {
//            return "video"
//        } else if url.lowercased().hasSuffix(".jpg") || url.lowercased().hasSuffix(".jpeg") || url.lowercased().hasSuffix(".png") {
//            return "image"
//        } else if url.lowercased().hasSuffix(".pdf") {
//            return "document"
//        } else if url.lowercased().hasSuffix(".mp3") || url.lowercased().hasSuffix(".wav") {
//            return "audio"
//        }
//        return "file"
//    }
    
    private func getMediaType(from url: String) -> String {
        let lowercasedURL = url.lowercased()
        
        // Check for YouTube URLs first
        if lowercasedURL.contains("youtube.com") || lowercasedURL.contains("youtu.be") {
            return "video"
        }
        
        // Check file extensions
        if lowercasedURL.hasSuffix(".mp4") || lowercasedURL.hasSuffix(".mov") || lowercasedURL.hasSuffix(".avi") {
            return "video"
        } else if lowercasedURL.hasSuffix(".jpg") || lowercasedURL.hasSuffix(".jpeg") || lowercasedURL.hasSuffix(".png") {
            return "image"
        } else if lowercasedURL.hasSuffix(".pdf") {
            return "document"
        } else if lowercasedURL.hasSuffix(".mp3") || lowercasedURL.hasSuffix(".wav") {
            return "audio"
        }
        
        return "file"
    }
    
    private func showSuccessAndDismiss() {
        showAlert(title: "Success", message: "Post submitted successfully") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            
            // Optional: Notify that a new post was created
            NotificationCenter.default.post(name: NSNotification.Name("NewPostCreated"), object: nil)
        }
    }
    
    private func showLoadingIndicator() {
        let alert = UIAlertController(title: nil, message: "Uploading files...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideLoadingIndicator() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func uploadFilesToDigitalOcean(completion: @escaping (Bool, [String], [String]) -> Void) {
        var fileURLs: [String] = []
        var thumbnailURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []

        // Upload main file using SpacesFileRepository
        if let documentURL = self.documentURL {
            dispatchGroup.enter()
            
            let fileType: FileType
            let ext = documentURL.pathExtension.lowercased()
            switch ext {
            case "mp4", "mov": fileType = .video
            case "mp3", "wav": fileType = .audio
            case "pdf": fileType = .pdf
            default: fileType = .image
            }
            
            SpacesFileRepository.shared.upload(fileURL: documentURL, fileType: fileType) { result in
                switch result {
                case .success(let url):
                    fileURLs.append(url)
                case .failure(let error):
                    uploadErrors.append(error)
                    print("Main file upload error: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Upload thumbnails
        for thumbURL in localThumbfilePath {
            dispatchGroup.enter()
            SpacesFileRepository.shared.upload(fileURL: thumbURL, fileType: .image) { result in
                switch result {
                case .success(let url):
                    thumbnailURLs.append(url)
                case .failure(let error):
                    uploadErrors.append(error)
                    print("Thumbnail upload error: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let success = uploadErrors.isEmpty
            completion(success, fileURLs, thumbnailURLs)
        }
    }
//    private func uploadFilesToDigitalOcean(completion: @escaping (Bool, [String], [String]) -> Void) {
//        var fileURLs: [String] = []
//        var thumbnailURLs: [String] = []
//        let dispatchGroup = DispatchGroup()
//        var uploadErrors: [Error] = []
//
//        // Handle main file
//        if let documentURL = self.documentURL {
//            // Check if it's a YouTube URL - don't upload, just use the URL directly
//            if isYouTubeURL(documentURL) {
//                fileURLs.append(documentURL.absoluteString)
//            } else if documentURL.isFileURL {
//                // Local file - upload to Digital Ocean
//                dispatchGroup.enter()
//                let fileType: FileType = getFileType(from: documentURL)
//                SpacesFileRepository.shared.upload(fileURL: documentURL, fileType: fileType) { result in
//                    switch result {
//                    case .success(let url):
//                        fileURLs.append(url)
//                    case .failure(let error):
//                        uploadErrors.append(error)
//                        print("Main file upload error: \(error.localizedDescription)")
//                    }
//                    dispatchGroup.leave()
//                }
//            } else {
//                // External URL (not YouTube) - use directly
//                fileURLs.append(documentURL.absoluteString)
//            }
//        }
//
//        // Upload thumbnails (these should always be local files)
//        for thumbURL in localThumbfilePath {
//            dispatchGroup.enter()
//            SpacesFileRepository.shared.upload(fileURL: thumbURL, fileType: .image) { result in
//                switch result {
//                case .success(let url):
//                    thumbnailURLs.append(url)
//                case .failure(let error):
//                    uploadErrors.append(error)
//                    print("Thumbnail upload error: \(error.localizedDescription)")
//                }
//                dispatchGroup.leave()
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            let success = uploadErrors.isEmpty
//            completion(success, fileURLs, thumbnailURLs)
//        }
//    }

    private func isYouTubeURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        
        // Check for various YouTube URL patterns
        let youtubePatterns = [
            "youtube.com",
            "youtu.be",
            "youtube-nocookie.com",
            "youtube.googleapis.com",
            "www.youtube.com",
            "m.youtube.com"
        ]
        
        for pattern in youtubePatterns {
            if urlString.contains(pattern) {
                return true
            }
        }
        
        // Check for YouTube URL schemes
        if let scheme = url.scheme?.lowercased() {
            if scheme == "youtube" || scheme == "vnd.youtube" {
                return true
            }
        }
        
        // Check for YouTube video ID pattern (11 characters)
        if let _ = extractYouTubeVideoID(from: urlString) {
            return true
        }
        
        // Check for YouTube embed patterns
        if urlString.contains("/embed/") || urlString.contains("youtube.com/embed/") {
            return true
        }
        
        // Check for YouTube watch patterns with various parameter formats
        if urlString.contains("youtube.com/watch") {
            return true
        }
        
        // Check for YouTube share links
        if urlString.contains("youtu.be/") {
            return true
        }
        
        return false
    }

    private func extractYouTubeVideoID(from urlString: String) -> String? {
        // Regular expression patterns for YouTube video ID extraction
        let patterns = [
            #"(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})"#,
            #"youtube\.com\/embed\/([^"&?\/\s]{11})"#,
            #"youtube\.com\/watch\?v=([^"&?\/\s]{11})"#,
            #"youtu\.be\/([^"&?\/\s]{11})"#,
            #"youtube\.com\/v\/([^"&?\/\s]{11})"#,
            #"youtube\.com\/user\/[^\/]+\/?#([^"&?\/\s]{11})"#,
            #"youtube\.com\/shorts\/([^"&?\/\s]{11})"#,
            #"youtube\.com\/live\/([^"&?\/\s]{11})"#
        ]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let range = NSRange(location: 0, length: urlString.utf16.count)
                
                if let match = regex.firstMatch(in: urlString, options: [], range: range) {
                    let videoIDRange = match.range(at: 1)
                    if let range = Range(videoIDRange, in: urlString) {
                        return String(urlString[range])
                    }
                }
            } catch {
                print("Error parsing YouTube URL with pattern \(pattern): \(error)")
            }
        }
        
        // Additional fallback: try to extract from query parameters
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            // Look for v parameter
            if let videoID = queryItems.first(where: { $0.name == "v" })?.value,
               videoID.count == 11 {
                return videoID
            }
        }
        
        return nil
    }
    private func getFileType(from url: URL) -> FileType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "mp4", "mov": return .video
        case "mp3", "wav": return .audio
        case "pdf": return .pdf
        default: return .image
        }
    }
    
    private func uploadFileToDigitalOcean(fileURL: URL, fileType: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let transferUtility = getTransferUtility() else {
            completion(.failure(NSError(domain: "AWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transfer utility not configured"])))
            return
        }
        
        let remoteName = "\(UUID().uuidString)_\(fileURL.lastPathComponent)"
        let key = "posts/\(remoteName)"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { task, progress in
            print("Upload progress: \(progress.fractionCompleted)")
        }
        
        // Set ACL to public read
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        transferUtility.uploadFile(fileURL,
                                   bucket: spaceName,
                                   key: key,
                                   contentType: getMimeType(for: fileURL.pathExtension),
                                   expression: expression) { task, error in
            if let error = error {
                print("Upload failed with error: \(error)")
                completion(.failure(error))
            } else {
                // Digital Ocean Spaces URL format: https://bucketname.region.digitaloceanspaces.com/key
                let regionPart = self.endpoint.replacingOccurrences(of: "https://", with: "")
                let uploadedURL = "https://\(self.spaceName).\(regionPart)/\(key)"
                print("Uploaded to: \(uploadedURL)")
                completion(.success(uploadedURL))
            }
        }
    }
    
    private func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "pdf": return "application/pdf"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : teamPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedInfoTableViewCell", for: indexPath) as? AddFeedInfoTableViewCell else {
                return UITableViewCell()
            }
            cell.parentViewController = self
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTableViewCell", for: indexPath) as? ClassTableViewCell else {
                return UITableViewCell()
            }
            let teamPost = teamPosts[indexPath.row]
            cell.configure(teamPost: teamPost)
            cell.setFirstLetterAsImage()
            
            let isSelected = selectedIndexPath == indexPath
            let imageName = isSelected ? "checkmark.rectangle.fill" : "rectangle"
            cell.checkBox.setImage(UIImage(systemName: imageName), for: .normal)
            
            cell.checkBox.tag = indexPath.row
            cell.checkBox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // MARK: - Checkbox Action
    @objc func checkboxTapped(_ sender: UIButton) {
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 1)
        
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            let previousIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            
            var indexPathsToReload: [IndexPath] = [indexPath]
            if let previousIndexPath = previousIndexPath {
                indexPathsToReload.append(previousIndexPath)
            }
            addFeedTableView.reloadRows(at: indexPathsToReload, with: .automatic)
        }
    }
    
    func loadTeams() {
        guard !isLoading else { return }
        isLoading = true
        getTeams(groupId: groupID ?? "", page: currentPage) { result in
            switch result {
            case .success(let responseData):
                self.teamPosts.append(contentsOf: responseData.data)
                self.currentPage += 1
                
                DispatchQueue.main.async {
                    self.addFeedTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching teams: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func getTeams(groupId: String, page: Int, completion: @escaping (Result<ResponseData, Error>) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/feeder/teams/get?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        guard let authToken = TokenManager.shared.getToken() else {
            completion(.failure(NSError(domain: "Missing Auth Token", code: 401, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
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
            
            // Print the JSON being sent for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Final JSON Body Sent:\n\(jsonString)")
            }
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            print("📡 Response Status Code: \(httpResponse.statusCode)")
            
            // Print response body for debugging
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                print("📡 Response Body: \(responseBody)")
            }
            
            // Handle success status codes (200, 201)
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                if let data = data, !data.isEmpty {
                    do {
                        let decodedResponse = try JSONDecoder().decode(AddPostResponse.self, from: data)
                        completion(.success(decodedResponse))
                    } catch {
                        print("❌ Decoding Error: \(error)")
                        // Even if decoding fails, consider it success if status is 201
                        let successResponse = AddPostResponse(success: true, message: "Post created successfully")
                        completion(.success(successResponse))
                    }
                } else {
                    let successResponse = AddPostResponse(success: true, message: "Post created successfully")
                    completion(.success(successResponse))
                }
                return
            }
            
            // Handle error status codes (400+)
            if let data = data, !data.isEmpty {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let errorMessage = errorResponse.message ?? "Unknown server error"
                    print("❌ Server Error: \(errorMessage)")
                    let error = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error))
                } catch {
                    let errorBody = String(data: data, encoding: .utf8) ?? "No error details"
                    print("❌ Server Error (non-JSON): \(errorBody)")
                    let error = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode) - \(errorBody)"])
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    func assignPostName(postName: String) {
        self.postName = postName
    }
    
    func assignPostDescription(postDescription: String) {
        self.postDescription = postDescription
    }
    
    func assignFinalUrl(finalUrl: URL) {
        self.documentURL = finalUrl
    }
}

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}



