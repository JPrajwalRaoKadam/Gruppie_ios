import UIKit

class AbsentStudentTableViewCell: UITableViewCell {

    @IBOutlet weak var absentStudentName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(name: String) {
        absentStudentName.text = name
    }
}
