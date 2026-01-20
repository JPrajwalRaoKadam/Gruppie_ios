import UIKit

class SubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var groupClasses: [GroupClass] = []
    var school: School?
    var subjects: [SubjectData] = []
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
        let selectedSubject = subjects[indexPath.row]
        fetchSubjectForTeam(teamId: selectedSubject.teamId)
    }

    func fetchSubjectForTeam(teamId: String) {
        guard !token.isEmpty else { return }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/get?option=more"
        print("📌 API URL for fetching subject data for team: \(urlString)")
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching subject data: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📌 Raw JSON response for team subject data: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SubjectRegisterResponse.self, from: data)
                let subjectDetails = response.data
                
                DispatchQueue.main.async {
                    self.navigateToAllSubjectViewController(subjectDetails: subjectDetails, teamId: teamId)
                }
            } catch {
                print("❌ Error decoding subject data: \(error)")
            }
        }.resume()
    }

    func navigateToAllSubjectViewController(subjectDetails: [SubjectDetail], teamId: String) {
//        let storyboard = UIStoryboard(name: "Subject", bundle: nil)
//        guard let allSubjectVC = storyboard.instantiateViewController(withIdentifier: "AllSubjectViewController") as? AllSubjectViewController else {
//            print("❌ Failed to instantiate AllSubjectViewController")
//            return
//        }
//
//        allSubjectVC.subjectDetails = subjectDetails
//        allSubjectVC.token = self.token
//        allSubjectVC.groupId = self.groupId
//        allSubjectVC.teamId = teamId
//
//        print("✅ Navigating to AllSubjectViewController with:")
//        print("   🔹 Token: \(self.token)")
//        print("   🔹 Group ID: \(self.groupId)")
//        print("   🔹 Team ID: \(teamId)")
//
//        self.navigationController?.pushViewController(allSubjectVC, animated: true)
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
