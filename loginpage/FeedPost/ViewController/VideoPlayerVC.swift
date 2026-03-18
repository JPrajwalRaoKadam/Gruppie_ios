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
    
    // MARK: - IBOutlet
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Properties
    var mediaURL: String?
    var fileType: String?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var youtubePlayer: YTPlayerView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        handleMedia()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerView.bounds
        youtubePlayer?.frame = playerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    // MARK: - UI
    private func setupUI() {
        
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true
        
        playerView.layer.cornerRadius = 12
        playerView.clipsToBounds = true
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Main Handler
    private func handleMedia() {
        
        guard let urlString = mediaURL?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty else {
            
            showError("Invalid media URL")
            return
        }
        
        print("🎯 Media URL:", urlString)
        
        // YouTube
        if let videoId = extractYouTubeID(from: urlString) {
            playYouTube(videoId)
            return
        }
        
        // PDF
        if urlString.lowercased().hasSuffix(".pdf") {
            showPDF(urlString)
            return
        }
        
        // Image
        if isImage(urlString) {
            showImage(urlString)
            return
        }
        
        // Video (Default)
        playVideo(urlString)
    }
    
    // MARK: - Video
    private func playVideo(_ urlString: String) {
        
        cleanup()
        
        let finalURL: URL?
        
        if urlString.hasPrefix("file://") {
            
            let path = urlString.replacingOccurrences(of: "file://", with: "")
            finalURL = URL(fileURLWithPath: path)
            
        } else {
            finalURL = URL(string: urlString)
        }
        
        guard let url = finalURL else {
            showError("Invalid video URL")
            return
        }
        
        print("🎬 Playing:", url)
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer?.frame = playerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        playerView.layer.addSublayer(playerLayer!)
        
        player?.play()
    }
    
    // MARK: - YouTube
    private func playYouTube(_ videoId: String) {
        
        cleanup()
        
        let playerView = YTPlayerView()
        playerView.delegate = self
        
        playerView.frame = playerView.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        playerView.addSubview(playerView)
        
        youtubePlayer = playerView
        
        playerView.load(
            withVideoId: videoId,
            playerVars: [
                "playsinline": 1,
                "autoplay": 1,
                "controls": 1
            ]
        )
    }
    
    private func extractYouTubeID(from url: String) -> String? {
        
        let patterns = [
            "v=([a-zA-Z0-9_-]{11})",
            "youtu\\.be/([a-zA-Z0-9_-]{11})",
            "embed/([a-zA-Z0-9_-]{11})"
        ]
        
        for pattern in patterns {
            
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(
                in: url,
                range: NSRange(url.startIndex..., in: url)
               ),
               let range = Range(match.range(at: 1), in: url) {
                
                return String(url[range])
            }
        }
        
        return nil
    }
    
    // MARK: - PDF
    private func showPDF(_ urlString: String) {
        
        cleanup()
        
        guard let url = URL(string: urlString) else {
            showError("Invalid PDF URL")
            return
        }
        
        let pdfView = PDFView(frame: playerView.bounds)
        
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        
        playerView.addSubview(pdfView)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let data = data,
               let document = PDFDocument(data: data) {
                
                DispatchQueue.main.async {
                    pdfView.document = document
                }
                
            } else {
                DispatchQueue.main.async {
                    self.showError("Failed to load PDF")
                }
            }
            
        }.resume()
    }
    
    // MARK: - Image
    private func showImage(_ urlString: String) {
        
        cleanup()
        
        let imageView = UIImageView(frame: playerView.bounds)
        
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        playerView.addSubview(imageView)
        
        guard let url = URL(string: urlString) else {
            imageView.image = UIImage(named: "placeholder")
            return
        }
        
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    private func isImage(_ url: String) -> Bool {
        
        let formats = ["jpg","jpeg","png","webp","gif","bmp","tiff"]
        
        return formats.contains {
            url.lowercased().hasSuffix(".\($0)")
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        
        playerView.subviews.forEach { $0.removeFromSuperview() }
        playerView.layer.sublayers?.removeAll()
        
        player?.pause()
        player = nil
        playerLayer = nil
        youtubePlayer = nil
    }
    
    // MARK: - Alert
    private func showError(_ message: String) {
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - YT Delegate
extension VideoPlayerVC: YTPlayerViewDelegate {

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        showError("YouTube Error")
    }
}
