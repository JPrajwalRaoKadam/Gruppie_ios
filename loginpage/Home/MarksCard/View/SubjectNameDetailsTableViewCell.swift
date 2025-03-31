//
//  SubjectNameDetailsTableViewCell.swift
//  loginpage
//
//  Created by apple on 13/03/25.
//

import UIKit

protocol SubjectMarksChangeProtocol: AnyObject {
    func sendChangedMarks(maeks: String)
}
class SubjectNameDetailsTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var obtainedMarksTextFeild: UITextField!
    weak var delegate: SubjectMarksChangeProtocol?
    
    // Closure to send data back
    var onMarksChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup target for text field changes
        self.obtainedMarksTextFeild.delegate = self
        obtainedMarksTextFeild.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        // Call the closure when text changes
        onMarksChanged?(textField.text ?? "")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.delegate?.sendChangedMarks(maeks: text)
    }
}
