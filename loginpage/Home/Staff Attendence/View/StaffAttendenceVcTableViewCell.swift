import UIKit

class StaffAttendenceVcTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var presentButton: UIButton!
    @IBOutlet weak var absentButton: UIButton!
    @IBOutlet weak var oodButton: UIButton!
    
    var attendanceStatus: String?
    var attendanceChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButtons()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetButtons()
        attendanceStatus = nil
    }
    
    // MARK: - Setup
    private func setupButtons() {
        let checkmarkImage = UIImage(systemName: "checkmark.square.fill")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        let emptyImage = UIImage(systemName: "square")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        [presentButton, absentButton, oodButton].forEach {
            guard let button = $0 else { return }
            
            button.setTitle(nil, for: .normal)
            
            button.setImage(emptyImage, for: .normal)
            button.setImage(checkmarkImage, for: .selected)
            
            button.adjustsImageWhenHighlighted = false
            button.tintColor = .clear
            
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func resetButtons() {
        [presentButton, absentButton, oodButton].forEach {
            $0?.isSelected = false
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        updateSelection(selectedButton: sender)
        
        switch sender {
        case presentButton: attendanceStatus = "Present"
        case absentButton: attendanceStatus = "Absent"
        case oodButton: attendanceStatus = "On Leave"
        default: break
        }
        
        if let status = attendanceStatus {
            attendanceChanged?(status)
        }
    }
    
    private func updateSelection(selectedButton: UIButton) {
        resetButtons()
        selectedButton.isSelected = true
    }
    
    func configure(with status: String?, isOOD: Bool = false) {
        resetButtons()
        
        if isOOD {
            oodButton.isSelected = true
            return
        }
        
        switch status {
        case "Present": presentButton.isSelected = true
        case "Absent": absentButton.isSelected = true
        case "On Leave": oodButton.isSelected = true
        default: break
        }
    }
}
