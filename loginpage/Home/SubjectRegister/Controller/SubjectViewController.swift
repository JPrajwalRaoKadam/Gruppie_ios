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
        
        // 🔵 UI Styling
        TableView.layer.cornerRadius = 10
        TableView.layer.masksToBounds = true
        
        backButton.clipsToBounds = true
        
        self.token = TokenManager.shared.getToken() ?? ""

        print("✅ SubjectViewController Loaded with:")
        print("   🔹 Token: \(token)")
        print("   🔹 Group ID: \(groupId)")
        print("   🔹 Team IDs: \(teamIds.isEmpty ? "Not available" : teamIds.joined(separator: ", "))")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 🔵 Make back button circular
        backButton.layer.cornerRadius = backButton.frame.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TableView.reloadData()
    }

    // MARK: - TableView Methods

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

        let selectedClass = groupClasses[indexPath.row]

        let storyboard = UIStoryboard(name: "Subject", bundle: nil)

        guard let languageVC = storyboard.instantiateViewController(withIdentifier: "LanguageViewController") as? LanguageViewController else {
            print("❌ Could not instantiate LanguageViewController")
            return
        }

        languageVC.classId = selectedClass.id
        languageVC.groupAcademicYearId = selectedClass.groupAcademicYearId

        navigationController?.pushViewController(languageVC, animated: true)
    }


    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
