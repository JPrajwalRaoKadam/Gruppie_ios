////
////  A2SubjectTableViewCell.swift
////  loginpage
////
////  Created by apple on 08/04/25.
////
//
//import UIKit
//
//class A2SubjectTableViewCell: UITableViewCell {
//    @IBOutlet weak var SubjectsName: UILabel!
//    @IBOutlet weak var checkButton: UIButton!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        setupCheckButton(initiallySelected: false)
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    private func setupCheckButton(initiallySelected: Bool) {
//        checkButton.setImage(UIImage(systemName: "square"), for: .normal)               // Unchecked
//        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
//        checkButton.isSelected = initiallySelected                                      // Initially checked
//        checkButton.backgroundColor = .white                                            // ✅ Keep background white
//    }
//    
//}
import UIKit
class A2SubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectsName: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var subjectId: String = ""
    var onCheckButtonTapped: ((String, Bool) -> Void)? // (subjectId, isSelected)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckButton(initiallySelected: false)
    }

    private func setupCheckButton(initiallySelected: Bool) {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked
        checkButton.isSelected = initiallySelected
        checkButton.backgroundColor = .white
    }

    @IBAction func checkButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        onCheckButtonTapped?(subjectId, sender.isSelected)
    }
    
}

