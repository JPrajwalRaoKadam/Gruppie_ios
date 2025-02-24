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
    
    func configure(with post: Post) {
        loadFile(for: post)
        adminLabel.text = post.createdBy
        // Set adminImageView to show the first letter of the admin's name
        if post.createdByImage == "" {
            updateImageViewWithFirstLetter(from: adminLabel, in: adminImageView)
        } else {
            loadImageForAdminImage(from: post.createdByImage ?? "") { image in
                self.adminImageView.image = image
            }
            
            noticeLabel.text = post.title
            firstDescriptionLabel.text = post.teamName
            descriptionLabel.text = post.text
            noOfViews.text = post.postViewedCount
            noOfComments.text = "\(post.comments)"
            noOfLikes.text = "\(post.likes)"
            timingLabel.text = convertToFormattedDate(dateString: post.updatedAt)
            grpId = post.groupId
            postId = post.id
            if post.isLiked {
                likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            } else {
                likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
            // Load image, video, or PDF based on file type
        }
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
        guard let fileType = post.fileType else {
            mainImageView.image = nil
            return
        }
        
        let fileName = post.fileName?.first
        
        switch fileType {
        case "image":
            downloadButton.isHidden = false
            playPauseButton.isHidden = true
            loadImage(from: fileName ?? "new_banner")
            
        case "video":
            playPauseButton.isHidden = true
            downloadButton.isHidden = false
            setVideoThumbnail(from: fileName ?? "new_banner") { thumbnailImage in
                DispatchQueue.main.async {
                    if let image = thumbnailImage {
                        self.mainImageView.image = image
                    } else {
                        print("Failed to fetch thumbnail")
                    }
                }
            }
        case "youtube":
            downloadButton.isHidden = false
            playPauseButton.isHidden = true
            setVideoThumbnail(from: fileName ?? "new_banner") { thumbnailImage in
                DispatchQueue.main.async {
                    if let image = thumbnailImage {
                        self.mainImageView.image = image
                    } else {
                        print("Failed to fetch thumbnail")
                    }
                }
            }
        case "pdf":
            loadPDFIcon()
            downloadButton.isHidden = false
            playPauseButton.isHidden = true
        case "audio":
            audioView.isHidden = false
            setupAudioPlayer()
            setupSlider()
            downloadButton.isHidden = true
            playPauseButton.isHidden = true
        default:
            mainImageView.image = nil
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
    func loadImage(from urlString: String) {
        guard let decodedURLString = decodeBase64String(urlString),
              let url = URL(string: decodedURLString) else {
            DispatchQueue.main.async {
                self.mainImageView.image = nil
            }
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.mainImageView.image = nil
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.mainImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.mainImageView.image = nil
                }
            }
        }
        task.resume()
    }
    
    func setVideoThumbnail(from videoURLString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if it's a YouTube video
        if let videoId = extractYouTubeVideoId(from: videoURLString) {
            // Generate YouTube thumbnail URL
            let thumbnailURLString = "https://img.youtube.com/vi/\(videoId)/0.jpg"
            if let thumbnailURL = URL(string: thumbnailURLString) {
                // Fetch the YouTube thumbnail image
                fetchImage(from: thumbnailURL, completion: completion)
            } else {
                print("Error: Invalid YouTube thumbnail URL")
                completion(nil)
            }
        } else if let videoURL = URL(string: videoURLString) {
            // Generate thumbnail for local/remote video
            generateThumbnail(from: videoURL, completion: completion)
        } else {
            print("Error: Invalid video URL")
            completion(nil)
        }
    }
    
    private func extractYouTubeVideoId(from urlString: String) -> String? {
        let pattern = "v=([a-zA-Z0-9_-]{11})" // YouTube video ID regex pattern
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)),
           let range = Range(match.range(at: 1), in: urlString) {
            return String(urlString[range])
        }
        return nil
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
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
        guard let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
    
    
    // Function to load PDF icon
    func loadPDFIcon() {
        // Set an image or icon for PDF
        mainImageView.image = UIImage(named: "defaultpdf")  // Ensure you have a PDF icon in your assets
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

