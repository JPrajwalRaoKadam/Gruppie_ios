import UIKit

class BuslistVC: UIViewController {

    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var buslistTable: UITableView!
    @IBOutlet weak var textToSearch: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var buses: [Bus] = []   // store API buses
    var groupId: String? // pass dynamically in your real app
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buslistTable.dataSource = self
        buslistTable.delegate = self
        buslistTable.register(UINib(nibName: "BuslistCell", bundle: nil), forCellReuseIdentifier: "BuslistCell")
        add.layer.cornerRadius = 10
        print("groupId:\(groupId)")
        print("currentRole:\(currentRole)")
        fetchBusList()
    }

        func fetchBusList() {
        guard let token = TokenManager.shared.getToken() else { return }
        guard let groupId = groupId else { return }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/bus/get"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error fetching buses: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📦 Bus API Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else { return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Bus API Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(BusListResponse.self, from: data)
                let busList = response.data ?? []
                
                DispatchQueue.main.async {
                    if busList.isEmpty {
            
                        if let addBusVC = self?.storyboard?.instantiateViewController(withIdentifier: "AddBusViewController") as? AddBusViewController {
                            addBusVC.currentRole = self?.currentRole
                            addBusVC.groupId = self?.groupId
                            self?.navigationController?.pushViewController(addBusVC, animated: true)
                        }

                    } else {
                        // ✅ Only update table if data exists
                        self?.buses = busList
                        self?.buslistTable.reloadData()
                    }
                }
            } catch {
                print("❌ Error decoding buses: \(error.localizedDescription)")
            }
        }.resume()
    }


    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let searchText = textToSearch.text?.lowercased(), !searchText.isEmpty else {
            showAlert(message: "⚠️ Please enter a route name to search.")
            return
        }

        // Find first bus matching the search
        if let index = buses.firstIndex(where: { $0.routeName.lowercased().contains(searchText) }) {
            let foundBus = buses.remove(at: index) // remove from old position
            buses.insert(foundBus, at: 0)          // insert at top
            
            buslistTable.reloadData()
            
            // Scroll to the top (first cell)
            let topIndex = IndexPath(row: 0, section: 0)
            buslistTable.scrollToRow(at: topIndex, at: .top, animated: true)
            
            print("✅ Moved bus route '\(foundBus.routeName)' to the top")
        } else {
            showAlert(message: "❌ Route '\(searchText)' does not exist.")
        }
    }
    // Mark - alert
    /// Helper function to show alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Search Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    @IBAction func addBusButton(_ sender: Any) {
        // TODO: implement navigation to Add Bus screen
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BuslistVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buses.count
    }
    //MARK: - extension of class
    //MARK: - extension of class


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuslistCell", for: indexPath) as! BuslistCell
        let bus = buses[indexPath.row]
    
        cell.configure(with: bus)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedBus = buses[indexPath.row]
//
//        if let busRouteMapVC = self.storyboard?.instantiateViewController(withIdentifier: "BusRouteMapVC") as? BusRouteMapVC {
//            busRouteMapVC.routeName = buses.routeName
//            busRouteMapVC.groupId = groupId
//            busRouteMapVC.currentRole = currentRole
//            navigationController?.pushViewController(busRouteMapVC, animated: true)
//            
//        } else {
//            print("❌ BusRouteMapVC not found in storyboard")
//        }
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBus = buses[indexPath.row]

        let storyboard = UIStoryboard(name: "BusRegister", bundle: nil)
        if let busRouteMapVC = storyboard.instantiateViewController(withIdentifier: "BusRouteMapVC") as? BusRouteMapVC {
            
            busRouteMapVC.currentRole = currentRole
            busRouteMapVC.groupId = groupId
            busRouteMapVC.routeNameText = selectedBus.routeName  // <-- pass string here
            
            navigationController?.pushViewController(busRouteMapVC, animated: true)
        } else {
            print("❌ BusRouteMapVC not found in storyboard")
        }
    }



}
