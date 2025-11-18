//
//  VideoPlayerVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 08/01/25.
//
import UIKit
import AVKit
import AVFoundation
import youtube_ios_player_helper
import PDFKit

class VideoPlayerVC: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var videoPlayerURL: String?
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var yTplayerView: YTPlayerView!
    private var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.layer.cornerRadius = 10
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        playPauseButton.isHidden = true
        playPauseButton.addTarget(self, action: #selector(playPauseAction(_:)), for: .touchUpInside)
        
        guard let inputString = videoPlayerURL else {
            print("No URL string provided.")
            showError(message: "No media URL provided")
            return
        }

        print("🔍 Input string: \(inputString)")
        
        // Step 1: Check if it's already a valid URL
        if isValidURL(inputString) {
            print("✅ Input is already a valid URL")
            processMediaURL(inputString)
            return
        }
        
        // Step 2: If not a valid URL, try to decode as Base64
        print("🔄 Input doesn't appear to be a URL, trying Base64 decode...")
        let cleanedBase64 = inputString.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespaces)
        
        guard let decodedData = Data(base64Encoded: cleanedBase64),
              let decodedURLString = String(data: decodedData, encoding: .utf8) else {
            print("❌ Base64 decoding failed.")
            showError(message: "Invalid media format or URL")
            return
        }
        
        print("✅ Decoded from Base64: \(decodedURLString)")
        processMediaURL(decodedURLString)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
//        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
//        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
    }
    
    // MARK: - URL Validation
    private func isValidURL(_ string: String) -> Bool {
        let urlPatterns = [
            "^(https?|ftp|file)://",
            "^www\\.",
            ".*\\.(mp4|mov|avi|m3u8|pdf|jpg|jpeg|png|webp|gif|bmp|tiff)$",
            "youtube\\.com/watch",
            "youtu\\.be/",
            "youtube\\.com/embed/"
        ]
        
        let lowercasedString = string.lowercased()
        
        for pattern in urlPatterns {
            if lowercasedString.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        if let url = URL(string: string) {
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
    
    // MARK: - Media Processing
    private func processMediaURL(_ urlString: String) {
        print("🎯 Processing media URL: \(urlString)")
        
        let cleanedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // YouTube detection
        if let videoId = extractVideoId(from: cleanedURLString) {
            print("📺 Detected YouTube video")
            setupYouTubePlayer()
            loadYouTubeVideo(videoId: videoId)
            return
        }

        // PDF detection
        if cleanedURLString.lowercased().hasSuffix(".pdf") {
            print("📄 Detected PDF document")
            displayPDFInUIView(from: cleanedURLString, on: playerView)
            return
        }

        // Image detection
        let imageExtensions = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".tiff"]
        if imageExtensions.contains(where: cleanedURLString.lowercased().hasSuffix) {
            print("🖼️ Detected image")
            displayImage(from: cleanedURLString, in: playerView)
            return
        }

        // Video (default)
        print("🎬 Assuming video content")
        playVideo(from: cleanedURLString, on: playerView)
    }
    
    // MARK: - YouTube Methods
    private func extractVideoId(from url: String) -> String? {
        let patterns = [
            "v=([a-zA-Z0-9_-]{11})",
            "youtu\\.be/([a-zA-Z0-9_-]{11})",
            "embed/([a-zA-Z0-9_-]{11})"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               match.range(at: 1).location != NSNotFound,
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }
    
    private func setupYouTubePlayer() {
        yTplayerView = YTPlayerView()
        yTplayerView.delegate = self
        yTplayerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(yTplayerView, belowSubview: playPauseButton)
        
        NSLayoutConstraint.activate([
            yTplayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            yTplayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            yTplayerView.topAnchor.constraint(equalTo: view.topAnchor),
            yTplayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addBackButton()
    }
    
    private func loadYouTubeVideo(videoId: String) {
        yTplayerView.load(withVideoId: videoId, playerVars: [
            "playsinline": 1,
            "autoplay": 1,
            "controls": 1,
            "rel": 0
        ])
    }
    
    // MARK: - Video Methods
    private func playVideo(from urlString: String, on view: UIView) {
        playPauseButton.isHidden = false
        
        let decodedURLString = urlString.removingPercentEncoding ?? urlString
        let url: URL?
        
        if decodedURLString.starts(with: "file://") {
            let localPath = String(decodedURLString.dropFirst("file://".count))
            url = URL(fileURLWithPath: localPath)
        } else {
            url = URL(string: decodedURLString)
        }
        
        guard let validURL = url else {
            print("Error: Invalid video URL → \(urlString)")
            showError(message: "Invalid video URL")
            return
        }
        
        print("🎬 Final video URL to play:", validURL)
        
        // Remove existing layers and subviews
        cleanupPlayerView()
        
        // Setup player
        player = AVPlayer(url: validURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer!)
        
        // Add observer for player state
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
        
        // Add notification for playback end
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(playerDidFinishPlaying),
                                             name: .AVPlayerItemDidPlayToEndTime,
                                             object: player?.currentItem)
        
        player?.play()
        isPlaying = true
//        updatePlayPauseButton()
    }
    
    private func cleanupPlayerView() {
        playerView.subviews.forEach { $0.removeFromSuperview() }
        playerView.layer.sublayers?.removeAll(where: { $0 is AVPlayerLayer })
        
        player?.pause()
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        player = nil
        playerLayer = nil
    }
    
    // MARK: - Image Methods
    private func displayImage(from urlString: String, in view: UIView) {
        playPauseButton.isHidden = true
        cleanupPlayerView()
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(named: "placeholder_image")
            return
        }
        
        // Load image asynchronously
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder_image")
                }
            }
        }
    }
    
    // MARK: - PDF Methods
    private func displayPDFInUIView(from urlString: String, on containerView: UIView) {
        playPauseButton.isHidden = true
        cleanupPlayerView()
        
        guard let pdfURL = URL(string: urlString) else {
            print("Error: Invalid PDF URL")
            showError(message: "Invalid PDF URL")
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: pdfURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching PDF: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showError(message: "Failed to load PDF")
                }
                return
            }
            
            guard let data = data else {
                print("Error: No PDF data received")
                DispatchQueue.main.async {
                    self.showError(message: "No PDF data received")
                }
                return
            }
            
            DispatchQueue.main.async {
                if let pdfDocument = PDFDocument(data: data) {
                    let pdfView = PDFView(frame: containerView.bounds)
                    pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    pdfView.document = pdfDocument
                    pdfView.autoScales = true
                    pdfView.displayMode = .singlePageContinuous
                    pdfView.displayDirection = .vertical
                    
                    containerView.addSubview(pdfView)
                } else {
                    self.showError(message: "Failed to create PDF document")
                }
            }
        }.resume()
    }
    
    // MARK: - UI Methods
    private func addBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backButton.layer.cornerRadius = 8
        backButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
    }
    
//    private func updatePlayPauseButton() {
//        let imageName = isPlaying ? "pause.fill" : "play.fill"
//        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
//        playPauseButton.tintColor = .white
//        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        playPauseButton.layer.cornerRadius = 25
//    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Observers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if let status = player?.timeControlStatus {
                isPlaying = (status == .playing)
//                updatePlayPauseButton()
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
//        updatePlayPauseButton()
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
//        updatePlayPauseButton()
    }
}

// MARK: - YTPlayerViewDelegate
extension VideoPlayerVC: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("YouTube player is ready")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print("YouTube player state changed to: \(state.rawValue)")
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        print("YouTube player error: \(error)")
        showError(message: "YouTube player error: \(error)")
    }
}
