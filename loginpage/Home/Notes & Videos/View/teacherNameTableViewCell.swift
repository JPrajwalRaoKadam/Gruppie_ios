//
//  teacherNameTableViewCell.swift
//  loginpage
//
//  Created by apple on 11/04/25.
//
protocol TeacherCellDelegate: AnyObject {
    func didToggleCheckBox(for staffId: String, isSelected: Bool)
}

import UIKit

 class teacherNameTableViewCell: UITableViewCell {
    @IBOutlet weak var checkBoxStaff: UIButton!
    @IBOutlet weak var staffNames: UILabel!

    weak var delegate: TeacherCellDelegate?
    private var staffId: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckButton(initiallySelected: false)
    }

    func configure(with name: String, staffId: String, isSelected: Bool) {
        self.staffNames.text = name
        self.staffId = staffId
        checkBoxStaff.isSelected = isSelected
    }

    private func setupCheckButton(initiallySelected: Bool) {
        checkBoxStaff.setImage(UIImage(systemName: "square"), for: .normal)
        checkBoxStaff.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkBoxStaff.isSelected = initiallySelected
        checkBoxStaff.backgroundColor = .white
    }

    @IBAction func checkBoxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.didToggleCheckBox(for: staffId, isSelected: sender.isSelected)
    }
}


