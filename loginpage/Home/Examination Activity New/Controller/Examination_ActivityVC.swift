//
//  Examination_ActivityVC.swift
//  loginpage
//
//  Created by apple on 11/09/25.
//

import UIKit

class Examination_ActivityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamId: String = ""
    var className: String = ""
    var subjects: [SubjectData] = [] // Store fetched subjects
    var currentRole: String?
    var userId:String = ""
    
    @IBOutlet weak var Notes_Video: UILabel!
    @IBOutlet weak var marks_card: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marks_card.delegate = self
        marks_card.dataSource = self
        marks_card.register(UINib(nibName: "ClassNameExamCell", bundle: nil), forCellReuseIdentifier: "ClassNameExamCell")
        //print("gid NV: \(groupId) tid NV: \(subjects.teamId)")
        enableKeyboardDismissOnTap()
        print("userid in Examination_ActivityVC :\(userId)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassNameExamCell", for: indexPath) as? ClassNameExamCell else {
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
    
    func navigateToSubjectStaffVC(subjects: [SubjectData], teamId: String, selectedSubject: SubjectData) {
        let storyboard = UIStoryboard(name: "Examination Activity", bundle: nil)
        if let examlist = storyboard.instantiateViewController(withIdentifier: "Exam_listVC") as? Exam_listVC {
            examlist.groupId = self.groupId
            examlist.userId = self.userId
            examlist.teamId = teamId
            examlist.currentRole = self.currentRole
            examlist.className =  self.className
                  print("✅ Selected teamId: \(teamId)")
            self.navigationController?.pushViewController(examlist, animated: true)
        }
    }

}


