//
//  AddFeedVC.swift
//  loginpage
//

import UIKit
import AVFoundation
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

class AddFeedVC: UIViewController,
                UITableViewDelegate,
                UITableViewDataSource,
                AddFeedInfoCellDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addFeedTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Properties
    
    var postName: String = ""
    var postDescription: String?
    var documentURL: URL?
    var selectedMediaData: Data?
    var selectedMediaMimeType: String?
    var selectedMediaFileName: String?
    var isConverting = false
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    
    var selectedIndexPath: IndexPath?
    
    var teamID: String?
    var feedSource: FeedSource = .normalFeed
    
    var currentPage = 1
    var isLoading = false
    
    public var teamPosts: [GroupClass] = []
    public var pagination: Pagination?
    
    var visibleTeams: [GroupClass] {
        switch feedSource {
        case .normalFeed:
            return teamPosts
        case .noticeBoard:
            return []
        case .classroom(let teamId):
            return teamPosts.filter { $0.id == teamId }
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTeams()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addFeedTableView.layer.cornerRadius = 10
        
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true
        
        submitButton.layer.cornerRadius = 10
        
        addFeedTableView.register(UINib(nibName: "AddFeedInfoTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "AddFeedInfoTableViewCell")
        
        addFeedTableView.register(UINib(nibName: "ClassTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "ClassTableViewCell")
        
        addFeedTableView.delegate = self
        addFeedTableView.dataSource = self
        
        addFeedTableView.rowHeight = UITableView.automaticDimension
        addFeedTableView.estimatedRowHeight = 100
        
        enableKeyboardDismissOnTap()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        guard !postName.isEmpty else {
            showAlert(title: "Error", message: "Enter title")
            return
        }
        
        guard let body = postDescription, !body.isEmpty else {
            showAlert(title: "Error", message: "Enter description")
            return
        }
        
        if postName.count < 5 || (postDescription ?? "").count < 10 {
            showAlert(
                title: "Invalid Input",
                message: "Title must be at least 5 characters and Description must be at least 10 characters"
            )
            return
        }
        
        guard let selectedIndexPath else {
            showAlert(title: "Error", message: "Select team")
            return
        }
        
        guard let token = SessionManager.useRoleToken else {
            showAlert(title: "Error", message: "Token missing")
            return
        }
        
        // Check if we need to convert MOV to MP4
        if let url = documentURL, url.pathExtension.lowercased() == "mov" {
            convertMovToMp4(sourceURL: url, token: token)
        } else {
            // Proceed with normal upload
            submitPost(token: token, selectedIndexPath: selectedIndexPath)
        }
    }
    
    private func submitPost(token: String, selectedIndexPath: IndexPath) {
        showLoading()
        guard let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not available")
            return
        }
        
        // Base params
        var params: [String: String] = [
            "postType": "team",
            "title": postName,
            "body": postDescription ?? "",
            "shareInternal": "true",
            "shareExternal": "false",
            "groupAcademicYearId": groupAcademicYearId
        ]
        
        // Set post type based on selection
        switch feedSource {
        case .noticeBoard:
            params["postType"] = "group"
            params["teamId"] = nil
            
        case .classroom(let teamId):
            params["postType"] = "team"
            params["teamId"] = teamId
            
        case .normalFeed:
            let row = selectedIndexPath.row
            if row == 0 {
                params["postType"] = "group"
                params["teamId"] = nil
            } else if row - 1 < teamPosts.count {
                let team = teamPosts[row - 1]
                params["teamId"] = team.id
            }
        }
        
        // Handle attachment
        var files: [URL] = []
        var mediaData: [String: Any] = [:]
        
        if let url = documentURL {
            let urlString = url.absoluteString.lowercased()
            
            // Check if it's a YouTube URL
            if urlString.contains("youtube.com") || urlString.contains("youtu.be") {
                print("🎥 YouTube URL:", url.absoluteString)
                params["videoUrl"] = url.absoluteString
                params["hasAttachments"] = "false"
            } else {
                // Get proper MIME type and file data
                let mimeType = getMimeType(for: url)
                let fileName = url.lastPathComponent
                
                print("📎 File Selected:", fileName)
                print("📎 MIME Type:", mimeType)
                
                // Check if it's a supported media type (server accepts: PDF, JPEG, JPG, PNG, mp3, mp4)
                let isServerSupported = isServerSupportedFileType(mimeType: mimeType, fileName: fileName)
                
                if isServerSupported {
                    if fileName.lowercased().hasSuffix(".mp4") || mimeType.contains("video/mp4") {
                        // For MP4 files
                        if let fileData = try? Data(contentsOf: url) {
                            mediaData["data"] = fileData
                            mediaData["mimeType"] = "video/mp4"
                            mediaData["fileName"] = fileName.replacingOccurrences(of: ".mov", with: ".mp4")
                            params["hasAttachments"] = "true"
                            print("✅ MP4 file ready for upload")
                        }
                    } else {
                        // For other supported files (PDF, images, mp3)
                        files.append(url)
                        params["hasAttachments"] = "true"
                    }
                } else {
                    hideLoading()
                    showAlert(title: "Error",
                             message: "File type not supported. Server accepts: PDF, JPEG, JPG, PNG, MP3, MP4 files only.")
                    return
                }
            }
        } else {
            params["hasAttachments"] = "false"
        }
        
        // Print final payload for debugging
        print("\n==============================")
        print("🚀 FINAL POST PAYLOAD")
        print("==============================")
        print("📄 Params:")
        params.forEach { print("\($0.key): \($0.value)") }
        
        print("\n📎 Files:")
        if !files.isEmpty {
            files.forEach { print($0.lastPathComponent) }
        } else if !mediaData.isEmpty {
            print("📎 Media Data: \(mediaData["fileName"] ?? "Unknown")")
        } else {
            print("No Attachments")
        }
        print("==============================\n")
        
        // Upload based on whether we have file URLs or direct data
        if !mediaData.isEmpty {
            uploadMultipartWithData(token: token,
                                   params: params,
                                   mediaData: mediaData,
                                   completion: { [weak self] (result: Result<String, Error>) in
                guard let self = self else { return }
                self.hideLoading()
                
                switch result {
                case .success(let response):
                    print("✅ Server Response:", response)
                    // Check if response contains success
                    if response.contains("\"success\":true") {
                        self.showSuccessAndDismiss()
                    } else {
                        self.showAlert(title: "Upload Failed",
                                      message: "Server rejected the file. Please ensure it's a valid MP4 file.")
                    }
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                    self.showAlert(title: "Failed", message: error.localizedDescription)
                }
            })
        } else {
            uploadMultipartWithFiles(token: token,
                                    params: params,
                                    files: files,
                                    completion: { [weak self] (result: Result<String, Error>) in
                guard let self = self else { return }
                self.hideLoading()
                
                switch result {
                case .success(let response):
                    print("✅ Server Response:", response)
                    if response.contains("\"success\":true") {
                        self.showSuccessAndDismiss()
                    } else {
                        // Try to parse error message
                        if let data = response.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = json["message"] as? String {
                            self.showAlert(title: "Upload Failed", message: message)
                        } else {
                            self.showAlert(title: "Upload Failed", message: "Server rejected the file")
                        }
                    }
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                    self.showAlert(title: "Failed", message: error.localizedDescription)
                }
            })
        }
    }
    
    // MARK: - MOV to MP4 Conversion
    
    private func convertMovToMp4(sourceURL: URL, token: String) {
        guard !isConverting else { return }
        
        isConverting = true
        showLoading(message: "Converting video...")
        
        let asset = AVAsset(url: sourceURL)
        let preset = AVAssetExportPresetHighestQuality
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        // Remove existing file if any
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
            isConverting = false
            hideLoading()
            showAlert(title: "Error", message: "Could not create export session")
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isConverting = false
                self.hideLoading()
                
                switch exportSession.status {
                case .completed:
                    print("✅ MOV to MP4 conversion completed")
                    self.documentURL = outputURL
                    // Now submit with the converted MP4
                    if let selectedIndexPath = self.selectedIndexPath {
                        self.submitPost(token: token, selectedIndexPath: selectedIndexPath)
                    }
                    
                case .failed:
                    print("❌ Conversion failed:", exportSession.error?.localizedDescription ?? "Unknown error")
                    self.showAlert(title: "Conversion Failed",
                                  message: "Could not convert MOV to MP4. Please try another video.")
                    
                case .cancelled:
                    print("❌ Conversion cancelled")
                    self.showAlert(title: "Cancelled", message: "Video conversion was cancelled")
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func isServerSupportedFileType(mimeType: String, fileName: String) -> Bool {
        let lowercasedFileName = fileName.lowercased()
        let lowercasedMimeType = mimeType.lowercased()
        
        // Server accepts: PDF, JPEG, JPG, PNG, mp3, mp4
        if lowercasedFileName.hasSuffix(".pdf") || lowercasedMimeType.contains("application/pdf") {
            return true
        }
        if lowercasedFileName.hasSuffix(".jpg") || lowercasedFileName.hasSuffix(".jpeg") ||
           lowercasedMimeType.contains("image/jpeg") {
            return true
        }
        if lowercasedFileName.hasSuffix(".png") || lowercasedMimeType.contains("image/png") {
            return true
        }
        if lowercasedFileName.hasSuffix(".mp3") || lowercasedMimeType.contains("audio/mpeg") {
            return true
        }
        if lowercasedFileName.hasSuffix(".mp4") || lowercasedMimeType.contains("video/mp4") {
            return true
        }
        
        return false
    }
    
    static func create(feedSource: FeedSource) -> AddFeedVC {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddFeedVC") as! AddFeedVC
        vc.feedSource = feedSource
        return vc
    }
    
    // MARK: - Load Teams
    
    func loadTeams() {
        guard !isLoading else { return }
        
        isLoading = true
        
        fetchTeams { [weak self] teams in
            guard let self = self else { return }
            self.teamPosts = teams
            self.isLoading = false
            self.addFeedTableView.reloadData()
        }
    }
    
    // MARK: - Fetch Teams
    
    func fetchTeams(completion: @escaping ([GroupClass]) -> Void) {
        APIManager.shared.getGroupClasses(page: 1, limit: 10) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(response.data)
                }
            case .failure(let error):
                print("❌ API Error:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        
        switch feedSource {
        case .normalFeed:
            return visibleTeams.count + 1   // Notice Board + Teams
        case .noticeBoard:
            return 1                        // Only Notice Board
        case .classroom:
            return visibleTeams.count       // Only Matching Team
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFeedInfoTableViewCell", for: indexPath) as! AddFeedInfoTableViewCell
            cell.delegate = self
            cell.parentViewController = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTableViewCell", for: indexPath) as! ClassTableViewCell
        
        switch feedSource {
        case .normalFeed:
            if indexPath.row == 0 {
                cell.classLabel.text = "Notice Board"
            } else {
                let team = visibleTeams[indexPath.row - 1]
                cell.configure(teamPost: team)
            }
        case .noticeBoard:
            cell.classLabel.text = "Notice Board"
        case .classroom:
            let team = visibleTeams[indexPath.row]
            cell.configure(teamPost: team)
        }
        
        let selected = selectedIndexPath == indexPath
        cell.checkBox.setImage(UIImage(systemName: selected ? "checkmark.rectangle.fill" : "rectangle"), for: .normal)
        
        cell.checkBox.tag = indexPath.row
        cell.checkBox.accessibilityIdentifier = "\(indexPath.section)"
        cell.checkBox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Checkbox
    
    @objc func checkboxTapped(_ sender: UIButton) {
        guard let sectionString = sender.accessibilityIdentifier,
              let section = Int(sectionString) else { return }
        
        let indexPath = IndexPath(row: sender.tag, section: section)
        selectedIndexPath = (selectedIndexPath == indexPath) ? nil : indexPath
        
        addFeedTableView.reloadSections(IndexSet(integer: section), with: .none)
    }
    
    // MARK: - Delegates
    
    func assignPostName(postName: String) { self.postName = postName }
    func assignPostDescription(postDescription: String) { self.postDescription = postDescription }
    
    func assignFinalUrl(finalUrl: URL) {
        self.documentURL = finalUrl
        // Reset any previously stored media data
        self.selectedMediaData = nil
        self.selectedMediaMimeType = nil
        self.selectedMediaFileName = nil
    }
    
    // MARK: - Helper Methods
    
    private func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        // Common MIME types mapping
        let mimeTypes: [String: String] = [
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "gif": "image/gif",
            "heic": "image/heic",
            "mp4": "video/mp4",
            "mov": "video/quicktime",
            "m4v": "video/x-m4v",
            "avi": "video/x-msvideo",
            "pdf": "application/pdf",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "mp3": "audio/mpeg",
            "m4a": "audio/mp4",
            "wav": "audio/wav"
        ]
        
        if let mimeType = mimeTypes[pathExtension] {
            return mimeType
        }
        
        // Try UTType for iOS 14+
        if #available(iOS 14.0, *) {
            if let utType = UTType(filenameExtension: pathExtension),
               let mimeType = utType.preferredMIMEType {
                return mimeType
            }
        } else {
            // Fallback for older iOS versions
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
               let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        
        return "application/octet-stream"
    }
    
    private func showLoading(message: String = "Posting...") {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        alert.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])
        
        present(alert, animated: true)
    }
    
    private func hideLoading() {
        dismiss(animated: true)
    }
    
    private func showSuccessAndDismiss() {
        showAlert(title: "Success", message: "Post created") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    // MARK: - Upload Methods
    
    func uploadMultipartWithFiles(token: String,
                                  params: [String: String],
                                  files: [URL],
                                  completion: @escaping (Result<String, Error>) -> Void) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "https://backend.gc2.co.in/api/v1/posts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 300
        
        var body = Data()
        
        // Add parameters
        for (key, value) in params {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        // Add files
        for fileURL in files {
            let fileName = fileURL.lastPathComponent
            let mimeType = getMimeType(for: fileURL)
            
            guard let fileData = try? Data(contentsOf: fileURL) else {
                print("⚠️ Could not read file data for: \(fileName)")
                continue
            }
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"attachments\"; filename=\"\(fileName)\"\r\n")
            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
            body.append(fileData)
            body.appendString("\r\n")
            
            print("✅ Added file: \(fileName) with MIME: \(mimeType) size: \(fileData.count) bytes")
        }
        
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body
        
        // Create and start upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            let result = String(decoding: data, as: UTF8.self)
            print("📩 Server Response:", result)
            
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
        
        task.resume()
    }
    
    func uploadMultipartWithData(token: String,
                                 params: [String: String],
                                 mediaData: [String: Any],
                                 completion: @escaping (Result<String, Error>) -> Void) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "https://backend.gc2.co.in/api/v1/posts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 300
        
        var body = Data()
        
        // Add parameters
        for (key, value) in params {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        // Add media data
        if let fileName = mediaData["fileName"] as? String,
           let mimeType = mediaData["mimeType"] as? String,
           let fileData = mediaData["data"] as? Data {
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"attachments\"; filename=\"\(fileName)\"\r\n")
            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
            body.append(fileData)
            body.appendString("\r\n")
            
            print("✅ Added media data: \(fileName) with MIME: \(mimeType) size: \(fileData.count) bytes")
        }
        
        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body
        
        // Create and start upload task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            let result = String(decoding: data, as: UTF8.self)
            print("📩 Server Response:", result)
            
            DispatchQueue.main.async {
                completion(.success(result))
            }
        }
        
        task.resume()
    }
}

// MARK: - Extensions

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension.lowercased()
        
        let mimeTypes: [String: String] = [
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "gif": "image/gif",
            "heic": "image/heic",
            "mp4": "video/mp4",
            "mov": "video/quicktime",
            "m4v": "video/x-m4v",
            "avi": "video/x-msvideo",
            "pdf": "application/pdf",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "mp3": "audio/mpeg",
            "m4a": "audio/mp4",
            "wav": "audio/wav"
        ]
        
        if let mimeType = mimeTypes[pathExtension] {
            return mimeType
        }
        
        // Try UTType for iOS 14+
        if #available(iOS 14.0, *) {
            if let utType = UTType(filenameExtension: pathExtension),
               let mimeType = utType.preferredMIMEType {
                return mimeType
            }
        } else {
            // Fallback for older iOS versions
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
               let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        
        return "application/octet-stream"
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension OutputStream {
    func writeString(_ string: String) {
        if let data = string.data(using: .utf8) {
            data.withUnsafeBytes {
                write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
            }
        }
    }
}

