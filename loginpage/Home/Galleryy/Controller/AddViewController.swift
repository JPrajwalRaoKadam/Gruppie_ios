import UIKit
import PhotosUI
import AVFoundation

class AddViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {

    var groupId: String = ""
    var token: String = ""

    // Array to store selected images or video thumbnails
    var selectedMedia: [UIImage] = []

    // MARK: - IBOutlets
    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var videosButton: UIButton!
    @IBOutlet weak var youtubeLinkButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton! // ✅ createButton

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Corner radius setup
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true

        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true

        createButton.layer.cornerRadius = 10
        createButton.layer.masksToBounds = true

        
        collectionView.delegate = self
        collectionView.dataSource = self


        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
        
        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true

        // Register CollectionView Cell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let numberOfColumns: CGFloat = 4
        let totalSpacing = (numberOfColumns - 1) * spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true
    }

    // MARK: - COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMedia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = selectedMedia[indexPath.row]
        return cell
    }

    // MARK: - COLLECTION VIEW FLOW LAYOUT (4 per row)
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    @IBAction func youtubeLinkButtonTapped(_ sender: UIButton) {
        let youtubeURLString = "https://www.youtube.com" // replace with your desired YouTube URL
        guard let url = URL(string: youtubeURLString) else {
            print("❌ Invalid URL")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback to Safari if YouTube app is not available
            let safariURL = URL(string: "https://www.youtube.com")!
            UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
        }
    }

    @IBAction func imagesButtonTapped(_ sender: Any) {
        openGallery(mediaType: .images)
    }

    // MARK: - VIDEO BUTTON TAP
    @IBAction func videosButtonTapped(_ sender: Any) {
        openGallery(mediaType: .videos)
    }

    enum MediaType {
        case images
        case videos
    }

    // MARK: - PHPicker for Image & Video Selection
    func openGallery(mediaType: MediaType) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // unlimited selection

        switch mediaType {
        case .images:
            config.filter = .images
        case .videos:
            config.filter = .videos
        }

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - PHPicker Delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                // For images
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedMedia.append(image)
                            self.collectionView.reloadData()
                        }
                    }
                }
            } else {
                // For videos - load thumbnail
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    guard let videoURL = url else { return }
                    let asset = AVAsset(url: videoURL)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true

                    if let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) {
                        let thumbnail = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async {
                            self.selectedMedia.append(thumbnail)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

    @IBAction func createButtonTapped(_ sender: UIButton) {
        print("✅ Create button tapped with \(selectedMedia.count) items selected")
    }

    // MARK: - BACK BUTTON ACTION
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
