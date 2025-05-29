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

    @IBOutlet weak var ChapterName: UITextField!
    @IBOutlet weak var topicName: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentCancel: UIButton!
    @IBOutlet weak var pdfNameLabel: UILabel!
    
    var groupId: String?
    var teamId: String?
    var subjectId: String?

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
    var filetype = fileType.none.rawValue
    
    var postNameText: String = ""
    var postDescriptionText: String = ""
    var image: UIImage?
    var finalURL: URL?
    
    private var documentURL: URL?
    private var vidUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ChapterName.delegate = self
        topicName.delegate = self
        
        contentCancel.isHidden = true
        pdfNameLabel.isHidden = true

        addDropDownIcon(to: ChapterName, action: #selector(showChapterPicker))
        addDropDownIcon(to: topicName, action: #selector(showTopicPicker))

        fetchSyllabusData()
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

    // MARK: - Fetch Data
    func fetchSyllabusData() {
        guard let token = TokenManager.shared.getToken(),
              let groupId = groupId,
              let teamId = teamId,
              let subjectId = subjectId else {
            print("❌ Missing token or IDs")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/syllabus/get/master"

        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SyllabusResponse.self, from: data)
                self.chapterNames = decodedResponse.data.map { $0.chapterName }
                self.topicNames = decodedResponse.data.flatMap { $0.topicsList.map { $0.topicName } }

                DispatchQueue.main.async {
                    print("✅ Chapters: \(self.chapterNames)")
                    print("✅ Topics: \(self.topicNames)")
                }
            } catch {
                print("❌ JSON Decode Error: \(error)")
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

    @IBAction func addButton(_ sender: Any) {
        ChapterName.resignFirstResponder()
        topicName.resignFirstResponder()

        print("✅ Add Button Tapped")
        print("📘 Chapter Name: \(ChapterName.text ?? "")")
        print("📗 Topic Name: \(topicName.text ?? "")")

        // Call your API here
        submitSubjectPost()
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
        
        //        dataViewHeightCn.constant = 150
        //        mainViewHtCn.constant = 448
        
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
            
            //            dataViewHeightCn.constant = 150
            //            mainViewHtCn.constant = 448
            //
            // Generate thumbnail and set it into contentImage
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

    
    func submitSubjectPost() {
        let postName = self.postName
        
        // Validate required fields
        guard let postDescription = self.topicName.text else {
            print("❌ Post Name or Description is missing")
            return
        }

        // Determine fileType and fileName array
        var fileType: String = ""
        var fileNameArray: [String] = []
        var youTube: URL = URL(fileURLWithPath: "")

        if let documentURL = self.finalURL {
            let absoluteString = documentURL.absoluteString.lowercased()

            if absoluteString.contains("youtube.com") || absoluteString.contains("youtu.be") {
                fileType = "youtube"
            } else {
                let pathExtension = documentURL.pathExtension.lowercased()
                switch pathExtension {
                case "jpg", "jpeg", "png", "gif":
                    fileType = "image"
                case "mp4", "mov", "avi":
                    fileType = "video"
                case "pdf":
                    fileType = "pdf"
                case "mp3", "aac", "wav":
                    fileType = "audio"
                default:
                    fileType = "unknown"
                }
            }

            // Encode file URL to Base64
            if let base64URL = documentURL.absoluteString.data(using: .utf8)?.base64EncodedString() {
                youTube = documentURL
                fileNameArray.append(base64URL)
            }
        }

        // Dummy chapter and topic name; ideally these should come from user input or picker
        let chapterName = ChapterName.text ?? ""
        let topicName = topicName.text ?? ""

        let postRequest = SubjectPostRequest(
            chapterName: chapterName,
            fileName: fileNameArray,
            fileType: fileType,
            thumbnailImage: [],
            topicName: topicName,
            video: ""
        )

        // Use actual IDs and token
        guard let bearerToken = TokenManager.shared.getToken(),
              let groupId = groupId,
              let teamId = teamId,
              let subjectId = subjectId else {
            print("❌ Missing group/team/subject ID or token")
            return
        }

        addSubjectPost(
            token: bearerToken,
            groupId: groupId,
            teamId: teamId,
            subjectId: subjectId,
            postRequest: postRequest
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Subject Post Added: \(response.message ?? "")")
                case .failure(let error):
                    print("❌ Error Submitting Subject Post: \(error.localizedDescription)")
                }
                if let previousVC = self.navigationController?.viewControllers.dropLast().last as? SubDetailsVC {
                            previousVC.shouldRefreshData = true
                        }
                        self.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    func assignPostName(postName: String) {
        self.postName = postName
    }
    
    func assignPostDescription(postDescription: String) {
        self.postDescription = postDescription
    }
    
    func addSubjectPost(
        token: String,
        groupId: String,
        teamId: String,
        subjectId: String,
        postRequest: SubjectPostRequest,
        completion: @escaping (Result<SubjectPostResponse, Error>) -> Void
    ) {
        let baseURL = APIManager.shared.baseURL
        let endpoint = "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/posts/add"
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(postRequest)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Final JSON Body Sent:\n\(jsonString)")
            }
        } catch {
            print("❌ JSON Encoding Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 1001)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SubjectPostResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
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
