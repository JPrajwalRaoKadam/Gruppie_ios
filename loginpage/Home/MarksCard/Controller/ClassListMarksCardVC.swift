import UIKit

class ClassListMarksCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var classListTableView: UITableView!
    
    var subjects: [SubjectData] = []
    var examDataResponse: [ExamData] = []
    var token: String = "" // Authentication token
    var groupId: String = "" // Group ID
    var teamIds: [String] = []
    var teamId: String?
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classListTableView.delegate = self
        classListTableView.dataSource = self
        
        // Register the custom cell
        classListTableView.register(UINib(nibName: "ClassNameMarksCardTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassNameMarksCardTableViewCell")
        }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        classListTableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassNameMarksCardTableViewCell", for: indexPath) as? ClassNameMarksCardTableViewCell else {
            return UITableViewCell()
        }
        
        let sub = subjects[indexPath.row]
        cell.nameLabel?.text = sub.name
        cell.configure(with: sub)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeamId = teamIds[indexPath.row] // Get teamId for selected row
                fetchExamData(teamId: selectedTeamId)
        self.teamId = selectedTeamId
    }
    
    func fetchExamData(teamId: String) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/offline/testexam/get"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ExamDataResponse.self, from: data)
                DispatchQueue.main.async {
                    self.examDataResponse = decodedResponse.data
                    self.navigateToExamVC()
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(rawString)")
                }
            }
        }

        task.resume()
    }
    
    func navigateToExamVC() {
        let storyboard = UIStoryboard(name: "MarksCard", bundle: nil)
        guard let examVC = storyboard.instantiateViewController(withIdentifier: "ExamVC") as? ExamVC else {
            print("❌ Failed to instantiate SubjectViewController")
            return
        }
        
        examVC.examDataResponse = self.examDataResponse
        examVC.token = TokenManager.shared.getToken() ?? ""
        examVC.groupId = groupId
        examVC.teamId = self.teamId
        
        
        self.navigationController?.pushViewController(examVC, animated: true)
    }
}
