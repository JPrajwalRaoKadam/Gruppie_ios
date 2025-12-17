//import UIKit
//
//class EditSubMarksTableViewCell: UITableViewCell {
//    @IBOutlet weak var obtainedMarks: UITextField!
//    @IBOutlet weak var subMaxMarks: UILabel!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//}
//
//
import UIKit

class EditSubMarksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subMaxMarks: UILabel!
    @IBOutlet weak var obtainedMarks: UITextField!
    
    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        obtainedMarks.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc private func textChanged() {
        onTextChanged?(obtainedMarks.text ?? "")
    }
    
    func configureSubMark(subMark: SubMarks) {
        subMaxMarks.text = subMark.maxMarks
        obtainedMarks.text = subMark.actualMarks
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subMaxMarks.text = nil
        obtainedMarks.text = nil
        onTextChanged = nil
    }
}
