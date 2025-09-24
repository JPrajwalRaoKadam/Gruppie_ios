import UIKit

class listOfStudentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var token: String = ""
    var groupId: String = ""
    var teamIds: [String] = []
    var teamId: String?
    var currentRole: String?
    var subjects: [SubjectData] = []
    var userIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        
        studentsTableView.layer.cornerRadius = 10
        studentsTableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        studentsTableView.register(UINib(nibName: "listOfStudentsVCCell", bundle: nil), forCellReuseIdentifier: "listOfStudentsVCCell")
        
        print("------ Received Data in listOfStudentsVC ------")
        print("Token: \(token)")
        print("Group ID: \(groupId)")
        print("Team ID: \(teamId ?? "nil")")
        print("Team ID: \(teamIds)")
        print("Current Role: \(currentRole ?? "nil")")
        print("User IDs: \(userIds)")
        print("Team IDs: \(teamIds)")
        print("Subjects Count: \(subjects.count)")
        print("------------------------------------------------")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        studentsTableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listOfStudentsVCCell", for: indexPath) as? listOfStudentsVCCell else {
            return UITableViewCell()
        }
        
        let sub = subjects[indexPath.row]
        cell.nameLabel.text = sub.name
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make sure indices are safe
        guard indexPath.row < userIds.count, indexPath.row < teamIds.count else {
            print("Index out of bounds when accessing userIds or teamIds")
            return
        }
        
        let selectedUserId = userIds[indexPath.row]
        let selectedTeamId = teamIds[indexPath.row]
        
        navigateToFeedBackViewController(userId: selectedUserId, teamId: selectedTeamId)
    }
    
    func navigateToFeedBackViewController(userId: String, teamId: String) {
        let storyboard = UIStoryboard(name: "FeedBack", bundle: nil)
        if let feedbackVC = storyboard.instantiateViewController(withIdentifier: "FeedBackViewController") as? FeedBackViewController {
            
            feedbackVC.groupId = self.groupId
            feedbackVC.userId = userId
            feedbackVC.teamId = teamId
            feedbackVC.currentRole = self.currentRole
            feedbackVC.token = TokenManager.shared.getToken() ?? ""
            
            print("Navigating to FeedBackViewController with:")
            print("Group ID: \(feedbackVC.groupId)")
            print("User ID: \(feedbackVC.userId)")
            print("Team ID: \(feedbackVC.teamId)")
            print("Current Role: \(feedbackVC.currentRole ?? "nil")")
            print("Token: \(feedbackVC.token)")
            
            navigationController?.pushViewController(feedbackVC, animated: true)
        } else {
            print("Failed to instantiate FeedBackViewController")
        }
    }
}
