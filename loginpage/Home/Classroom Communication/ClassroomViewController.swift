//
//  SubjectViewController.swift
//  loginpage
//
//  Created by apple on 10/02/26.
//


import UIKit

class ClassroomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var groupClasses: [GroupClass] = []
    var token: String = ""
    var groupId: String = ""
    var teamIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        TableView.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectTableViewCell")
        TableView.delegate = self
        TableView.dataSource = self
        
        TableView.layer.cornerRadius = 10
        TableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        self.token = TokenManager.shared.getToken() ?? ""

        print("✅ SubjectViewController Loaded with:")
        print("   🔹 Token: \(token)")
        print("   🔹 Group ID: \(groupId)")
        print("   🔹 Team IDs: \(teamIds.isEmpty ? "Not available" : teamIds.joined(separator: ", "))")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    
    override func viewWillAppear(_: Bool) {
           super.viewWillAppear(true)
           TableView.reloadData()
       }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupClasses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectTableViewCell", for: indexPath) as? SubjectTableViewCell else {
            return UITableViewCell()
        }
        
        let className = groupClasses[indexPath.row].name
        cell.configure(with: className)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let selectedClass = groupClasses[indexPath.row]
        let selectedTeamId = selectedClass.id   // adjust if property name differs

        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)

        guard let feedVC = storyboard.instantiateViewController(
            withIdentifier: "FeedViewController"
        ) as? FeedViewController else {
            print("❌ Failed to instantiate FeedViewController")
            return
        }
        feedVC.teamId = selectedTeamId
        feedVC.feedSource = .classroom(teamId: selectedTeamId)

        navigationController?.pushViewController(feedVC, animated: true)
    }

    
}
