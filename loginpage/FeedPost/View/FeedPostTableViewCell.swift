import UIKit
import AVFoundation

protocol PostActivityDelegate: AnyObject {
    func didTapLikeButton(cell: FeedPostTableViewCell)
    func didTapMedia(cell: FeedPostTableViewCell, url: String)
    func didTapReadMore(text: String, from cell: FeedPostTableViewCell)
}

final class FeedPostTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var noOfLikes: UILabel!
    @IBOutlet weak var noOfComments: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var RepostButton: UIButton!
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var firstDescriptionLabel: UILabel!
    @IBOutlet weak var noOfViews: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl! 

    // MARK: - Properties
    weak var delegate: PostActivityDelegate?
    private let maxLines = 3
    private var isExpanded = false
    var attachments: [FeedAttachment] = []

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.isPagingEnabled = true
        mediaCollectionView.showsHorizontalScrollIndicator = false
        mediaCollectionView.register(
            UINib(nibName: "FeedMediaCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "FeedMediaCollectionViewCell"
        )
        
        playPauseButton.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        attachments = []
        mediaCollectionView.reloadData()
        isExpanded = false
        playPauseButton.isHidden = true
        pageControl.isHidden = true
    }

    // MARK: - Configure
    func configure(with post: FeedPost) {
        firstDescriptionLabel.text = post.team?.name
        adminLabel.text = post.fromUser.name
        descriptionLabel.text = post.body
        timingLabel.text = formatDate(post.createdAt ?? "")
        noOfLikes.text = "\(post.likeCount)"
        noOfComments.text = "\(post.commentCount)"
        noticeLabel.text = post.title
        descriptionLabel.numberOfLines = isExpanded ? 0 : maxLines

        attachments = post.attachments
        mediaCollectionView.reloadData()

        // Setup page control
        pageControl.numberOfPages = attachments.count
        pageControl.currentPage = 0
        pageControl.isHidden = attachments.count <= 1

        // Show playPauseButton only if first attachment is video/YouTube
        if let first = attachments.first {
            playPauseButton.isHidden = !isVideoOrYouTube(first)
        } else {
            playPauseButton.isHidden = true
        }

        if post.isLiked {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            likeButton.tintColor = .black
        } else {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            likeButton.tintColor = .lightGray
        }

        updateReadMoreVisibility()
    }

    // MARK: - Helpers
    private func isVideoOrYouTube(_ attachment: FeedAttachment) -> Bool {
        
        let type = attachment.fileType?.lowercased() ?? ""
        let url  = attachment.fileUrl?.lowercased() ?? ""
        
        return type.contains("video")
            || url.contains("youtube.com")
            || url.contains("youtu.be")
    }

    private func updateReadMoreVisibility() {
        let maxHeight = descriptionLabel.font.lineHeight * CGFloat(maxLines)
        let size = CGSize(width: descriptionLabel.bounds.width, height: .greatestFiniteMagnitude)
        let height = descriptionLabel.text?.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionLabel.font!],
            context: nil
        ).height ?? 0
        readMoreButton.isHidden = height <= maxHeight
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        let output = DateFormatter()
        output.dateFormat = "dd MMM yyyy, h:mm a"
        return output.string(from: date)
    }

    // MARK: - Actions
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(cell: self)
    }
    
    @IBAction func readMoreTapped(_ sender: UIButton) {
        guard let text = descriptionLabel.text else { return }
        delegate?.didTapReadMore(text: text, from: self)
    }
    
    @IBAction func commentAction(_ sender: UIButton) {
        
    }
    
    @IBAction func playPauseAction(_ sender: UIButton) {
        
    }
    
}

// MARK: - UICollectionView Delegate/DataSource
extension FeedPostTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FeedMediaCollectionViewCell",
            for: indexPath
        ) as! FeedMediaCollectionViewCell
        cell.configure(with: attachments[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attachment = attachments[indexPath.row]
        delegate?.didTapMedia(cell: self, url: attachment.fileUrl ?? "")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth/2) / pageWidth)
        pageControl.currentPage = currentPage

        // Update playPauseButton visibility for current page
        if attachments.indices.contains(currentPage) {
            let attachment = attachments[currentPage]
            playPauseButton.isHidden = !isVideoOrYouTube(attachment)
        }
    }
}
