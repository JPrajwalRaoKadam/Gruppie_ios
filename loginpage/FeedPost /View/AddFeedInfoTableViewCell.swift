//
//  AddFeedInfoTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 16/01/25.
//

import UIKit
import MobileCoreServices
import AVKit
import UniformTypeIdentifiers
import PhotosUI

enum fileType : String {
    case image      = "image"
    case youtube    = "youtube"
    case pdf        = "pdf"
    case video      = "video"
    case audio      = "audio"
    case none       = ""
}

protocol AddFeedInfoCellDelegate: AnyObject {
    func assignPostName(postName: String)
    func assignPostDescription(postDescription: String)
    func assignFinalUrl(finalUrl: URL)
}


class AddFeedInfoTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UITextFieldDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    
    @IBOutlet weak var postNAme: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var contentSelectionView: UIView!
    @IBOutlet weak var dataViewHeightCn: NSLayoutConstraint!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var mainViewHtCn: NSLayoutConstraint!
    @IBOutlet weak var shareClassLabelHeightcn: NSLayoutConstraint!
    
    @IBOutlet weak var contentImage: UIImageView!
    
    @IBOutlet weak var contentCancel: UIButton!
    @IBOutlet weak var pdfNameLabel: UILabel!
    
    weak var delegate: AddFeedInfoCellDelegate?
    
    var selectAssets = [PHAsset]()
    var filename = [String]()
    var localfilePath = [URL]()
    var localPdfFilePath = [URL]()
    var localVideofilePath = [URL]()
    var localAudiofilePath = [URL]()
    // Kanika
    var localThumbfilePath = [URL]()
    var filetype = fileType.none.rawValue
    
    var postNameText: String = ""
    var postDescriptionText: String = ""
    var image: UIImage?
    var finalURL: URL?
    
    var parentViewController: UIViewController? // Reference to the view controller
    private var documentURL: URL?
    private var vidUrl: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postNAme.delegate = self
        textView.delegate = self
        
        print("lololllll: \(postNAme.text)")
        print("lololllll2: \(postNameText)")
        // Disable the gray background on selection
        self.selectionStyle = .none
        
        contentSelectionView.layer.cornerRadius = 10
        contentStackView.layer.cornerRadius = 10
        dataView.layer.cornerRadius = 10
        contentImage.layer.cornerRadius = 10
        textView.layer.cornerRadius = 5
        //        dataViewHeightCn.constant = 0
        //        mainViewHtCn.constant = 300
        
        // Initially hide the cancel button and document name
        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true
    }

    func submitFeedInfo() {
        print("➡️ submitFeedInfo() called")
        print("📸 Image: \(image != nil ? "Available" : "nil")")
        print("📄 Document URL: \(documentURL?.absoluteString ?? "nil")")
        print("📹 Video URL: \(vidUrl?.absoluteString ?? "nil")")
        print("🔗 YouTube URL: \(pdfNameLabel.text ?? "nil")")
        
        finalURL = nil // Clear previous
        filetype = fileType.none.rawValue

        // 1️⃣ Priority: YouTube Link
        if let youtubeURL = pdfNameLabel.text, !youtubeURL.isEmpty, isValidYouTubeURL(youtubeURL) {
            print("✅ Using YouTube URL")
            finalURL = URL(string: youtubeURL)
            filetype = fileType.youtube.rawValue

        // 2️⃣ Priority: Video
        } else if let videoUrl = self.vidUrl {
            print("✅ Using Video URL")
            finalURL = videoUrl
            image = contentImage.image // Also assign thumbnail image
            filetype = fileType.video.rawValue

        // 3️⃣ Priority: Image
        } else if let image = image {
            print("✅ Using Image")
            if let imageURL = saveImageToDocumentsDirectory(image: image) {
                finalURL = imageURL
                filetype = fileType.image.rawValue
            }

        // 4️⃣ Priority: Document (PDF or others)
        } else if let documentURL = documentURL {
            print("✅ Using Document URL")
            finalURL = documentURL
            filetype = fileType.pdf.rawValue
        }

        // Fallback
        if finalURL == nil {
            print("⚠️ No valid content selected.")
            finalURL = URL(fileURLWithPath: "")
            filetype = fileType.none.rawValue
        }

        delegate?.assignFinalUrl(finalUrl: finalURL!)
        print("📦 Final URL: \(finalURL!.absoluteString)")
        print("📝 Filetype: \(filetype)")
    }


    
    // Function to save image to documents directory and return its URL
    private func saveImageToDocumentsDirectory(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    
    private func openMediaPicker(for type: String) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = type == "video" ? .videos : .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        parentViewController?.present(picker, animated: true)
    }


    
    private func openDocumentPicker() {
        // Allow access to all file types
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        parentViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func removeImageButtonAction(_ sender: Any) {
        // Clear the content image and hide the cancel button
        contentImage.image = nil
        contentCancel.isHidden = true
        
        // Hide document name
        pdfNameLabel.isHidden = true
        documentURL = nil
        
        parentViewController?.view.layoutIfNeeded()
    }
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        // First Alert with two options
        let alert = UIAlertController(title: "Add Image", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.showConfirmationAlert(for: "Take a Photo")
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showConfirmationAlert(for: "Choose from Library")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func showConfirmationAlert(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleOptionSelection(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the confirmation alert
        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func handleOptionSelection(_ option: String) {
        // Perform the specific action for the selected option
        if option == "Take a Photo" {
            print("Take a photo selected. Opening camera...")
            openCamera()
        } else if option == "Choose from Library" {
            print("Choose from library selected. Opening photo library...")
            openMediaPicker(for: "image")
        }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "This device does not support camera access.")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentImageCamera()
                    } else {
                        self.showAlert(title: "Camera Access Denied", message: "Please allow camera access in Settings.")
                    }
                }
            }
        case .authorized:
            presentImageCamera()
        case .denied, .restricted:
            showAlert(title: "Camera Access Denied", message: "Please enable camera permissions in Settings.")
        @unknown default:
            showAlert(title: "Error", message: "Unknown camera permission status.")
        }
    }

    private func presentImageCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [UTType.image.identifier] // correct UTType
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func videoButtonActon(_ sender: UIButton) {
        // First Alert with two options
        let alert = UIAlertController(title: "Add Video", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Record a Video", style: .default, handler: { _ in
            self.showConfirmationAlertForVideo(for: "Record a Video")
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showConfirmationAlertForVideo(for: "Choose from Library")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func showConfirmationAlertForVideo(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleOptionSelectionForVideo(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the confirmation alert
        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func handleOptionSelectionForVideo(_ option: String) {
        // Perform the specific action for the selected option
        if option == "Record a Video" {
            print("Record a video selected. Opening camera...")
            openVideoRecorder()
        } else if option == "Choose from Library" {
            print("Choose from library selected. Opening photo library...")
            openMediaPicker(for: "video")
        }
    }
    
    private func openVideoRecorder() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable", message: "This device does not support camera access.")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentVideoRecorder()
                    } else {
                        self.showAlert(title: "Camera Access Denied", message: "Please allow camera access in Settings.")
                    }
                }
            }
        case .authorized:
            presentVideoRecorder()
        case .denied, .restricted:
            showAlert(title: "Camera Access Denied", message: "Please enable camera permissions in Settings.")
        @unknown default:
            showAlert(title: "Error", message: "Unknown camera permission status.")
        }
    }

    private func presentVideoRecorder() {
        let videoPicker = UIImagePickerController()
        videoPicker.sourceType = .camera
        videoPicker.mediaTypes = [UTType.movie.identifier] // correct UTType
        videoPicker.videoQuality = .typeMedium
        videoPicker.delegate = self
        videoPicker.allowsEditing = false
        parentViewController?.present(videoPicker, animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        parentViewController?.present(alert, animated: true)
    }

    
    @IBAction func audioButtonAction(_ sender: Any) {
        // First Alert with two options
        let alert = UIAlertController(title: "Add Audio", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Record an Audio", style: .default, handler: { _ in
            self.showAudioConfirmationAlert(for: "Record an Audio")
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showAudioConfirmationAlert(for: "Choose from Library")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func showAudioConfirmationAlert(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleAudioOptionSelection(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the confirmation alert
        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func handleAudioOptionSelection(_ option: String) {
        // Perform the specific action for the selected option
        if option == "Record an Audio" {
            print("Record an audio selected. Opening audio recorder...")
            openAudioRecorder()
        } else if option == "Choose from Library" {
            print("Choose from library selected. Opening audio library...")
            openAudioLibrary()
        }
    }
    
    private func openAudioRecorder() {
        showAlert(title: "Coming Soon", message: "Audio recording is not implemented yet.")
    }
    
    private func openAudioLibrary() {
        // Code to open the library for audio selection
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        parentViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func youTibeAction(_ sender: Any) {
        showTextFieldAlert()
    }
    
    private func showTextFieldAlert() {
        // Create the alert controller
        let alertController = UIAlertController(
            title: "Add YouTube Link",
            message: "Please insert below.",
            preferredStyle: .alert
        )
        
        // Add a text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = "Type here..."
        }
        
        // Add "Add" action
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            // Get the text from the text field
            if let textField = alertController.textFields?.first,
               let enteredText = textField.text, !enteredText.isEmpty {
                
                // Validate if the entered text is a valid YouTube URL
                if self.isValidYouTubeURL(enteredText) {
                    self.pdfNameLabel.text = enteredText // Assign to the label
                    self.submitFeedInfo()
                } else {
                    // Show an alert for invalid YouTube URL
                    let invalidAlert = UIAlertController(
                        title: "Invalid URL",
                        message: "Please enter a valid YouTube URL.",
                        preferredStyle: .alert
                    )
                    invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.parentViewController?.present(invalidAlert, animated: true, completion: nil)
                }
            } else {
                self.pdfNameLabel.text = "No text entered."
            }
        }
        
        // Add "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    // Helper function to validate YouTube URL
    private func isValidYouTubeURL(_ urlString: String) -> Bool {
        // Regular expression for a basic YouTube URL validation
        let youtubeRegex = "^(https?://)?(www\\.)?(youtube|youtu|youtube-nocookie)\\.(com|be)/(watch\\?v=|embed\\/|v\\/|.+\\/videos\\/|shorts\\/)([a-zA-Z0-9_-]{11})$"
        let youtubePredicate = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubePredicate.evaluate(with: urlString)
    }
    
    @IBAction func docButtonAction(_ sender: Any) {
        openDocumentPicker()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            print("Picked an image")
            contentImage.image = selectedImage
            image = selectedImage
            vidUrl = nil
            documentURL = nil
            pdfNameLabel.text = nil

            submitFeedInfo()
            contentCancel.isHidden = false
            pdfNameLabel.isHidden = true

        } else if let mediaType = info[.mediaType] as? String, mediaType == "public.movie" {
            print("Media type is video")

            if let mediaURL = info[.mediaURL] as? URL {
                // Video picked from Files or recorded
                print("Picked video URL: \(mediaURL)")
                contentImage.image = generateThumbnail(for: mediaURL)
                vidUrl = mediaURL
                image = contentImage.image
                documentURL = nil
                pdfNameLabel.text = nil

                submitFeedInfo()
                contentCancel.isHidden = false
                pdfNameLabel.isHidden = true

            } else if let refURL = info[.referenceURL] as? URL {
                // Video picked from Photos library (asset URL)
                print("Picked reference URL: \(refURL)")
                fetchVideoURLFromPhotoLibrary(refURL: refURL)
            }

        } else {
            print("⚠️ Neither image nor video was selected.")
        }

        parentViewController?.view.layoutIfNeeded()
    }

    private func fetchVideoURLFromPhotoLibrary(refURL: URL) {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let assets = PHAsset.fetchAssets(withALAssetURLs: [refURL], options: options)

        guard let asset = assets.firstObject else {
            print("❌ Failed to fetch asset for reference URL")
            return
        }

        let manager = PHImageManager.default()
        let videoOptions = PHVideoRequestOptions()
        videoOptions.deliveryMode = .highQualityFormat

        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, audioMix, info in
            if let urlAsset = avAsset as? AVURLAsset {
                let localVideoUrl = urlAsset.url
                print("✅ Got local video URL from library: \(localVideoUrl)")

                DispatchQueue.main.async {
                    self.contentImage.image = self.generateThumbnail(for: localVideoUrl)
                    self.vidUrl = localVideoUrl
                    self.image = self.contentImage.image
                    self.documentURL = nil
                    self.pdfNameLabel.text = nil
                    self.submitFeedInfo()
                    self.contentCancel.isHidden = false
                    self.pdfNameLabel.isHidden = true
                }
            } else {
                print("❌ Failed to get AVURLAsset from PHAsset")
            }
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
          picker.dismiss(animated: true)

          guard let itemProvider = results.first?.itemProvider else { return }

          if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
              itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                  guard let url = url else { return }
                  let fileName = UUID().uuidString + ".mov"
                  let destURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

                  do {
                      try FileManager.default.copyItem(at: url, to: destURL)
                      DispatchQueue.main.async {
                          self.vidUrl = destURL
                          self.contentImage.image = self.generateThumbnail(for: destURL)
                          self.image = self.contentImage.image
                          self.submitFeedInfo()
                          self.contentCancel.isHidden = false
                          self.pdfNameLabel.isHidden = true
                      }
                  } catch {
                      print("❌ Failed to copy video file: \(error)")
                  }
              }
          } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
              itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                  DispatchQueue.main.async {
                      if let selectedImage = image as? UIImage {
                          self.image = selectedImage
                          self.contentImage.image = selectedImage
                          self.vidUrl = nil
                          self.submitFeedInfo()
                          self.contentCancel.isHidden = false
                          self.pdfNameLabel.isHidden = true
                      }
                  }
              }
          }
      }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentURL = urls.first else { return }
        
        self.documentURL = documentURL
        
        //        dataViewHeightCn.constant = 150
        //        mainViewHtCn.constant = 448
        
        // Set the document image to a black icon
        contentImage.image = UIImage(systemName: "doc.fill")?.withTintColor(.black) // Set a black doc icon
        submitFeedInfo()
        contentCancel.isHidden = false
        pdfNameLabel.isHidden = false
        pdfNameLabel.text = documentURL.lastPathComponent
        
        parentViewController?.view.layoutIfNeeded()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Helper method to generate a thumbnail for video
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.postNameText = textField.text ?? ""
        delegate?.assignPostName(postName: postNameText)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
            self.postDescriptionText = textView.text
        delegate?.assignPostDescription(postDescription: postDescriptionText)
    }
    
}


