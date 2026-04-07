
import UIKit

enum subjectsView {
    case subject
    case days
}

class PeriodViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var classId: String?
    var groupAcademicYearId: String?
    var groupId: String = ""
    var token: String = ""
    var teamIds: [String] = []
    var subjects: [SubjectData] = []
    var day: Int = 0
    var periods: [PeriodData] = []
    var className: String? // new property to hold the class name
    var flowMode : subjectsView = .subject
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch flowMode {
                case .subject:
                    addButton.isHidden = false
                case .days:
                    addButton.isHidden = true
                }
        // Set delegates and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register tableview cell nib
        let nib = UINib(nibName: "PeriodTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PeriodTableViewCell")
        
        // UI styling
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        // Debug print received data
        print("✅ Received Data in PeriodViewController:")
        print("✅ classId:\(classId)")
        print("✅ groupAcademicYearId:\(groupAcademicYearId)")

        print("Group ID: \(groupId)")
        print("Day: \(day)")
        print("Token: \(token)")
        print("Periods count: \(periods.count)")
        
        // Print the full periods array as JSON for complete console output
        if !periods.isEmpty {
            do {
                let jsonData = try JSONEncoder().encode(periods)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📄 Full Periods Data:\n\(jsonString)")
                }
            } catch {
                print("❌ Error encoding periods to JSON: \(error)")
            }
        } else {
            print("⚠️ No periods passed from previous VC.")
            fetchPeriodData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchPeriodData() {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/day/period/max/get?day=\(day)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching period data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received from API")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(PeriodResponse.self, from: data)
                DispatchQueue.main.async {
                    self.periods = decodedResponse.data
                    self.tableView.reloadData()
                    print("✅ API Response: \(decodedResponse)")
                }
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
        if let periodDetailVC = storyboard.instantiateViewController(withIdentifier: "PeriodDetailViewController") as? PeriodDetailViewController {
            
            // Pass all required data
            periodDetailVC.token = token
            periodDetailVC.groupId = groupId
            periodDetailVC.day = day
            periodDetailVC.classId = classId
            periodDetailVC.groupAcademicYearId = groupAcademicYearId      // ✅ Pass classId here
            periodDetailVC.className = className ?? ""
            
            navigationController?.pushViewController(periodDetailVC, animated: true)
        }
    }
}

extension PeriodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodTableViewCell", for: indexPath) as? PeriodTableViewCell else {
            return UITableViewCell()
        }
        
        let periodData = periods[indexPath.row]
        cell.configure(with: periodData) // ✅ Use the new configure method
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeriod = periods[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil)
        if let periodDetailVC = storyboard.instantiateViewController(withIdentifier: "PeriodDetailViewController") as? PeriodDetailViewController {
            
            // Pass all required data
            periodDetailVC.token = token
            periodDetailVC.groupId = groupId
            periodDetailVC.classId = classId
            periodDetailVC.groupAcademicYearId = groupAcademicYearId      // ✅ Pass classId here
            periodDetailVC.day = day
//            periodDetailVC.periodData = selectedPeriod
            
            navigationController?.pushViewController(periodDetailVC, animated: true)
        }
    }
}
