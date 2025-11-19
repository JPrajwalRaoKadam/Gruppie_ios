//
//  AddGateViewController.swift
//  loginpage
//
//  Created by apple on 03/09/25.
//

import UIKit

class AddGatePassVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GatePassReloadDelegate {
    
    weak var delegate: GatePassReloadDelegate?   // ✅ Forward delegate
    var groupId: String?
    var currentRole: String?
    var searchResults: [SearchStudentList] = []
    
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var studentName: UITableView!
    @IBOutlet weak var searchbox: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentName.delegate = self
        studentName.dataSource = self
        studentName.register(UINib(nibName: "SearchStudentCell", bundle: nil), forCellReuseIdentifier: "SearchStudentCell")
        studentName.layer.cornerRadius = 10
        searchbox.layer.cornerRadius = 10
        searchbox.clipsToBounds = true
        searchButton.layer.cornerRadius = 10
        searchbox.clipsToBounds = true
        addButton.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true

    }
    func reloadGatePassData() {
          // Forward the call to GatePassVC
          delegate?.reloadGatePassData()
      }
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let query = searchbox.text, !query.isEmpty else { return }
        fetchStudents(query: query)
    }

    func fetchStudents(query: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        guard let groupId = groupId else { return }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/agents/search?type=student&filter=\(query)&page=1"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ API Error:", error)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(SearchStudentResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = decoded.data
                    if self.searchResults.isEmpty {
                        self.showPopup(message: "This student does not exist")
                    }
                    self.studentName.reloadData()
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }
    
    func showPopup(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButton(_ sender: Any) {
        
    }
}

extension AddGatePassVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchStudentCell", for: indexPath) as? SearchStudentCell else {
            return UITableViewCell()
        }
        let student = searchResults[indexPath.row]
        cell.configure(with: student)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 70
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected student from searchResults
        let selectedStudent = searchResults[indexPath.row]
        
        let storyboard = UIStoryboard(name: "GatePass", bundle: nil)
        if let addGatePassDetailsVC = storyboard.instantiateViewController(withIdentifier: "AddGatePassDetailsVC") as? AddGatePassDetailsVC {
            
            // Pass values
            addGatePassDetailsVC.groupId = self.groupId
            addGatePassDetailsVC.currentRole = self.currentRole
            addGatePassDetailsVC.selectedStudent = selectedStudent  // ✅ Passing student model
            addGatePassDetailsVC.delegate = self
            
            addGatePassDetailsVC.modalPresentationStyle = .pageSheet
            if let sheet = addGatePassDetailsVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(addGatePassDetailsVC, animated: true)
        }
    }
}
