import UIKit

class SubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    var school: School? // Store school data

    var subjects: [SubjectData] = [] // Store fetched subjects
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom cell for the table view
        TableView.register(UINib(nibName: "SubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectTableViewCell")
        
        // Set delegate and dataSource
        TableView.delegate = self
        TableView.dataSource = self
        
        // Fetch the token and groupId
        self.token = TokenManager.shared.getToken() ?? ""

        // Debugging prints
        print("✅ SubjectViewController Loaded with:")
        print("   🔹 Token: \(token)")
        print("   🔹 Group ID: \(groupId)")
        print("   🔹 Team IDs: \(teamIds.isEmpty ? "Not available" : teamIds.joined(separator: ", "))")

        // Fetch subject data
        fetchSubjectData()
    }
    
    override func viewWillAppear(_: Bool) {
           super.viewWillAppear(true)
           TableView.reloadData()
       }
    
    func fetchSubjectData() {
        guard !token.isEmpty else { return }
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/get"
        print("📌 API URL for fetching subjects: \(urlString)")
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching subjects: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            // Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📌 Raw JSON response for fetching subjects: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([SubjectData].self, from: data)
                self.subjects = response
                
                // Print fetched subjects
                for subject in self.subjects {
                    print("✅ Fetched Subject - Team ID: \(subject.teamId)")
                }
                
                // Reload table view on main thread
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
            } catch {
                print("❌ Error decoding subject data: \(error)")
            }
        }.resume()
    }

    // MARK: - UITableView DataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectTableViewCell", for: indexPath) as? SubjectTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = subjects[indexPath.row]
        cell.configure(with: subject)
        
        return cell
    }
    
    // MARK: - UITableView Delegate Methods

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
        let storyboard = UIStoryboard(name: "Subject", bundle: nil)
        guard let allSubjectVC = storyboard.instantiateViewController(withIdentifier: "AllSubjectViewController") as? AllSubjectViewController else {
            print("❌ Failed to instantiate AllSubjectViewController")
            return
        }

        // Pass data
        allSubjectVC.subjectDetails = subjectDetails
        allSubjectVC.token = self.token
        allSubjectVC.groupId = self.groupId
        allSubjectVC.teamId = teamId

        // Debugging prints
        print("✅ Navigating to AllSubjectViewController with:")
        print("   🔹 Token: \(self.token)")
        print("   🔹 Group ID: \(self.groupId)")
        print("   🔹 Team ID: \(teamId)")

        self.navigationController?.pushViewController(allSubjectVC, animated: true)
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
