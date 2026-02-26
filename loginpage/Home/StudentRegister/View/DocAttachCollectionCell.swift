
import UIKit

// Protocol for document selection
protocol DocAttachCollectionCellDelegate: AnyObject {
    func didTapImageIcon(at index: Int)
}

class DocAttachCollectionCell: UICollectionViewCell {
    @IBOutlet weak var anImageIcon: UIImageView!
    @IBOutlet weak var aLabelTeamNameIcon: UILabel!
    
    weak var delegate: DocAttachCollectionCellDelegate?
    private var cellIndex: Int = 0
    
    static let documentLabels: [String] = [
          "Student Photo",
          "Father Photo",
          "Mother Photo",
          "Guardian Photo",
          "Birth Certificate",
          "Aadhaar Card",
          "Transfer Certificate (TC)",  // Updated to match API
          "Previous Mark Sheet",        // Updated to match API
          "Caste Certificate",
          "Income Certificate",
          "Medical Certificate",
          "Address Proof",
          "Other 1",                    // Updated to match API
          "Other 2",                    // Updated to match API
          "Other 3"                     // Updated to match API
      ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        // Make image view tappable
        anImageIcon.isUserInteractionEnabled = true
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        anImageIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageTapped() {
        delegate?.didTapImageIcon(at: cellIndex)
    }
  
    func configureCell(at index: Int) {
        guard index >= 0 && index < DocAttachCollectionCell.documentLabels.count else {
            aLabelTeamNameIcon.text = "Unknown"
            anImageIcon.image = UIImage(systemName: "doc")
            return
        }
        cellIndex = index
        aLabelTeamNameIcon.text = DocAttachCollectionCell.documentLabels[index]
    }
      
    override func prepareForReuse() {
        super.prepareForReuse()
        anImageIcon.image = nil
        aLabelTeamNameIcon.text = nil
        cellIndex = 0
    }
}
