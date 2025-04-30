import UIKit
import Photos
import UniformTypeIdentifiers
import PhotosUI

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
    var selectedIndices: Set<Int> = [] // Track selected images

    var mediaItems: [UIImage] = []
    var mediaItemsStrings: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailGalleryViewController Loaded with Group ID: \(groupId), Token: \(token), and Album ID: \(albumId), currentRole : \(currentRole)")
        
        // Show/hide buttons based on currentRole
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

        albumName.text = albumNameString
        loadImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10  // Spacing between cells
        let numberOfColumns: CGFloat = 3  // Change to 1 for even bigger images
        let totalSpacing = (numberOfColumns - 1) * spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth * 1.2) // Adjust height ratio if needed
    }
    func loadImages() {
        let dispatchGroup = DispatchGroup()
        var downloadedImages: [UIImage] = []
        
        for imageString in mediaItemsStrings {
            let cleanedBase64 = imageString.replacingOccurrences(of: "\n", with: "")
            
            if let decodedData = Data(base64Encoded: cleanedBase64),
               let decodedURL = String(data: decodedData, encoding: .utf8),
               let url = URL(string: decodedURL), url.scheme?.hasPrefix("http") == true {
                
                // If the imageString is a Base64-encoded URL, decode and download it
                dispatchGroup.enter()
                downloadImage(from: url) { image in
                    if let image = image {
                        downloadedImages.append(image)
                    }
                    dispatchGroup.leave()
                }
                
            } else if let image = convertBase64ToImage(cleanedBase64) {
                // If it's a direct Base64 image string, convert it
                downloadedImages.append(image)
            } else {
                print("⚠️ Invalid image format: \(cleanedBase64.prefix(30))...")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.mediaItems = downloadedImages
            print("✅ Total images loaded: \(self.mediaItems.count)")
            self.CollectionView.reloadData()
        }
    }

    // MARK: - Download Image from URL
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
            self.openMediaPicker()
        }

        let addVideoAction = UIAlertAction(title: "Add Video", style: .default) { _ in
            self.openVideoPicker()
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
                    self.CollectionView.reloadData()
                }

                if let base64String = self.convertImageToBase64(selectedImage) {
                    encodedImages.append(base64String)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.uploadImages(encodedImages) // Call API after all images are encoded
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
        return mediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.imageView.image = mediaItems[indexPath.item]
        
        // Update selection state
        let isSelected = selectedIndices.contains(indexPath.item)
        cell.isSelectedCell = isSelected // Update cell's selection state

        // Handle button tap for selection
        cell.SelectButton.tag = indexPath.item
        cell.SelectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)

        return cell
    }

    @objc func selectButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        if selectedIndices.contains(index) {
            selectedIndices.remove(index) // Deselect
        } else {
            selectedIndices.insert(index) // Select
        }
        
        CollectionView.reloadItems(at: [IndexPath(item: index, section: 0)]) // Refresh only the changed cell
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
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(albumId)/remove?"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        let selectedImages = selectedIndices.map { mediaItemsStrings[$0] }
        let requestData: [String: Any] = [
            "fileName": selectedImages
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

        print("📤 Deleting \(selectedImages.count) images from API...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error deleting images: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Response Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    print("🎉 Images successfully deleted!")

                    DispatchQueue.main.async {
                        // Remove deleted images from data source
                        self.mediaItems.removeAll { self.selectedIndices.contains(self.mediaItems.firstIndex(of: $0) ?? -1) }
                        self.mediaItemsStrings.removeAll { selectedImages.contains($0) }
                        self.selectedIndices.removeAll() // Clear selection
                        self.CollectionView.reloadData()
                    }

                } else {
                    print("⚠️ Failed to delete images. Response code: \(httpResponse.statusCode)")
                }
            }

            if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("✅ Delete Response JSON: \(jsonResponse)")
            } else {
                print("❌ Failed to parse response data")
            }
        }.resume()
    }


}
