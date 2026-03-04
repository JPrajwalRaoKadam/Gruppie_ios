//
//  AssignTeacherViewController 2.swift
//  loginpage
//
//  Created by apple on 26/02/26.
//


import UIKit

class AssignTeacherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    var subject: ClassSubject?
    var teachers: [String] = ["Teacher A", "Teacher B", "Teacher C"] // Example data, replace with your model

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI styling
        backButton.layer.cornerRadius = backButton.frame.height / 2
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        
        // ✅ Register AssignTeacherTableViewCell
        let nib = UINib(nibName: "AssignTeacherTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AssignTeacherTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignTeacherTableViewCell", for: indexPath) as? AssignTeacherTableViewCell else {
            return UITableViewCell()
        }
        
        let teacherName = teachers[indexPath.row]
        cell.name.text = teacherName
        
        // Optional: setup enableButton action
        cell.enableButton.tag = indexPath.row
        cell.enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Enable Button Action
    @objc func enableButtonTapped(_ sender: UIButton) {
        let selectedTeacher = teachers[sender.tag]
        
        let alertController = UIAlertController(title: "Assign Teacher", message: "Do you want to assign \(selectedTeacher) to \(subject?.subjectName ?? "")?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            print("Assigned \(selectedTeacher) to \(self.subject?.subjectName ?? "")")
            // Add your assignment logic here (API call, model update, etc.)
        }))
        
        present(alertController, animated: true)
    }
    
    // MARK: - Back Button
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) // Since it is presented modally
    }
}