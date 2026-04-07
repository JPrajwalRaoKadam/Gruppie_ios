import UIKit

class TimetableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var noOfPeriod: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(with classItem: DailyClass) {
        className.text = classItem.className ?? "No Class"
        
        // Get scheduled periods (default to 0 if nil)
        let scheduledPeriods = classItem.scheduledPeriods ?? 0
        
        // Always show period count, even if 0
        noOfPeriod.text = "Periods: \(scheduledPeriods)"
        
        // Optional: You can keep the color black for consistency
        noOfPeriod.textColor = .black
    }
}
