import UIKit

class DetailTimeTableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var startingTime: UILabel!
    @IBOutlet weak var endingTime: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var teacher: UILabel!
    
    @IBOutlet weak var startingTimeLabel: UILabel!
    @IBOutlet weak var endingTimeLabel: UILabel!

    var onTimeSelection: ((Bool) -> Void)?
    var onSubjectSelection: (() -> Void)?
    var onTeacherSelection: (() -> Void)?
    var onPeriodSelection: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTapGesture(to: period, action: #selector(didTapPeriod))
        addTapGesture(to: startingTime, action: #selector(didTapStartingTime))
        addTapGesture(to: endingTime, action: #selector(didTapEndingTime))
        addTapGesture(to: subject, action: #selector(didTapSubject))
        addTapGesture(to: teacher, action: #selector(didTapTeacher))
    }
    
    private func addTapGesture(to label: UILabel, action: Selector) {
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        label.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapSubject() {
        onSubjectSelection?()
    }

    @objc func didTapTeacher() {
        onTeacherSelection?()
    }

    @objc func didTapStartingTime() {
        onTimeSelection?(true) // true → starting time
    }

    @objc func didTapEndingTime() {
        onTimeSelection?(false) // false → ending time
    }

    @objc func didTapPeriod() {
        onPeriodSelection?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with session: Session) {
        period.text = "\(session.period)"
        startingTime.text = session.startTime
        endingTime.text = session.endTime
        subject.text = session.subjectName
        teacher.text = session.teacherName ?? ""
        
        let defaultColor = UIColor.black
        period.textColor = defaultColor
        subject.textColor = defaultColor
        teacher.textColor = defaultColor
        startingTime.textColor = defaultColor
        endingTime.textColor = defaultColor
    }
    
    func configureAsEmpty() {
        period.text = "0"
        subject.text = "Subject"
        teacher.text = "Teacher"
        startingTime.text = "StartTime"
        endingTime.text = "EndTime"
        
        let placeholderColor = UIColor.lightGray
        period.textColor = placeholderColor
        subject.textColor = placeholderColor
        teacher.textColor = placeholderColor
        startingTime.textColor = placeholderColor
        endingTime.textColor = placeholderColor
    }
}
