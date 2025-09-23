//
//  Notes&Videos.swift
//  loginpage
//
//  Created by apple on 10/04/25.
//

import UIKit

class Notes_VideosVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamId: String = ""
    var className: String = ""
    var subjects: [SubjectData] = [] // Store fetched subjects
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
        subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "classNameTableViewCell", for: indexPath) as? classNameTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = subjects[indexPath.row]
        cell.configure(with: subject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubject = subjects[indexPath.row]
        let teamId = selectedSubject.teamId
        self.className = selectedSubject.name
        print("Extracted teamId: \(teamId)")
        self.navigateToSubjectStaffVC(subjects: self.subjects, teamId: teamId, selectedSubject: selectedSubject)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension Notes_VideosVC {

//    func navigateToSubjectStaffVC() {
//        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
//        if let SubjectNotes_VideosVC = storyboard.instantiateViewController(withIdentifier: "SubjectNotes_VideosVC") as? SubjectNotes_VideosVC {
////            SubjectNotes_VideosVC.SubjectStaff = staffDetails
//            SubjectNotes_VideosVC.className = self.className
//            SubjectNotes_VideosVC.groupId = self.groupId  // Pass groupId
//            SubjectNotes_VideosVC.teamId = self.teamId    // Pass teamId
//           // SubjectNotes_VideosVC.passedSubjectId = subjectId // Pass subjectId
//
//            self.navigationController?.pushViewController(SubjectNotes_VideosVC, animated: true)
//        }
//    }
    
//    func navigateToSubjectStaffVC(subjects: [SubjectData], teamId: [String], selectedSubject: Int) {
//        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
//        if let SubjectNotes_VideosVC = storyboard.instantiateViewController(withIdentifier: "SubjectNotes_VideosVC") as? SubjectNotes_VideosVC {
//            SubjectNotes_VideosVC.groupId = self.groupId
//            SubjectNotes_VideosVC.clsName = self.className
//            SubjectNotes_VideosVC.subjects = subjects
//            SubjectNotes_VideosVC.token = TokenManager.shared.getToken() ?? ""
//            SubjectNotes_VideosVC.teamId = teamId[selectedSubject]
//            print("✅ Selected teamId: \(teamId[selectedSubject])")
//            self.navigationController?.pushViewController(SubjectNotes_VideosVC, animated: true)
//        }
//    }

    func navigateToSubjectStaffVC(subjects: [SubjectData], teamId: String, selectedSubject: SubjectData) {
        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
        if let subjectNotesVC = storyboard.instantiateViewController(withIdentifier: "SubjectNotes_VideosVC") as? SubjectNotes_VideosVC {
            subjectNotesVC.groupId = self.groupId
            subjectNotesVC.clsName = self.className
            subjectNotesVC.subjects = subjects
            subjectNotesVC.token = TokenManager.shared.getToken() ?? ""
            subjectNotesVC.teamId = teamId
            subjectNotesVC.currentRole = self.currentRole
            print("✅ Selected teamId: \(teamId)")
            self.navigationController?.pushViewController(subjectNotesVC, animated: true)
        }
    }
}
