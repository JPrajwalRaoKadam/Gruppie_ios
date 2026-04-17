//
//  AddChapterVC.swift
//  loginpage
//
//  Created by apple on 17/04/25.
//

import UIKit
import Photos
import UniformTypeIdentifiers

class AddChapterVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate {

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

    var classId: String = ""
    var subjectId: String = ""
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var groupAcademicYearId: String = ""

    var chapterNames: [String] = []
    var topicNames: [String] = []
    
    var postName : String = ""
    var postDescription: String?
    
    var customParentViewController: UIViewController?
    var selectAssets = [PHAsset]()
    var filename = [String]()
    var localfilePath = [URL]()
    var localPdfFilePath = [URL]()
    var localVideofilePath = [URL]()
    var localAudiofilePath = [URL]()
    // Kanika
    var localThumbfilePath = [URL]()
//    var filetype = fileType.none.rawValue
    
    var postNameText: String = ""
    var postDescriptionText: String = ""
    var image: UIImage?
    var finalURL: URL?
    
    private var documentURL: URL?
    private var vidUrl: URL?
    
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

        //fetchSyllabusData()
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
    
    func uploadNotes() {

        guard let token = SessionManager.useRoleToken else { return }

        let urlString = "https://backend.gc2.co.in/api/v1/notes"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body = Data()

        let params: [String: String] = [
            "classId": classId,
            "subjectId": subjectId,
            "chapterId": "1",
            "title": ChapterName.text ?? "",
            "description": topicName.text ?? "",
            "groupAcademicYearId": groupAcademicYearId
        ]

        // Parameters
        for (key,value) in params {

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // File
        if let fileURL = documentURL,
           let fileData = try? Data(contentsOf: fileURL) {

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"attachmentLinks\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            // Print raw response
            if let raw = String(data: data, encoding: .utf8) {
                print("📩 RAW RESPONSE:", raw)
            }

             do {
                let decoded = try JSONDecoder().decode(AddNoteResponse.self, from: data)
                print("✅ Decoded:", decoded)

                DispatchQueue.main.async {

                    self.clearForm()

                    if let previousVC = self.navigationController?.viewControllers.dropLast().last as? SubDetailsVC {
                        previousVC.fetchNotes()
                    }

                    self.navigationController?.popViewController(animated: true)
                }

            } catch {
                print("❌ Decoding Error:", error)
            }
        }.resume()
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
            alert.addAction(UIAlertAction(title: option, style: .default) { _ in
                onSelect(option)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Button Actions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func submitButton(_ sender: Any) {
        ChapterName.resignFirstResponder()
        topicName.resignFirstResponder()
        uploadNotes()
    }
 

    @IBAction func chapterAddButton(_ sender: Any) {
        ChapterName.becomeFirstResponder()
    }

    @IBAction func topicAddButton(_ sender: Any) {
        topicName.becomeFirstResponder()
    }
    
    @IBAction func removeImageButtonAction(_ sender: Any) {
        // Clear the content image and hide the cancel button
        contentImage.image = nil
        contentCancel.isHidden = true
        
        // Hide document name
        pdfNameLabel.isHidden = true
//        documentURL = nil
        
        customParentViewController?.view.layoutIfNeeded()
    }
    
    @IBAction func imageButtonAction(_ sender: Any) {
        // First Alert with two options
        let alert = UIAlertController(title: "Add Image", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.showConfirmationAlert(for: "Take a Photo")
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showConfirmationAlert(for: "Choose from Library")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func videoButtonAction(_ sender: Any) {
        
        // First Alert with two options
        let alert = UIAlertController(title: "Add Video", message: "Please select an action.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Record a Video", style: .default, handler: { _ in
            self.showConfirmationAlertForVideo(for: "Record a Video")
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.showConfirmationAlertForVideo(for: "Choose from Library")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
       
    }
    
    @IBAction func youTubeButtonAction(_ sender: Any) {
        
        showTextFieldAlert()
    }
    
    @IBAction func docButtonAction(_ sender: Any) {
        openDocumentPicker()
        
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
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitFeedInfo() {
        print("Image is present: \(image != nil)")
        print("Document URL: \(documentURL?.absoluteString ?? "None")")
        
        if let image = image {
            if let imageURL = saveImageToDocumentsDirectory(image: image) {
                finalURL = imageURL
            }
        } else if let youtubeURL = pdfNameLabel.text, !youtubeURL.isEmpty, isValidYouTubeURL(youtubeURL) {
            finalURL = URL(string: youtubeURL) ?? URL(fileURLWithPath: "")
        } else if let videoUrl = self.vidUrl{
            finalURL = videoUrl
            image = contentImage.image
        }else if let documentURL = documentURL {
            finalURL = documentURL
        }
        
        assignFinalUrl(finalUrl: finalURL ?? URL(fileURLWithPath: ""))
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
        
        let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary

           if type == "image" {
               imagePicker.mediaTypes = [UTType.image.identifier]
           } else if type == "video" {
               imagePicker.mediaTypes = [UTType.movie.identifier]
           }

           self.present(imagePicker, animated: true, completion: nil)
        submitFeedInfo()
    }
    
    private func openDocumentPicker() {
        // Allow access to all file types
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    private func showConfirmationAlert(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleOptionSelection(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(confirmationAlert, animated: true, completion: nil)
        
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
        // Code to open the camera
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self // Ensure your class conforms to UIImagePickerControllerDelegate
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func showConfirmationAlertForVideo(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleOptionSelectionForVideo(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
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
        // Code to open the camera for video recording
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.movie"] // Only allow video recording
        imagePicker.delegate = self // Ensure your class conforms to UIImagePickerControllerDelegate
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func showAudioConfirmationAlert(for option: String) {
        // Second Alert for Confirmation
        let confirmationAlert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to \(option.lowercased())?", preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.handleAudioOptionSelection(option)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
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
        // Code to open an audio recorder
        print("Audio recorder functionality goes here.")
        // Implement your audio recording functionality here
    }
    
    private func openAudioLibrary() {
        // Code to open the library for audio selection
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
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
                    self.present(invalidAlert, animated: true, completion: nil)
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

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // Helper function to validate YouTube URL
    private func isValidYouTubeURL(_ urlString: String) -> Bool {
        // Regular expression for a basic YouTube URL validation
        let youtubeRegex = "^(https?://)?(www\\.)?(youtube|youtu|youtube-nocookie)\\.(com|be)/(watch\\?v=|embed\\/|v\\/|.+\\/videos\\/|shorts\\/)([a-zA-Z0-9_-]{11})$"
        let youtubePredicate = NSPredicate(format: "SELF MATCHES %@", youtubeRegex)
        return youtubePredicate.evaluate(with: urlString)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
         if let selectedImage = info[.originalImage] as? UIImage {
            // Set the selected image into contentImage
            contentImage.image = selectedImage
            image = contentImage.image
            submitFeedInfo()
            contentCancel.isHidden = false // Show the cancel button
            
            // Hide document name
            pdfNameLabel.isHidden = true
            
            customParentViewController?.view.layoutIfNeeded()
        } else if let videoURL = info[.mediaURL] as? URL {
            
            contentImage.image = generateThumbnail(for: videoURL)
            self.vidUrl = videoURL
            submitFeedInfo()
            contentCancel.isHidden = false // Show the cancel button
            
            // Hide document name
            pdfNameLabel.isHidden = true
            
            customParentViewController?.view.layoutIfNeeded()
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
        
        customParentViewController?.view.layoutIfNeeded()
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
    
    func assignFinalUrl(finalUrl: URL) {
        guard finalUrl.absoluteString != "file:///" else {
            print("⚠️ Invalid file URL assigned.")
            return
        }
        self.documentURL = finalUrl
    }

    func assignPostName(postName: String) {
        self.postName = postName
    }
    
    func assignPostDescription(postDescription: String) {
        self.postDescription = postDescription
    }
}

// MARK: - UITextFieldDelegate
extension AddChapterVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        assignPostName(postName: ChapterName.text ?? "")
//        assignPostDescription(postDescription: topicName.text ?? "")
        return true // Allow manual typing
    }
}
