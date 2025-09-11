//
//  StatusapproveVC.swift
//  loginpage
//
//  Created by apple on 08/09/25.
//
import UIKit
class StatusApproveVC : UIViewController{
    var groupId: String?
    var currentRole: String?
    var school: School?
    var kids: [KidProfile] = []
    var gatePassList: [GatePassStatus] = []
    
    @IBOutlet weak var statustableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        statustableview.register(UINib(nibName: "GatePassStatusCell", bundle: nil), forCellReuseIdentifier: "GatePassStatusCell")
        statustableview.delegate = self
        statustableview.dataSource = self
        
        guard let groupId = groupId else {
            print("❌ groupId is nil, cannot fetch kids")
            return
        }
        
        fetchKids(groupId: groupId)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchKids(groupId: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/my/kids"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📦 Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw kids API response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let profileResponse = try decoder.decode(KidProfileResponse.self, from: data)
                let kids = profileResponse.data ?? []
                
                DispatchQueue.main.async {
                    self?.kids = kids
                    self?.statustableview.reloadData()
                    self?.fetchGatePassStatusForKids()
                }
            } catch {
                print("❌ Error decoding kids API: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchGatePassStatusForKids() {
        guard let groupId = groupId, let token = TokenManager.shared.getToken() else { return }
        
        let dispatchGroup = DispatchGroup()
        var tempGatePassList: [GatePassStatus] = []
        var seenUserIds = Set<String>() // Track unique userIds
        
        for kid in kids {
            let userId = kid.userId
            if seenUserIds.contains(userId) { continue } // Skip duplicates
            seenUserIds.insert(userId)
            
            dispatchGroup.enter()
            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/user/gatepass?userId=\(userId)"
            print("🌐 GatePass URL: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                dispatchGroup.leave()
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("❌ GatePass API Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📦 GatePass Status Code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("❌ No data received from gatepass API")
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 GatePass Response: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(GatePassStatusSResponse.self, from: data)
                    if let gatePasses = response.data {
                        tempGatePassList.append(contentsOf: gatePasses) // append all
                    }
                } catch {
                    print("❌ Error decoding GatePass API: \(error.localizedDescription)")
                }

            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.gatePassList = tempGatePassList
            self?.statustableview.reloadData()
        }
    }
}
    extension StatusApproveVC: UITableViewDataSource, UITableViewDelegate {

       // MARK: - UITableViewDataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return gatePassList.count
       }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GatePassStatusCell", for: indexPath) as! GatePassStatusCell
            let item = gatePassList[indexPath.row]
            
            // Use ?? to provide a default value if optional is nil
            let studentName = item.name ?? "Unknown"
            
            cell.studentName.text = "\(studentName) (\(item.className))"
            cell.status.text = item.status.capitalized
            return cell
        }

        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let gatePass = gatePassList[indexPath.row]
                showStatusPopup(for: gatePass)
            }

            private func showStatusPopup(for gatePass: GatePassStatus) {
                let alert = UIAlertController(title: "Select Status", message: "Choose an action for \(gatePass.name ?? "Student")", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { [weak self] _ in
                    self?.updateGatePassStatus(gatePassId: gatePass.gatepassId, status: "approved")
                }))
                
                alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { [weak self] _ in
                    self?.updateGatePassStatus(gatePassId: gatePass.gatepassId, status: "rejected")
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alert, animated: true)
            }

            private func updateGatePassStatus(gatePassId: String, status: String) {
                guard let groupId = groupId, let token = TokenManager.shared.getToken() else { return }
                let urlString = APIManager.shared.baseURL + "groups/\(groupId)/user/gatepass/statusupdate"
                guard let url = URL(string: urlString) else { return }

                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = [
                    "gatepassId": gatePassId,
                    "status": status
                ]

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                } catch {
                    print("❌ Error encoding body: \(error)")
                    return
                }

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("❌ PUT API Error: \(error.localizedDescription)")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        print("📦 Status update response code: \(httpResponse.statusCode)")
                    }

                    guard let data = data else { return }
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📄 Status update response: \(jsonString)")
                    }

                    // Optionally refresh the table view after status change
                    DispatchQueue.main.async { [weak self] in
                        self?.fetchGatePassStatusForKids()
                    }

                }.resume()
            }
        }

   

   
