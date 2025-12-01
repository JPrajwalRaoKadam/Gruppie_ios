//
//  CreatePostViewController.swift
//  loginpage
//
//  Created by apple on 19/11/25.
//

import UIKit

protocol AttachmentCellDelegate: AnyObject {
    func didTapImageAttachment()
    func didTapVideoAttachment()
    func didTapYoutubeAttachment()
    func didTapDocumentAttachment()
    func didTapAudioAttachment()
}

class MediaSelectionVC: UIViewController {
    
    weak var delegate: AttachmentCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
        
        @IBAction func btnImagesAttachmentAction(_ sender: Any) {
            delegate?.didTapImageAttachment()
            dismiss(animated: true)
        }
        
        @IBAction func btnVideoAttachmentAction(_ sender: Any) {
            delegate?.didTapVideoAttachment()
            dismiss(animated: true)
        }
        
        @IBAction func btnYoutubeAttachmentAction(_ sender: Any) {
            delegate?.didTapYoutubeAttachment()
            dismiss(animated: true)
        }
        
        @IBAction func btnDocAttachmentAction(_ sender: Any) {
            delegate?.didTapDocumentAttachment()
            dismiss(animated: true)
        }
        
        @IBAction func btnAudioAttachmentAction(_ sender: Any) {
            delegate?.didTapAudioAttachment()
            dismiss(animated: true)
        }
    
}
