import UIKit

class LanguageSubViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LanguageSubTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var subjects: [ClassSubject] = []
    var classId: Int? // Add this property to receive class ID from previous VC
    var groupAcademicYearId: String? // Add this property

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: "LanguageSubTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "LanguageSubTableViewCell")
        
        backButton.layer.cornerRadius = backButton.frame.height / 2
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        
        print("📌 Received subjects from previous VC: \(subjects.count) items")
        print("📌 Received classId: \(classId ?? 0)")
        
        for subject in subjects {
            print("Subject Name: \(subject.subjectName), Code: \(subject.code)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageSubTableViewCell", for: indexPath) as? LanguageSubTableViewCell else {
            return UITableViewCell()
        }

        let subject = subjects[indexPath.row]
        cell.subject.text = subject.subjectName
        cell.type.text = subject.code
        cell.delegate = self  // ✅ Set delegate

        return cell
    }
    
    func didTapAddButton(on cell: LanguageSubTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let selectedSubject = subjects[indexPath.row]
        
        // Create action sheet
        let actionSheet = UIAlertController(title: "Choose Category",
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        // Custom attributed title to match the style
        let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
                              NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedTitle = NSAttributedString(string: "Choose Category", attributes: titleAttributes)
        actionSheet.setValue(attributedTitle, forKey: "attributedTitle")
        
        // Assign Teacher action
        let assignTeacherAction = UIAlertAction(title: "Assign Teacher", style: .default) { _ in
            self.showSubOptions(for: selectedSubject, action: "Assign Teacher")
        }
        assignTeacherAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        // Assign Student action
        let assignStudentAction = UIAlertAction(title: "Assign Student", style: .default) { _ in
            self.showSubOptions(for: selectedSubject, action: "Assign Student")
        }
        assignStudentAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        actionSheet.addAction(assignTeacherAction)
        actionSheet.addAction(assignStudentAction)
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        present(actionSheet, animated: true)
    }
    func showSubOptions(for subject: ClassSubject, action: String) {
        // Create second alert for Confirm/Cancel
        let alertController = UIAlertController(title: action,
                                              message: "\(action) for \(subject.subjectName)",
                                              preferredStyle: .alert)
        
        // Custom message to show the code
        let messageAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                               NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let attributedMessage = NSAttributedString(string: "Code: \(subject.code)", attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        // Confirm button
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            print("Confirmed: \(action) for \(subject.subjectName) with code \(subject.code)")
            
            if action == "Assign Teacher" {
                // ✅ Present AssignTeacherViewController modally
                let storyboard = UIStoryboard(name: "Subject", bundle: nil)
                if let assignTeacherVC = storyboard.instantiateViewController(withIdentifier: "AssignTeacherViewController") as? AssignTeacherViewController {
                    
                    // Pass data to AssignTeacherViewController
                    assignTeacherVC.subject = subject
                    
                    // Present modally
                    assignTeacherVC.modalPresentationStyle = .fullScreen
                    self.present(assignTeacherVC, animated: true)
                }
            } else if action == "Assign Student" {
                // ✅ Present AssignStudentViewController modally with classId and groupAcademicYearId
                let storyboard = UIStoryboard(name: "Subject", bundle: nil)
                if let assignStudentVC = storyboard.instantiateViewController(withIdentifier: "AssignStudentViewController") as? AssignStudentViewController {
                    
                    // Pass subject, classId, and groupAcademicYearId to AssignStudentViewController
                    assignStudentVC.subject = subject
                    assignStudentVC.classId = self.classId // Pass the classId
                    assignStudentVC.groupAcademicYearId = self.groupAcademicYearId // Pass the groupAcademicYearId
                    
                    print("📤 Navigating to AssignStudentViewController with:")
                    print("   - Subject: \(subject.subjectName) (ID: \(subject.subjectId))")
                    print("   - ClassId: \(self.classId ?? 0)")
                    print("   - GroupAcademicYearId: \(self.groupAcademicYearId ?? "nil")")
                    
                    // Present modally
                    assignStudentVC.modalPresentationStyle = .fullScreen
                    self.present(assignStudentVC, animated: true)
                }
            }
        }
        confirmAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
