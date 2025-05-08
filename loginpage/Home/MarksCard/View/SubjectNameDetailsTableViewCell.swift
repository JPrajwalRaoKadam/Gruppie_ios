//
//  SubjectNameDetailsTableViewCell.swift
//  loginpage
//
//  Created by apple on 13/03/25.
//

//import UIKit
//
//protocol SubjectMarksChangeProtocol: AnyObject {
//    func sendChangedMarks(maeks: String)
//}
//class SubjectNameDetailsTableViewCell: UITableViewCell, UITextFieldDelegate {
//
//    @IBOutlet weak var subName: UILabel!
//    @IBOutlet weak var minLabel: UILabel!
//    @IBOutlet weak var obtainedMarksTextFeild: UITextField!
//    weak var delegate: SubjectMarksChangeProtocol?
//    
//    // Closure to send data back
//    var onMarksChanged: ((String) -> Void)?
//    
//    override func awakeFromNib() {
//           super.awakeFromNib()
//           obtainedMarksTextFeild.delegate = self
//           obtainedMarksTextFeild.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
//       }
//       
//       func textFieldDidEndEditing(_ textField: UITextField) {
//           onMarksChanged?(textField.text ?? "")
//       }
//}

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
           obtainedMarksTextFeild.delegate = self
           obtainedMarksTextFeild.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       }
       
       @objc func textFieldDidChange(_ textField: UITextField) {
           onMarksChanged?(textField.text ?? "")
       }
}
