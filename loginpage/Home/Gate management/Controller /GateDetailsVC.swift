import UIKit

class GateDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddGateDelegate {
    
    var groupId: String?
    @IBOutlet weak var tablevw: UITableView!
    var gates: [GateData] = []
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GateDetailsVC groupId: \(groupId ?? "nil")")
        setupTableView()
        setupLoadingIndicator()
        fetchGateData()
    }
    
    func setupTableView() {
        tablevw.delegate = self
        tablevw.dataSource = self
        tablevw.rowHeight = 80
        tablevw.register(UINib(nibName: "GateDetailsVCCell", bundle: nil), forCellReuseIdentifier: "GateDetailsVCCell")
    }

    func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddGateVC") as? AddGateVC {
            vc.groupId = self.groupId
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("❌ Could not instantiate AddGateVC")
        }
    }

    func didAddNewGate() {
        print("🔄 Refreshing gate list after adding new gate")
        gates.removeAll()
         tablevw.reloadData()
         fetchGateData()
    }

    func fetchGateData() {
        guard let groupId = groupId else {
            print("❌ groupId is nil")
            return
        }
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/gates"
        print("🔗 Fetching gate data from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 15) // set timeout
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        loadingIndicator.startAnimating()

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                if error.code == NSURLErrorTimedOut {
                    print("⏱ Request timed out. Retrying...")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchGateData() // retry after 2s
                    }
                } else {
                    print("❌ API Error: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
                return
            }

            guard let data = data else {
                print("❌ No Data Received")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GateResponse.self, from: data)
                let fetchedGates = decoded.data

                DispatchQueue.main.async {
                    for gate in fetchedGates {
                        self.gates.append(gate)
                        let indexPath = IndexPath(row: self.gates.count - 1, section: 0)
                        self.tablevw.insertRows(at: [indexPath], with: .fade)
                    }
                    self.loadingIndicator.stopAnimating()
                    print("✅ Loaded \(self.gates.count) gates")
                }
            } catch {
                print("❌ Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }.resume()
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GateDetailsVCCell", for: indexPath) as? GateDetailsVCCell else {
            return UITableViewCell()
        }
        let gate = gates[indexPath.row]
        print("📱 Configuring cell with gate: \(gate.gateNumber)")
        cell.configure(with: gate)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gate = gates[indexPath.row]

        let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "editORdeleteVC") as? editORdeleteVC {
            vc.groupId = self.groupId
            vc.gate = gate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

