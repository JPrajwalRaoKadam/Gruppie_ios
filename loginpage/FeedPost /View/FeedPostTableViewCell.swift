//
//  FeedPostTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 30/12/24.
//
import UIKit
import AVFoundation
import AVKit

protocol PostActivityDelegate: AnyObject {
    func didTapLikeButton(cell: FeedPostTableViewCell)
    func taptoNaviagteWithURL(cell: FeedPostTableViewCell, videoURL: String)
}


class FeedPostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var audioPlayPauseButton: UIButton!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var firstDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var noOfViews: UILabel!
    @IBOutlet weak var noOfComments: UILabel!
    @IBOutlet weak var noOfLikes: UILabel!
    
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var RepostButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var videoUrl: URL?
    var grpId: String?
    var postId: String?
    var commentAction: (() -> Void)?
    weak var delegate: PostActivityDelegate?
    var post : Post?
    
    var videoPlayerURL: String?
    
    
    var audioPlayer: AVPlayer?
    var isPlayingAudio = false
    var timeObserverToken: Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        audioView.isHidden = true
        mainImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mainImageView?.addGestureRecognizer(tapGesture)
    }
    
    @objc func imageTapped() {
//        if playPauseButton.isHidden && downloadButton.isHidden && audioView.isHidden {
            delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
//        }
       }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        delegate?.didTapLikeButton(cell: self)
    }
    
    @IBAction func commentButtonAction(_ sender: Any) {
        //        delegate?.getComments(cell: self)
        commentAction?()
    }
    
    @IBAction func repostButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
            // Prepare the content you want to share
//            let url = decodeBase64String(videoPlayerURL ?? "")
            
        guard let contentToShre = mainImageView.image else { return }
            let textToShare = "Check out this awesome post!"
            
            // Create an array of items to share
            let itemsToShare: [Any] = [textToShare, contentToShre]
            
            // Initialize the UIActivityViewController with the items
            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            
            // Exclude certain activities (optional)
            activityViewController.excludedActivityTypes = [
                .addToReadingList, .postToFacebook // Example: you can exclude specific options if needed
            ]
            
            // Present the UIActivityViewController
            if let viewController = self.delegate as? UIViewController {
                viewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    
//    @IBAction func shareButtonAction(_ sender: Any) {
//        // Prepare the content you want to share
//        let url = decodeBase64String(videoPlayerURL ?? "")
//        
//        guard let contentToShare = url else { return }
//        let textToShare = "Check out this awesome post!"
//        
//        // Debugging: Check what contentToShare is
//        print("Content to share: \(contentToShare)")
//        
//        // Check if the content is a valid file URL or remote URL
//        if let fileURL = URL(string: contentToShare), fileURL.isFileURL {
//            // Ensure the file exists at the path before proceeding
//            if FileManager.default.fileExists(atPath: fileURL.path) {
//                let itemsToShare: [Any] = [textToShare, fileURL]
//                
//                let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//                activityViewController.excludedActivityTypes = [] // Remove exclusions if any
//                
//                // Present the activity view controller
//                if let viewController = self.delegate as? UIViewController {
//                    viewController.present(activityViewController, animated: true, completion: nil)
//                }
//            } else {
//                print("File does not exist at path: \(fileURL.path)")
//            }
//        } else if let remoteURL = URL(string: contentToShare), remoteURL.scheme == "http" || remoteURL.scheme == "https" {
//            // If it's a remote URL (e.g., YouTube link), share the link
//            let itemsToShare: [Any] = [textToShare, remoteURL]
//            
//            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//            activityViewController.excludedActivityTypes = [] // Remove exclusions if any
//            
//            // Present the activity view controller to share the link
//            if let viewController = self.delegate as? UIViewController {
//                viewController.present(activityViewController, animated: true, completion: nil)
//            }
//        } else {
//            // If it's a base64 encoded string, create a temporary file and share it
//            if let data = Data(base64Encoded: contentToShare), let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                let tempFileURL = tempDirectory.appendingPathComponent("sharedContent").appendingPathExtension("mp4") // Adjust extension based on content type
//                
//                do {
//                    try data.write(to: tempFileURL)
//                    print("Temporary file created at \(tempFileURL.path)")
//                    
//                    let itemsToShare: [Any] = [textToShare, tempFileURL]
//                    
//                    let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//                    activityViewController.excludedActivityTypes = [] // Remove exclusions if any
//                    
//                    // Present the activity view controller
//                    if let viewController = self.delegate as? UIViewController {
//                        viewController.present(activityViewController, animated: true, completion: nil)
//                    }
//                } catch {
//                    print("Error writing temporary file: \(error)")
//                }
//            }
//        }
//    }

    
    @IBAction func playPauseButtonAction(_ sender: Any) {
//        guard let videoURL = videoPlayerURL else { return }
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
//        guard let videoURL = videoPlayerURL else { return }
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
    }
    
    
    @IBAction func audioPlayPauseAction(_ sender: Any) {
        guard let player = audioPlayer else { return }
        setupAudioPlayer()
        setupSlider()
        
        if isPlayingAudio {
            player.pause()
            audioPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            audioPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPlayingAudio.toggle()
    }
    
    private func printDecodedURL(_ base64String: String) {
        guard let decoded = decodeBase64String(base64String) else {
            print("Failed to decode: \(base64String)")
            return
        }
        print("Decoded URL: \(decoded)")
    }

    private func validateURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return false
        }
        return true
    }
    
    func configure(with post: Post) {
        self.post = post
        self.grpId = post.groupId
        self.postId = post.id
        self.videoPlayerURL = post.fileName?.first
        
        // Set other UI elements
        adminLabel.text = post.createdBy
        noticeLabel.text = post.title
        firstDescriptionLabel.text = post.teamName
        descriptionLabel.text = post.text
        noOfViews.text = post.postViewedCount
        noOfComments.text = "\(post.comments)"
        noOfLikes.text = "\(post.likes)"
        timingLabel.text = convertToFormattedDate(dateString: post.updatedAt)
        
        // Set like button state
        likeButton.setImage(
            UIImage(systemName: post.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"),
            for: .normal
        )
        
        // Load admin image
        if let adminImageUrl = post.createdByImage, !adminImageUrl.isEmpty {
            loadImageForAdminImage(from: adminImageUrl) { [weak self] image in
                self?.adminImageView.image = image
            }
        } else {
            updateImageViewWithFirstLetter(from: adminLabel, in: adminImageView)
        }
        
        // Load main content
        loadFile(for: post)
    }
    func updateLikeCount(_ count: Int) {
        noOfLikes.text = "\(count)"
    }
    
    func convertToFormattedDate(dateString: String) -> String? {
        // Define the date formatter
        let dateFormatter = DateFormatter()
        
        // Define the input date format
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        // Convert the string to Date
        if let date = dateFormatter.date(from: dateString) {
            
            // Define the output date format (12-hour format with AM/PM)
            dateFormatter.dateFormat = "dd MMMM yyyy, h:mm a"
            
            // Return the formatted date string
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    // Function to update the imageView with the first letter of the admin's name
    func updateImageViewWithFirstLetter(from label: UILabel, in imageView: UIImageView) {
        guard let text = label.text, let firstLetter = text.first else {
            imageView.image = nil  // If there's no text or it's empty, clear the image
            return
        }
        
        // Create an image with the first letter
        let letterImage = generateLetterImage(from: String(firstLetter).uppercased())
        
        // Set the generated image to the imageView
        imageView.image = letterImage
    }
    
    // Function to generate an image with the given letter
    func generateLetterImage(from letter: String) -> UIImage? {
        // Create a label with the letter
        let letterLabel = UILabel()
        letterLabel.text = letter
        letterLabel.font = UIFont.boldSystemFont(ofSize: 30)  // Adjust size based on your needs
        letterLabel.textColor = .white
        letterLabel.textAlignment = .center
        letterLabel.backgroundColor = .gray  // Adjust the color
        letterLabel.layer.cornerRadius = 25  // Adjust for circle size
        letterLabel.layer.masksToBounds = true
        letterLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)  // Size of the circle
        
        // Render the label into an image
        UIGraphicsBeginImageContextWithOptions(letterLabel.bounds.size, false, 0)
        letterLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    //     Function to load the file based on its type
    func loadFile(for post: Post) {
        guard let fileType = post.fileType?.lowercased() else {
            mainImageView.image = nil
            return
        }
        
        let fileName = post.fileName?.first ?? ""
        
        // Debug print
        print("Loading file of type: \(fileType), name: \(fileName)")
        
        // Reset UI elements
        downloadButton.isHidden = false
        playPauseButton.isHidden = true
        audioView.isHidden = true
        
        switch fileType {
        case "image":
            loadImage(from: fileName) { [weak self] image in
                DispatchQueue.main.async {
                    self?.mainImageView.image = image
                    self?.mainImageView.contentMode = .scaleAspectFill
                }
            }
            
        case "video":
            playPauseButton.isHidden = false
            setVideoThumbnail(from: fileName) { [weak self] thumbnailImage in
                DispatchQueue.main.async {
                    self?.mainImageView.image = thumbnailImage
                    self?.mainImageView.contentMode = .scaleAspectFill
                }
            }
            
        case "youtube":
            playPauseButton.isHidden = false
            if let youtubeURL = post.video {
                setYouTubeThumbnail(from: youtubeURL) { [weak self] thumbnailImage in
                    DispatchQueue.main.async {
                        self?.mainImageView.image = thumbnailImage
                        self?.mainImageView.contentMode = .scaleAspectFill
                    }
                }
            } else {
                mainImageView.image = UIImage(named: "youtube_placeholder")
            }
            
        case "pdf":
            loadPDFIcon()
            
        case "audio":
            audioView.isHidden = false
            downloadButton.isHidden = true
            setupAudioPlayer()
            setupSlider()
            
        default:
            mainImageView.image = UIImage(named: "file_placeholder")
        }
    }
    
    func loadImageForAdminImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let decodedURLString = decodeBase64String(urlString),
              let url = URL(string: decodedURLString) else {
            completion(nil)
            return
        }
        
        // You can use an image loading library like AlamofireImage or SDWebImage for caching and loading images asynchronously
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    // Function to load an image from URL
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        printDecodedURL(urlString) // 👈 DEBUG: Print the decoded URL
          
          guard let decodedURLString = decodeBase64String(urlString) else {
              completion(UIImage(named: "image_placeholder"))
              return
          }
          
          // Add this validation check
          if !validateURL(decodedURLString) { // 👈 DEBUG: Validate URL
              print("Invalid URL: \(decodedURLString)")
          }
        
        guard let decodedURLString = decodeBase64String(urlString) else {
            completion(UIImage(named: "image_placeholder"))
            return
        }
        
        print("Decoded image URL: \(decodedURLString)")
        
        guard let url = URL(string: decodedURLString) else {
            print("Invalid image URL")
            completion(UIImage(named: "image_placeholder"))
            return
        }
        
        // Use URLSession with a timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        let session = URLSession(configuration: configuration)
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("Invalid response or no data")
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Failed to create image from data")
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
            }
        }.resume()
    }
    

    func setVideoThumbnail(from videoURLString: String, completion: @escaping (UIImage?) -> Void) {
        
        printDecodedURL(videoURLString) // 👈 DEBUG: Print the decoded URL
           
           guard let decodedURLString = decodeBase64String(videoURLString) else {
               completion(UIImage(named: "video_placeholder"))
               return
           }
           
           // Add this validation check
           if !validateURL(decodedURLString) { // 👈 DEBUG: Validate URL
               print("Invalid video URL: \(decodedURLString)")
           }
           
        // First decode the base64 URL if needed
        guard let decodedURLString = decodeBase64String(videoURLString) else {
            completion(UIImage(named: "video_placeholder"))
            return
        }
        
        print("Decoded URL string: \(decodedURLString)")
        
        // Check if this is a file URL
        if decodedURLString.hasPrefix("file://") {
            // Handle local file URL
            let filePath = String(decodedURLString.dropFirst("file://".count))
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Verify file exists
            if FileManager.default.fileExists(atPath: filePath) {
                generateThumbnailForLocalVideo(url: fileURL, completion: completion)
            } else {
                print("File does not exist at path: \(filePath)")
                completion(UIImage(named: "video_placeholder"))
            }
        } else if let url = URL(string: decodedURLString) {
            // Handle remote URL
            if url.absoluteString.contains("youtube.com") || url.absoluteString.contains("youtu.be") {
                setYouTubeThumbnail(from: decodedURLString, completion: completion)
            } else {
                generateThumbnailForRemoteVideo(url: url, completion: completion)
            }
        } else {
            completion(UIImage(named: "video_placeholder"))
        }
    }

    private func generateThumbnailForLocalVideo(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            
            // Try multiple time points if first fails
            let timePoints = [0.1, 1.0, 5.0] // seconds - start with 0.1s
            
            for time in timePoints {
                do {
                    let cmTime = CMTime(seconds: time, preferredTimescale: 600)
                    let cgImage = try assetImageGenerator.copyCGImage(at: cmTime, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        completion(thumbnail)
                    }
                    return
                } catch {
                    print("Error generating thumbnail at \(time) seconds: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion(UIImage(named: "video_placeholder"))
            }
        }
    }

    private func generateThumbnailForRemoteVideo(url: URL, completion: @escaping (UIImage?) -> Void) {
        // First download a small portion of the video to generate thumbnail
        let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { tempLocation, response, error in
            guard let tempLocation = tempLocation else {
                DispatchQueue.main.async {
                    completion(UIImage(named: "video_placeholder"))
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempLocation, to: tempFileURL)
                self.generateThumbnailForLocalVideo(url: tempFileURL) { image in
                    try? FileManager.default.removeItem(at: tempFileURL)
                    completion(image)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(UIImage(named: "video_placeholder"))
                }
            }
        }
        downloadTask.resume()
    }
    
    func setYouTubeThumbnail(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let videoId = extractYouTubeVideoId(from: urlString) else {
            completion(UIImage(named: "youtube_placeholder"))
            return
        }
        
        // Try different quality levels in order
        let thumbnailURLs = [
            URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/default.jpg")
        ].compactMap { $0 }
        
        tryThumbnailURLs(thumbnailURLs, completion: completion)
    }

    private func extractYouTubeVideoId(from urlString: String) -> String? {
        let patterns = [
            #"youtu\.be\/([^\?]+)"#,                      // youtu.be/<id>
            #"youtube\.com\/watch\?v=([^&]+)"#,            // youtube.com/watch?v=<id>
            #"youtube\.com\/embed\/([^\/]+)"#,            // youtube.com/embed/<id>
            #"youtube\.com\/v\/([^\/]+)"#                 // youtube.com/v/<id>
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)),
               let range = Range(match.range(at: 1), in: urlString) {
                return String(urlString[range])
            }
        }
        
        return nil
    }

    private func tryThumbnailURLs(_ urls: [URL], index: Int = 0, completion: @escaping (UIImage?) -> Void) {
        guard index < urls.count else {
            completion(UIImage(named: "youtube_placeholder"))
            return
        }
        
        URLSession.shared.dataTask(with: urls[index]) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                self.tryThumbnailURLs(urls, index: index + 1, completion: completion)
            }
        }.resume()
    }
    
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        print("Fetching image from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(nil)
                return
            }
            
            print("Image fetch status code: \(httpResponse.statusCode)")
            
            if let data = data {
                print("Received image data of size: \(data.count) bytes")
                let image = UIImage(data: data)
                completion(image)
            } else {
                print("No image data received")
                completion(nil)
            }
        }.resume()
    }
    
    private func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true // Adjust for video orientation
            let time = CMTime(seconds: 1, preferredTimescale: 600) // Capture at 1-second mark
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(image)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    
    // Decode base64 encoded URL string
    func decodeBase64String(_ base64String: String) -> String? {
        guard !base64String.isEmpty else { return nil }
        
        // Check if it's already a URL (not base64 encoded)
        if base64String.hasPrefix("http://") ||
           base64String.hasPrefix("https://") ||
           base64String.hasPrefix("file://") {
            return base64String
        }
        
        // Clean the string by removing newlines and whitespace
        let cleanedString = base64String
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try decoding as base64
        guard let decodedData = Data(base64Encoded: cleanedString),
              var decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        
        // Clean the decoded string as well
        decodedString = decodedString
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle potential URL encoding issues
        if decodedString.hasPrefix("file://") {
            return decodedString
        }
        
        // If it looks like a URL but isn't properly encoded
        if decodedString.contains("http://") || decodedString.contains("https://") {
            return decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
        return decodedString
    }
    
    // Function to load PDF icon
    func loadPDFIcon() {
        // First try to load thumbnail if available
        if let thumbnailImage = post?.thumbnailImage?.first,
           let image = loadImageFromBase64(thumbnailImage) {
            mainImageView.image = image
            return
        }
        
        // Fallback to default PDF icon
        mainImageView.image = UIImage(named: "pdf_icon")
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.backgroundColor = .lightGray
    }

    private func loadImageFromBase64(_ base64String: String) -> UIImage? {
        guard let decodedData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: decodedData)
    }
    
    func setupAudioPlayer() {
        
        guard let url = decodeBase64String(videoPlayerURL ?? "") else {return}
        print("kkkkvvvccvcvv\(videoPlayerURL)")
        guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" ) else {
            print("Invalid URL")
            return
        }
        
        audioPlayer = AVPlayer(url: url)
        
        // Observe the player's progress
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = self.audioPlayer?.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            
            // Update slider and UI
            self.audioSlider.value = Float(currentSeconds / totalSeconds)
        }
    }
    
    // Set up the slider
    func setupSlider() {
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.value = 0
        
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    // Slider value changed action
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let player = audioPlayer, let duration = player.currentItem?.duration else { return }
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let newTime = CMTime(seconds: totalSeconds * Double(sender.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.seek(to: newTime)
    }
    
    deinit {
        if let token = timeObserverToken {
            audioPlayer?.removeTimeObserver(token)
        }
    }
}

