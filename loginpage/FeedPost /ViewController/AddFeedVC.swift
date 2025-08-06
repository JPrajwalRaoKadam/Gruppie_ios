//
//  AddFeedVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 16/01/25.
//

import UIKit
import AVFoundation
import PDFKit

class AddFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddFeedInfoCellDelegate {
    
    @IBOutlet weak var addFeedTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addFeedTableView.register(UINib(nibName: "AddFeedInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFeedInfoTableViewCell")
        addFeedTableView.register(UINib(nibName: "ClassTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassTableViewCell")
        
        loadTeams()
        
        submitButton.layer.cornerRadius = 10
        addFeedTableView.delegate = self
        addFeedTableView.dataSource = self
        
        addFeedTableView.estimatedRowHeight = 100
        addFeedTableView.rowHeight = UITableView.automaticDimension
        enableKeyboardDismissOnTap()
    }
    
    // MARK: - Video Compression and Thumbnail Generation
    
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
       
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                self.localVideofilePath.append(compressedURL)
                self.saveImageFromVideo(url: compressedURL, at: 0)
                
            case .failed, .cancelled:
                print("Video compression failed or was cancelled")
            default:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func saveImageFromVideo(url: URL, at time: TimeInterval) {
        let asset = AVURLAsset(url: url)
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uniqueId = NSUUID().uuidString.lowercased()
            let fileName = uniqueId + ".jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let data = UIImage(cgImage: thumbnailImageRef).jpegData(compressionQuality: 0.3),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
                self.localThumbfilePath.append(fileURL)
                print("THUMBNAIL_file saved", fileURL)
            }
        } catch let error {
            print("Error generating thumbnail: \(error)")
        }
    }
    
    func imageFromPdf(url: URL) -> UIImage? {
        let pdfDocument = PDFDocument(url: url)
        let pdfDocumentPage = pdfDocument?.page(at: 0)
        let pdfThumbNailImage = pdfDocumentPage?.thumbnail(of: CGSize(width: 200, height: 350), for: PDFDisplayBox.trimBox)
        
        do {
            var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uniqueId = NSUUID().uuidString.lowercased()
            let fileName = uniqueId + ".jpg"
            documentsDirectory = documentsDirectory.appendingPathComponent("thumbImages")
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let data = pdfThumbNailImage!.jpegData(compressionQuality: 0.4),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
                self.localThumbfilePath.append(fileURL)
                print("PDF thumbnail saved", fileURL)
            }
        } catch let error {
            print("Error saving PDF thumbnail: \(error)")
            return nil
        }
        
        return pdfThumbNailImage
    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        let postName = self.postName
        
        guard let postDescription = self.postDescription else {
            print("Post Name or Post Description is missing")
            return
        }
        
        var fileType: String = ""
        var fileNameArray: [String] = []
        var youTube: URL = URL(fileURLWithPath: "")
        
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
                    // Compress video if needed
                    compressWithSessionStatusFunc(documentURL as NSURL)
                case "pdf":
                    fileType = "pdf"
                    _ = imageFromPdf(url: documentURL)
                case "mp3", "aac", "wav":
                    fileType = "audio"
                default:
                    fileType = "unknown"
                }
            }

            if let base64URL = documentURL.absoluteString.data(using: .utf8)?.base64EncodedString() {
                youTube = documentURL
                fileNameArray.append(base64URL)
            }
        }

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

        // Prepare thumbnail URLs if available
        var thumbnailImageArray: [String] = []
        for thumbURL in localThumbfilePath {
            if let base64Thumb = thumbURL.absoluteString.data(using: .utf8)?.base64EncodedString() {
                thumbnailImageArray.append(base64Thumb)
            }
        }

        let postRequest = AddPostRequest(
            fileName: fileNameArray,
            fileType: fileType,
            selectedArray: selectedArray,
            text: postDescription,
            thumbnailImage: thumbnailImageArray,
            title: postName,
            video: "\(youTube)"
        )

        if let bearerToken = TokenManager.shared.getToken() {
            addPost(token: bearerToken, groupId: self.groupID ?? "", postRequest: postRequest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseData):
                        print("✅ Post Added Successfully")
                        
                        let newPost = Post(
                            updatedAt: Date().iso8601String,
                            type: postRequest.selectedArray.first?.type ?? "",
                            title: postRequest.title,
                            text: postRequest.text,
                            teamName: postRequest.selectedArray.first?.name,
                            teamId: postRequest.selectedArray.first?.id,
                            postViewedCount: "0",
                            likes: 0,
                            isLiked: false,
                            isFavourited: false,
                            id: UUID().uuidString,
                            groupId: self.groupID ?? "",
                            fileType: postRequest.fileType,
                            fileName: postRequest.fileName,
                            createdByImage: nil,
                            createdById: "CURRENT_USER_ID",
                            createdBy: "CURRENT_USER_NAME",
                            createdAt: Date().iso8601String,
                            commentsEnabled: true,
                            comments: 0,
                            canEdit: true,
                            video: postRequest.video,
                            thumbnail: postRequest.thumbnailImage.first,
                            thumbnailImage: postRequest.thumbnailImage.isEmpty ? nil : postRequest.thumbnailImage
                        )
                        
                        self.response?.data.insert(newPost, at: 0)
                        self.navigationController?.popViewController(animated: true)

                    case .failure(let error):
                        print("❌ Error Adding Post: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - AddFeedInfoCellDelegate
    
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
    
    // MARK: - API Calls
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            loadTeams()
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
