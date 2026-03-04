import UIKit

class AssignTeacherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    var isSelectedForAssignment: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // REMOVE THIS LINE - let the view controller handle the button action
        // enableButton.addTarget(self, action: #selector(enableButtonTapped), for: .touchUpInside)
        updateButtonAppearance()
    }

    private func updateButtonAppearance() {
        if isSelectedForAssignment {
            // ✅ Show green tick when selected
            enableButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            enableButton.tintColor = .systemGreen
        } else {
            // Default state: no image at all
            enableButton.setImage(nil, for: .normal)
        }
        
        // Remove any background color/highlight
        enableButton.backgroundColor = .clear
    }

    // REMOVE THIS METHOD - let the view controller handle the toggle
    // @objc private func enableButtonTapped() {
    //     // Toggle selection
    //     isSelectedForAssignment.toggle()
    // }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
