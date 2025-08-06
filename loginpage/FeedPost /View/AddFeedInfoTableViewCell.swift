////
////  AddFeedInfoTableViewCell.swift
////  loginpage
////
////  Created by Prajwal rao Kadam J on 16/01/25.
////
//
//import UIKit
//import MobileCoreServices
//import AVKit
//import UniformTypeIdentifiers
//import PhotosUI
//
//enum fileType : String {
//    case image      = "image"
//    case youtube    = "youtube"
//    case pdf        = "pdf"
//    case video      = "video"
//    case audio      = "audio"
//    case none       = ""
//}
//
//protocol AddFeedInfoCellDelegate: AnyObject {
//    func assignPostName(postName: String)
//    func assignPostDescription(postDescription: String)
//    func assignFinalUrl(finalUrl: URL)
//}
//
//
//class AddFeedInfoTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UITextFieldDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
//    
//    
//    @IBOutlet weak var postNAme: UITextField!
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var contentStackView: UIStackView!
//    @IBOutlet weak var contentSelectionView: UIView!
//    @IBOutlet weak var dataViewHeightCn: NSLayoutConstraint!
//    @IBOutlet weak var dataView: UIView!
//    @IBOutlet weak var imageButton: UIButton!
//    @IBOutlet weak var videoButton: UIButton!
//    @IBOutlet weak var docButton: UIButton!
//    @IBOutlet weak var mainViewHtCn: NSLayoutConstraint!
//    @IBOutlet weak var shareClassLabelHeightcn: NSLayoutConstraint!
//    
//    @IBOutlet weak var contentImage: UIImageView!
//    
//    @IBOutlet weak var contentCancel: UIButton!
//    @IBOutlet weak var pdfNameLabel: UILabel!
//    
//    weak var delegate: AddFeedInfoCellDelegate?
//    
//    var selectAssets = [PHAsset]()
//    var filename = [String]()
//    var localfilePath = [URL]()
//    var localPdfFilePath = [URL]()
//    var localVideofilePath = [URL]()
//    var localAudiofilePath = [URL]()
//    // Kanika
//    var localThumbfilePath = [URL]()
//    var filetype = fileType.none.rawValue
//    
//    var postNameText: String = ""
//    var postDescriptionText: String = ""
//    var image: UIImage?
//    var finalURL: URL?
//    
//    var parentViewController: UIViewController? // Reference to the view controller
//    private var documentURL: URL?
//    private var vidUrl: URL?
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        postNAme.delegate = self
//        textView.delegate = self
//        
//        print("lololllll: \(postNAme.text)")
//        print("lololllll2: \(postNameText)")
//        // Disable the gray background on selection
//        self.selectionStyle = .none
//        
//        contentSelectionView.layer.cornerRadius = 10
//        contentStackView.layer.cornerRadius = 10
//        dataView.layer.cornerRadius = 10
//        contentImage.layer.cornerRadius = 10
//        textView.layer.cornerRadius = 5
//        //        dataViewHeightCn.constant = 0
//        //        mainViewHtCn.constant = 300
//        
//        // Initially hide the cancel button and document name
//        contentCancel.isHidden = true
//        pdfNameLabel.isHidden = true
//    }
//
//    func submitFeedInfo() {
//        print("➡️ submitFeedInfo() called")
//        print("📸 Image: \(image != nil ? "Available" : "nil")")
//        print("📄 Document URL: \(documentURL?.absoluteString ?? "nil")")
//        print("📹 Video URL: \(vidUrl?.absoluteString ?? "nil")")
//        print("🔗 YouTube URL: \(pdfNameLabel.text ?? "nil")")
//        
//        finalURL = nil // Clear previous
//        filetype = fileType.none.rawValue
//
//        // 1️⃣ Priority: YouTube Link
//        if let youtubeURL = pdfNameLabel.text, !youtubeURL.isEmpty, isValidYouTubeURL(youtubeURL) {
//            print("✅ Using YouTube URL")
//            finalURL = URL(string: youtubeURL)
//            filetype = fileType.youtube.rawValue
//
//        // 2️⃣ Priority: Video
//        } else if let videoUrl = self.vidUrl {
//            print("✅ Using Video URL")
//            finalURL = videoUrl
//            image = contentImage.image // Also assign thumbnail image
//            filetype = fileType.video.rawValue
//
//        // 3️⃣ Priority: Image
//        } else if let image = image {
//            print("✅ Using Image")
//            if let imageURL = saveImageToDocumentsDirectory(image: image) {
//                finalURL = imageURL
//                filetype = fileType.image.rawValue
//            }
//
//        // 4️⃣ Priority: Document (PDF or others)
//        } else if let documentURL = documentURL {
//            print("✅ Using Document URL")
//            finalURL = documentURL
//            filetype = fileType.pdf.rawValue
//        }
//
//        // Fallback
//        if finalURL == nil {
//            print("⚠️ No valid content selected.")
//            finalURL = URL(fileURLWithPath: "")
//            filetype = fileType.none.rawValue
//        }
//
//        delegate?.assignFinalUrl(finalUrl: finalURL!)
//        print("📦 Final URL: \(finalURL!.absoluteString)")
//        print("📝 Filetype: \(filetype)")
//    }
//
//
//    
//    // Function to save image to documents directory and return its URL
//    private func saveImageToDocumentsDirectory(image: UIImage) -> URL? {
//        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
//        let filename = UUID().uuidString + ".jpg"
//        
//        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
//        
//        do {
//            try data.write(to: fileURL)
//            return fileURL
//        } catch {
//            print("Error saving image: \(error)")
//            return nil
//        }
//    }
//    
//    
//    private func openMediaPicker(for type: String) {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = type == "video" ? .videos : .images
//
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        parentViewController?.present(picker, animated: true)
//    }
//
//
//    
//    private func openDocumentPicker() {
//        // Allow access to all file types
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        parentViewController?.present(documentPicker, animated: true, completion: nil)
//    }
//    
//    
//    @IBAction func removeImageButtonAction(_ sender: Any) {
//        // Clear the content image and hide the cancel button
//        contentImage.image = nil
//        contentCancel.isHidden = true
//        
//        // Hide document name
//        pdfNameLabel.isHidden = true
//        documentURL = nil
//        
//        parentViewController?.view.layoutIfNeeded()
//    }
//    
//    @IBAction func imageButtonAction(_ sender: UIButton) {
//        // First Alert with two options
//        let alert = UIAlertController(title: "Add Image", message: "Please select an action.", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
//            self.showConfirmationAlert(for: "Take a Photo")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
//            self.showConfirmationAlert(for: "Choose from Library")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the alert
//        parentViewController?.present(alert, animated: true, completion: nil)
//    }
//    
//    private func showConfirmationAlert(for option: String) {
//        // Second Alert for Confirmation
//        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
//        
//        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            self.handleOptionSelection(option)
//        }))
//        
//        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the confirmation alert
//        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
//    }
//    
//    private func handleOptionSelection(_ option: String) {
//        // Perform the specific action for the selected option
//        if option == "Take a Photo" {
//            print("Take a photo selected. Opening camera...")
//            openCamera()
//        } else if option == "Choose from Library" {
//            print("Choose from library selected. Opening photo library...")
//            openMediaPicker(for: "image")
//        }
//    }
//    
//    private func openCamera() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            showAlert(title: "Camera Unavailable", message: "This device does not support camera access.")
//            return
//        }
//
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        self.presentImageCamera()
//                    } else {
//                        self.showAlert(title: "Camera Access Denied", message: "Please allow camera access in Settings.")
//                    }
//                }
//            }
//        case .authorized:
//            presentImageCamera()
//        case .denied, .restricted:
//            showAlert(title: "Camera Access Denied", message: "Please enable camera permissions in Settings.")
//        @unknown default:
//            showAlert(title: "Error", message: "Unknown camera permission status.")
//        }
//    }
//
//    private func presentImageCamera() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .camera
//        imagePicker.mediaTypes = [UTType.image.identifier] // correct UTType
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = false
//        parentViewController?.present(imagePicker, animated: true, completion: nil)
//    }
//    
//    @IBAction func videoButtonActon(_ sender: UIButton) {
//        // First Alert with two options
//        let alert = UIAlertController(title: "Add Video", message: "Please select an action.", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Record a Video", style: .default, handler: { _ in
//            self.showConfirmationAlertForVideo(for: "Record a Video")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
//            self.showConfirmationAlertForVideo(for: "Choose from Library")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the alert
//        parentViewController?.present(alert, animated: true, completion: nil)
//    }
//    
//    private func showConfirmationAlertForVideo(for option: String) {
//        // Second Alert for Confirmation
//        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
//        
//        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            self.handleOptionSelectionForVideo(option)
//        }))
//        
//        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the confirmation alert
//        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
//    }
//    
//    private func handleOptionSelectionForVideo(_ option: String) {
//        // Perform the specific action for the selected option
//        if option == "Record a Video" {
//            print("Record a video selected. Opening camera...")
//            openVideoRecorder()
//        } else if option == "Choose from Library" {
//            print("Choose from library selected. Opening photo library...")
//            openMediaPicker(for: "video")
//        }
//    }
//    
//    private func openVideoRecorder() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            showAlert(title: "Camera Unavailable", message: "This device does not support camera access.")
//            return
//        }
//
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        self.presentVideoRecorder()
//                    } else {
//                        self.showAlert(title: "Camera Access Denied", message: "Please allow camera access in Settings.")
//                    }
//                }
//            }
//        case .authorized:
//            presentVideoRecorder()
//        case .denied, .restricted:
//            showAlert(title: "Camera Access Denied", message: "Please enable camera permissions in Settings.")
//        @unknown default:
//            showAlert(title: "Error", message: "Unknown camera permission status.")
//        }
//    }
//
//    private func presentVideoRecorder() {
//        let videoPicker = UIImagePickerController()
//        videoPicker.sourceType = .camera
//        videoPicker.mediaTypes = [UTType.movie.identifier] // correct UTType
//        videoPicker.videoQuality = .typeMedium
//        videoPicker.delegate = self
//        videoPicker.allowsEditing = false
//        parentViewController?.present(videoPicker, animated: true, completion: nil)
//    }
//
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        parentViewController?.present(alert, animated: true)
//    }
//
//    
//    @IBAction func audioButtonAction(_ sender: Any) {
//        // First Alert with two options
//        let alert = UIAlertController(title: "Add Audio", message: "Please select an action.", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Record an Audio", style: .default, handler: { _ in
//            self.showAudioConfirmationAlert(for: "Record an Audio")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
//            self.showAudioConfirmationAlert(for: "Choose from Library")
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the alert
//        parentViewController?.present(alert, animated: true, completion: nil)
//    }
//    
//    private func showAudioConfirmationAlert(for option: String) {
//        // Second Alert for Confirmation
//        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
//        
//        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            self.handleAudioOptionSelection(option)
//        }))
//        
//        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        // Present the confirmation alert
//        parentViewController?.present(confirmationAlert, animated: true, completion: nil)
//    }
//    
//    private func handleAudioOptionSelection(_ option: String) {
//        // Perform the specific action for the selected option
//        if option == "Record an Audio" {
//            print("Record an audio selected. Opening audio recorder...")
//            openAudioRecorder()
//        } else if option == "Choose from Library" {
//            print("Choose from library selected. Opening audio library...")
//            openAudioLibrary()
//        }
//    }
//    
//    private func openAudioRecorder() {
//        showAlert(title: "Coming Soon", message: "Audio recording is not implemented yet.")
//    }
//    
//    private func openAudioLibrary() {
//        // Code to open the library for audio selection
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        parentViewController?.present(documentPicker, animated: true, completion: nil)
//    }
//    
//    @IBAction func youTibeAction(_ sender: Any) {
//        showTextFieldAlert()
//    }
//    
//    private func showTextFieldAlert() {
//        // Create the alert controller
//        let alertController = UIAlertController(
//            title: "Add YouTube Link",
//            message: "Please insert below.",
//            preferredStyle: .alert
//        )
//        
//        // Add a text field to the alert
//        alertController.addTextField { textField in
//            textField.placeholder = "Type here..."
//        }
//        
//        // Add "Add" action
//        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
//            // Get the text from the text field
//            if let textField = alertController.textFields?.first,
//               let enteredText = textField.text, !enteredText.isEmpty {
//                
//                // Validate if the entered text is a valid YouTube URL
//                if self.isValidYouTubeURL(enteredText) {
//                    self.pdfNameLabel.text = enteredText // Assign to the label
//                    self.submitFeedInfo()
//                } else {
//                    // Show an alert for invalid YouTube URL
//                    let invalidAlert = UIAlertController(
//                        title: "Invalid URL",
//                        message: "Please enter a valid YouTube URL.",
//                        preferredStyle: .alert
//                    )
//                    invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.parentViewController?.present(invalidAlert, animated: true, completion: nil)
//                }
//            } else {
//                self.pdfNameLabel.text = "No text entered."
//            }
//        }
//        
//        // Add "Cancel" action
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        // Add actions to the alert controller
//        alertController.addAction(addAction)
//        alertController.addAction(cancelAction)
//        
//        // Present the alert
//        parentViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    // Helper function to validate YouTube URL
//    private func isValidYouTubeURL(_ urlString: String) -> Bool {
//        // Regular expression for a basic YouTube URL validation
//        let youtubeRegex = "^(https?://)?(www\\.)?(youtube|youtu|youtube-nocookie)\\.(com|be)/(watch\\?v=|embed\\/|v\\/|.+\\/videos\\/|shorts\\/)([a-zA-Z0-9_-]{11})$"
//        let youtubePredicate = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
//        return youtubePredicate.evaluate(with: urlString)
//    }
//    
//    @IBAction func docButtonAction(_ sender: Any) {
//        openDocumentPicker()
//    }
//    
//    // MARK: - UIImagePickerControllerDelegate
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        
//        if let selectedImage = info[.originalImage] as? UIImage {
//            print("Picked an image")
//            contentImage.image = selectedImage
//            image = selectedImage
//            vidUrl = nil
//            documentURL = nil
//            pdfNameLabel.text = nil
//
//            submitFeedInfo()
//            contentCancel.isHidden = false
//            pdfNameLabel.isHidden = true
//
//        } else if let mediaType = info[.mediaType] as? String, mediaType == "public.movie" {
//            print("Media type is video")
//
//            if let mediaURL = info[.mediaURL] as? URL {
//                // Video picked from Files or recorded
//                print("Picked video URL: \(mediaURL)")
//                contentImage.image = generateThumbnail(for: mediaURL)
//                vidUrl = mediaURL
//                image = contentImage.image
//                documentURL = nil
//                pdfNameLabel.text = nil
//
//                submitFeedInfo()
//                contentCancel.isHidden = false
//                pdfNameLabel.isHidden = true
//
//            } else if let refURL = info[.referenceURL] as? URL {
//                // Video picked from Photos library (asset URL)
//                print("Picked reference URL: \(refURL)")
//                fetchVideoURLFromPhotoLibrary(refURL: refURL)
//            }
//
//        } else {
//            print("⚠️ Neither image nor video was selected.")
//        }
//
//        parentViewController?.view.layoutIfNeeded()
//    }
//
//    private func fetchVideoURLFromPhotoLibrary(refURL: URL) {
//        let options = PHFetchOptions()
//        options.fetchLimit = 1
//        let assets = PHAsset.fetchAssets(withALAssetURLs: [refURL], options: options)
//
//        guard let asset = assets.firstObject else {
//            print("❌ Failed to fetch asset for reference URL")
//            return
//        }
//
//        let manager = PHImageManager.default()
//        let videoOptions = PHVideoRequestOptions()
//        videoOptions.deliveryMode = .highQualityFormat
//
//        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, audioMix, info in
//            if let urlAsset = avAsset as? AVURLAsset {
//                let localVideoUrl = urlAsset.url
//                print("✅ Got local video URL from library: \(localVideoUrl)")
//
//                DispatchQueue.main.async {
//                    self.contentImage.image = self.generateThumbnail(for: localVideoUrl)
//                    self.vidUrl = localVideoUrl
//                    self.image = self.contentImage.image
//                    self.documentURL = nil
//                    self.pdfNameLabel.text = nil
//                    self.submitFeedInfo()
//                    self.contentCancel.isHidden = false
//                    self.pdfNameLabel.isHidden = true
//                }
//            } else {
//                print("❌ Failed to get AVURLAsset from PHAsset")
//            }
//        }
//    }
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//          picker.dismiss(animated: true)
//
//          guard let itemProvider = results.first?.itemProvider else { return }
//
//          if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//              itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
//                  guard let url = url else { return }
//                  let fileName = UUID().uuidString + ".mov"
//                  let destURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//
//                  do {
//                      try FileManager.default.copyItem(at: url, to: destURL)
//                      DispatchQueue.main.async {
//                          self.vidUrl = destURL
//                          self.contentImage.image = self.generateThumbnail(for: destURL)
//                          self.image = self.contentImage.image
//                          self.submitFeedInfo()
//                          self.contentCancel.isHidden = false
//                          self.pdfNameLabel.isHidden = true
//                      }
//                  } catch {
//                      print("❌ Failed to copy video file: \(error)")
//                  }
//              }
//          } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
//              itemProvider.loadObject(ofClass: UIImage.self) { image, error in
//                  DispatchQueue.main.async {
//                      if let selectedImage = image as? UIImage {
//                          self.image = selectedImage
//                          self.contentImage.image = selectedImage
//                          self.vidUrl = nil
//                          self.submitFeedInfo()
//                          self.contentCancel.isHidden = false
//                          self.pdfNameLabel.isHidden = true
//                      }
//                  }
//              }
//          }
//      }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    // MARK: - UIDocumentPickerDelegate
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let documentURL = urls.first else { return }
//        
//        self.documentURL = documentURL
//        
//        //        dataViewHeightCn.constant = 150
//        //        mainViewHtCn.constant = 448
//        
//        // Set the document image to a black icon
//        contentImage.image = UIImage(systemName: "doc.fill")?.withTintColor(.black) // Set a black doc icon
//        submitFeedInfo()
//        contentCancel.isHidden = false
//        pdfNameLabel.isHidden = false
//        pdfNameLabel.text = documentURL.lastPathComponent
//        
//        parentViewController?.view.layoutIfNeeded()
//    }
//    
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//    
//    // Helper method to generate a thumbnail for video
//    private func generateThumbnail(for url: URL) -> UIImage? {
//        let asset = AVAsset(url: url)
//        let generator = AVAssetImageGenerator(asset: asset)
//        generator.appliesPreferredTrackTransform = true
//        
//        do {
//            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
//            return UIImage(cgImage: cgImage)
//        } catch {
//            print("Error generating thumbnail: \(error)")
//            return nil
//        }
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.postNameText = textField.text ?? ""
//        delegate?.assignPostName(postName: postNameText)
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//            self.postDescriptionText = textView.text
//        delegate?.assignPostDescription(postDescription: postDescriptionText)
//    }
//    
//}
//
//



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
import PDFKit
import DKImagePickerController

enum fileType: String {
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
    
    // MARK: - IBOutlets
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
    
    // MARK: - Properties
    weak var delegate: AddFeedInfoCellDelegate?
    var parentViewController: UIViewController?
    var assets: [DKAsset]?
    var selectAssets = [PHAsset]()
    var filename = [String]()
    var localfilePath = [URL]()
    var localPdfFilePath = [URL]()
    var localVideofilePath = [URL]()
    var localAudiofilePath = [URL]()
    var localThumbfilePath = [URL]()
    
    var filetype = fileType.none.rawValue
    var postNameText: String = ""
    var postDescriptionText: String = ""
    var image: UIImage?
    var finalURL: URL?
    var documentURL: URL?
    var vidUrl: URL?
    var strYouTubeUrl: String = ""
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postNAme.delegate = self
        textView.delegate = self
        
        setupUI()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        
        contentSelectionView.layer.cornerRadius = 10
        contentStackView.layer.cornerRadius = 10
        dataView.layer.cornerRadius = 10
        contentImage.layer.cornerRadius = 10
        textView.layer.cornerRadius = 5
        
        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true
    }
    
    // MARK: - Video Compression Methods
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
       
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                
                self.localVideofilePath.append(compressedURL)
                DispatchQueue.main.async {
//                    self.updateCollectionView()
                }
            default:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func compressVideoWithAssest(asset: AVAsset, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        if let urlAsset = asset as? AVURLAsset {
            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
                handler(nil)
                return
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
        }
    }
    
    // MARK: - Image/Thumbnail Generation
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch {
            return nil
        }

        return UIImage(cgImage: thumbnailImageRef)
    }
    
    func saveImageFromVideo(url: URL, at time: TimeInterval) {
        let asset = AVURLAsset(url: url)
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uniqueId = NSUUID().uuidString.lowercased()
            let fileName = uniqueId + ".jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let data = UIImage(cgImage: thumbnailImageRef).jpegData(compressionQuality: 0.3),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                try? data.write(to: fileURL)
                self.localThumbfilePath.append(fileURL)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func imageFromPdf(url: URL) -> UIImage? {
        let pdfDocument = PDFDocument(url: url)
        let pdfDocumentPage = pdfDocument?.page(at: 0)
        let pdfThumbNailImage = pdfDocumentPage?.thumbnail(of: CGSize(width: 200, height: 350), for: PDFDisplayBox.trimBox)
        
        do {
            var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uniqueId = NSUUID().uuidString.lowercased()
            let fileName = uniqueId + ".jpg"
            documentsDirectory = documentsDirectory.appendingPathComponent("thumbImages")
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if let data = pdfThumbNailImage!.jpegData(compressionQuality: 0.4),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                try data.write(to: fileURL)
                self.localThumbfilePath.append(fileURL)
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
        return pdfThumbNailImage
    }
    
    // MARK: - Button Actions
    @IBAction func btnImagesAttachmentAction(_ sender: Any) {
        self.OpenImageSelectionView()
    }
    
    @IBAction func btnVideoAttachmentAction(_ sender: Any) {
        self.OpenVideoSelectionView()
    }
    
    @IBAction func btnYoutubeAttachmentAction(_ sender: Any) {
        self.addVideoLink()
    }
    
    @IBAction func btnDocAttachmentAction(_ sender: Any) {
        self.addDocument()
    }
    
    @IBAction func btnAudioAttachmentAction(_ sender: Any) {
//        if UserDefaults.standard.value(forKey: "AudioFileName") != nil {
//            UserDefaults.standard.removeObject(forKey: "AudioFileName")
//            UserDefaults.standard.synchronize()
//        }
//        
//        filetype = fileType.audio.rawValue
////        let anRecordVC = RecordVC(nibName: "RecordVC", bundle: nil)
//        parentViewController?.navigationController?.pushViewController(anRecordVC, animated: true)
    }
    
    // MARK: - Selection Methods
    func OpenImageSelectionView() {
        let alert = UIAlertController(title: "Add Image", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openMediaPicker(for: "image")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        parentViewController?.present(alert, animated: true)
    }
    
    func OpenVideoSelectionView() {
        let alert = UIAlertController(title: "Add Video", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Record a Video", style: .default, handler: { _ in
            self.openVideoRecorder()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.filetype = fileType.video.rawValue
            self.openMediaPicker(for: "video") // Use the unified media picker
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        parentViewController?.present(alert, animated: true)
    }
    
    func addVideoLink() {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter video link"
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            let firstTextField = alertController.textFields![0]
            self.strYouTubeUrl = firstTextField.text ?? ""
            self.uploadVideoUrl()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        parentViewController?.present(alertController, animated: true)
    }
    
    func uploadVideoUrl() {
        if self.strYouTubeUrl.isEmpty {
            return
        }
        
        if self.strYouTubeUrl.extractYoutubeId(fromLink: self.strYouTubeUrl) != "" {
            self.filetype = fileType.youtube.rawValue
            self.pdfNameLabel.text = self.strYouTubeUrl
            self.pdfNameLabel.isHidden = false
            self.contentCancel.isHidden = false
            self.submitFeedInfo()
        } else {
            showAlert(title: "Invalid URL", message: "Please enter valid YouTube URL")
        }
    }
    
    func addDocument() {
        let attachSheet = UIAlertController(title: nil, message: "File attaching", preferredStyle: .actionSheet)
        
        attachSheet.addAction(UIAlertAction(title: "File", style: .default, handler: { _ in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            self.parentViewController?.present(documentPicker, animated: true)
        }))
        
        attachSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        parentViewController?.present(attachSheet, animated: true)
    }
    
    func getAudioDocumentDirectory() {
        guard let audioFileName = UserDefaults.standard.value(forKey: "AudioFileName") as? String else { return }
        
        var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("audios")
            .appendingPathComponent(audioFileName)
        
        self.filetype = fileType.audio.rawValue
        self.localAudiofilePath.append(filePath)
        
        DispatchQueue.main.async {
//            self.updateCollectionView()
        }
        
        UserDefaults.standard.removeObject(forKey: "AudioFileName")
        UserDefaults.standard.synchronize()
    }
    
//    // MARK: - Helper Methods
//    private func updateCollectionView() {
//        DispatchQueue.main.async {
//            self.view.layoutIfNeeded()
//            self.viewCollection.isHidden = false
//            self.collectionMultipleImageList.isHidden = false
//            self.heightCollectionConstraint.constant = 140
//            self.view.layoutIfNeeded()
//            self.collectionMultipleImageList.reloadData()
//            self.view.layoutIfNeeded()
//        }
//    }
    
    private func removeImages() {
        localfilePath.removeAll()
        localPdfFilePath.removeAll()
        localVideofilePath.removeAll()
        localAudiofilePath.removeAll()
        localThumbfilePath.removeAll()
    }
    
    // MARK: - Submission
    func submitFeedInfo() {
        finalURL = nil
        filetype = fileType.none.rawValue

        // Priority 1: YouTube URL
        if let youtubeURL = pdfNameLabel.text, !youtubeURL.isEmpty, isValidYouTubeURL(youtubeURL) {
            finalURL = URL(string: youtubeURL)
            filetype = fileType.youtube.rawValue

        // Priority 2: Video
        } else if let videoUrl = self.vidUrl {
            finalURL = videoUrl
            filetype = fileType.video.rawValue
            // Ensure we have a thumbnail
            if contentImage.image == nil {
                contentImage.image = generateThumbnail(for: videoUrl)
            }

        // Priority 3: Image
        } else if let image = image {
            if let imageURL = saveImageToDocumentsDirectory(image: image) {
                finalURL = imageURL
                filetype = fileType.image.rawValue
            }

        // Priority 4: Document
        } else if let documentURL = documentURL {
            finalURL = documentURL
            filetype = fileType.pdf.rawValue
        }

        // Fallback
        if finalURL == nil {
            finalURL = URL(fileURLWithPath: "")
            filetype = fileType.none.rawValue
        }

        delegate?.assignFinalUrl(finalUrl: finalURL!)
    }
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
    
    private func isValidYouTubeURL(_ urlString: String) -> Bool {
        let youtubeRegex = "^(https?://)?(www\\.)?(youtube|youtu|youtube-nocookie)\\.(com|be)/(watch\\?v=|embed/|v/|.+/videos/|shorts/)([a-zA-Z0-9_-]{11})$"
        let youtubePredicate = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubePredicate.evaluate(with: urlString)
    }
    
    // MARK: - Media Picker Methods
    private func openMediaPicker(for type: String) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = type == "video" ? .videos : .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        parentViewController?.present(picker, animated: true)
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
        imagePicker.mediaTypes = [UTType.image.identifier]
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        parentViewController?.present(imagePicker, animated: true)
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
        videoPicker.mediaTypes = [UTType.movie.identifier]
        videoPicker.videoQuality = .typeMedium
        videoPicker.delegate = self
        videoPicker.allowsEditing = false
        parentViewController?.present(videoPicker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        parentViewController?.present(alert, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func removeImageButtonAction(_ sender: Any) {
        contentImage.image = nil
        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true
        documentURL = nil
        vidUrl = nil
        image = nil
        pdfNameLabel.text = nil
        parentViewController?.view.layoutIfNeeded()
    }
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        OpenImageSelectionView()
    }
    
    @IBAction func videoButtonActon(_ sender: UIButton) {
        OpenVideoSelectionView()
    }
    
    @IBAction func audioButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add Audio", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Record an Audio", style: .default) { _ in
            self.showAlert(title: "Coming Soon", message: "Audio recording is not implemented yet.")
        })
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            self.parentViewController?.present(documentPicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        parentViewController?.present(alert, animated: true)
    }
    
    @IBAction func youTibeAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Add YouTube Link", message: "Please insert below.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Type here..."
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let enteredText = textField.text, !enteredText.isEmpty {
                
                if self.isValidYouTubeURL(enteredText) {
                    self.pdfNameLabel.text = enteredText
                    self.submitFeedInfo()
                } else {
                    self.showAlert(title: "Invalid URL", message: "Please enter a valid YouTube URL.")
                }
            } else {
                self.pdfNameLabel.text = "No text entered."
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        parentViewController?.present(alertController, animated: true)
    }
    
    @IBAction func docButtonAction(_ sender: Any) {
        addDocument()
    }
    
    // MARK: - Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            contentImage.image = selectedImage
            image = selectedImage
            vidUrl = nil
            documentURL = nil
            pdfNameLabel.text = nil

            submitFeedInfo()
            contentCancel.isHidden = false
            pdfNameLabel.isHidden = true

        } else if let mediaType = info[.mediaType] as? String, mediaType == UTType.movie.identifier {
            if let mediaURL = info[.mediaURL] as? URL {
                contentImage.image = generateThumbnail(for: mediaURL)
                vidUrl = mediaURL
                image = contentImage.image
                documentURL = nil
                pdfNameLabel.text = nil

                submitFeedInfo()
                contentCancel.isHidden = false
                pdfNameLabel.isHidden = true

            } else if let refURL = info[.referenceURL] as? URL {
                fetchVideoURLFromPhotoLibrary(refURL: refURL)
            }
        }
    }

    private func fetchVideoURLFromPhotoLibrary(refURL: URL) {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let assets = PHAsset.fetchAssets(withALAssetURLs: [refURL], options: options)

        guard let asset = assets.firstObject else {
            print("❌ Failed to fetch asset for reference URL")
            return
        }

        let videoOptions = PHVideoRequestOptions()
        videoOptions.deliveryMode = .highQualityFormat

        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                let localVideoUrl = urlAsset.url
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
            }
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        let itemProvider = result.itemProvider
        
        // Handle video selection
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
                guard let self = self, let url = url else { return }
                
                // Create a unique filename in temp directory
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                
                do {
                    // Copy the video to temp directory
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    
                    // Generate thumbnail
                    let thumbnail = self.generateThumbnail(for: tempURL)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.vidUrl = tempURL
                        self.contentImage.image = thumbnail
                        self.image = thumbnail
                        self.documentURL = nil
                        self.pdfNameLabel.text = nil
                        self.contentCancel.isHidden = false
                        self.pdfNameLabel.isHidden = true
                        self.submitFeedInfo()
                    }
                    
                } catch {
                    print("Error handling video: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to process video")
                    }
                }
            }
        }
        // Handle image selection (existing code)
        else if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.handleSelectedImage(image)
                    }
                }
            }
        }
    }
    
    private func handleSelectedImage(_ image: UIImage) {
        self.image = image
        self.contentImage.image = image
        self.vidUrl = nil
        self.documentURL = nil
        self.pdfNameLabel.text = nil
        self.contentCancel.isHidden = false
        self.pdfNameLabel.isHidden = true
        self.submitFeedInfo()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentURL = urls.first else { return }
        self.documentURL = documentURL
        
        contentImage.image = UIImage(systemName: "doc.fill")?.withTintColor(.black)
        submitFeedInfo()
        contentCancel.isHidden = false
        pdfNameLabel.isHidden = false
        pdfNameLabel.text = documentURL.lastPathComponent
        
        parentViewController?.view.layoutIfNeeded()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 300, height: 300) // Set appropriate size
        
        do {
            let cgImage = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return UIImage(named: "video_placeholder") // Fallback image
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

// Helper extension
extension String {
    func extractYoutubeId(fromLink link: String) -> String {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        guard let regExp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return ""
        }
        let nsLink = link as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: nsLink.length)
        let matches = regExp.matches(in: link, options: options, range: range)
        
        if let firstMatch = matches.first {
            return nsLink.substring(with: firstMatch.range)
        }
        return ""
    }
}
