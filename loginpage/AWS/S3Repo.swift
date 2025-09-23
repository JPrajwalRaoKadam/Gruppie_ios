import Foundation
import AWSS3
import UIKit

/// Enum for DO Spaces regions
private enum SpaceRegion: String {
    case sfo = "sfo2", ams = "ams3", sgp = "sgp1"
    
    var endpointUrl: String { "https://\(self.rawValue).digitaloceanspaces.com" }
}

/// Enum for file types
enum FileType {
    case image, video, audio, pdf, other(mimeType: String, ext: String)
    
    var contentType: String {
        switch self {
        case .image: return "image/jpeg"
        case .video: return "video/mp4"
        case .audio: return "audio/mpeg"
        case .pdf: return "application/pdf"
        case .other(let mimeType, _): return mimeType
        }
    }
    
    var fileExtension: String {
        switch self {
        case .image: return "jpg"
        case .video: return "mp4"
        case .audio: return "mp3"
        case .pdf: return "pdf"
        case .other(_, let ext): return ext
        }
    }
}

/// Singleton for handling DigitalOcean Spaces uploads
final class SpacesFileRepository {
    static let shared = SpacesFileRepository()
    
    // Hardcoded credentials
    private let accessKey = "NZZPHWUCQLCGPKDSWXHA"
    private let secretKey = "0BOBamyRMoWstLoX96aTg92Q9EMOZg9B7dXY/35BMn0"
    private let bucket = "gruppiemedia"
    private let region: SpaceRegion = .sgp
    private let publicURLBase = "https://gruppiemedia.sgp1.digitaloceanspaces.com"
    
    private var transferUtility: AWSS3TransferUtility?
    private var configurationStatus = false // ✅ RENAMED from isConfigured
    
    /// Optional: Store uploaded URLs locally
    var uploadedURLs: [String] = []
    
    private init() {
        configureAWS()
    }
    
    // MARK: - AWS Configuration
    private func configureAWS() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let endpoint = AWSEndpoint(urlString: region.endpointUrl)
        
        // DigitalOcean Spaces requires us-east-1 region with custom endpoint
        let configuration = AWSServiceConfiguration(
            region: .USEast1,
            endpoint: endpoint,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let transferConfig = AWSS3TransferUtilityConfiguration()
        transferConfig.isAccelerateModeEnabled = false
        transferConfig.bucket = bucket
        transferConfig.retryLimit = 3
        transferConfig.timeoutIntervalForResource = 300
        
        // Register the transfer utility
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: transferConfig,
            forKey: bucket
        )
        
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: bucket)
        configurationStatus = true // ✅ UPDATED to use new property name
        print("✅ DO Spaces TransferUtility configured successfully")
        print("🔑 Using Access Key: \(accessKey.prefix(4))...\(accessKey.suffix(4))")
    }
    
    // MARK: - Check Configuration Status
    func isConfigured() -> Bool {
        if transferUtility == nil {
            // Try to reconfigure if needed
            configureAWS()
        }
        return transferUtility != nil
    }
    
    // MARK: - Generic Upload Method with Better Error Handling
    func upload(fileURL: URL,
                fileType: FileType,
                prefix: String = "gruppie",
                progressHandler: ((Double) -> Void)? = nil,
                completion: @escaping (Result<String, Error>) -> Void) {
        
        // Ensure we're configured before uploading
        if !isConfigured() {
            let error = NSError(domain: "AWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "TransferUtility not configured. Check Digital Ocean Spaces credentials."])
            completion(.failure(error))
            return
        }
        
        guard let transferUtility = transferUtility else {
            let error = NSError(domain: "AWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "TransferUtility not available"])
            completion(.failure(error))
            return
        }
        
        let key = generateKey(prefix: prefix, ext: fileType.fileExtension)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        expression.progressBlock = { _, progress in
            DispatchQueue.main.async { progressHandler?(progress.fractionCompleted) }
        }
        
        transferUtility.uploadFile(fileURL,
                                 key: key,
                                 contentType: fileType.contentType,
                                 expression: expression) { task, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Upload failed for file: \(fileURL.lastPathComponent), Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let publicURL = "\(self.publicURLBase)/\(key)"
                self.uploadedURLs.append(publicURL)
                print("✅ Upload successful: \(publicURL)")
                completion(.success(publicURL))
            }
        }.continueWith { task in
            if let error = task.error {
                DispatchQueue.main.async {
                    print("❌ Upload task error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            return nil
        }
    }
    
    // MARK: - Backward Compatible Functions
    func uploadFileOnDigitalSpace1(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        upload(fileURL: uploadFileURL, fileType: .image) { result in
            switch result {
            case .success(let url): OnCompletation(true, url)
            case .failure(let error):
                print("Upload failed: \(error.localizedDescription)")
                OnCompletation(false, "")
            }
        }
    }
    
    func uploadVideoFileOnDigitalSpace(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        upload(fileURL: uploadFileURL, fileType: .video) { result in
            switch result {
            case .success(let url): OnCompletation(true, url)
            case .failure(let error):
                print("Video upload failed: \(error.localizedDescription)")
                OnCompletation(false, "")
            }
        }
    }
    
    func uploadVideoFileOnDigitalSpaceMp4(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        uploadVideoFileOnDigitalSpace(uploadFileURL: uploadFileURL, OnCompletation: OnCompletation)
    }
    
    func uploadPdfFileOnDigitalSpace(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        upload(fileURL: uploadFileURL, fileType: .pdf) { result in
            switch result {
            case .success(let url): OnCompletation(true, url)
            case .failure(let error):
                print("PDF upload failed: \(error.localizedDescription)")
                OnCompletation(false, "")
            }
        }
    }
    
    func uploadAudioFileOnDigitalSpace(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        upload(fileURL: uploadFileURL, fileType: .audio) { result in
            switch result {
            case .success(let url): OnCompletation(true, url)
            case .failure(let error):
                print("Audio upload failed: \(error.localizedDescription)")
                OnCompletation(false, "")
            }
        }
    }
    
    func uploadFileOnDigitalSpace(uploadFileURL: URL, OnCompletation: @escaping ((Bool, String) -> ())) {
        uploadFileOnDigitalSpace1(uploadFileURL: uploadFileURL, OnCompletation: OnCompletation)
    }
    
    // MARK: - Helper
    private func generateKey(prefix: String, ext: String) -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "")
        let randomSuffix = Int.random(in: 1000...9999)
        return "\(prefix)_\(timestamp)_\(randomSuffix).\(ext)"
    }
    
    // MARK: - Task Management
    func cancelAllUploads() {
        transferUtility?.getUploadTasks().continueWith { task in
            guard let uploads = task.result as? [AWSS3TransferUtilityUploadTask] else { return nil }
            uploads.forEach { $0.cancel() }
            return nil
        }
    }
    
    func getCurrentTaskProgress(OnCompletation: @escaping ((Int) -> ())) {
        if let multiPartUploadTasks = transferUtility?.getUploadTasks().result,
           let uploads = multiPartUploadTasks as? [AWSS3TransferUtilityUploadTask] {
            OnCompletation(uploads.count)
        } else { OnCompletation(0) }
    }
    
    func downloadExampleFile(fileName: String, completion: @escaping ((Data?, Error?) -> Void)) {
        transferUtility?.downloadData(forKey: fileName, expression: nil, completionHandler: { _, _, data, error in
            completion(data, error)
        }).continueWith { _ in nil }
    }
    
    // MARK: - Debug Methods
    func checkConfiguration() {
        if transferUtility == nil {
            print("❌ TransferUtility is nil")
        } else {
            print("✅ TransferUtility is configured and ready")
        }
    }
 
    func uploadBase64(_ base64String: String,
                      fileType: FileType,
                      prefix: String = "gruppie",
                      progressHandler: ((Double) -> Void)? = nil,
                      completion: @escaping (Result<String, Error>) -> Void) {

        // Ensure configured
        if !isConfigured() {
            let error = NSError(domain: "AWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "TransferUtility not configured. Check Digital Ocean Spaces credentials."])
            completion(.failure(error))
            return
        }
        guard let transferUtility = transferUtility else {
            let error = NSError(domain: "AWSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "TransferUtility not available"])
            completion(.failure(error))
            return
        }

        // Decode the base64
        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            let error = NSError(domain: "Base64Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 string"])
            completion(.failure(error))
            return
        }

        let key = generateKey(prefix: prefix, ext: fileType.fileExtension)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.progressBlock = { _, progress in
            DispatchQueue.main.async { progressHandler?(progress.fractionCompleted) }
        }

        transferUtility.uploadData(data,
                                   bucket: bucket,
                                   key: key,
                                   contentType: fileType.contentType,
                                   expression: expression) { task, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ uploadBase64 failed for key: \(key), error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let publicURL = "\(self.publicURLBase)/\(key)"
                self.uploadedURLs.append(publicURL)
                print("✅ uploadBase64 successful: \(publicURL)")
                completion(.success(publicURL))
            }
        }.continueWith { task -> Any? in
            if let err = task.error {
                DispatchQueue.main.async {
                    print("❌ uploadData continueWith error: \(err.localizedDescription)")
                    completion(.failure(err))
                }
            }
            return nil
        }
    }

}
