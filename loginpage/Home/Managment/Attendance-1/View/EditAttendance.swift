import UIKit

// MARK: - Delegate Protocol
protocol EditAttendanceDelegate: AnyObject {
    /// Called when user taps Delete
    func didTapDeleteAttendance(attendanceId: String)
    /// Called when user taps Save/Edit
    func didTapEditAttendance(status: String, attendanceId: String, userId: String)
}

/// A custom popup view to edit or delete attendance
class EditAttendance: UIView {
    // MARK: - Outlets
    @IBOutlet weak var attendanceStatus: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var teacherName: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var periodNumber: UITextField!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentName: UILabel!

    // MARK: - Delegate & Data
    weak var delegate: EditAttendanceDelegate?
    var attendanceId: String?
    var userId: String?

    // MARK: - Load from nib
    class func loadFromNib() -> EditAttendance? {
        return Bundle.main.loadNibNamed("EditAttendance", owner: nil, options: nil)?.first as? EditAttendance
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        layer.masksToBounds = true
        setupDropdownTap() // Dismiss dropdown on outside tap
    }

    // MARK: - Public Configuration
    /// Configure the view with existing attendance data
    func configure(studentName: String,
                   attendanceId: String,
                   userId: String,
                   status: String,
                   date: String,
                   teacher: String,
                   subject: String,
                   period: String) {
        studentNameLabel.text = studentName
        self.attendanceId = attendanceId
        self.userId = userId
        attendanceStatus.text = status
        self.date.text = date
        teacherName.text = teacher
        self.subject.text = subject
        periodNumber.text = period
    }

    // MARK: - Button Actions
    @IBAction func deleteButton(_ sender: Any) {
        guard let id = attendanceId else { return }
        delegate?.didTapDeleteAttendance(attendanceId: id)
        removeFromSuperview()
    }

    @IBAction func editButton(_ sender: Any) {
        guard let statusText = attendanceStatus.text,
              let id = attendanceId,
              let uid = userId else {
            print("❌ Missing data for edit")
            return
        }
        delegate?.didTapEditAttendance(status: statusText,
                                       attendanceId: id,
                                       userId: uid)
        removeFromSuperview()
    }

    // MARK: - Dropdown for Status
    @IBAction func dropdown(_ sender: UIButton) {
        toggleDropdown()
    }
    

    // MARK: - Private Dropdown
    private let dropdownTag = 9999
    private func toggleDropdown() {
        if let existing = viewWithTag(dropdownTag) {
            removeDropdown(existing)
            return
        }
        showDropdown()
    }

//    private func showDropdown() {
//        guard let parent = attendanceStatus.superview else { return }
//        // Calculate frame next to textField
//        let tfFrame = attendanceStatus.convert(attendanceStatus.bounds, to: self)
//        let menu = UIView(frame: CGRect(x: tfFrame.minX,
//                                        y: tfFrame.maxY + 5,
//                                        width: attendanceStatus.frame.width,
//                                        height: 120))
//        menu.backgroundColor = .white
//        menu.tag = dropdownTag
//        menu.layer.cornerRadius = 8
//        menu.layer.shadowColor = UIColor.black.cgColor
//        menu.layer.shadowOpacity = 0.2
//
//        let options = ["present", "absent"]
//        for (i, opt) in options.enumerated() {
//            let btn = UIButton(frame: CGRect(x: 0,
//                                             y: CGFloat(i) * 30,
//                                             width: menu.frame.width,
//                                             height: 30))
//            btn.setTitle(opt.capitalized, for: .normal)
//            btn.setTitleColor(.darkText, for: .normal)
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            btn.tag = i
//            btn.addTarget(self, action: #selector(statusSelected(_:)), for: .touchUpInside)
//            menu.addSubview(btn)
//        }
//
//        addSubview(menu)
//    }
    private func showDropdown() {
        let options = ["present", "absent"]
        let optionHeight: CGFloat = 30
        let menuHeight = optionHeight * CGFloat(options.count)

        // Calculate frame next to textField
        let tfFrame = attendanceStatus.convert(attendanceStatus.bounds, to: self)
        let menu = UIView(frame: CGRect(
            x: tfFrame.minX,
            y: tfFrame.maxY + 5,
            width: attendanceStatus.frame.width,
            height: menuHeight
        ))
        menu.backgroundColor = .white
        menu.tag = dropdownTag
        menu.layer.cornerRadius = 8
        menu.layer.shadowColor = UIColor.black.cgColor
        menu.layer.shadowOpacity = 0.2

        for (i, opt) in options.enumerated() {
            let btn = UIButton(frame: CGRect(
                x: 0,
                y: CGFloat(i) * optionHeight,
                width: menu.frame.width,
                height: optionHeight
            ))
            btn.setTitle(opt.capitalized, for: .normal)
            btn.setTitleColor(.darkText, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.tag = i
            btn.addTarget(self, action: #selector(statusSelected(_:)), for: .touchUpInside)
            menu.addSubview(btn)
        }

        addSubview(menu)
    }


    @objc private func statusSelected(_ sender: UIButton) {
        let options = ["present", "absent"]
        let chosen = options[sender.tag]
        attendanceStatus.text = chosen
        if let menu = viewWithTag(dropdownTag) {
            removeDropdown(menu)
        }
    }

    private func removeDropdown(_ dropdown: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            dropdown.alpha = 0
        }) { _ in
            dropdown.removeFromSuperview()
        }
    }

    // Dismiss on outside tap
    private func setupDropdownTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if let menu = viewWithTag(dropdownTag), !menu.frame.contains(location) {
            removeDropdown(menu)
        }
    }
}
