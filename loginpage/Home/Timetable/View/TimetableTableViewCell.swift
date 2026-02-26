import UIKit

class TimetableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var noOfPeriod: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureCell(with classItem: DailyClass) {
           className.text = classItem.className ?? "No Class"
           noOfPeriod.text = "Periods: \(classItem.totalPeriods ?? 0)"       }
}
