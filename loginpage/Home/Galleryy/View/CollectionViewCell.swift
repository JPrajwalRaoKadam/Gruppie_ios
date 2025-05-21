import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var SelectButton: UIButton!

    // Add this play icon image view (programmatically)
    let playIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "play.circle.fill") // system or custom icon
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // hidden by default
        return imageView
    }()

    var isSelectedCell: Bool = false {
        didSet {
            updateSelectionAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayIcon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayIcon()
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

    private func setupPlayIcon() {
        contentView.addSubview(playIcon)

        NSLayoutConstraint.activate([
            playIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 30),
            playIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
