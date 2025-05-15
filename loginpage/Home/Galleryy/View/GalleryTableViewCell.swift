
import UIKit

class GalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var ImageUrl: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var Date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
