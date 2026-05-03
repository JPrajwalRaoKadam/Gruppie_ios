//
//  AddChapterVC.swift
//  loginpage
//

import UIKit
import AVFoundation
import Photos
import UniformTypeIdentifiers

class AddChapterVC: UIViewController,
                    UIImagePickerControllerDelegate,
                    UINavigationControllerDelegate,
                    UIDocumentPickerDelegate {

    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var ChapterName: UITextField!
    @IBOutlet weak var topicName: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentCancel: UIButton!
    @IBOutlet weak var pdfNameLabel: UILabel!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: - Properties

    var classId: String = ""
    var subjectId: String = ""
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var groupAcademicYearId: String = ""

    var chapterNames: [String] = []
    var topicNames: [String] = []

    var postName: String = ""
    var postDescription: String?

    var customParentViewController: UIViewController?
    var selectAssets = [PHAsset]()
    var filename = [String]()
    var localfilePath = [URL]()
    var localPdfFilePath = [URL]()
    var localVideofilePath = [URL]()
    var localAudiofilePath = [URL]()
    var localThumbfilePath = [URL]()

    var postNameText: String = ""
    var postDescriptionText: String = ""
    var image: UIImage?
    var finalURL: URL?

    private var documentURL: URL?
    private var vidUrl: URL?

    // MARK: - Upload State (mirrors AddFeedVC)

    var isConverting = false
    var isUploading = false

    let MAX_FILE_SIZE_BYTES = 500 * 1024       // 500 KB for images/docs
    let MAX_VIDEO_SIZE_BYTES = 1 * 1024 * 1024 // 1 MB for videos

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        ChapterName.layer.cornerRadius = 10
        topicName.layer.cornerRadius = 10
        mediaContainer.layer.cornerRadius = 10
        ChapterName.delegate = self
        topicName.delegate = self

        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true

        submitButton.layer.cornerRadius = 10

        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true

        addDropDownIcon(to: ChapterName, action: #selector(showChapterPicker))
        addDropDownIcon(to: topicName, action: #selector(showTopicPicker))

        if let id = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId {
            self.groupAcademicYearId = id
            print("groupAcademicYearId:", self.groupAcademicYearId)
        }

        enableKeyboardDismissOnTap()
    }

    // MARK: - DropDown Icon Setup

    func addDropDownIcon(to textField: UITextField, action: Selector) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        button.center = container.center
        container.addSubview(button)

        textField.rightView = container
        textField.rightViewMode = .always
    }

    // MARK: - Clear Form

    func clearForm() {
        ChapterName.text = ""
        topicName.text = ""
        contentImage.image = nil
        pdfNameLabel.text = ""
        pdfNameLabel.isHidden = true
        contentCancel.isHidden = true
        documentURL = nil
        vidUrl = nil
        image = nil
        finalURL = nil
    }

    // MARK: - Picker Actions

    @objc func showChapterPicker() {
        showPicker(title: "Select Chapter", options: chapterNames) { selected in
            self.ChapterName.text = selected
        }
    }

    @objc func showTopicPicker() {
        showPicker(title: "Select Topic", options: topicNames) { selected in
            self.topicName.text = selected
        }
    }

    func showPicker(title: String, options: [String], onSelect: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in onSelect(option) })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Button Actions

    @IBAction func backButton(_ sender: Any) {
        if isConverting || isUploading {
            showAlert(title: "In Progress", message: "Please wait, upload/conversion in progress")
            return
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitButton(_ sender: Any) {
        ChapterName.resignFirstResponder()
        topicName.resignFirstResponder()

        guard !isUploading else {
            showAlert(title: "Please Wait", message: "Upload already in progress")
            return
        }

        guard let token = SessionManager.useRoleToken else {
            showAlert(title: "Error", message: "Token missing")
            return
        }

        // File size / compression check — same logic as AddFeedVC
        if let url = resolvedFileURL() {
            let fileExtension = url.pathExtension.lowercased()

            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attrs[.size] as? UInt64 ?? 0
                print("📊 Original file size: \(fileSize) bytes (\(fileSize / 1024) KB)")

                if isVideoFile(url: url) && fileSize > MAX_VIDEO_SIZE_BYTES {
                    compressVideo(sourceURL: url, token: token)
                    return
                } else if isImageFile(fileExtension: fileExtension) && fileSize > MAX_FILE_SIZE_BYTES {
                    compressImage(sourceURL: url, token: token)
                    return
                } else if !isVideoFile(url: url) && !isImageFile(fileExtension: fileExtension)
                            && fileSize > MAX_FILE_SIZE_BYTES {
                    showAlert(title: "File Too Large",
                              message: "File size must be less than 500KB. Please compress your file.")
                    return
                }
            } catch {
                print("Error getting file size: \(error)")
            }
        }

        uploadNotes(token: token)
    }

    @IBAction func chapterAddButton(_ sender: Any) { ChapterName.becomeFirstResponder() }
    @IBAction func topicAddButton(_ sender: Any)   { topicName.becomeFirstResponder() }

    @IBAction func removeImageButtonAction(_ sender: Any) {
        contentImage.image = nil
        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true
        documentURL = nil
        vidUrl = nil
        image = nil
        finalURL = nil
        customParentViewController?.view.layoutIfNeeded()
    }

    @IBAction func imageButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add Image", message: "Please select an action.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default) { _ in
            self.showConfirmationAlert(for: "Take a Photo")
        })
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showConfirmationAlert(for: "Choose from Library")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func videoButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add Video", message: "Please select an action.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Record a Video", style: .default) { _ in
            self.showConfirmationAlertForVideo(for: "Record a Video")
        })
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showConfirmationAlertForVideo(for: "Choose from Library")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func youTubeButtonAction(_ sender: Any) { showTextFieldAlert() }

    @IBAction func docButtonAction(_ sender: Any) { openDocumentPicker() }

    @IBAction func audioButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add Audio", message: "Please select an action.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Record an Audio", style: .default) { _ in
            self.showAudioConfirmationAlert(for: "Record an Audio")
        })
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.showAudioConfirmationAlert(for: "Choose from Library")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Resolve Final File URL

    /// Returns the single URL that should be uploaded, honouring image/video/doc priority.
    private func resolvedFileURL() -> URL? {
        if let img = image {
            return saveImageToDocumentsDirectory(image: img)
        } else if let vid = vidUrl {
            return vid
        } else if let doc = documentURL {
            // YouTube links are not file URLs — skip size checks for them
            let s = doc.absoluteString.lowercased()
            if s.contains("youtube.com") || s.contains("youtu.be") { return nil }
            return doc
        }
        return nil
    }

    // MARK: - Image Compression (same as AddFeedVC)

    private func compressImage(sourceURL: URL, token: String) {
        isUploading = true
        showLoading(message: "Compressing image...")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            if let imageData = try? Data(contentsOf: sourceURL),
               let img = UIImage(data: imageData) {

                var compressedData: Data?
                var quality: CGFloat = 0.8

                while quality > 0.1 {
                    if let jpeg = img.jpegData(compressionQuality: quality),
                       jpeg.count <= self.MAX_FILE_SIZE_BYTES {
                        compressedData = jpeg
                        break
                    }
                    quality -= 0.1
                }

                if compressedData == nil || (compressedData?.count ?? 0) > self.MAX_FILE_SIZE_BYTES {
                    let newSize = CGSize(width: img.size.width * 0.5, height: img.size.height * 0.5)
                    UIGraphicsBeginImageContext(newSize)
                    img.draw(in: CGRect(origin: .zero, size: newSize))
                    let resized = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    compressedData = resized?.jpegData(compressionQuality: 0.7)
                }

                DispatchQueue.main.async {
                    self.hideLoading()

                    if let finalData = compressedData, finalData.count <= self.MAX_FILE_SIZE_BYTES {
                        print("✅ Image compressed: \(finalData.count) bytes")
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent("compressed_\(UUID().uuidString).jpg")
                        try? finalData.write(to: tempURL)
                        // Replace source so uploadNotes picks it up
                        self.image = nil
                        self.documentURL = tempURL
                        self.uploadNotes(token: token)
                    } else {
                        self.isUploading = false
                        self.showAlert(title: "Error",
                                       message: "Could not compress image to under 500KB. Please choose a smaller image.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.isUploading = false
                    self.showAlert(title: "Error", message: "Could not process image")
                }
            }
        }
    }

    // MARK: - Video Compression (same as AddFeedVC)

    private func compressVideo(sourceURL: URL, token: String) {
        isConverting = true
        isUploading = true
        showLoading(message: "Compressing video...\nThis may take a moment")

        let asset = AVAsset(url: sourceURL)
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("compressed_\(UUID().uuidString)")
            .appendingPathExtension("mp4")

        try? FileManager.default.removeItem(at: outputURL)

        let preset = AVAssetExportPresetLowQuality

        guard AVAssetExportSession.exportPresets(compatibleWith: asset).contains(preset),
              let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
            isConverting = false
            isUploading = false
            hideLoading()
            showAlert(title: "Error", message: "Cannot compress this video format")
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isConverting = false

                switch exportSession.status {
                case .completed:
                    do {
                        let attrs = try FileManager.default.attributesOfItem(atPath: outputURL.path)
                        let fileSize = attrs[.size] as? UInt64 ?? 0
                        print("✅ Compressed video: \(fileSize / 1024) KB")

                        if fileSize <= self.MAX_VIDEO_SIZE_BYTES {
                            self.vidUrl = nil
                            self.documentURL = outputURL
                            self.uploadNotes(token: token)
                        } else {
                            self.hideLoading()
                            self.isUploading = false
                            self.showAlert(title: "Video Too Large",
                                           message: "Even after compression, video is \(fileSize / 1024)KB. Please choose a shorter video.")
                        }
                    } catch {
                        self.hideLoading()
                        self.isUploading = false
                        self.showAlert(title: "Error", message: "Failed to get compressed video size")
                    }

                case .failed:
                    self.hideLoading()
                    self.isUploading = false
                    self.showAlert(title: "Compression Failed", message: "Could not compress video. Please try a shorter video.")

                default:
                    self.hideLoading()
                    self.isUploading = false
                    self.showAlert(title: "Compression Failed", message: "Video compression failed")
                }
            }
        }
    }

    // MARK: - Upload Notes (same multipart pattern as AddFeedVC)

    func uploadNotes(token: String) {
        isUploading = true
        showLoading(message: "Uploading...")

        let urlString = "https://backend.gc2.co.in/api/v1/notes"
        guard let url = URL(string: urlString) else {
            hideLoading()
            isUploading = false
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        let params: [String: String] = [
            "classId": classId,
            "subjectId": subjectId,
            "chapterId": "1",
            "title": ChapterName.text ?? "",
            "description": topicName.text ?? "",
            "groupAcademicYearId": groupAcademicYearId
        ]

        var body = Data()

        // Parameters
        for (key, value) in params {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        // Resolve the file to attach
        var attachURL: URL? = nil
        if let img = image {
            attachURL = saveImageToDocumentsDirectory(image: img)
        } else if let vid = vidUrl {
            attachURL = vid
        } else if let doc = documentURL {
            let s = doc.absoluteString.lowercased()
            if s.contains("youtube.com") || s.contains("youtu.be") {
                // YouTube: send as videoUrl param instead of file attachment
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"videoUrl\"\r\n\r\n")
                body.appendString("\(doc.absoluteString)\r\n")
                attachURL = nil
            } else {
                attachURL = doc
            }
        }

        // File attachment
        if let fileURL = attachURL {
            let mimeType = getMimeType(for: fileURL)
            let fileName = fileURL.lastPathComponent

            if let fileData = try? Data(contentsOf: fileURL) {
                let fileSizeKB = fileData.count / 1024
                print("📊 Attaching: \(fileName) | \(mimeType) | \(fileSizeKB) KB")

                // Final size guard
                let sizeOK = isVideoFile(url: fileURL)
                    ? fileData.count <= MAX_VIDEO_SIZE_BYTES
                    : fileData.count <= MAX_FILE_SIZE_BYTES

                guard sizeOK else {
                    hideLoading()
                    isUploading = false
                    showAlert(title: "File Too Large",
                              message: "File is \(fileSizeKB)KB. Max: \(MAX_FILE_SIZE_BYTES/1024)KB for images/docs, \(MAX_VIDEO_SIZE_BYTES/1024)KB for videos.")
                    return
                }

                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"attachmentLinks\"; filename=\"\(fileName)\"\r\n")
                body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                body.append(fileData)
                body.appendString("\r\n")
            } else {
                hideLoading()
                isUploading = false
                showAlert(title: "Error", message: "Could not read file data")
                return
            }
        }

        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                self.isUploading = false

                if let error = error {
                    print("❌ Error:", error.localizedDescription)
                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    return
                }

                guard let data = data else {
                    self.showAlert(title: "Upload Failed", message: "No response from server")
                    return
                }

                let responseString = String(decoding: data, as: UTF8.self)
                print("📩 RAW RESPONSE:", responseString)

                // Check for server-side size rejection
                if responseString.contains("<html") ||
                   responseString.contains("413 Request Entity Too Large") {
                    self.showAlert(title: "Upload Failed",
                                   message: "File too large for server. Please compress more.")
                    return
                }

                // Parse JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            self.clearForm()
                            if let previousVC = self.navigationController?.viewControllers
                                .dropLast().last as? SubDetailsVC {
                                previousVC.fetchNotes()
                            }
                            self.showAlert(title: "Success", message: "Note uploaded successfully") {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else if let message = json["message"] as? String {
                            self.showAlert(title: "Upload Failed", message: message)
                        } else {
                            // Fallback: treat any parseable JSON as success
                            self.clearForm()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } catch {
                    print("❌ Decoding Error:", error)
                    // Original decoder path
                    if let decoded = try? JSONDecoder().decode(AddNoteResponse.self, from: data) {
                        print("✅ Decoded:", decoded)
                        self.clearForm()
                        if let previousVC = self.navigationController?.viewControllers
                            .dropLast().last as? SubDetailsVC {
                            previousVC.fetchNotes()
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showAlert(title: "Upload Failed", message: "Failed to parse server response")
                    }
                }
            }
        }.resume()
    }

    // MARK: - Media Picker Helpers

    func submitFeedInfo() {
        if let img = image {
            finalURL = saveImageToDocumentsDirectory(image: img)
        } else if let youtubeText = pdfNameLabel.text, !youtubeText.isEmpty,
                  isValidYouTubeURL(youtubeText) {
            finalURL = URL(string: youtubeText) ?? URL(fileURLWithPath: "")
        } else if let vid = vidUrl {
            finalURL = vid
            image = contentImage.image
        } else if let doc = documentURL {
            finalURL = doc
        }
        assignFinalUrl(finalUrl: finalURL ?? URL(fileURLWithPath: ""))
    }

    private func saveImageToDocumentsDirectory(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    private func openMediaPicker(for type: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        if type == "image" {
            imagePicker.mediaTypes = [UTType.image.identifier]
        } else if type == "video" {
            imagePicker.mediaTypes = [UTType.movie.identifier]
        }
        present(imagePicker, animated: true)
        submitFeedInfo()
    }

    private func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    private func showConfirmationAlert(for option: String) {
        let alert = UIAlertController(title: "Confirm Action",
                                      message: "Are you sure you want to \(option.lowercased())?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.handleOptionSelection(option)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func handleOptionSelection(_ option: String) {
        if option == "Take a Photo" { openCamera() }
        else if option == "Choose from Library" { openMediaPicker(for: "image") }
    }

    private func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    private func showConfirmationAlertForVideo(for option: String) {
        let alert = UIAlertController(title: "Confirm Action",
                                      message: "Are you sure you want to \(option.lowercased())?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.handleOptionSelectionForVideo(option)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func handleOptionSelectionForVideo(_ option: String) {
        if option == "Record a Video" { openVideoRecorder() }
        else if option == "Choose from Library" { openMediaPicker(for: "video") }
    }

    private func openVideoRecorder() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    private func showAudioConfirmationAlert(for option: String) {
        let alert = UIAlertController(title: "Confirm Action",
                                      message: "Are you sure you want to \(option.lowercased())?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.handleAudioOptionSelection(option)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func handleAudioOptionSelection(_ option: String) {
        if option == "Record an Audio" { openAudioRecorder() }
        else if option == "Choose from Library" { openAudioLibrary() }
    }

    private func openAudioRecorder() {
        print("Audio recorder functionality goes here.")
    }

    private func openAudioLibrary() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    private func showTextFieldAlert() {
        let alertController = UIAlertController(title: "Add YouTube Link",
                                                message: "Please insert below.",
                                                preferredStyle: .alert)
        alertController.addTextField { $0.placeholder = "Type here..." }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let text = alertController.textFields?.first?.text, !text.isEmpty {
                if self.isValidYouTubeURL(text) {
                    self.pdfNameLabel.text = text
                    self.pdfNameLabel.isHidden = false
                    self.documentURL = URL(string: text)
                    self.submitFeedInfo()
                } else {
                    let invalid = UIAlertController(title: "Invalid URL",
                                                    message: "Please enter a valid YouTube URL.",
                                                    preferredStyle: .alert)
                    invalid.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(invalid, animated: true)
                }
            } else {
                self.pdfNameLabel.text = "No text entered."
            }
        }
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func isValidYouTubeURL(_ urlString: String) -> Bool {
        let regex = "^(https?://)?(www\\.)?(youtube|youtu|youtube-nocookie)\\.(com|be)/(watch\\?v=|embed\\/|v\\/|.+\\/videos\\/|shorts\\/)([a-zA-Z0-9_-]{11})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: urlString)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let selectedImage = info[.originalImage] as? UIImage {
            contentImage.image = selectedImage
            image = selectedImage
            vidUrl = nil
            documentURL = nil
            submitFeedInfo()
            contentCancel.isHidden = false
            pdfNameLabel.isHidden = true
            customParentViewController?.view.layoutIfNeeded()
        } else if let videoURL = info[.mediaURL] as? URL {
            contentImage.image = generateThumbnail(for: videoURL)
            vidUrl = videoURL
            image = nil
            documentURL = nil
            submitFeedInfo()
            contentCancel.isHidden = false
            pdfNameLabel.isHidden = true
            customParentViewController?.view.layoutIfNeeded()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else { return }
        documentURL = pickedURL
        image = nil
        vidUrl = nil
        contentImage.image = UIImage(systemName: "doc.fill")?.withTintColor(.black)
        submitFeedInfo()
        contentCancel.isHidden = false
        pdfNameLabel.isHidden = false
        pdfNameLabel.text = pickedURL.lastPathComponent
        customParentViewController?.view.layoutIfNeeded()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }

    // MARK: - File Type Helpers (same as AddFeedVC)

    private func isVideoFile(url: URL) -> Bool {
        let videoExtensions = ["mov", "mp4", "avi", "m4v", "wmv", "flv", "mkv", "webm", "3gp", "mpeg", "mpg"]
        return videoExtensions.contains(url.pathExtension.lowercased())
    }

    private func isImageFile(fileExtension: String) -> Bool {
        return ["jpg", "jpeg", "png", "heic", "gif"].contains(fileExtension.lowercased())
    }

    private func getMimeType(for url: URL) -> String {
        let mimeTypes: [String: String] = [
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "gif": "image/gif",
            "heic": "image/jpeg",
            "mp4": "video/mp4",
            "mov": "video/mp4",
            "pdf": "application/pdf",
            "mp3": "audio/mpeg"
        ]
        return mimeTypes[url.pathExtension.lowercased()] ?? "application/octet-stream"
    }

    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }

    // MARK: - Loading / Alert Helpers (same as AddFeedVC)

    private func showLoading(message: String = "Processing...") {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        alert.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])
        present(alert, animated: true)
    }

    private func hideLoading() {
        if presentedViewController is UIAlertController {
            dismiss(animated: true)
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        if presentedViewController is UIAlertController {
            dismiss(animated: false) { [weak self] in
                self?.presentAlert(title: title, message: message, completion: completion)
            }
        } else {
            presentAlert(title: title, message: message, completion: completion)
        }
    }

    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }

    // MARK: - Delegate stubs

    func assignFinalUrl(finalUrl: URL) {
        guard finalUrl.absoluteString != "file:///" else {
            print("⚠️ Invalid file URL assigned.")
            return
        }
        self.documentURL = finalUrl
    }

    func assignPostName(postName: String)             { self.postName = postName }
    func assignPostDescription(postDescription: String) { self.postDescription = postDescription }
}

// MARK: - UITextFieldDelegate

extension AddChapterVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { return true }
}

