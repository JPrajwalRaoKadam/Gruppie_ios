//
//  SelectStuVC.swift
//  loginpage
//
//  Created by apple on 31/07/25.
//

import UIKit

class SelectStuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    
    var studentTeams: [StudentTeam] = []
    var filteredStudentTeams: [StudentTeam] = []
    var combinedStudentTeams: [CombinedStudentTeam] = []
    var token: String = ""
    var groupId: String?
    var teamId: String = ""
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("groupId in SelectStuVC:::\(groupId)")
        
        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
        heightConstraintOfSearchView.constant = 0
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        searchView.isHidden = true
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
        filteredStudentTeams = studentTeams
        
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        if SegmentController.selectedSegmentIndex == 0 {
            fetchStudentDataForRegularClass()
        } else {
            segmentChanged()
        }
        enableKeyboardDismissOnTap()
    }
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
        if shouldShow {
            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
            searchTextField?.placeholder = "Search..."
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchTextField?.backgroundColor = .white
            searchTextField?.layer.cornerRadius = 5
            searchTextField?.layer.borderWidth = 1
            searchTextField?.layer.borderColor = UIColor.gray.cgColor
            if let searchTextField = searchTextField {
                searchView.addSubview(searchTextField)
            }
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func navigateToAddRegularClass(withClassData classData: [ClassType], classTypeId: String, className: String) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass") as? AddRegularClass else {
            print("❌ Failed to instantiate AddRegularClass from Student.storyboard")
            return
        }

        addRegularClassVC.classData = classData
        addRegularClassVC.classTypeId = classTypeId
        addRegularClassVC.className = className
        addRegularClassVC.groupId = groupId ?? ""
        addRegularClassVC.token = token

        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
    }
    
    func addCombinedClass() {
        print("✅ Adding Combined class")
        
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addCombineClassVC = storyboard.instantiateViewController(withIdentifier: "AddCombineClass") as? AddCombineClass else {
            print("❌ Failed to instantiate AddCombineClass from Student.storyboard")
            return
        }

        addCombineClassVC.token = self.token
        addCombineClassVC.groupIds = self.groupId ?? ""
        addCombineClassVC.studentTeams = self.studentTeams
        addCombineClassVC.filteredStudentTeams = self.filteredStudentTeams
        addCombineClassVC.combinedStudentTeams = self.combinedStudentTeams
        
        self.navigationController?.pushViewController(addCombineClassVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SegmentController.selectedSegmentIndex == 0 {
            return filteredStudentTeams.count
        } else {
            return combinedStudentTeams.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentIndex = SegmentController.selectedSegmentIndex
        
        if segmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RegularTableViewCell", for: indexPath) as? RegularTableViewCell else {
                return UITableViewCell()
            }
            
            let studentTeam = filteredStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = studentTeam.phone.isEmpty ? "N/A" : studentTeam.phone
            
            cell.configure(name: studentTeam.name, designation: studentTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CombineTableViewCell", for: indexPath) as? CombineTableViewCell else {
                return UITableViewCell()
            }

            let combinedTeam = combinedStudentTeams[indexPath.row]
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let phoneNumber = combinedTeam.phone.isEmpty ? "N/A" : combinedTeam.phone
            
            cell.configure(name: combinedTeam.name, designation: combinedTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        }
    }
    @objc func segmentChanged() {
        let selectedIndex = SegmentController.selectedSegmentIndex
        print("Segment changed to index: \(selectedIndex)")

        if selectedIndex == 1 {
            fetchCombinedStudentTeams()
        }
        
        StudentList.reloadData()
    }
    func fetchStudentDataForRegularClass() {
        guard let token = TokenManager.shared.getToken(), !token.isEmpty,
              let groupId = groupId, !groupId.isEmpty else {
            print("❌ Token or Group ID is missing")
            showAlert(message: "Missing token or group ID.")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/get?type=regular"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(StudentTeamResponse.self, from: data)
                DispatchQueue.main.async {
                    self.studentTeams = response.data
                    self.filteredStudentTeams = response.data
                    self.StudentList.reloadData()
                    print("✅ Loaded \(response.data.count) regular student teams.")
                }
            } catch {
                print("❌ Error decoding data: \(error)")
            }
        }

        task.resume()
    }


    func fetchCombinedStudentTeams() {
        // 🔐 Get token
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            showAlert(message: "Authentication required")
            return
        }
        
        // 📦 Get groupId
        guard let groupId = self.groupId else {
            print("❌ groupId not found")
            showAlert(message: "Group ID is missing")
            return
        }

        // 🌐 Create URL
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/class/get?type=combined") else {
            print("❌ Invalid URL")
            return
        }

        print("📡 API URL: \(url.absoluteString)")

        // 📡 Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // 🚀 Start network task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CombinedStudentTeamResponse.self, from: data)
                DispatchQueue.main.async {
                    self.combinedStudentTeams = response.data
                    self.StudentList.reloadData()
                }
            } catch {
                print("❌ Error decoding data: \(error)")
            }
        }

        task.resume()
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = SegmentController.selectedSegmentIndex
        
        if selectedIndex == 0 {
            let selectedStudentTeam = filteredStudentTeams[indexPath.row]
            navigateToDetailViewController(withTeamId: selectedStudentTeam.teamId, name: selectedStudentTeam.name)
        } else {
            let selectedCombinedTeam = combinedStudentTeams[indexPath.row]
            navigateToDetailViewController(withTeamId: selectedCombinedTeam.teamId, name: selectedCombinedTeam.name)
        }
    }

 func navigateToDetailViewController(withTeamId teamId: String, name: String) {
        // Safely unwrap token and groupId
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            showAlert(message: "Authentication required")
            return
        }

        guard let groupId = groupId, !groupId.isEmpty else {
            print("❌ groupId is nil or empty")
            showAlert(message: "Group ID missing")
            return
        }

        let fullURL = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/students/get"
        print("📡 Final URL: \(fullURL)")

        guard let url = URL(string: fullURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response to detailView: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(StudentDataResponse.self, from: data)

                DispatchQueue.main.async {
                    let studentDbId = response.data.first?.studentDbId ?? "N/A"
                    print("Student Database ID: \(studentDbId)")

                    if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController2") as? DetailViewController2 {
                        detailVC.token = token
                        detailVC.groupId = groupId
                        detailVC.teamId = teamId
                        detailVC.studentName = name
                        detailVC.studentDbId = studentDbId
                        detailVC.studentDetails = response.data
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }

        task.resume()
    }


    
    func filterMembers(textField: String) {
        let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText.isEmpty {
            filteredStudentTeams = studentTeams
            StudentList.reloadData()
            return
        }
        
        if SegmentController.selectedSegmentIndex == 0 {
            filteredStudentTeams = studentTeams.filter {
            
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        StudentList.reloadData()
    }
    
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    filterMembers(textField: searchText)
    return true
}
}
