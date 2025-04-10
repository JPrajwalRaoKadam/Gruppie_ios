//
//  AddSubjectViewController.swift
//  loginpage
//
//  Created by apple on 13/03/25.
//

import UIKit

class AddSubjectStaffViewController: UIViewController {
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var staffTableView: UITableView!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var searchBox: UITextField!
    var staffList: [StaffSub] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        staffTableView.delegate = self
        staffTableView.dataSource = self
        staffTableView.register(UINib(nibName: "AddSubjectStaffTableViewCell", bundle: nil), forCellReuseIdentifier: "AddSubjectStaffTableViewCell")
    }
}
extension AddSubjectStaffViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubjectStaffTableViewCell", for: indexPath) as? AddSubjectStaffTableViewCell else {
            return UITableViewCell()
        }
        
        let staff = staffList[indexPath.row]
        cell.staffNames.text = staff.name
        cell.checkBoxStaff.isSelected = staff.isSelected

        // Add target to handle checkbox selection
        cell.checkBoxStaff.tag = indexPath.row
        cell.checkBoxStaff.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle selection
        staffList[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Checkbox toggle function
    @objc func checkBoxTapped(_ sender: UIButton) {
        let index = sender.tag
        staffList[index].isSelected.toggle()
        staffTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

