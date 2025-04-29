//
//  SubjectStaffTableViewCell.swift
//  loginpage
//
//  Created by apple on 12/03/25.
//

import UIKit

class SubjectNotes_videosTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var StaffName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with staff: SubjectStaffSyllabus) {
        SubjectLabel.text = staff.subjectName
           StaffName.text = staff.staffName
       }
    
}
