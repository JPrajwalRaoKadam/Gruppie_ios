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
    @IBOutlet weak var cardView: UIView!
    
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
    private var thumbnailCache = NSCache<NSString, UIImage>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        backgroundColor = .clear
        contentView.backgroundColor = .white
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.numberOfLines = maxLinesWhenCollapsed
        isExpanded = false
        audioPlayer?.pause()
        audioPlayer = nil
        timeObserverToken = nil
        mainImageView.image = nil
        playPauseButton.isHidden = true
        audioView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let verticalSpacing: CGFloat = 8
        let horizontalSpacing: CGFloat = 1

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(
            top: verticalSpacing / 2,
            left: horizontalSpacing,
            bottom: verticalSpacing / 2,
            right: horizontalSpacing
        ))

        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 3
        layer.masksToBounds = false
        backgroundColor = .clear
        
        updateReadMoreButtonVisibility()
    }
    
    // MARK: - Setup
    private func setupCell() {
        audioView.isHidden = true
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
        
//        cardView.layer.borderColor = UIColor.black.cgColor
//        cardView.layer.borderWidth = 0.5
        
        mainImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        mainImageView.addGestureRecognizer(tapGesture)
        
        descriptionLabel.numberOfLines = maxLinesWhenCollapsed
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        descriptionLabel.onLinkTapped = { [weak self] url in
            var finalURL = url
            if url.scheme == nil {
                finalURL = URL(string: "https://\(url.absoluteString)") ?? url
            }
            
            if UIApplication.shared.canOpenURL(finalURL) {
                UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
            }
        }
        
        // Configure image view for better rendering
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 8
    }
    
    // MARK: - Configuration
    func configure(with post: Post) {
        self.post = post
        self.grpId = post.groupId
        self.postId = post.id
        self.videoPlayerURL = post.fileName?.first
        
        // Reset UI elements
        audioView.isHidden = true
        playPauseButton.isHidden = true
        downloadButton.isHidden = false
        
        // Set text content
        adminLabel.text = post.createdBy
        noticeLabel.text = post.title
        firstDescriptionLabel.text = post.teamName
        
        if let text = post.text {
            descriptionLabel.text = text
            descriptionLabel.setTextWithLinks(text)
        }
        
        descriptionLabel.numberOfLines = isExpanded ? 0 : maxLinesWhenCollapsed
        
        // Set counts and timing
        noOfViews.text = post.postViewedCount
        noOfComments.text = "\(post.comments)"
        noOfLikes.text = "\(post.likes)"
        timingLabel.text = convertToFormattedDate(dateString: post.updatedAt)
        
        // Set like button state
        likeButton.setImage(
            UIImage(systemName: post.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"),
            for: .normal
        )
        
        // Configure admin image
        configureAdminImage(with: post.createdByImage)
        
        // Load media content
        loadFile(for: post)
    }
    
    private func configureAdminImage(with imageUrl: String?) {
        if let adminImageUrl = imageUrl, !adminImageUrl.isEmpty {
            loadImageForAdminImage(from: adminImageUrl) { [weak self] image in
                self?.adminImageView.image = image
                self?.adminImageView.contentMode = .scaleAspectFill
                self?.adminImageView.layer.cornerRadius = self?.adminImageView.bounds.width ?? 0 / 2
                self?.adminImageView.clipsToBounds = true
            }
        } else {
            updateImageViewWithFirstLetter(from: adminLabel, in: adminImageView)
        }
    }
    
    // MARK: - Read More Functionality
    @IBAction func readMoreButtonTapped(_ sender: UIButton) {
        guard let text = descriptionLabel.text else { return }
        delegate?.didTapReadMore(text: text, from: self)
    }
    
    private func updateReadMoreButtonVisibility() {
        guard let text = descriptionLabel.text, !text.isEmpty else {
            readMoreButton.isHidden = true
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
        readMoreButton.isHidden = textHeight <= maxHeight
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
        imageView.contentMode = .center
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
    }
    
    func generateLetterImage(from letter: String) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        
        return renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 50, height: 50)
            ctx.cgContext.setFillColor(UIColor.systemGray5.cgColor)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.systemBlue
            ]
            
            let string = letter
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            let stringRect = CGRect(x: 0, y: 10, width: 50, height: 30)
            attributedString.draw(in: stringRect)
        }
    }
    
    // MARK: - File Loading
    func loadFile(for post: Post) {
        guard let fileType = post.fileType?.lowercased() else {
            mainImageView.image = UIImage(named: "file_placeholder")
            return
        }

        // Reset UI elements
        downloadButton.isHidden = false
        playPauseButton.isHidden = true
        audioView.isHidden = true
        mainImageView.image = nil

        // Handle case where there are no files
        guard let firstFileName = post.fileName?.first else {
            mainImageView.image = UIImage(named: "file_placeholder")
            return
        }

        // Decode the base64 URL
        guard let decodedURLString = decodeBase64String(firstFileName) else {
            mainImageView.image = UIImage(named: "file_placeholder")
            return
        }

        switch fileType {
        case "image":
            loadImage(from: decodedURLString) { [weak self] image in
                self?.mainImageView.image = image
                self?.mainImageView.contentMode = .scaleAspectFill
            }

        case "video":
            playPauseButton.isHidden = false
            loadVideoThumbnail(from: decodedURLString) { [weak self] thumbnailImage in
                DispatchQueue.main.async {
                    self?.mainImageView.image = thumbnailImage ?? UIImage(named: "video_placeholder")
                    self?.mainImageView.contentMode = .scaleAspectFill
                }
            }

        case "pdf":
            loadPDFThumbnail(for: post)

        case "audio":
            audioView.isHidden = false
            downloadButton.isHidden = true
            setupAudioPlayer(with: decodedURLString)
            setupSlider()

        default:
            mainImageView.image = UIImage(named: "file_placeholder")
        }
    }
    
    // MARK: - Image Loading
    private func loadImageForAdminImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Check cache first
        if let cachedImage = thumbnailCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading admin image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.thumbnailCache.setObject(image, forKey: urlString as NSString)
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
        guard let url = URL(string: urlString) else {
            completion(UIImage(named: "image_placeholder"))
            return
        }
        
        // Check cache first
        if let cachedImage = thumbnailCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(UIImage(named: "image_placeholder"))
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.thumbnailCache.setObject(image, forKey: urlString as NSString)
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
    
    // MARK: - Video Thumbnail
    private func loadVideoThumbnail(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = thumbnailCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        if urlString.isYouTubeURL {
            loadYouTubeThumbnail(from: urlString, completion: completion)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(UIImage(named: "video_placeholder"))
            return
        }
        
        if url.isFileURL {
            generateLocalVideoThumbnail(url: url, completion: completion)
        } else {
            generateRemoteVideoThumbnail(url: url, completion: completion)
        }
    }
    
    private func loadYouTubeThumbnail(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let videoId = urlString.youtubeVideoID else {
            completion(UIImage(named: "youtube_placeholder"))
            return
        }
        
        let thumbnailURLs = [
            URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg"),
            URL(string: "https://img.youtube.com/vi/\(videoId)/default.jpg")
        ].compactMap { $0 }
        
        tryThumbnailURLs(thumbnailURLs, for: urlString, completion: completion)
    }
    
    private func generateLocalVideoThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.maximumSize = CGSize(width: 400, height: 400)
            
            let timePoints = [CMTime(seconds: 1.0, preferredTimescale: 600)]
            
            for time in timePoints {
                do {
                    let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        completion(thumbnail)
                    }
                    return
                } catch {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion(UIImage(named: "video_placeholder"))
            }
        }
    }
    
    private func generateRemoteVideoThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.maximumSize = CGSize(width: 400, height: 400)
            
            let timePoints = [CMTime(seconds: 1.0, preferredTimescale: 600)]
            
            for time in timePoints {
                do {
                    let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        completion(thumbnail)
                    }
                    return
                } catch {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion(UIImage(named: "video_placeholder"))
            }
        }
    }
    
    private func tryThumbnailURLs(_ urls: [URL], for cacheKey: String, index: Int = 0, completion: @escaping (UIImage?) -> Void) {
        guard index < urls.count else {
            completion(UIImage(named: "youtube_placeholder"))
            return
        }
        
        URLSession.shared.dataTask(with: urls[index]) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                self.thumbnailCache.setObject(image, forKey: cacheKey as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                self.tryThumbnailURLs(urls, for: cacheKey, index: index + 1, completion: completion)
            }
        }.resume()
    }
    
    // MARK: - PDF Thumbnail
    private func loadPDFThumbnail(for post: Post) {
        if let thumbnailImage = post.thumbnailImage?.first,
           let image = loadImageFromBase64(thumbnailImage) {
            mainImageView.image = image
            mainImageView.contentMode = .scaleAspectFit
            return
        }
        
        mainImageView.image = UIImage(named: "defaultpdf")
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.backgroundColor = .systemGray6
    }
    
    private func loadImageFromBase64(_ base64String: String) -> UIImage? {
        guard let decodedData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: decodedData)
    }
    
    // MARK: - Audio Player
    private func setupAudioPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        audioPlayer = AVPlayer(url: url)
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = self.audioPlayer?.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            
            if totalSeconds.isFinite && totalSeconds > 0 {
                self.audioSlider.value = Float(currentSeconds / totalSeconds)
            }
        }
    }
    
    private func setupSlider() {
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.value = 0
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
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
        guard let videoURLString = videoPlayerURL,
              let decodedURLString = decodeBase64String(videoURLString) else {
            return
        }
        
        delegate?.taptoNaviagteWithURL(cell: self, videoURL: decodedURLString)
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
    
    // MARK: - Base64 Decoding
    private func decodeBase64String(_ base64String: String) -> String? {
        guard !base64String.isEmpty else { return nil }
        
        let cleanedString = base64String
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's already a URL (not base64), return it
        if cleanedString.hasPrefix("http://") ||
           cleanedString.hasPrefix("https://") ||
           cleanedString.hasPrefix("file://") {
            return cleanedString
        }
        
        // Decode base64
        guard let decodedData = Data(base64Encoded: cleanedString),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        
        return decodedString
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
//
//// MARK: - LinkLabel
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
        let fontToUse = self.font ?? UIFont.systemFont(ofSize: 16)
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: fontToUse])

        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []

        links.removeAll()
        linkRanges.removeAll()

        for match in matches {
            guard match.resultType == .link, let url = match.url else { continue }

            let range = match.range
            let urlString = (text as NSString).substring(with: range)

            links[urlString] = url
            linkRanges.append(range)

            attributedString.addAttributes(linkAttributes, range: range)
        }

        self.attributedText = attributedString
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = self.attributedText else { return }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode

        let location = gesture.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textOffset = CGPoint(
            x: (bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationInTextContainer = CGPoint(x: location.x - textOffset.x, y: location.y - textOffset.y)

        let index = layoutManager.characterIndex(
            for: locationInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        for (range, urlString) in zip(linkRanges, links.keys) {
            if range.contains(index), let url = links[urlString] {
                onLinkTapped?(url)
                return
            }
        }
    }
}
//
//// MARK: - URL Extensions
extension String {
    var isYouTubeURL: Bool {
        return contains("youtube.com") || contains("youtu.be")
    }
    
    var youtubeVideoID: String? {
        let patterns = [
            #"youtu\.be\/([^\?]+)"#,
            #"youtube\.com\/watch\?v=([^&]+)"#,
            #"youtube\.com\/embed\/([^\/]+)"#,
            #"youtube\.com\/v\/([^\/]+)"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)),
               let range = Range(match.range(at: 1), in: self) {
                return String(self[range])
            }
        }
        
        return nil
    }
}
//
extension URL {
    var isFileURL: Bool {
        return scheme == "file"
    }
}
//


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
