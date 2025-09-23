import UIKit

protocol EditAttendanceDelegate: AnyObject {
    func didTapDeleteAttendance(attendanceId: String)
    func didTapEditAttendance(status: String, attendanceId: String, userId: String)
}

class EditAttendance: UIView {
    // MARK: - Outlets
    @IBOutlet weak var attendanceStatus: UITextField!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
  //  @IBOutlet weak var studentName: UILabel!

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
        layer.cornerRadius = 10
        layer.masksToBounds = true
        setupDropdownTap() // Dismiss dropdown on outside tap
        cancelButtonOutlet.layer.cornerRadius =  10
        editButtonOutlet.layer.cornerRadius =  10
        attendanceStatus.layer.cornerRadius =  10
        attendanceStatus.layer.masksToBounds = true
        editButtonOutlet.layer.masksToBounds = true
        editButtonOutlet.clipsToBounds = true
    }
    func configure(studentName: String,
                   attendanceId: String,
                   userId: String,
                   status: String) {
        studentNameLabel.text = studentName
        self.attendanceId = attendanceId
        self.userId = userId
        attendanceStatus.text = status

        // 👇 Hide edit button if status is "holiday"
        if status.lowercased() == "holiday" {
            editButtonOutlet.isHidden = true
        } else {
            editButtonOutlet.isHidden = false
        }
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.removeFromSuperview()
    }

    
   @IBAction func deleteButton(_ sender: Any) {
        guard let id = attendanceId else { return }

        // Create alert
        let alert = UIAlertController(title: "Confirm Delete",
                                      message: "Are you sure you want to delete this attendance?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.delegate?.didTapDeleteAttendance(attendanceId: id)
            self.removeFromSuperview()
        }))

        // ✅ Fix: Get key window and root view controller safely
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            var presentingVC = rootVC
            while let presented = presentingVC.presentedViewController {
                presentingVC = presented
            }
            presentingVC.present(alert, animated: true, completion: nil)
        } else {
            print("❌ Could not find a valid view controller to present alert.")
        }
    }

    @IBAction func editButton(_ sender: Any) {
        guard let statusText = attendanceStatus.text,
              let id = attendanceId,
              let uid = userId else {
            print("❌ Missing data for edit")
            return
        }
        print("📤 Sending edited status: \(statusText)")
        delegate?.didTapEditAttendance(status: statusText,attendanceId: id, userId: uid)
        DispatchQueue.main.async {
               self.removeFromSuperview()
           }
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
        attendanceStatus.resignFirstResponder()
        attendanceStatus.setNeedsDisplay()

        print("✅ Selected status: \(chosen)")

        // Only remove dropdown — not the entire view!
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
