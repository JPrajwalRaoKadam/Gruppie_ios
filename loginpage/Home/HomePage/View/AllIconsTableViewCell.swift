//protocol AllIconsTableViewCellDelegate: AnyObject {
//    func collectionViewHeightDidChange(_ height: CGFloat, forCell cell: AllIconsTableViewCell)
//}

//navi
import UIKit
protocol AllIconsTableViewCellDelegate: AnyObject {
    func didSelectIcon(_ featureIcon: FeatureIcon)
}
class AllIconsTableViewCell: UITableViewCell {

    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: AllIconsTableViewCellDelegate?
    var featureIcons: [FeatureIcon] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        iconCollectionView.register(UINib(nibName: "AlliconsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlliconsCollectionViewCell")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }

    func configure(with activity: GroupData) {
//        activityLabel.text = activity.activity
        featureIcons = activity.featureIcons
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
        delegate?.didSelectIcon(featureIcons[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
