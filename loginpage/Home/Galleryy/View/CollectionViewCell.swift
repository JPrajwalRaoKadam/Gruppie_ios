import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var SelectButton: UIButton!
//    @IBOutlet weak var playIcon: UIImageView!

    var isSelectedCell: Bool = false {
        didSet {
            updateSelectionAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        SelectButton.layer.cornerRadius = SelectButton.frame.height / 2
        SelectButton.clipsToBounds = true
        SelectButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        SelectButton.tintColor = UIColor.white
        SelectButton.backgroundColor = .clear

        SelectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }

    @objc func selectButtonTapped() {
        isSelectedCell.toggle() 
    }

    func updateSelectionAppearance() {
        if isSelectedCell {
            SelectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            SelectButton.tintColor = UIColor.black
        } else {
            SelectButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            SelectButton.tintColor = UIColor.white
        }
    }
}
