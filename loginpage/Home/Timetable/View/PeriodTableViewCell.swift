import UIKit

class PeriodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Period: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // ✅ Configure cell with PeriodData
    func configure(with periodData: PeriodData) {
        // Period number
        if let periodNumber = periodData.period?.trimmingCharacters(in: .whitespacesAndNewlines) {
            Period.text = "Period \(periodNumber)"
        } else {
            Period.text = "Period N/A"
        }
        
        // Teacher's name
        name.text = periodData.name
        
        // Subject name
        if let firstSubject = periodData.subjectsHandled?.first {
            subjectName.text = firstSubject.subjectName
        } else {
            subjectName.text = "No Subject"
        }
        
        // Start & End Time with formatting
        startTime.text = formatTime(periodData.startTime)
        endTime.text = formatTime(periodData.endTime)
    }
    
    // 🔹 Format time from "HH:mm" to "hh:mm a"
    private func formatTime(_ time: String?) -> String {
        guard let time = time else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: date)
        }
        return time
    }
}
