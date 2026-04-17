import UIKit
import PhotosUI
import AVFoundation

enum GalleryMedia {
    case image(UIImage)
    case video(url: URL, thumbnail: UIImage)
}

class AddViewController: UIViewController,
                         UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout,
                         PHPickerViewControllerDelegate {

    var groupId: String = ""
    var token: String = ""
    var selectedMedia: [GalleryMedia] = []

    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var videosButton: UIButton!
    @IBOutlet weak var youtubeLinkButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton!

    let spinner = UIActivityIndicatorView(style: .large)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        createButton.layer.cornerRadius = 10

        collectionView.register(
            UINib(nibName: "CollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CollectionViewCell"
        )

        enableKeyboardDismissOnTap()
        collectionView.delegate = self
        collectionView.dataSource = self
        spinner.center = view.center
            view.addSubview(spinner)
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.height / 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMedia.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CollectionViewCell",
            for: indexPath
        ) as! CollectionViewCell

        let media = selectedMedia[indexPath.row]

        switch media {
        case .image(let image):
            cell.imageView.image = image

        case .video(_, let thumbnail):
            cell.imageView.image = thumbnail
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 10
        let columns: CGFloat = 4
        let totalSpacing = (columns - 1) * spacing
        let width = (collectionView.frame.width - totalSpacing) / columns
        return CGSize(width: width, height: width * 1.2)
    }

    @IBAction func youtubeLinkButtonTapped(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.youtube.com")!)
    }

    @IBAction func imagesButtonTapped(_ sender: Any) {
        openGallery(filter: .images)
    }

    @IBAction func videosButtonTapped(_ sender: Any) {
        openGallery(filter: .videos)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func openGallery(filter: PHPickerFilter) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = filter

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        for result in results {

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedMedia.append(.image(image))
                            self.collectionView.reloadData()
                        }
                    }
                }
            }

            else if result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
                result.itemProvider.loadFileRepresentation(
                    forTypeIdentifier: "public.movie"
                ) { url, _ in
                    guard let url = url else { return }

                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + ".mp4")

                    try? FileManager.default.copyItem(at: url, to: tempURL)

                    let thumbnail = self.generateThumbnail(from: tempURL)

                    DispatchQueue.main.async {
                        self.selectedMedia.append(
                            .video(url: tempURL, thumbnail: thumbnail)
                        )
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    func generateThumbnail(from url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        if let cgImage = try? generator.copyCGImage(
            at: CMTime(seconds: 0.5, preferredTimescale: 600),
            actualTime: nil
        ) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage()
    }

    @IBAction func createButtonTapped(_ sender: UIButton) {

        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            showError("Token missing")
            return
        }

        guard let albumName = albumTextField.text, !albumName.isEmpty else {
            showError("Please enter album name")
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        let parameters = [
            "name": albumName,
            "groupAcademicYearId": "1"
        ]

        let body = createMultipartFormData(
            boundary: boundary,
            parameters: parameters,
            media: selectedMedia
        )

        var request = URLRequest(
            url: URL(string: "https://backend.gc2.co.in/api/v1/gallery/albums")!
        )
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.spinner.stopAnimating()

                if let error = error {
                    self.showAlert(message: "Upload failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResp = response as? HTTPURLResponse else {
                    self.showAlert(message: "Upload failed: Invalid response")
                    return
                }

                if (200...299).contains(httpResp.statusCode) {
                    self.showAlert(message: "Album created successfully", success: true, autoBack: true)
                    
                    // Refresh gallery
                    if (200...299).contains(httpResp.statusCode) {
                        self.showAlert(message: "Album created successfully", success: true, autoBack: true)
                    }
                } else {
                    self.showAlert(message: "Upload failed with status: \(httpResp.statusCode)")
                }
            }
        }.resume()

    }

    func createMultipartFormData(
        boundary: String,
        parameters: [String: String],
        media: [GalleryMedia]
    ) -> Data {

        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        for (index, item) in media.enumerated() {

            switch item {

            case .image(let image):
                guard let data = image.jpegData(compressionQuality: 0.7) else { continue }

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append(
                    "Content-Disposition: form-data; name=\"attachments\"; filename=\"image\(index).jpg\"\r\n"
                        .data(using: .utf8)!
                )
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n".data(using: .utf8)!)

            case .video(let url, _):
                guard let data = try? Data(contentsOf: url) else { continue }

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append(
                    "Content-Disposition: form-data; name=\"attachments\"; filename=\"video\(index).mp4\"\r\n"
                        .data(using: .utf8)!
                )
                body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                body.append(data)
                body.append("\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showAlert(message: String, success: Bool = true, autoBack: Bool = false) {
        let alert = UIAlertController(title: success ? "Success" : "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if autoBack {
                self.navigationController?.popViewController(animated: true)
            }
        })
        self.present(alert, animated: true)
    }

}
