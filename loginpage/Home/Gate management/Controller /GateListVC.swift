protocol GateListVCDelegate: AnyObject {
    func didSelectGate(gateId: String, gateNumber: String)
}

import UIKit
class GateListVC: UIViewController {
    
    weak var delegate: GateListVCDelegate?
    
    @IBOutlet weak var gatetableview: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var gates: [GateData] = []
    var groupId: String?
    var currentRole: String?
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    var selectedGate: GateData?
    var selectedIndex: Int?
    var selectedGateId: String?
    var selectedGateNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        gatetableview.layer.cornerRadius = 10
        gatetableview.delegate = self
        gatetableview.dataSource = self
        setupUI()
        fetchGateData()
    }
    
    func setupUI() {
        doneButton.layer.cornerRadius = 10
        gatetableview.register(UINib(nibName: "GateListVCTableViewCell", bundle: nil), forCellReuseIdentifier: "GateListVCTableViewCell")
        gatetableview.delegate = self
        gatetableview.dataSource = self
        
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        guard let selectedGate = selectedGate else {
            showAlert(message: "Please select a gate")
            return
        }
        
        delegate?.didSelectGate(gateId: selectedGate.gateId, gateNumber: selectedGate.gateNumber)
        dismiss(animated: true)
    }
    
    
    func fetchGateData() {
        guard let groupId = groupId else {
            showAlert(message: "Group ID missing")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            showAlert(message: "Authentication required")
            return
        }

        loadingIndicator.startAnimating()
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/gates"
        guard let url = URL(string: urlString) else {
            showAlert(message: "Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received")
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GateResponse.self, from: data)
                DispatchQueue.main.async {
                    self.gates = decoded.data
                    self.gatetableview.reloadData()
                    print("Loaded \(self.gates.count) gates")
                }
            } catch {
                print("Decoding Error: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Error processing data")
                }
            }
        }.resume()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension GateListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GateListVCTableViewCell", for: indexPath) as? GateListVCTableViewCell else {
            return UITableViewCell()
        }

        let gate = gates[indexPath.row]
        cell.gateName.text = gate.gateNumber
        cell.gateId = gate.gateId
        cell.delegate = self
        cell.isChecked = (selectedIndex == indexPath.row)
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedGate = gates[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension GateListVC: GateListVCCellDelegate {
    func didTapCheckButton(gateId: String, gateName: String) {
        selectedGateId = gateId
        selectedGateNumber = gateName

        gatetableview.reloadData()

        delegate?.didSelectGate(gateId: gateId, gateNumber: gateName)
        self.dismiss(animated: true, completion: nil)
    }
}
