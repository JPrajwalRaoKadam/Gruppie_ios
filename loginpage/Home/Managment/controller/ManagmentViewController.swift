import UIKit

class ManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    
    var managementResponse: [ManagementMember] = []
    var filteredMembers: [ManagementMember] = []
    var searchTextField: UITextField?
    var token: String?
    var groupIds: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchManagementList()
        enableKeyboardDismissOnTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    func setupUI() {
        heightConstraintOfSearchView.constant = 0
        searchView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "Member_TableViewCell", bundle: nil),
                           forCellReuseIdentifier: "Member_TableViewCell")
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMember = filteredMembers[indexPath.row]
        
        // Directly show delete confirmation without action sheet
        confirmDelete(member: selectedMember, at: indexPath)
    }
    
    private func confirmDelete(member: ManagementMember, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Member",
            message: "Are you sure you want to delete \"\(member.fullName)\"? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteManagement(memberId: member.id, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteManagement(memberId: Int, at indexPath: IndexPath) {
        guard let token = self.token else {
            showError("Token missing")
            return
        }
        
        let urlString = "https://backend.gc2.co.in/api/v1/management/\(memberId)"
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Deleting...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        print("🗑️ Deleting management ID: \(memberId)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        self?.showError("Delete failed: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.showError("Invalid server response")
                        return
                    }
                    
                    print("✅ Delete Status Code:", httpResponse.statusCode)
                    
                    // Check if deletion was successful
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                        self?.handleDeleteSuccess(at: indexPath, memberName: self?.getMemberName(at: indexPath) ?? "")
                    } else if httpResponse.statusCode == 401 {
                        self?.showError("Unauthorized. Please login again.")
                    } else if httpResponse.statusCode == 404 {
                        self?.showError("Member not found")
                    } else {
                        // Try to parse error message from response
                        if let data = data,
                           let errorResponse = try? JSONDecoder().decode(DeleteManagementResponse.self, from: data) {
                            self?.showError(errorResponse.message ?? "Delete failed with status: \(httpResponse.statusCode)")
                        } else {
                            self?.showError("Delete failed with status code: \(httpResponse.statusCode)")
                        }
                    }
                }
            }
        }.resume()
    }
    
    private func handleDeleteSuccess(at indexPath: IndexPath, memberName: String) {
        // Remove from both arrays
        let memberToRemove = filteredMembers[indexPath.row]
        
        // Remove from filteredMembers
        filteredMembers.remove(at: indexPath.row)
        
        // Remove from managementResponse if present
        if let indexInOriginal = managementResponse.firstIndex(where: { $0.id == memberToRemove.id }) {
            managementResponse.remove(at: indexInOriginal)
        }
        
        // Delete row from table view with animation
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        // Show success message
        let successAlert = UIAlertController(
            title: "Success",
            message: "\(memberName) has been deleted successfully.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
    
    private func getMemberName(at indexPath: IndexPath) -> String {
        guard indexPath.row < filteredMembers.count else { return "Member" }
        return filteredMembers[indexPath.row].fullName
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let token = self.token else {
            print("❌ Token not available")
            showError("Token missing. Please login again.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "AddSingleManagement"
        ) as? AddSingleManagement else {
            print("❌ Failed to instantiate AddSingleManagement")
            showError("Unable to open add member screen")
            return
        }
        
        // Pass required data
        vc.token = token
        vc.groupIds = self.groupIds // Pass groupIds if needed
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchManagementList() {
        guard let token = UserDefaults.standard.string(forKey: "user_role_Token") else {
            print("❌ Token missing")
            return
        }
        self.token = token
        
        let apiUrlString = APIManager.shared.baseURL + "management"
        guard let url = URL(string: apiUrlString) else {
            print("❌ Invalid URL:", apiUrlString)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("📡 GET:", apiUrlString)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Network Error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                return
            }
            
            print("📡 Status Code:", httpResponse.statusCode)
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ API failed with status:", httpResponse.statusCode)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("📥 Raw Management Response:\n", raw)
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ManagementResponse.self, from: data)
                print("✅ Decoded members count:", response.data.count)
                
                DispatchQueue.main.async {
                    self.managementResponse = response.data
                    self.filteredMembers = response.data
                    self.tableView.reloadData()
                }
                
            } catch {
                print("❌ Decoding Error:", error)
            }
            
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "Member_TableViewCell",
            for: indexPath
        ) as? Member_TableViewCell else {
            return UITableViewCell()
        }
        
        let member = filteredMembers[indexPath.row]
        cell.configureCell(with: member)
        return cell
    }
    
    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let member = filteredMembers[indexPath.row]
            confirmDelete(member: member, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
        
        if shouldShow {
            searchTextField = UITextField(
                frame: CGRect(x: 10, y: 5,
                              width: searchView.frame.width - 20,
                              height: 35)
            )
            searchTextField?.placeholder = "Search"
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchView.addSubview(searchTextField!)
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
        }
    }
    
    func filterMembers(searchText: String) {
        if searchText.isEmpty {
            filteredMembers = managementResponse
        } else {
            filteredMembers = managementResponse.filter {
                $0.fullName.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString)
            .replacingCharacters(in: range, with: string)
        filterMembers(searchText: text)
        return true
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

