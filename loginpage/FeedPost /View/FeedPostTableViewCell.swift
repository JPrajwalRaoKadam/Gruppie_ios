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
    func didTapReadMore(text: String, from cell: FeedPostTableViewCell)
}

class FeedPostTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var audioPlayPauseButton: UIButton!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var firstDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: LinkLabel!
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
    
    // MARK: - Properties
    var videoUrl: URL?
    var grpId: String?
    var postId: String?
    var commentAction: (() -> Void)?
    weak var delegate: PostActivityDelegate?
    var post: Post?
    var videoPlayerURL: String?
    var audioPlayer: AVPlayer?
    var isPlayingAudio = false
    var timeObserverToken: Any?
    
    private var isExpanded = false
    private let maxLinesWhenCollapsed = 3
//    private var readMoreButton: UIButton?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.numberOfLines = maxLinesWhenCollapsed
        isExpanded = false
        audioPlayer?.pause()
        audioPlayer = nil
        timeObserverToken = nil
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           updateReadMoreButtonVisibility()
       }
    
    // MARK: - Setup
    private func setupCell() {
        audioView.isHidden = true
        mainImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mainImageView?.addGestureRecognizer(tapGesture)
        
        descriptionLabel.numberOfLines = maxLinesWhenCollapsed
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        // Set up link handling
        descriptionLabel.onLinkTapped = { [weak self] url in
            // Ensure the URL has a scheme (add https if missing)
            var finalURL = url
            if url.scheme == nil {
                finalURL = URL(string: "https://\(url.absoluteString)") ?? url
            }
            
            if UIApplication.shared.canOpenURL(finalURL) {
                UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
            }
        }
    }
    // MARK: - Configuration
    func configure(with post: Post) {
        self.post = post
        self.grpId = post.groupId
        self.postId = post.id
        self.videoPlayerURL = post.fileName?.first
        
        // Set other UI elements
        adminLabel.text = post.createdBy
        noticeLabel.text = post.title
        firstDescriptionLabel.text = post.teamName
        
        if let text = post.text {
            descriptionLabel.text = text
            descriptionLabel.setTextWithLinks(text)
        }
        
        // Configure description label with read more functionality
        descriptionLabel.text = post.text
        descriptionLabel.numberOfLines = maxLinesWhenCollapsed
        descriptionLabel.numberOfLines = isExpanded ? 0 : maxLinesWhenCollapsed
        
        noOfViews.text = post.postViewedCount
        noOfComments.text = "\(post.comments)"
        noOfLikes.text = "\(post.likes)"
        timingLabel.text = convertToFormattedDate(dateString: post.updatedAt)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateReadMoreButtonVisibility()
        }
        
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
        
        // Layout the cell first, then setup read more button
        DispatchQueue.main.async { [weak self] in
            self?.readMoreButton.isHidden = true
        }
    }
    
    // MARK: - Read More Functionality
      
    @IBAction func readMoreButtonTapped(_ sender: UIButton) {
            guard let text = descriptionLabel.text else { return }
            delegate?.didTapReadMore(text: text, from: self)
        }
        
    private func updateReadMoreButtonVisibility() {
        guard let text = descriptionLabel.text, !text.isEmpty else {
            readMoreButton?.isHidden = true
            return
        }
        
        let size = CGSize(width: descriptionLabel.bounds.width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let textHeight = (text as NSString).boundingRect(
            with: size,
            options: options,
            attributes: [.font: descriptionLabel.font ?? UIFont.systemFont(ofSize: 17)],
            context: nil
        ).height
        
        let maxHeight = descriptionLabel.font.lineHeight * CGFloat(maxLinesWhenCollapsed)
        readMoreButton?.isHidden = textHeight <= maxHeight
    }
    
        
        private func descriptionTextRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
            guard let text = descriptionLabel.text else { return .zero }
            
            let size = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            let attributes: [NSAttributedString.Key: Any] = [.font: descriptionLabel.font as Any]
            
            let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let textRect = text.boundingRect(
                with: size,
                options: options,
                attributes: attributes,
                context: nil
            )
            
            let lineHeight = descriptionLabel.font.lineHeight
            let maxHeight = lineHeight * CGFloat(limitedToNumberOfLines)
            
            return CGRect(
                x: bounds.origin.x,
                y: bounds.origin.y,
                width: min(textRect.width, bounds.width),
                height: min(textRect.height, maxHeight)
            )
        }
        
        private func shouldShowReadMore() -> Bool {
            guard let text = descriptionLabel.text, !text.isEmpty else { return false }
            
            let labelSize = CGSize(width: descriptionLabel.bounds.width, height: .greatestFiniteMagnitude)
            let textHeight = (text as NSString)
                .boundingRect(
                    with: labelSize,
                    options: .usesLineFragmentOrigin,
                    attributes: [.font: descriptionLabel.font as Any],
                    context: nil
                )
                .height
            
            let maxHeight = descriptionLabel.font.lineHeight * CGFloat(maxLinesWhenCollapsed)
            return textHeight > maxHeight
        }
        
    
    // MARK: - Helper Methods
    func updateLikeCount(_ count: Int) {
        noOfLikes.text = "\(count)"
    }
    
    func convertToFormattedDate(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd MMMM yyyy, h:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func updateImageViewWithFirstLetter(from label: UILabel, in imageView: UIImageView) {
        guard let text = label.text, let firstLetter = text.first else {
            imageView.image = nil
            return
        }
        
        let letterImage = generateLetterImage(from: String(firstLetter).uppercased())
        imageView.image = letterImage
    }
    
    func generateLetterImage(from letter: String) -> UIImage? {
        let letterLabel = UILabel()
        letterLabel.text = letter
        letterLabel.font = UIFont.boldSystemFont(ofSize: 30)
        letterLabel.textColor = .white
        letterLabel.textAlignment = .center
        letterLabel.backgroundColor = .gray
        letterLabel.layer.cornerRadius = 25
        letterLabel.layer.masksToBounds = true
        letterLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        UIGraphicsBeginImageContextWithOptions(letterLabel.bounds.size, false, 0)
        letterLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - File Loading
    func loadFile(for post: Post) {
        guard let fileType = post.fileType?.lowercased() else {
            mainImageView.image = nil
            return
        }
        
        let fileName = post.fileName?.first ?? ""
        
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
    
    // ... [Keep all your existing methods for image loading, video thumbnail generation, etc.] ...
    
    // MARK: - Audio Player
    func setupAudioPlayer() {
        guard let url = decodeBase64String(videoPlayerURL ?? "") else { return }
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        audioPlayer = AVPlayer(url: url)
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = self.audioPlayer?.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            
            self.audioSlider.value = Float(currentSeconds / totalSeconds)
        }
    }
    
    func setupSlider() {
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.value = 0
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let player = audioPlayer, let duration = player.currentItem?.duration else { return }
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let newTime = CMTime(seconds: totalSeconds * Double(sender.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.seek(to: newTime)
    }
    
    // MARK: - Actions
    @objc func imageTapped() {
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
        delegate?.didTapLikeButton(cell: self)
    }
    
    @IBAction func commentButtonAction(_ sender: Any) {
        commentAction?()
    }
    
    @IBAction func repostButtonAction(_ sender: Any) {
        // Handle repost
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        guard let contentToShare = mainImageView.image else { return }
        let textToShare = "Check out this awesome post!"
        let itemsToShare: [Any] = [textToShare, contentToShare]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .postToFacebook]
        
        if let viewController = self.delegate as? UIViewController {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func playPauseButtonAction(_ sender: Any) {
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: videoPlayerURL ?? "")
    }
    
    @IBAction func audioPlayPauseAction(_ sender: Any) {
        guard let player = audioPlayer else { return }
        
        if isPlayingAudio {
            player.pause()
            audioPlayPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            audioPlayPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPlayingAudio.toggle()
    }
    
    deinit {
        if let token = timeObserverToken {
            audioPlayer?.removeTimeObserver(token)
        }
    }
    
    // MARK: - Image Loading Methods
    private func loadImageForAdminImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let decodedURLString = decodeBase64String(urlString),
              let url = URL(string: decodedURLString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading admin image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let decodedURLString = decodeBase64String(urlString),
              let url = URL(string: decodedURLString) else {
            completion(UIImage(named: "image_placeholder"))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
            }
        }.resume()
    }
    
    // MARK: - Thumbnail Methods
    private func setVideoThumbnail(from videoURLString: String, completion: @escaping (UIImage?) -> Void) {
        guard let decodedURLString = decodeBase64String(videoURLString) else {
            completion(UIImage(named: "video_placeholder"))
            return
        }
        
        if decodedURLString.hasPrefix("file://") {
            let filePath = String(decodedURLString.dropFirst("file://".count))
            let fileURL = URL(fileURLWithPath: filePath)
            generateThumbnailForLocalVideo(url: fileURL, completion: completion)
        } else if let url = URL(string: decodedURLString) {
            generateThumbnailForRemoteVideo(url: url, completion: completion)
        } else {
            completion(UIImage(named: "video_placeholder"))
        }
    }
    
    private func setYouTubeThumbnail(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let videoId = extractYouTubeVideoId(from: urlString) else {
            completion(UIImage(named: "youtube_placeholder"))
            return
        }
        
        let thumbnailURLs = [
            URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/default.jpg")
        ].compactMap { $0 }
        
        tryThumbnailURLs(thumbnailURLs, completion: completion)
    }
    
    private func generateThumbnailForLocalVideo(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            
            let timePoints = [0.1, 1.0, 5.0]
            
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
    
    private func extractYouTubeVideoId(from urlString: String) -> String? {
        let patterns = [
            #"youtu\.be\/([^\?]+)"#,
            #"youtube\.com\/watch\?v=([^&]+)"#,
            #"youtube\.com\/embed\/([^\/]+)"#,
            #"youtube\.com\/v\/([^\/]+)"#
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
    
    // MARK: - PDF Icon
    private func loadPDFIcon() {
        if let thumbnailImage = post?.thumbnailImage?.first,
           let image = loadImageFromBase64(thumbnailImage) {
            mainImageView.image = image
            return
        }
        
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
    
    // MARK: - Base64 Decoding
    private func decodeBase64String(_ base64String: String) -> String? {
        guard !base64String.isEmpty else { return nil }
        
        if base64String.hasPrefix("http://") ||
            base64String.hasPrefix("https://") ||
            base64String.hasPrefix("file://") {
            return base64String
        }
        
        let cleanedString = base64String
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let decodedData = Data(base64Encoded: cleanedString),
              var decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        
        decodedString = decodedString
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if decodedString.hasPrefix("file://") {
            return decodedString
        }
        
        if decodedString.contains("http://") || decodedString.contains("https://") {
            return decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
        return decodedString
    }
}
     
class LinkLabel: UILabel {
    private var links: [String: URL] = [:]
    private var linkRanges: [NSRange] = []
    private var linkAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.systemBlue,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var onLinkTapped: ((URL) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    func setTextWithLinks(_ text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        
        // Improved URL detection
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text,
                                      options: [],
                                      range: NSRange(location: 0, length: text.utf16.count)) ?? []
        
        links.removeAll()
        linkRanges.removeAll()
        
        for match in matches {
            guard match.resultType == .link, let url = match.url else { continue }
            
            let range = match.range
            let urlString = (text as NSString).substring(with: range)
            
            // Store the URL and its range
            links[urlString] = url
            linkRanges.append(range)
            
            // Apply link styling
            attributedString.addAttributes(linkAttributes, range: range)
        }
        
        attributedText = attributedString
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        let touchPoint = gesture.location(in: self)
        
        // Find which character was tapped
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText ?? NSAttributedString())
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        let characterIndex = layoutManager.characterIndex(
            for: touchPoint,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if the tap was on a link
        for (range, urlString) in zip(linkRanges, links.keys) {
            if range.contains(characterIndex), let url = links[urlString] {
                onLinkTapped?(url)
                return
            }
        }
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
