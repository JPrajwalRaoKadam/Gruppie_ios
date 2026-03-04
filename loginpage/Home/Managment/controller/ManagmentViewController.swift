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

        guard let token = self.token else {
            print("❌ Token not available")
            return
        }

        let selectedMember = filteredMembers[indexPath.row]

        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "MoreDetailViewController"
        ) as? MoreDetailViewController else {
            return
        }

        vc.token = token
        vc.member = selectedMember
        vc.userId = selectedMember.id  

        
        
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {

        guard let token = self.token else {
            print("❌ Token not available")
            return
        }

        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "MoreDetailViewController"
        ) as? MoreDetailViewController else {
            print("❌ Failed to instantiate MoreDetailViewController")
            return
        }

        // Pass required data
        vc.token = token

        // Since this is ADD flow, there is NO selected member
        vc.member = nil
        vc.userId = nil
//        vc.isFromAdd = true   // optional flag (recommended)

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
