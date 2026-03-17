//
//  Notes&Videos.swift
//  loginpage
//
//  Created by apple on 10/04/25.
//

import UIKit

class Notes_VideosVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var className: String = ""
    var groupClasses: [GroupClass] = []
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var currentRole: String?
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var Notes_Video: UILabel!
    @IBOutlet weak var Notes_videosTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Notes_videosTV.delegate = self
        Notes_videosTV.dataSource = self
        Notes_videosTV.register(UINib(nibName: "classNameTableViewCell", bundle: nil), forCellReuseIdentifier: "classNameTableViewCell")
        //print("gid NV: \(groupId) tid NV: \(subjects.teamId)")
        enableKeyboardDismissOnTap()
        Notes_videosTV.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "classNameTableViewCell", for: indexPath) as? classNameTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = groupClasses[indexPath.row]
        cell.configure(with: subject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupClass = groupClasses[indexPath.row]
        let teamId = groupClass.id
        self.className = groupClass.name
        print("Extracted teamId: \(teamId)")
        self.navigateToSubjectStaffVC(classId: groupClass.id, groupClass: groupClass)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension Notes_VideosVC {

    func navigateToSubjectStaffVC(classId: String, groupClass: GroupClass) {
        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
        if let subjectNotesVC = storyboard.instantiateViewController(withIdentifier: "SubjectNotes_VideosVC") as? SubjectNotes_VideosVC {
            subjectNotesVC.clsName = self.className
            subjectNotesVC.classId = classId
            subjectNotesVC.groupAcademicYearResponse = self.groupAcademicYearResponse
            print("✅ Selected teamId: \(classId)")
            self.navigationController?.pushViewController(subjectNotesVC, animated: true)
        }
    }
}
