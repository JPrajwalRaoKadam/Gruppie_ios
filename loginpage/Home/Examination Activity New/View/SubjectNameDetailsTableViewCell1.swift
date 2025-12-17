import UIKit

class SubjectNameDetailsTableViewCell1: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var obtainedMarksTextFeild: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    var onMarksChanged: ((String, String?, String?) -> Void)?
    var onEditingBegan: (() -> Void)?
    var onEditingEnded: (() -> Void)?
    var onEyeButtonTapped: (() -> Void)?
    
    private var studentId: String?
    private var subjectId: String?
    private var subjectDetail: SubjectMarksDetails?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
        self.selectionStyle = .none
        
        // CRITICAL: Add tap gesture to the ENTIRE CELL for editing
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.contentView.addGestureRecognizer(cellTapGesture)
        
        // Also add tap gesture to text field
        let textFieldTapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
        obtainedMarksTextFeild.addGestureRecognizer(textFieldTapGesture)
    }
    
    
    @IBAction func eyeTapped(_ sender: Any) {
        print("👁️ Eye button tapped for subject: \(subjectDetail?.subjectName ?? "")")
        onEyeButtonTapped?()
        
    }
    
    @objc private func cellTapped() {
        print("📱 Cell tapped - starting editing")
        obtainedMarksTextFeild.becomeFirstResponder()
    }
    
    @objc private func textFieldTapped() {
        print("⌨️ Text field tapped - starting editing")
        obtainedMarksTextFeild.becomeFirstResponder()
    }
    
    private func setupTextField() {
        obtainedMarksTextFeild.isUserInteractionEnabled = true
        obtainedMarksTextFeild.isEnabled = true
        obtainedMarksTextFeild.keyboardType = .numberPad
        obtainedMarksTextFeild.delegate = self
        
        obtainedMarksTextFeild.isExclusiveTouch = true
        
        obtainedMarksTextFeild.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        }
    
    @objc private func doneButtonTapped() {
        obtainedMarksTextFeild.resignFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        print("📝 Text changed: \(textField.text ?? "")")
        onMarksChanged?(textField.text ?? "", studentId, subjectId)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("🎯 Text field began editing")
        onEditingBegan?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("🏁 Text field ended editing")
        onEditingEnded?()
        
        let text = textField.text ?? ""
        onMarksChanged?(text, studentId, subjectId)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace
        if string.isEmpty { return true }
        
        // Only allow digits
        let allowedCharacters = CharacterSet.decimalDigits
        return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
    
    func configure(with subjectDetail: SubjectMarksDetails, studentId: String?) {
        self.studentId = studentId
        self.subjectId = subjectDetail.subjectId
        self.subjectDetail = subjectDetail
        
        subName.text = subjectDetail.subjectName
        obtainedMarksTextFeild.text = subjectDetail.actualMarks
        minLabel.text = "\(subjectDetail.minMarks) - \(subjectDetail.maxMarks)"
        
        // Make sure text field is enabled and responsive
        obtainedMarksTextFeild.isEnabled = true
        obtainedMarksTextFeild.isUserInteractionEnabled = true
        
        // ✅ Show/Hide eye button based on subMarks data
        if !subjectDetail.subMarks.isEmpty {
            eyeButton.isHidden = false
            eyeButton.isEnabled = true
            print("👁️ Showing eye button for \(subjectDetail.subjectName ?? ""): \(subjectDetail.subMarks.count) sub marks")
        } else {
            eyeButton.isHidden = true
            eyeButton.isEnabled = false
            print("👁️ Hiding eye button for \(subjectDetail.subjectName ?? ""): No sub marks")
        }
        
        print("🔄 Cell configured for: \(subjectDetail.subjectName ?? "") - Student: \(studentId ?? "")")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        obtainedMarksTextFeild.text = nil
        subName.text = nil
        minLabel.text = nil
        studentId = nil
        subjectId = nil
        subjectDetail = nil
        eyeButton.isHidden = true // Reset eye button
        eyeButton.isEnabled = false
    }
}
