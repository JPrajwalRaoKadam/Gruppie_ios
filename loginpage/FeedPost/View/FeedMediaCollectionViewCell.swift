//
//  FeedMediaCollectionViewCell.swift
//  loginpage
//
//  Created by apple on 20/01/26.
//

import UIKit
import AVFoundation

class FeedMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioPlayPauseButton: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImageView.layer.cornerRadius = 8
        ImageView.clipsToBounds = true
        audioView.isHidden = true
        audioPlayPauseButton.isHidden = true
    }
    
    func configure(with attachment: FeedAttachment) {
        let urlString = attachment.fileUrl
        let type = attachment.fileType.lowercased()
        
        // Reset
        ImageView.image = nil
        audioView.isHidden = true
        audioPlayPauseButton.isHidden = true
        
        if FeedMediaCollectionViewCell.isYouTubeURL(urlString) {
            // YouTube thumbnail
            audioPlayPauseButton.isHidden = false
            let thumbnailURL = FeedMediaCollectionViewCell.youtubeThumbnailURL(from: urlString)
            loadImage(thumbnailURL)
            
        } else if type.contains("image") {
            loadImage(urlString)
            
        } else if type.contains("video") {
            audioPlayPauseButton.isHidden = false
            loadVideoThumbnail(urlString)
            
        } else if type.contains("audio") {
            audioView.isHidden = false
            ImageView.image = UIImage(named: "audioMedia")
            
        } else if type.contains("pdf") {
            ImageView.image = UIImage(named: "defaultpdf")
            
        } else {
            ImageView.image = UIImage(named: "file_placeholder")
        }
    }
    
    // MARK: - Image Loader
    private func loadImage(_ urlString: String) {
        if let cached = imageCache.object(forKey: urlString as NSString) {
            ImageView.image = cached
            return
        }
        
        guard let url = URL(string: urlString) else {
            ImageView.image = UIImage(named: "file_placeholder")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else { return }
            self.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async { self.ImageView.image = image }
        }.resume()
    }
    
    // MARK: - Video Thumbnail
    private func loadVideoThumbnail(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global(qos: .background).async {
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                DispatchQueue.main.async { self.ImageView.image = UIImage(cgImage: cgImage) }
            } else {
                DispatchQueue.main.async { self.ImageView.image = UIImage(named: "video_placeholder") }
            }
        }
    }
    
    // MARK: - YouTube Helpers
    private static func isYouTubeURL(_ urlString: String) -> Bool {
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
    
    private static func youtubeThumbnailURL(from urlString: String) -> String {
        var videoID = ""
        if urlString.contains("youtu.be") {
            videoID = urlString.components(separatedBy: "/").last ?? ""
        } else if let query = URLComponents(string: urlString)?.queryItems {
            videoID = query.first(where: { $0.name == "v" })?.value ?? ""
        }
        return "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
    }
}
