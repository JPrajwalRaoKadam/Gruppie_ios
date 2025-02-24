//protocol AllIconsTableViewCellDelegate: AnyObject {
//    func collectionViewHeightDidChange(_ height: CGFloat, forCell cell: AllIconsTableViewCell)
//}

//navi
import UIKit
protocol AllIconsTableViewCellDelegate: AnyObject {
    func didSelectIcon(_ featureIcon: FeatureIcon)
}


class AllIconsTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    //navi
    weak var delegate: AllIconsTableViewCellDelegate?
    
    var featureIcons : [FeatureIcon] = []
    var groupDatas: [GroupData] = []
    @IBOutlet weak var ActivityLabel: UILabel!
    @IBOutlet var iconCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // if iconCollectionView != nil {
               iconCollectionView.delegate = self
               iconCollectionView.dataSource = self
               iconCollectionView.register(UINib(nibName: "AlliconsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlliconsCollectionViewCell")

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }

    
    func configure(with activity: GroupData) {
        ActivityLabel.text = activity.activity
        featureIcons = activity.featureIcons
        print("Feature Icons Count: \(featureIcons.count)")
        iconCollectionView.reloadData()
        DispatchQueue.main.async {
               self.updateCollectionViewHeight()
           }
    }
    
    func configureActivityNames(indexPath: IndexPath, activity: [GroupData]) {
            // Assuming the names array 'a' is already populated
            if indexPath.row < activity.count {
                let activity = activity[indexPath.row] // Get name based on row index
                ActivityLabel.text = activity.activity // Assign name to the Profile label
             // let featureIcon = activity.featureIcons
                featureIcons = activity.featureIcons
            }
        }
    
    
    
     func updateCollectionViewHeight() {
        DispatchQueue.main.async {
            let numberOfItems = self.featureIcons.count // Total items in the collection view
            let numberOfCellsPerRow: CGFloat = 4 // Number of cells per row
            let spacing: CGFloat = 10 // Spacing between cells (adjust as per your layout)

            // Calculate cell width
            let collectionViewWidth = self.iconCollectionView.bounds.width
            let cellWidth = (collectionViewWidth - (numberOfCellsPerRow - 1) * spacing) / numberOfCellsPerRow

            // Calculate number of rows
            let numberOfRows = ceil(CGFloat(numberOfItems) / numberOfCellsPerRow)

            // Calculate total height
            let totalHeight = (cellWidth * numberOfRows) + ((numberOfRows - 1) * spacing)

            // Update height constraint
            self.collectionViewHeightConstraint.constant = totalHeight

            // Animate layout update (optional)
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }


    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featureIcons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlliconsCollectionViewCell", for: indexPath) as? AlliconsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: featureIcons[indexPath.row])
        return cell
    }

    // MARK: - Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 4
        let spacing: CGFloat = 10
        let totalSpacing = (numberOfCellsPerRow - 1) * spacing
        let cellWidth = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeatureIcon = featureIcons[indexPath.row]
        delegate?.didSelectIcon(selectedFeatureIcon) // Notify the delegate
    }

}
