//protocol AllIconsTableViewCellDelegate: AnyObject {
//    func collectionViewHeightDidChange(_ height: CGFloat, forCell cell: AllIconsTableViewCell)
//}

//navi
import UIKit
protocol AllIconsTableViewCellDelegate: AnyObject {
    func didSelectIcon(_ featureIcon: FeatureIcon)
}
class AllIconsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityHeader: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    weak var delegate: AllIconsTableViewCellDelegate?
    var featureIcons: [FeatureIcon] = []
    private var isProcessingSelection = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        iconCollectionView.register(UINib(nibName: "AlliconsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlliconsCollectionViewCell")
        
        // Card View Styling
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = false
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }

    func configure(with activity: GroupData) {
        activityHeader.text = activity.activity
        featureIcons = activity.featureIcons
        print("........1234....\(featureIcons)")
        iconCollectionView.reloadData()
        DispatchQueue.main.async {
            self.updateCollectionViewHeight()
        }
    }

    private func updateCollectionViewHeight() {
        let numberOfItems = featureIcons.count
        let numberOfCellsPerRow: CGFloat = 4
        let spacing: CGFloat = 10

        let collectionViewWidth = iconCollectionView.bounds.width
        let cellWidth = (collectionViewWidth - (numberOfCellsPerRow - 1) * spacing) / numberOfCellsPerRow
        let numberOfRows = ceil(CGFloat(numberOfItems) / numberOfCellsPerRow)
        let totalHeight = (cellWidth * numberOfRows) + ((numberOfRows - 1) * spacing)

        collectionViewHeightConstraint.constant = totalHeight

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

extension AllIconsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featureIcons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlliconsCollectionViewCell", for: indexPath) as! AlliconsCollectionViewCell
        cell.configure(with: featureIcons[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 4
        let spacing: CGFloat = 10
        let totalSpacing = (numberOfCellsPerRow - 1) * spacing
        let cellWidth = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingSelection else {
               print("Tap ignored – already processing.")
               return
           }

        delegate?.didSelectIcon(featureIcons[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
