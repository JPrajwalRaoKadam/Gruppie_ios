import UIKit

class PeriodDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var noOfPeriod: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // 🔹 Configure method for binding
    func configure(dayText: String?, periodText: String?) {
        day.text = dayText ?? ""
        noOfPeriod.text = periodText ?? ""
    }
}
