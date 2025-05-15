//import UIKit
//import Photos
//import UniformTypeIdentifiers
//import PhotosUI
//import AVKit
//
//enum MediaType {
//    case image(UIImage)
//    case video(URL)
//}
//
//class DetailGalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
//    
//
//    @IBOutlet weak var deleteButton: UIButton!
//    @IBOutlet weak var CollectionView: UICollectionView!
//    @IBOutlet weak var albumName: UILabel!
//    @IBOutlet weak var addButton: UIButton!
//
//    var currentRole: String = ""
//    var groupId: String = ""
//    var token: String = ""
//    var albumId: String = ""
//    var albumNameString: String = ""
//    var selectedIndices: Set<Int> = []
//    var currentPlayer: AVPlayer? 
//
//    var mediaItems: [MediaItemModel] = []
//    var mediaItemsStrings: [String] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("DetailGalleryViewController Loaded with Group ID: \(groupId), Token: \(token), and Album ID: \(albumId), currentRole : \(currentRole)")
//
//        if currentRole == "parent" || currentRole == "teacher" {
//            deleteButton.isHidden = true
//            addButton.isHidden = true
//        } else if currentRole == "admin" {
//            deleteButton.isHidden = false
//            addButton.isHidden = false
//        }
//        
//        loadImages()
//
//        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
//        CollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
//        CollectionView.delegate = self
//        CollectionView.dataSource = self
//
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 10
//        CollectionView.collectionViewLayout = layout
//
//        albumName.text = albumNameString
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return mediaItemsStrings.count
//        }
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
//                return UICollectionViewCell()
//            }
//
//            let path = mediaItemsStrings[indexPath.item]
//            let url = URL(fileURLWithPath: path)
//
//            if path.lowercased().hasSuffix(".mp4") {
//                generateThumbnail(for: url) { thumbnail in
//                    DispatchQueue.main.async {
//                        cell.imageView.image = thumbnail ?? UIImage(systemName: "video.fill")
//                    }
//                }
//            } else {
//                if let image = UIImage(contentsOfFile: path) {
//                    cell.imageView.image = image
//                } else {
//                    cell.imageView.image = UIImage(systemName: "photo")
//                }
//            }
//
//            return cell
//        }
//
//func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let path = mediaItemsStrings[indexPath.item]
//        let url = URL(fileURLWithPath: path)
//        let fileExtension = url.pathExtension.lowercased()
//
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            print("❌ File does not exist at: \(url.path)")
//            return
//        }
//
//        if fileExtension == "mp4" {
//            let player = AVPlayer(url: url)
//            currentPlayer = player
//            let playerVC = AVPlayerViewController()
//            playerVC.player = player
//            present(playerVC, animated: true) {
//                player.play()
//            }
//        } else if ["jpg", "jpeg", "png", "heic", "heif"].contains(fileExtension) {
//            if let data = try? Data(contentsOf: url),
//               let image = UIImage(data: data) {
//                showFullScreenImage(image: image)
//            } else {
//                print("❌ Failed to load image data at path: \(url.path)")
//            }
//        } else {
//            print("❌ Unsupported media type: \(fileExtension)")
//        }
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let spacing: CGFloat = 10
//        let numberOfColumns: CGFloat = 4
//        let totalSpacing = (numberOfColumns - 1) * spacing
//        let cellWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
//        return CGSize(width: cellWidth, height: cellWidth * 1.2)
//    }
//    
//    func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
//            DispatchQueue.global().async {
//                let asset = AVAsset(url: url)
//                let imageGenerator = AVAssetImageGenerator(asset: asset)
//                imageGenerator.appliesPreferredTrackTransform = true
//
//                let time = CMTime(seconds: 1, preferredTimescale: 600)
//                do {
//                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
//                    let thumbnail = UIImage(cgImage: cgImage)
//                    completion(thumbnail)
//                } catch {
//                    print("❌ Failed to generate thumbnail: \(error)")
//                    completion(nil)
//                }
//            }
//        }
//
//    // MARK: - Image Display
//
//    func showFullScreenImage(image: UIImage) {
//        let backgroundView = UIView(frame: self.view.bounds)
//        backgroundView.backgroundColor = UIColor.white
//        backgroundView.alpha = 0
//        backgroundView.tag = 999
//
//        let imageView = UIImageView(image: image)
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.tag = 1000
//        backgroundView.addSubview(imageView)
//
//        let buttonStack = UIStackView()
//        buttonStack.axis = .horizontal
//        buttonStack.spacing = 40
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.addSubview(buttonStack)
//
//        let downloadButton = createIconButton(systemName: "arrow.down.circle", action: #selector(downloadImageTapped))
//        let shareButton = createIconButton(systemName: "square.and.arrow.up", action: #selector(shareImageTapped))
//        let rotateButton = createIconButton(systemName: "rotate.right", action: #selector(rotateImageTapped))
//
//        buttonStack.addArrangedSubview(downloadButton)
//        buttonStack.addArrangedSubview(shareButton)
//        buttonStack.addArrangedSubview(rotateButton)
//
//        self.view.addSubview(backgroundView)
//
//        NSLayoutConstraint.activate([
//            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -40),
//            imageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundView.widthAnchor),
//            imageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundView.heightAnchor, constant: -100),
//            buttonStack.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
//            buttonStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
//        ])
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenImage(_:)))
//        backgroundView.addGestureRecognizer(tapGesture)
//
//        UIView.animate(withDuration: 0.3) {
//            backgroundView.alpha = 1
//        }
//    }
//
//    func createIconButton(systemName: String, action: Selector) -> UIButton {
//        let button = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
//        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
//        button.tintColor = .black
//        button.addTarget(self, action: action, for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        return button
//    }
//    
//    
//    @IBAction func BackButton(_ sender: UIButton) {
//           navigationController?.popViewController(animated: true)
//       }
//    
//    @IBAction func addButtonTapped(_ sender: UIButton) {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 0 // 0 = unlimited selection
//        config.filter = .any(of: [.images, .videos])
//
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        self.present(picker, animated: true, completion: nil)
//    }
//
//    // MARK: - PHPickerViewControllerDelegate
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//
//        let dispatchGroup = DispatchGroup()
//
//        for result in results {
//            let itemProvider = result.itemProvider
//
//            if itemProvider.canLoadObject(ofClass: UIImage.self) {
//                dispatchGroup.enter()
//                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
//                    defer { dispatchGroup.leave() }
//                    guard let self = self else { return }
//                    if let image = object as? UIImage {
//                        DispatchQueue.main.async {
//                            let newItem = MediaItemModel(type: .image(image))
//                            self.mediaItems.append(newItem)
//                        }
//                    }
//                }
//            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                dispatchGroup.enter()
//                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
//                    defer { dispatchGroup.leave() }
//                    guard let self = self, let url = url else { return }
//
//                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
//                    do {
//                        try FileManager.default.copyItem(at: url, to: tempURL)
//                        let newItem = MediaItemModel(type: .video(tempURL))
//                        DispatchQueue.main.async {
//                            self.mediaItems.append(newItem)
//                        }
//                    } catch {
//                        print("❌ Failed to copy video: \(error)")
//                    }
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            self.CollectionView.reloadData()
//
//            // Extract file paths from media items
//            let filePaths: [String] = self.mediaItems.compactMap { item in
//                switch item.type {
//                case .image(let image):
//                    // Save image to temp directory and get the path
//                    if let data = image.jpegData(compressionQuality: 0.8) {
//                        let fileName = UUID().uuidString + ".jpg"
//                        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//                        do {
//                            try data.write(to: fileURL)
//                            return fileURL.path
//                        } catch {
//                            print("❌ Failed to save image: \(error)")
//                            return nil
//                        }
//                    }
//                    return nil
//
//                case .video(let url):
//                    return url.path
//                }
//            }
//
//            self.uploadImages(filePaths)
//        }
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//
//        if let image = info[.originalImage] as? UIImage {
//            let newItem = MediaItemModel(type: .image(image))
//            mediaItems.append(newItem)
//
//            // Save to temp directory
//            if let data = image.jpegData(compressionQuality: 0.8) {
//                let fileName = UUID().uuidString + ".jpg"
//                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//                do {
//                    try data.write(to: fileURL)
//                    mediaItemsStrings.append(fileURL.path)
//                    CollectionView.reloadData()
//                    uploadImages([fileURL.path])
//                } catch {
//                    print("❌ Failed to save image to temporary directory: \(error)")
//                }
//            }
//        } else if let videoURL = info[.mediaURL] as? URL {
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
//            do {
//                try FileManager.default.copyItem(at: videoURL, to: tempURL)
//                let newItem = MediaItemModel(type: .video(tempURL))
//                mediaItems.append(newItem)
//                mediaItemsStrings.append(tempURL.path)
//                CollectionView.reloadData()
//                uploadImages([tempURL.path])
//            } catch {
//                print("❌ Failed to save video to temporary directory: \(error)")
//            }
//        }
//    }
//
//
//
//    @objc func downloadImageTapped() {
//        if let backgroundView = self.view.viewWithTag(999),
//           let imageView = backgroundView.viewWithTag(1000) as? UIImageView,
//           let image = imageView.image {
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            print("✅ Image saved to Photos.")
//        }
//    }
//
//    @objc func shareImageTapped() {
//        if let backgroundView = self.view.viewWithTag(999),
//           let imageView = backgroundView.viewWithTag(1000) as? UIImageView,
//           let image = imageView.image {
//            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
//            present(activityVC, animated: true)
//        }
//    }
//
//    @objc func rotateImageTapped() {
//        if let backgroundView = self.view.viewWithTag(999),
//           let imageView = backgroundView.viewWithTag(1000) as? UIImageView {
//            UIView.animate(withDuration: 0.3) {
//                imageView.transform = imageView.transform.rotated(by: .pi / 2)
//            }
//        }
//    }
//
//    @objc func hideFullScreenImage(_ sender: UITapGestureRecognizer) {
//        if let viewWithTag = self.view.viewWithTag(999) {
//            UIView.animate(withDuration: 0.3, animations: {
//                viewWithTag.alpha = 0
//            }) { _ in
//                viewWithTag.removeFromSuperview()
//            }
//        }
//    }
//
//    // MARK: - Image/Video Loading
//
//    func loadImages() {
//        var loadedMediaItems: [MediaItemModel] = []
//
//        for itemString in mediaItemsStrings {
//            let cleaned = itemString.trimmingCharacters(in: .whitespacesAndNewlines)
//
//            if cleaned.hasPrefix("data:image/jpeg;base64,") {
//                let base64 = String(cleaned.dropFirst("data:image/jpeg;base64,".count))
//                if let image = convertBase64ToImage(base64) {
//                    loadedMediaItems.append(MediaItemModel(type: .image(image)))
//                }
//            } else if cleaned.hasPrefix("data:image/png;base64,") {
//                let base64 = String(cleaned.dropFirst("data:image/png;base64,".count))
//                if let image = convertBase64ToImage(base64) {
//                    loadedMediaItems.append(MediaItemModel(type: .image(image)))
//                }
//            } else if cleaned.hasPrefix("data:video/mp4;base64,") {
//                let base64 = String(cleaned.dropFirst("data:video/mp4;base64,".count))
//                if let videoURL = saveBase64VideoToTempFile(base64: base64) {
//                    loadedMediaItems.append(MediaItemModel(type: .video(videoURL)))
//                }
//            }
//        }
//
//        DispatchQueue.main.async {
//            self.mediaItems = loadedMediaItems
//            self.CollectionView.reloadData()
//        }
//    }
//
//    
//    func convertBase64ToImage(_ base64String: String) -> UIImage? {
//        if let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
//            return UIImage(data: imageData)
//        }
//        return nil
//    }
//
//    func saveBase64VideoToTempFile(base64: String) -> URL? {
//        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
//
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
//
//        do {
//            try data.write(to: fileURL)
//            return fileURL
//        } catch {
//            print("❌ Failed to save video to temp directory: \(error)")
//            return nil
//        }
//    }
//
//
//    func loadMediaFromURL(url: URL, completion: @escaping (MediaItemModel?) -> Void) {
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            guard let data = data else {
//                completion(nil)
//                return
//            }
//            if url.pathExtension.lowercased() == "mp4" {
//                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
//                do {
//                    try data.write(to: tempURL)
//                    completion(MediaItemModel(type: .video(tempURL)))
//                } catch {
//                    print("❌ Failed to save video")
//                    completion(nil)
//                }
//            } else if let image = UIImage(data: data) {
//                completion(MediaItemModel(type: .image(image)))
//            } else {
//                completion(nil)
//            }
//        }.resume()
//    }
//    
//    func uploadImages(_ encodedImages: [String]) {
//           guard !groupId.isEmpty, !albumId.isEmpty else {
//               print("❌ Error: groupId or albumId is empty")
//               return
//           }
//
//           let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(albumId)/add"
//           guard let url = URL(string: urlString) else {
//               print("❌ Invalid URL")
//               return
//           }
//
//           let requestData: [String: Any] = [
//               "fileName": encodedImages,
//               "fileType": "image"
//           ]
//
//           guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
//               print("❌ Failed to encode JSON request body")
//               return
//           }
//
//           var request = URLRequest(url: url)
//           request.httpMethod = "PUT"
//           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//           request.httpBody = jsonData
//
//           print("📤 Uploading \(encodedImages.count) images to API...")
//
//           URLSession.shared.dataTask(with: request) { data, response, error in
//               if let error = error {
//                   print("❌ Error uploading images: \(error.localizedDescription)")
//                   return
//               }
//
//               if let httpResponse = response as? HTTPURLResponse {
//                   print("✅ Response Code: \(httpResponse.statusCode)")
//
//                   if httpResponse.statusCode == 200 {
//                       print("🎉 Images successfully uploaded!")
//                   } else {
//                       print("⚠️ Failed to upload images. Response code: \(httpResponse.statusCode)")
//                   }
//               }
//
//               if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
//                   print("✅ Upload Response JSON: \(jsonResponse)")
//               } else {
//                   print("❌ Failed to parse response data")
//               }
//           }.resume()
//       }
//
//}

import UIKit
import Photos
import UniformTypeIdentifiers
import PhotosUI
import AVKit

enum MediaType {
    case image(UIImage)
    case video(URL)
}

class DetailGalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var currentRole: String = ""
    var groupId: String = ""
    var token: String = ""
    var albumId: String = ""
    var albumNameString: String = ""
    var selectedIndices: Set<Int> = []
    var currentPlayer: AVPlayer?

    var mediaItems: [MediaItemModel] = []
    var mediaItemsStrings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailGalleryViewController Loaded with Group ID: \(groupId), Token: \(token), and Album ID: \(albumId), currentRole : \(currentRole)")

        deleteButton.isHidden = (currentRole == "parent" || currentRole == "teacher")
        addButton.isHidden = (currentRole == "parent" || currentRole == "teacher")

        loadImages()

        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        CollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        CollectionView.delegate = self
        CollectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        CollectionView.collectionViewLayout = layout

        albumName.text = albumNameString
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItemsStrings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        let path = mediaItemsStrings[indexPath.item]
        let url = URL(fileURLWithPath: path)

        if path.lowercased().hasSuffix(".mp4") {
            generateThumbnail(for: url) { thumbnail in
                DispatchQueue.main.async {
                    cell.imageView.image = thumbnail ?? UIImage(systemName: "video.fill")
                }
            }
        } else {
            if let image = UIImage(contentsOfFile: path) {
                cell.imageView.image = image
            } else {
                cell.imageView.image = UIImage(systemName: "photo")
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let path = mediaItemsStrings[indexPath.item]
        let url = URL(fileURLWithPath: path)
        let fileExtension = url.pathExtension.lowercased()

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ File does not exist at: \(url.path)")
            return
        }

        if fileExtension == "mp4" {
            let player = AVPlayer(url: url)
            currentPlayer = player
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            present(playerVC, animated: true) {
                player.play()
            }
        } else if ["jpg", "jpeg", "png", "heic", "heif"].contains(fileExtension) {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                showFullScreenImage(image: image)
            } else {
                print("❌ Failed to load image data at path: \(url.path)")
            }
        } else {
            print("❌ Unsupported media type: \(fileExtension)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let numberOfColumns: CGFloat = 4
        let totalSpacing = (numberOfColumns - 1) * spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }

    func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                completion(thumbnail)
            } catch {
                print("❌ Failed to generate thumbnail: \(error)")
                completion(nil)
            }
        }
    }

    func showFullScreenImage(image: UIImage) {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.white
        backgroundView.alpha = 0
        backgroundView.tag = 999

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = 1000
        backgroundView.addSubview(imageView)

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 40
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(buttonStack)

        let downloadButton = createIconButton(systemName: "arrow.down.circle", action: #selector(downloadImageTapped))
        let shareButton = createIconButton(systemName: "square.and.arrow.up", action: #selector(shareImageTapped))
        let rotateButton = createIconButton(systemName: "rotate.right", action: #selector(rotateImageTapped))

        buttonStack.addArrangedSubview(downloadButton)
        buttonStack.addArrangedSubview(shareButton)
        buttonStack.addArrangedSubview(rotateButton)

        self.view.addSubview(backgroundView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundView.heightAnchor, constant: -100),
            buttonStack.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            buttonStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenImage(_:)))
        backgroundView.addGestureRecognizer(tapGesture)

        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 1
        }
    }

    func createIconButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let dispatchGroup = DispatchGroup()
        var newFilePaths: [String] = []

        for result in results {
            let itemProvider = result.itemProvider

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    defer { dispatchGroup.leave() }
                    guard let self = self, let image = object as? UIImage else { return }

                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

                    if let data = image.jpegData(compressionQuality: 0.8) {
                        do {
                            try data.write(to: fileURL)
                            newFilePaths.append(fileURL.path)
                        } catch {
                            print("❌ Failed to save image: \(error)")
                        }
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                dispatchGroup.enter()
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                    defer { dispatchGroup.leave() }
                    guard let self = self, let url = url else { return }

                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                    do {
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        newFilePaths.append(tempURL.path)
                    } catch {
                        print("❌ Failed to copy video: \(error)")
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.mediaItemsStrings.append(contentsOf: newFilePaths)
            self.CollectionView.reloadData()
            self.uploadImages(newFilePaths)
        }
    }

    // MARK: - Image Upload
    func uploadImages(_ paths: [String]) {
        print("🟢 Uploading files: \(paths)")
        // TODO: Implement your image/video upload logic here
    }

    // MARK: - Stubs for Button Actions
    @objc func downloadImageTapped() { print("⬇️ Download tapped") }
    @objc func shareImageTapped() { print("📤 Share tapped") }
    @objc func rotateImageTapped() { print("🔄 Rotate tapped") }
    @objc func hideFullScreenImage(_ gesture: UITapGestureRecognizer) {
        if let view = self.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }

    // Dummy placeholder
    func loadImages() {
        // Populate mediaItemsStrings with saved file paths
        print("📂 Load images for album \(albumId)")
    }
}


