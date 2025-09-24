import UIKit
import Photos
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation
import AVKit

class DetailGalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate, CollectionViewCellDelegate {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var processedMediaItems: [MediaType] = []
    var currentRole: String = ""
    var groupId: String = ""
    var token: String = ""
    var albumId: String = ""
    var albumNameString: String = ""
    var selectedIndices: [Int] = []
    var mediaItems: [UIImage] = []
    var mediaItemsStrings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailGalleryViewController Loaded with Group ID: \(groupId), Token: \(token), and Album ID: \(albumId), currentRole : \(currentRole)")
        
        if currentRole == "parent" || currentRole == "teacher" {
            deleteButton.isHidden = true
            addButton.isHidden = true
        } else if currentRole == "admin" {
            deleteButton.isHidden = false
            addButton.isHidden = false
        }

        print("Number of images in album: \(mediaItemsStrings.count)")
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        CollectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")

        CollectionView.delegate = self
        CollectionView.dataSource = self

        print("mediaItemsStrings: \(mediaItemsStrings)")

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        CollectionView.collectionViewLayout = layout
        
        CollectionView.layer.cornerRadius = 10
        CollectionView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        albumName.text = albumNameString
        loadImages()
        loadVideos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    
    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        
        if !asset.isPlayable {
            print("❌ Asset is not playable: \(url.path)")
            return nil
        }
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("❌ Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    func loadLocalImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }

    func loadLocalVideoThumbnail(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("❌ File does not exist at path: \(path)")
            return nil
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? NSNumber, fileSize.intValue == 0 {
                print("❌ File is empty (0 bytes): \(path)")
                return nil
            }
        } catch {
            print("❌ Error checking file size: \(error.localizedDescription)")
            return nil
        }
        let asset = AVAsset(url: fileURL)
        if !asset.isPlayable {
            print("❌ Video asset not playable: \(path)")
            return nil
        }

        return generateThumbnail(url: fileURL)
    }
    
    func loadVideos() {
        for path in mediaItemsStrings {
            if path.hasSuffix(".mp4") {
                let videoURL = URL(fileURLWithPath: path)
                
                if let thumbnail = loadLocalVideoThumbnail(from: path) {
                    processedMediaItems.append(.videoThumbnail(thumbnail, videoURL))
                } else {
                    print("❌ Failed to load video thumbnail: \(path)")
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = processedMediaItems[indexPath.item]
        
        switch item {
        case .image(let image):
            showFullScreenImage(image: image)
            
        case .videoThumbnail(_, let url):
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(url: url)
            self.present(playerVC, animated: true) {
                playerVC.player?.play()
            }
            
        case .video(let url, let playerItem):
            let playerVC = AVPlayerViewController()
            playerVC.player = AVPlayer(playerItem: playerItem)
            self.present(playerVC, animated: true) {
                playerVC.player?.play()
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
        buttonStack.alignment = .center
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 40
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(buttonStack)

        let downloadButton = createIconButton(systemName: "arrow.down.circle", action: #selector(downloadImageTapped))
        downloadButton.accessibilityLabel = "Download"

        let shareButton = createIconButton(systemName: "square.and.arrow.up", action: #selector(shareImageTapped))
        shareButton.accessibilityLabel = "Share"

        let rotateButton = createIconButton(systemName: "rotate.right", action: #selector(rotateImageTapped))
        rotateButton.accessibilityLabel = "Rotate"

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

        backgroundView.accessibilityElements = [image]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideFullScreenImage(_:)))
        backgroundView.addGestureRecognizer(tapGesture)

        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 1
        }
    }

    func createIconButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    @objc func downloadImageTapped() {
        if let backgroundView = self.view.viewWithTag(999),
           let imageView = backgroundView.viewWithTag(1000) as? UIImageView,
           let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("Image saved to Photos.")
        }
    }

    @objc func shareImageTapped() {
        if let backgroundView = self.view.viewWithTag(999),
           let imageView = backgroundView.viewWithTag(1000) as? UIImageView,
           let image = imageView.image {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        }
    }

    @objc func rotateImageTapped() {
        if let backgroundView = self.view.viewWithTag(999),
           let imageView = backgroundView.viewWithTag(1000) as? UIImageView {
            UIView.animate(withDuration: 0.3) {
                imageView.transform = imageView.transform.rotated(by: .pi / 2)
            }
        }
    }

    @objc func hideFullScreenImage(_ sender: UITapGestureRecognizer) {
        if let viewWithTag = self.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.3, animations: {
                viewWithTag.alpha = 0
            }) { _ in
                viewWithTag.removeFromSuperview()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let numberOfColumns: CGFloat = 4
        let totalSpacing = (numberOfColumns - 1) * spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
    
    func loadImages() {
        let dispatchGroup = DispatchGroup()
        var tempMediaItems: [MediaType] = []

        for item in mediaItemsStrings {
            let cleanedString = item
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n", with: "")

            if cleanedString.hasPrefix("/") {
                let fileURL = URL(fileURLWithPath: cleanedString)
                if cleanedString.hasSuffix(".mp4") {
                    if let thumbnail = generateThumbnail(url: fileURL) {
                        tempMediaItems.append(.videoThumbnail(thumbnail, fileURL))
                    } else {
                        print("❌ Failed to generate thumbnail for local video: \(cleanedString)")
                    }
                } else {
                    if let data = try? Data(contentsOf: fileURL),
                       let image = UIImage(data: data) {
                        tempMediaItems.append(.image(image))
                    } else {
                        print("❌ Failed to load local image from path: \(cleanedString)")
                    }
                }
                continue
            }

            var base64ImageString = cleanedString
            if cleanedString.hasPrefix("data:image/jpeg;base64,") {
                base64ImageString = String(cleanedString.dropFirst("data:image/jpeg;base64,".count))
            } else if cleanedString.hasPrefix("data:image/png;base64,") {
                base64ImageString = String(cleanedString.dropFirst("data:image/png;base64,".count))
            }

            if let image = convertBase64ToImage(base64ImageString) {
                tempMediaItems.append(.image(image))
                continue
            }

            if let decodedData = Data(base64Encoded: cleanedString),
               let decodedURLString = String(data: decodedData, encoding: .utf8),
               decodedURLString.hasPrefix("http"),
               let url = URL(string: decodedURLString) {

                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                    defer { dispatchGroup.leave() }

                    if decodedURLString.hasSuffix(".mp4") {
                        if let thumbnail = self.generateThumbnail(url: url) {
                            tempMediaItems.append(.videoThumbnail(thumbnail, url))
                        } else {
                            print("❌ Failed to generate thumbnail from video URL: \(decodedURLString)")
                        }
                    } else if let data = data, let image = UIImage(data: data) {
                        tempMediaItems.append(.image(image))
                    } else {
                        print("⚠️ Invalid or unsupported media format from URL: \(decodedURLString)")
                    }
                }.resume()
                continue
            }

            if cleanedString.hasPrefix("http"), let url = URL(string: cleanedString) {
                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                    defer { dispatchGroup.leave() }

                    if cleanedString.hasSuffix(".mp4") {
                        if let thumbnail = self.generateThumbnail(url: url) {
                            tempMediaItems.append(.videoThumbnail(thumbnail, url))
                        } else {
                            print("❌ Failed to generate thumbnail from video URL: \(cleanedString)")
                        }
                    } else if let data = data, let image = UIImage(data: data) {
                        tempMediaItems.append(.image(image))
                    } else {
                        print("⚠️ Invalid or unsupported media format from URL: \(cleanedString)")
                    }
                }.resume()
                continue
            }

            print("❌ Unsupported media format or invalid string: \(cleanedString)")
        }

        dispatchGroup.notify(queue: .main) {
            self.processedMediaItems = tempMediaItems
            self.CollectionView.reloadData()
            print("✅ Finished loading all media items: \(self.processedMediaItems.count)")
        }
    }
    
    enum MediaSourceType {
        case image
        case video
    }
    
    enum MediaType {
        case image(UIImage)
        case videoThumbnail(UIImage, URL)
        case video(URL, AVPlayerItem)
    }

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Add Media", message: "Choose an option", preferredStyle: .actionSheet)

        let addPhotoAction = UIAlertAction(title: "Add Photo", style: .default) { _ in
            self.presentPhotoOptions()
        }

        let addVideoAction = UIAlertAction(title: "Add Video", style: .default) { _ in
            self.presentVideoOptions()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(addPhotoAction)
        actionSheet.addAction(addVideoAction)
        actionSheet.addAction(cancelAction)

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        present(actionSheet, animated: true, completion: nil)
    }

    func presentPhotoOptions() {
        let photoSheet = UIAlertController(title: "Add Photo", message: "Choose source", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Open Camera", style: .default) { _ in
            self.openCamera(forSourceType: .image)
        }

        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openMediaPicker()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        photoSheet.addAction(cameraAction)
        photoSheet.addAction(galleryAction)
        photoSheet.addAction(cancelAction)

        present(photoSheet, animated: true, completion: nil)
    }

    func presentVideoOptions() {
        let videoSheet = UIAlertController(title: "Add Video", message: "Choose source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Open Camera", style: .default) { _ in
            self.openCamera(forSourceType: .video)
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openVideoPicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        videoSheet.addAction(cameraAction)
        videoSheet.addAction(galleryAction)
        videoSheet.addAction(cancelAction)
        
        present(videoSheet, animated: true, completion: nil)
    }

    func openCamera(forSourceType type: MediaSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self

            switch type {
            case .image:
                picker.mediaTypes = ["public.image"]
            case .video:
                picker.mediaTypes = ["public.movie"]
            }

            present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Camera not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }

    private func openMediaPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var encodedImages: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self, let selectedImage = image as? UIImage else {
                    dispatchGroup.leave()
                    return
                }
                
                DispatchQueue.main.async {
                    self.mediaItems.append(selectedImage)
                    self.processedMediaItems.append(.image(selectedImage))
                    self.CollectionView.reloadData()
                }

                if let base64String = self.convertImageToBase64(selectedImage) {
                    encodedImages.append(base64String)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.uploadImages(encodedImages)
        }
    }

    func uploadImages(_ encodedImages: [String]) {
        guard !groupId.isEmpty, !albumId.isEmpty else {
            print("❌ Error: groupId or albumId is empty")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(albumId)/add"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        let requestData: [String: Any] = [
            "fileName": encodedImages,
            "fileType": "image"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            print("❌ Failed to encode JSON request body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        print("📤 Uploading \(encodedImages.count) images to API...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error uploading images: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Response Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    print("🎉 Images successfully uploaded!")
                    // Add the new images to mediaItemsStrings
                    DispatchQueue.main.async {
                        self.mediaItemsStrings.append(contentsOf: encodedImages)
                    }
                } else {
                    print("⚠️ Failed to upload images. Response code: \(httpResponse.statusCode)")
                }
            }

            if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("✅ Upload Response JSON: \(jsonResponse)")
            } else {
                print("❌ Failed to parse response data")
            }
        }.resume()
    }

    func convertImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return "data:image/jpeg;base64," + imageData.base64EncodedString()
    }

    func convertBase64ToImage(_ base64String: String) -> UIImage? {
        let cleanedString = base64String.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")

        if let imageData = Data(base64Encoded: cleanedString, options: .ignoreUnknownCharacters) {
            return UIImage(data: imageData)
        } else {
            print("❌ Failed to decode base64: \(cleanedString.prefix(30))...")
            return nil
        }
    }

    private func openVideoPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [UTType.movie.identifier]
        present(imagePicker, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return processedMediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = processedMediaItems[indexPath.row]

        switch item {
        case .image(let image):
            cell.imageView.image = image
        case .videoThumbnail(let thumbnail, _):
            cell.imageView.image = thumbnail
        case .video(let url, _):
            if let thumbnail = loadLocalVideoThumbnail(from: url.path) {
                cell.imageView.image = thumbnail
            } else {
                cell.imageView.image = UIImage(named: "video_placeholder")
            }
        }

        cell.SelectButton.tag = indexPath.item
        cell.isSelectedCell = selectedIndices.contains(indexPath.item)
        cell.delegate = self
        return cell
    }
    
    func didToggleSelection(on cell: CollectionViewCell) {
        guard let indexPath = CollectionView.indexPath(for: cell) else { return }

        if let index = selectedIndices.firstIndex(of: indexPath.row) {
            selectedIndices.remove(at: index)
        } else {
            selectedIndices.append(indexPath.row)
        }

        cell.isSelectedCell = selectedIndices.contains(indexPath.row)
    }

    @objc func selectButtonTapped(_ sender: UIButton) {
        let index = sender.tag

        if selectedIndices.contains(index) {
            selectedIndices.removeAll(where: { $0 == index })
        } else {
            selectedIndices.append(index)
        }

        CollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard !selectedIndices.isEmpty else {
            print("⚠️ No images selected for deletion.")
            return
        }
        
        let alert = UIAlertController(title: "Delete Photo", message: "Do you want to delete the selected photo(s)?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            self.deleteSelectedImages()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func deleteSelectedImages() {
        guard !groupId.isEmpty, !albumId.isEmpty else {
            print("❌ Error: groupId or albumId is empty")
            showAlert(title: "Error", message: "Missing group or album information")
            return
        }

        let selectedImages = selectedIndices
            .filter { $0 < mediaItemsStrings.count }
            .map { mediaItemsStrings[$0] }

        guard !selectedImages.isEmpty else {
            print("❌ No valid items selected for deletion")
            showAlert(title: "Error", message: "No valid items selected")
            return
        }

        let fileNamesParam = selectedImages
            .compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
            .joined(separator: ",")

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(albumId)/remove?fileName=\(fileNamesParam)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            showAlert(title: "Error", message: "Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("📤 Deleting \(selectedImages.count) images from API...")
        print("Request URL: \(urlString)")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error deleting images: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to delete: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Invalid server response")
                }
                return
            }

            print("✅ Response Code: \(httpResponse.statusCode)")

            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📝 Raw Response: \(responseString)")
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✅ Parsed JSON Response: \(jsonResponse)")
                } catch {
                    print("⚠️ Could not parse JSON: \(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {
                if (200...299).contains(httpResponse.statusCode) {
                    let indicesToDelete = self.selectedIndices.sorted(by: >)
                    
                    for index in indicesToDelete {
                        if index < self.processedMediaItems.count {
                            self.processedMediaItems.remove(at: index)
                        }
                        if index < self.mediaItems.count {
                            self.mediaItems.remove(at: index)
                        }
                        if index < self.mediaItemsStrings.count {
                            self.mediaItemsStrings.remove(at: index)
                        }
                    }
                    
                    self.selectedIndices.removeAll()
                    self.CollectionView.reloadData()
                    print("✅ Successfully deleted items and updated UI")
                } else {
                    print("⚠️ Failed to delete images. Response code: \(httpResponse.statusCode)")
                    let message = self.parseErrorMessage(from: data) ?? "Server returned status code \(httpResponse.statusCode)"
                    self.showAlert(title: "Error", message: message)
                }
            }
        }
        task.resume()
    }

    private func parseErrorMessage(from data: Data?) -> String? {
        guard let data = data else { return nil }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["message"] as? String {
                return message
            }
        } catch {
            print("⚠️ Error parsing error message: \(error)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            return responseString
        }
        
        return nil
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
