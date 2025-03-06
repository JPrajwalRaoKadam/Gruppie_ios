import UIKit

class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    var studentTeams: [StudentTeam] = []
    var filteredStudentTeams: [StudentTeam] = []
    var combinedStudentTeams: [CombinedStudentTeam] = []
    var token: String = ""
    var groupIds: String = ""
    var teamId: String = ""
    
    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SearchClass: UITextField!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        SearchClass.delegate = self
        SearchClass.addTarget(self, action: #selector(searchStudents), for: .editingChanged)
        
        filteredStudentTeams = studentTeams
        
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        segmentChanged()
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
            let teacherName = studentTeam.teacherName ?? "Unknown"
            let phoneNumber = studentTeam.phone.isEmpty ? "N/A" : studentTeam.phone

            cell.configure(name: studentTeam.name, designation: studentTeam.members, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CombineTableViewCell", for: indexPath) as? CombineTableViewCell else {
                return UITableViewCell()
            }

            let combinedTeam = combinedStudentTeams[indexPath.row]
            
            let iconImage: UIImage? = UIImage(named: "default_profile")
            let teacherName = combinedTeam.teacherName ?? "Unknown"
            let phoneNumber = combinedTeam.phone.isEmpty ? "N/A" : combinedTeam.phone
            
            cell.configure(name: combinedTeam.name, designation: teacherName, icon: iconImage, phoneNumber: phoneNumber)
            
            return cell
        }
    }

    @objc func searchStudents() {
        guard let searchText = SearchClass.text, !searchText.isEmpty else {
            filteredStudentTeams = studentTeams
            StudentList.reloadData()
            return
        }
        
        if SegmentController.selectedSegmentIndex == 0 {
            filteredStudentTeams = studentTeams.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        StudentList.reloadData()
    }

    @objc func segmentChanged() {
        let selectedIndex = SegmentController.selectedSegmentIndex
        print("Segment changed to index: \(selectedIndex)")

        if selectedIndex == 1 {
            fetchCombinedStudentTeams()
        }
        
        StudentList.reloadData()
    }

    func fetchCombinedStudentTeams() {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/class/get?type=combined") else { return }

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

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CombinedStudentTeamResponse.self, from: data)
                DispatchQueue.main.async {
                    self.combinedStudentTeams = response.data
                    self.StudentList.reloadData()
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        
        task.resume()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = SegmentController.selectedSegmentIndex
        
        if selectedIndex == 0 {
            let selectedStudentTeam = filteredStudentTeams[indexPath.row]
            self.teamId = selectedStudentTeam.teamId
            let teamName = selectedStudentTeam.name
            navigateToDetailViewController(withTeamId: selectedStudentTeam.teamId, name: teamName)
        } else {
            let selectedCombinedTeam = combinedStudentTeams[indexPath.row]
            self.teamId = selectedCombinedTeam.teamId
            let teamName = selectedCombinedTeam.name
            navigateToDetailViewController(withTeamId: selectedCombinedTeam.teamId, name: teamName)
        }
    }

    func navigateToDetailViewController(withTeamId teamId: String, name: String) {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/team/\(teamId)/students/get") else {
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

            // Print raw API response data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response to detailView: \(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(StudentDataResponse.self, from: data)
                
                // Print decoded response data
                print("Decoded Response: \(response)")

                DispatchQueue.main.async {
                    if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                        detailVC.token = self.token
                        detailVC.groupIds = self.groupIds
                        detailVC.teamId = teamId
                        detailVC.studentName = name
                        detailVC.studentDetails = response.data // Assign the student data array
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        
        task.resume()
    }
}
