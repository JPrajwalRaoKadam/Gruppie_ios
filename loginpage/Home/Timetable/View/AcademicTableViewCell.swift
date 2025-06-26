

import UIKit

class AcademicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var startingTime: UILabel!
    @IBOutlet weak var endingTime: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var teacher: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
