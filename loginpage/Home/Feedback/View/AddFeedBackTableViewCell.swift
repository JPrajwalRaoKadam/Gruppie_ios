
import UIKit

class AddFeedBackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var QuestionNo: UILabel!
    @IBOutlet weak var Question: UITextField!
    @IBOutlet weak var Marks:  UITextField!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
