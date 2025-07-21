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
    
    var videoPlayerURL: String?
    var player: AVPlayer?
    
    private var yTplayerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayPauseButton()
        print("\(videoPlayerURL).....ooppppppppddddd")
        convert(from: videoPlayerURL ?? "", on: playerView)
        displayPDFInUIView(from: videoPlayerURL ?? "", on: playerView)
        player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
        if let videoId = extractVideoId(from: videoPlayerURL ?? "") {
            setupPlayerView()
            loadYouTubeVideo(videoId: videoId)
        } else {
            print("Invalid YouTube URL")
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Ensures the image fills the entire player view without distortion
        imageView.frame = playerView.bounds // Make the image view size match the player view's size
        playerView.addSubview(imageView)
        
        // Load the image from the URL
        if let urlString = videoPlayerURL, let url = URL(string: urlString) {
            loadImage(from: url, into: imageView)
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func playPauseAction(_ sender: Any) {
//        if let player = self.player, player.timeControlStatus == .playing {
//            // If it's playing, pause it
//            player.pause()
//        } else {
//            // If it's not playing, start or resume the video
//            convert(from: videoPlayerURL ?? "", on: playerView)
//            
//        }
//        updatePlayPauseButton()
    }
    
    // Function to decode Base64 string and play the video
    func convert(from base64EncodedString: String, on view: UIView) {
        // Remove newline characters or other unwanted characters
        let cleanedBase64String = base64EncodedString.replacingOccurrences(of: "\n", with: "")
        
        // Decode the cleaned Base64 string
        if let decodedData = Data(base64Encoded: cleanedBase64String),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            print("Decoded URL: \(decodedString)")
            
            // Call the play video function with the decoded URL
            self.videoPlayerURL = decodedString
            playVideo(from: decodedString, on: view)
            playPauseButton.isHidden = false
        } else {
            print("Error: Failed to decode Base64 string")
        }
    }

    // Function to play the video
    func playVideo(from urlString: String, on view: UIView) {
        playPauseButton.isHidden = false
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        // Remove any existing player layers
        view.layer.sublayers?.removeAll(where: { $0 is AVPlayerLayer })

        // Create the AVPlayer
        player = AVPlayer(url: url)

        // Create the AVPlayerLayer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill

        // Add the playerLayer to the view
        view.layer.addSublayer(playerLayer)

        // Start playing the video
        player?.play()
        
        updatePlayPauseButton()
        
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                    
                    // Calculate the proper frame to maintain aspect ratio
                    let imageRatio = image.size.width / image.size.height
                    let viewRatio = imageView.bounds.width / imageView.bounds.height
                    
                    if imageRatio > viewRatio {
                        // Image is wider than view - fit to width
                        let height = imageView.bounds.width / imageRatio
                        imageView.frame = CGRect(
                            x: 0,
                            y: (imageView.bounds.height - height) / 2,
                            width: imageView.bounds.width,
                            height: height
                        )
                    } else {
                        // Image is taller than view - fit to height
                        let width = imageView.bounds.height * imageRatio
                        imageView.frame = CGRect(
                            x: (imageView.bounds.width - width) / 2,
                            y: 0,
                            width: width,
                            height: imageView.bounds.height
                        )
                    }
                }
            } else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder_image")
                    imageView.contentMode = .center  // Center the placeholder if it's smaller
                }
            }
        }
    }
    func displayPDFInUIView(from urlString: String, on containerView: UIView) {
        // Step 1: Convert the URL string to a URL
        playPauseButton.isHidden = true
        guard let pdfURL = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        
        // Step 2: Fetch and load the PDF
        let session = URLSession.shared
        session.dataTask(with: pdfURL) { data, _, error in
            if let error = error {
                print("Error fetching PDF: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: No data fetched")
                return
            }
            
            // Step 3: Create a PDFDocument
            if let pdfDocument = PDFDocument(data: data) {
                DispatchQueue.main.async {
                    // Step 4: Display the PDF in a PDFView
                    let pdfView = PDFView(frame: containerView.bounds)
                    pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    pdfView.document = pdfDocument
                    pdfView.autoScales = true
                    
                    // Clear any existing subviews in the containerView and add the PDFView
                    containerView.subviews.forEach { $0.removeFromSuperview() }
                    containerView.addSubview(pdfView)
                }
            } else {
                print("Error: Failed to create PDFDocument")
            }
        }.resume()
    }

   
//    func setupPlayPauseButton() {
//           playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//           playPauseButton.tintColor = .white  // Set the button color to white for visibility
//           
//           // Set the button's size and position
//           playPauseButton.translatesAutoresizingMaskIntoConstraints = false
//           playerView.addSubview(playPauseButton)
//
//           // Set constraints to center the button over the video
//           NSLayoutConstraint.activate([
//               playPauseButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
//               playPauseButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
//               playPauseButton.widthAnchor.constraint(equalToConstant: 50),
//               playPauseButton.heightAnchor.constraint(equalToConstant: 50)
//           ])
//       }
    
    func updatePlayPauseButton() {
//            if let player = self.player {
//                if player.timeControlStatus == .playing {
//                    // Set Pause icon if the video is playing
//                    playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//                } else {
//                    // Set Play icon if the video is paused
//                    playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//                }
//            }
        }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(AVPlayer.timeControlStatus) {
                updatePlayPauseButton()
            }
        }
}

extension VideoPlayerVC {
    
    func extractVideoId(from url: String) -> String? {
        let pattern = "v=([a-zA-Z0-9_-]{11})"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
           let range = Range(match.range(at: 1), in: url) {
            return String(url[range])
        }
        return nil
    }
    
    private func setupPlayerView() {
        
        yTplayerView = YTPlayerView()
        
        yTplayerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yTplayerView)
        
        // Add constraints to make the player view fill the screen
        NSLayoutConstraint.activate([
            yTplayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            yTplayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            yTplayerView.topAnchor.constraint(equalTo: view.topAnchor),
            yTplayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add a back button
           let backButton = UIButton(type: .system)
           backButton.setTitle("Back", for: .normal)
           backButton.setTitleColor(.white, for: .normal) // Customize the text color
           backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
           backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
           view.addSubview(backButton)
           
           // Add constraints for the back button
           NSLayoutConstraint.activate([
               backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
               backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
           ])
    }
    
    private func loadYouTubeVideo(videoId: String) {
        // Load the video by videoId
        yTplayerView.load(withVideoId: videoId, playerVars: [
            "playsinline": 1,   // Plays video inline (1 = yes, 0 = no)
            "autoplay": 1,      // Automatically start playing (1 = yes, 0 = no)
            "controls": 1,      // Show playback controls (1 = yes, 0 = no)
            "rel": 0            // Do not show related videos at the end
        ])
    }
}

extension VideoPlayerVC: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("Player is ready")
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print("Player state changed to: \(state.rawValue)")
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        print("Player encountered an error: \(error)")
    }
}
