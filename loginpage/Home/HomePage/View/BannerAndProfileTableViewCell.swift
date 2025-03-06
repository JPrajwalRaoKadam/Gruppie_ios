import UIKit
import SDWebImage

class BannerAndProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var Bannerimg: UIImageView!
    @IBOutlet weak var Profile: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var heightConstraintofAdminLabel: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintofMainView: NSLayoutConstraint!

    
    var imageUrls: [String] = []
    var currentIndex: Int = 0
    var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupPageControl()
        startAutoSwipe()
//        if Profile.text == nil || Profile.text?.isEmpty == true {
//                   Profile.isHidden = true
//                   heightConstraintofAdminLabel.constant = 0
//               } else {
//                   Profile.isHidden = false
//               }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate() // Stop timer when cell is reused
        timer = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Configure image at a specific index
    func configureBannerImage(at index: Int) {
        guard index < imageUrls.count, let url = URL(string: imageUrls[index]) else {
            print("Invalid index or URL for image at index: \(index)")
            return
        }

        // Load the image using SDWebImage
        Bannerimg.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"), options: .refreshCached) { image, error, cacheType, url in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }

    // Set up the page control
    private func setupPageControl() {
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = currentIndex
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }

    // Start the auto-swipe timer
    private func startAutoSwipe() {
        // Auto swipe every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.imageUrls.count
            self.configureBannerImage(at: self.currentIndex)
            self.pageControl.currentPage = self.currentIndex
        }
    }

    // Handle user tapping on the page control (manual swipe)
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        currentIndex = sender.currentPage
        configureBannerImage(at: currentIndex)
        
        // Reset the timer to restart auto-swipe after manual swipe
        timer?.invalidate()
        startAutoSwipe() // Restart auto-swipe after manual interaction
    }
    
    // Optional: To stop auto swipe on manual swipe (for performance optimization, if needed)
    func stopAutoSwipe() {
        timer?.invalidate()
        timer = nil
    }
}
