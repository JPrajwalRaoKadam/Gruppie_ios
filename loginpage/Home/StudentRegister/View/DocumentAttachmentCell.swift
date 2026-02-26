//import UIKit
//
//class DocumentAttachmentCell: UITableViewCell {
//
//    @IBOutlet weak var docCollection: UICollectionView!
//    
//    // Store uploaded documents
//    private var uploadedDocuments: [Int: Any] = [:] // Store UIImage or URL
//    weak var parentViewController: UIViewController?
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupCollectionView()
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Ensure collection view fills the cell
//        docCollection.frame = CGRect(x: 0, y: 0,
//                                    width: self.bounds.width,
//                                    height: self.bounds.height)
//        
//        // Recalculate layout
//        if let layout = docCollection.collectionViewLayout as? UICollectionViewFlowLayout {
//            let screenWidth = self.bounds.width
//            let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 3
//            let horizontalInset: CGFloat = 16
//            let availableWidth = screenWidth - (horizontalInset * 2) - totalSpacing
//            let itemWidth = availableWidth / 4
//            
//            layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 30)
//            layout.sectionInset = UIEdgeInsets(top: 12, left: horizontalInset,
//                                              bottom: 12, right: horizontalInset)
//            
//            docCollection.collectionViewLayout.invalidateLayout()
//        }
//    }
//    
//    private func setupCollectionView() {
//        // Set delegates
//        docCollection.delegate = self
//        docCollection.dataSource = self
//        
//        // Register cell
//        let nib = UINib(nibName: "DocAttachCollectionCell", bundle: nil)
//        docCollection.register(nib, forCellWithReuseIdentifier: "DocAttachCollectionCell")
//        
//        // Setup layout for 5 columns
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 0
//        
//        // Calculate item width for 5 columns
//        let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 4
//        let availableWidth = UIScreen.main.bounds.width - totalSpacing - 32
//        let itemWidth = availableWidth / 5
//        
//        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 25)
//        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
//        
//        docCollection.collectionViewLayout = layout
//        docCollection.backgroundColor = .clear
//        docCollection.showsVerticalScrollIndicator = false
//        docCollection.isScrollEnabled = false
//    }
//    
//    func setParentViewController(_ vc: UIViewController) {
//        self.parentViewController = vc
//    }
//    
//    func reloadCollectionView() {
//        docCollection.reloadData()
//    }
//}
//
//// MARK: - UICollectionView DataSource & Delegate
//extension DocumentAttachmentCell: UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return DocAttachCollectionCell.documentLabels.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "DocAttachCollectionCell",  // FIXED HERE
//            for: indexPath
//        ) as? DocAttachCollectionCell else {
//            return UICollectionViewCell()
//        }
//        
//        cell.configureCell(at: indexPath.row)
//        cell.delegate = self
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected document: \(DocAttachCollectionCell.documentLabels[indexPath.row])")
//    }
//}
//
//// MARK: - DocAttachCollectionCellDelegate
//extension DocumentAttachmentCell: DocAttachCollectionCellDelegate {
//    
//    func didTapImageIcon(at index: Int) {
//        guard let parentVC = parentViewController else { return }
//        
//        // Show options for selecting document
//        showDocumentOptions(for: index, in: parentVC)
//    }
//    
//    private func showDocumentOptions(for index: Int, in viewController: UIViewController) {
//        let documentName = DocAttachCollectionCell.documentLabels[index]
//        
//        let alert = UIAlertController(
//            title: "Upload \(documentName)",
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//        
//        // Camera option
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
//                self?.openImagePicker(for: index, sourceType: .camera, in: viewController)
//            })
//        }
//        
//        // Photo Library option
//        alert.addAction(UIAlertAction(title: "Choose from Photos", style: .default) { [weak self] _ in
//            self?.openImagePicker(for: index, sourceType: .photoLibrary, in: viewController)
//        })
//        
//        // Document picker option
//        alert.addAction(UIAlertAction(title: "Choose File", style: .default) { [weak self] _ in
//            self?.openDocumentPicker(for: index, in: viewController)
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // For iPad
//        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) {
//            alert.popoverPresentationController?.sourceView = cell
//            alert.popoverPresentationController?.sourceRect = cell.bounds
//        }
//        
//        viewController.present(alert, animated: true)
//    }
//    
//    private func openImagePicker(for index: Int, sourceType: UIImagePickerController.SourceType, in viewController: UIViewController) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = sourceType
//        imagePicker.allowsEditing = true
//        imagePicker.accessibilityHint = "\(index)"
//        
//        viewController.present(imagePicker, animated: true)
//    }
//    
//    private func openDocumentPicker(for index: Int, in viewController: UIViewController) {
//        let documentTypes = ["public.image", "com.adobe.pdf", "public.item"]
//        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        documentPicker.accessibilityHint = "\(index)"
//        
//        viewController.present(documentPicker, animated: true)
//    }
//}
//
//// MARK: - UIImagePickerControllerDelegate
//extension DocumentAttachmentCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage,
//              let indexString = picker.accessibilityHint,
//              let index = Int(indexString) else {
//            picker.dismiss(animated: true)
//            return
//        }
//        
//        // Store image
//        uploadedDocuments[index] = image
//        
//        // Update cell image
//        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? DocAttachCollectionCell {
//            cell.anImageIcon.image = image
//        }
//        
//        picker.dismiss(animated: true)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true)
//    }
//}
//
//// MARK: - UIDocumentPickerDelegate
//extension DocumentAttachmentCell: UIDocumentPickerDelegate {
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let url = urls.first,
//              let indexString = controller.accessibilityHint,
//              let index = Int(indexString) else { return }
//        
//        // Store document URL
//        uploadedDocuments[index] = url
//        
//        // Update cell icon
//        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? DocAttachCollectionCell {
//            cell.anImageIcon.image = UIImage(systemName: "doc.fill")
//        }
//        
//        controller.dismiss(animated: true)
//    }
//    
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        controller.dismiss(animated: true)
//    }
//}
import UIKit
class DocumentAttachmentCell: UITableViewCell {

    @IBOutlet weak var docCollection: UICollectionView!
    
    // Store uploaded documents
    private var uploadedDocuments: [Int: Any] = [:] // Store UIImage or URL
    weak var delegate: DocumentAttachmentCellDelegate?
    weak var parentViewController: UIViewController?
    
    // Document type mapping for API
    static let documentTypes: [Int: String] = [
        0: "Student Photo",
        1: "Father Photo",
        2: "Mother Photo",
        3: "Guardian Photo",
        4: "Birth Certificate",
        5: "Aadhaar Card",
        6: "Transfer Certificate (TC)",
        7: "Previous Mark Sheet",
        8: "Caste Certificate",
        9: "Income Certificate",
        10: "Medical Certificate",
        11: "Address Proof",
        12: "Other 1",
        13: "Other 2",
        14: "Other 3"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure collection view fills the cell
        docCollection.frame = CGRect(x: 0, y: 0,
                                    width: self.bounds.width,
                                    height: self.bounds.height)
        
        // Recalculate layout
        if let layout = docCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let screenWidth = self.bounds.width
            let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 3
            let horizontalInset: CGFloat = 16
            let availableWidth = screenWidth - (horizontalInset * 2) - totalSpacing
            let itemWidth = availableWidth / 4
            
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 30)
            layout.sectionInset = UIEdgeInsets(top: 12, left: horizontalInset,
                                              bottom: 12, right: horizontalInset)
            
            docCollection.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func setupCollectionView() {
        // Set delegates
        docCollection.delegate = self
        docCollection.dataSource = self
        
        // Register cell
        let nib = UINib(nibName: "DocAttachCollectionCell", bundle: nil)
        docCollection.register(nib, forCellWithReuseIdentifier: "DocAttachCollectionCell")
        
        // Setup layout for 5 columns
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 0
        
        // Calculate item width for 5 columns
        let totalSpacing: CGFloat = layout.minimumInteritemSpacing * 4
        let availableWidth = UIScreen.main.bounds.width - totalSpacing - 32
        let itemWidth = availableWidth / 5
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 25)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        docCollection.collectionViewLayout = layout
        docCollection.backgroundColor = .clear
        docCollection.showsVerticalScrollIndicator = false
        docCollection.isScrollEnabled = false
    }
    
    func setParentViewController(_ vc: UIViewController) {
        self.parentViewController = vc
    }
    
    func reloadCollectionView() {
        docCollection.reloadData()
    }
    
    // MARK: - Get Document Data
    func getDocumentData() -> DocumentData {
        return DocumentData(
            studentPhoto: uploadedDocuments[0],
            fatherPhoto: uploadedDocuments[1],
            motherPhoto: uploadedDocuments[2],
            guardianPhoto: uploadedDocuments[3],
            birthCertificate: uploadedDocuments[4],
            aadhaarCard: uploadedDocuments[5],
            transferCertificate: uploadedDocuments[6],
            previousMarksheet: uploadedDocuments[7],
            casteCertificate: uploadedDocuments[8],
            incomeCertificate: uploadedDocuments[9],
            medicalCertificate: uploadedDocuments[10],
            addressProof: uploadedDocuments[11],
            other1: uploadedDocuments[12],
            other2: uploadedDocuments[13],
            other3: uploadedDocuments[14]
        )
    }
    
    // MARK: - Prepare Documents for API
    func prepareDocumentsForAPI() -> [String: Any] {
        var documentsDict: [String: Any] = [:]
        
        // Add document types
        for (index, docType) in DocumentAttachmentCell.documentTypes {
            documentsDict["documentType\(index + 1)"] = docType
        }
        
        // Add document URLs/binary data (you'll need to implement file upload)
        // This would typically be handled with multipart form data
        
        return documentsDict
    }
    
    // MARK: - Convert Image to Base64
    private func convertImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension DocumentAttachmentCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DocAttachCollectionCell.documentLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DocAttachCollectionCell",
            for: indexPath
        ) as? DocAttachCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(at: indexPath.row)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected document: \(DocAttachCollectionCell.documentLabels[indexPath.row])")
    }
}

// MARK: - DocAttachCollectionCellDelegate
extension DocumentAttachmentCell: DocAttachCollectionCellDelegate {
    
    func didTapImageIcon(at index: Int) {
        guard let parentVC = parentViewController else { return }
        
        // Show options for selecting document
        showDocumentOptions(for: index, in: parentVC)
    }
    
    private func showDocumentOptions(for index: Int, in viewController: UIViewController) {
        let documentName = DocAttachCollectionCell.documentLabels[index]
        
        let alert = UIAlertController(
            title: "Upload \(documentName)",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.openImagePicker(for: index, sourceType: .camera, in: viewController)
            })
        }
        
        // Photo Library option
        alert.addAction(UIAlertAction(title: "Choose from Photos", style: .default) { [weak self] _ in
            self?.openImagePicker(for: index, sourceType: .photoLibrary, in: viewController)
        })
        
        // Document picker option
        alert.addAction(UIAlertAction(title: "Choose File", style: .default) { [weak self] _ in
            self?.openDocumentPicker(for: index, in: viewController)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) {
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell.bounds
        }
        
        viewController.present(alert, animated: true)
    }
    
    private func openImagePicker(for index: Int, sourceType: UIImagePickerController.SourceType, in viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.accessibilityHint = "\(index)"
        
        viewController.present(imagePicker, animated: true)
    }
    
    private func openDocumentPicker(for index: Int, in viewController: UIViewController) {
        let documentTypes = ["public.image", "com.adobe.pdf", "public.item"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.accessibilityHint = "\(index)"
        
        viewController.present(documentPicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension DocumentAttachmentCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage,
              let indexString = picker.accessibilityHint,
              let index = Int(indexString) else {
            picker.dismiss(animated: true)
            return
        }
        
        // Store image
        uploadedDocuments[index] = image
        
        // Update cell image
        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? DocAttachCollectionCell {
            cell.anImageIcon.image = image
        }
        
        // Notify delegate
        let documentName = DocAttachCollectionCell.documentLabels[index]
        delegate?.documentDidUpload(documentName: documentName, document: image, documentIndex: index)
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension DocumentAttachmentCell: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
              let indexString = controller.accessibilityHint,
              let index = Int(indexString) else { return }
        
        // Store document URL
        uploadedDocuments[index] = url
        
        // Update cell icon
        if let cell = docCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? DocAttachCollectionCell {
            cell.anImageIcon.image = UIImage(systemName: "doc.fill")
        }
        
        // Notify delegate
        let documentName = DocAttachCollectionCell.documentLabels[index]
        delegate?.documentDidUpload(documentName: documentName, document: url, documentIndex: index)
        
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
