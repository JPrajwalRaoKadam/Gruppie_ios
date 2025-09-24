import UIKit

class PeriodViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!

    var groupId: String = ""
    var token: String = ""
    var teamIds: [String] = []
    var subjects: [SubjectData] = []
    var day: Int = 0
    var periods: [PeriodData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "PeriodTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PeriodTableViewCell")
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        print("✅ Received Data in PeriodViewController:")
        print("Group ID: \(groupId)")
        print("Day: \(day)")
        print("Token: \(token)")
        
        fetchPeriodData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update back button corner radius after layout is complete
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
        cell.Period.text = periodData.period
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeriod = periods[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Timetable", bundle: nil) // Change if using another storyboard
        if let periodDetailVC = storyboard.instantiateViewController(withIdentifier: "PeriodDetailViewController") as? PeriodDetailViewController {
            
            periodDetailVC.token = token
            periodDetailVC.groupId = groupId
            periodDetailVC.day = day
            periodDetailVC.periodData = selectedPeriod
            
            navigationController?.pushViewController(periodDetailVC, animated: true)
        }
    }
}
