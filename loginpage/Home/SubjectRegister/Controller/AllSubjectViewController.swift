
import UIKit

class AllSubjectViewController: UIViewController, AllSubjectDetailTableViewCellDelegate {
    @IBOutlet weak var TableView: UITableView!
    
    // Required Data for Navigation
    var staffList: [Staff] = [] // ✅ Store staff list here

    var token: String = TokenManager.shared.getToken() ?? ""
    var groupId: String = ""
    var teamId: String = ""
    
    var subjectDetails: [SubjectDetail] = []
    var subjectDetail: SubjectDetail?

    let sectionTitles = ["Language-1", "Language-2", "Language-3", "Other subjects", "Optional subjects"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib(nibName: "AllSubjectDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "AllSubjectDetailTableViewCell")
    }
    
    override func viewWillAppear(_: Bool) {
           super.viewWillAppear(true)
           TableView.reloadData()
       }

    func subjectsForSection(_ section: Int) -> [SubjectDetail] {
        switch section {
        case 0: return subjectDetails.filter { $0.subjectPriority == 1 }
        case 1: return subjectDetails.filter { $0.subjectPriority == 2 }
        case 2: return subjectDetails.filter { $0.subjectPriority == 3 }
        case 3: return subjectDetails.filter { $0.subjectPriority == 0 }
        default: return []
        }
    }
    
    func addNewSubject(to section: Int) {
//        let newSubject = SubjectDetail(subjectName: "New Subject", subjectPriority: section + 1)
//        subjectDetails.append(newSubject)
//        
//        // Reload only the affected section
//        let indexSet = IndexSet(integer: section)
//        TableView.reloadSections(indexSet, with: .automatic)
        if let subjectDetail = self.subjectDetail {
            self.didTapAddButton(for: subjectDetail, sectionIndex: section)
        }
        let indexSet = IndexSet(integer: section)
        TableView.reloadSections(indexSet, with: .automatic)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AllSubjectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectsForSection(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllSubjectDetailTableViewCell", for: indexPath) as? AllSubjectDetailTableViewCell else {
            return UITableViewCell()
        }
        
        // Get subjects for the section
        let subjectsInSection = subjectsForSection(indexPath.section)
        
        // Access the correct subject for the row
        let subjectDet = subjectsInSection[indexPath.row]
        self.subjectDetail = subjectDet

        cell.delegate = nil // Prevent reuse issues
        cell.delegate = self // ✅ Ensure delegate is set

        
        if let staffDet = subjectDet.staffName?.first  {// This is of type `SubjectStaffMember?`
            
            // Configure cell
            cell.configure(with: staffDet, subjectDetail: subjectDet)
        }
        
        return cell
    }

    
    // MARK: - Section Header with Button
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.systemGray6 // Lighter gray color

        // Section Title
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 10, width: 200, height: 30))
        titleLabel.text = sectionTitles[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerView.addSubview(titleLabel)

        // Add Button (Rounded)
        let buttonSize: CGFloat = 36
        let button = UIButton(frame: CGRect(x: tableView.frame.width - 50, y: 7, width: buttonSize, height: buttonSize))
        button.setTitle("+", for: .normal) // "+" to indicate adding
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = buttonSize / 2 // Make it circular
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        button.tag = section
        headerView.addSubview(button)

        return headerView
    }
    
    // Handle Add Button Tap
    @objc func addButtonTapped(_ sender: UIButton) {
        let sectionIndex = sender.tag
        print("✅ Add button tapped for section: \(sectionTitles[sectionIndex])")
        addNewSubject(to: sectionIndex)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension AllSubjectViewController {
    
    func didTapStaffSubject(for subjectDetail: SubjectDetail) {
        print("✅ Staff Subject Button Tapped for \(subjectDetail.subjectName)")

        guard !groupId.isEmpty, !teamId.isEmpty, !token.isEmpty else {
            print("❌ Missing groupId, teamId, or token")
            return
        }

        let apiURL = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching"
        fetchStaffData(from: apiURL) { [weak self] fetchedStaffList in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.staffList = fetchedStaffList // ✅ Store response in staffList

                // Extract subjectId safely
                guard let subjectId = subjectDetail.subjectId else {
                    print("❌ Missing subjectId")
                    return
                }

                let storyboard = UIStoryboard(name: "Subject", bundle: nil)
                if let staffSubjectVC = storyboard.instantiateViewController(withIdentifier: "StaffSujectViewController") as? StaffSujectViewController {
                    staffSubjectVC.token = self.token
                    staffSubjectVC.groupId = self.groupId
                    staffSubjectVC.teamId = self.teamId
                    staffSubjectVC.selectedSubject = subjectDetail
                    staffSubjectVC.subjectPriority = subjectDetail.subjectPriority
                    staffSubjectVC.subjectId = subjectId

                    print("✅ Navigating to StaffSubjectViewController with subjectId: \(subjectId) and \(self.staffList.count) staff members")
                    self.navigationController?.pushViewController(staffSubjectVC, animated: true)
                } else {
                    print("❌ Error: Could not instantiate StaffSubjectViewController")
                }
            }
        }
    }

    }

    extension AllSubjectViewController {
        func fetchStaffData(from urlString: String, completion: @escaping ([Staff]) -> Void) {
            print("🌍 API URL: \(urlString)")
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL")
                completion([])
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ API Request Error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion([])
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📜 Raw API Response: \(jsonString)")
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(StaffResponse.self, from: data)
                    let staffList = decodedResponse.data
                    print("✅ Fetched \(staffList.count) staff members")
                    completion(staffList) // ✅ Return fetched staff list
                } catch {
                    print("❌ JSON Decoding Error: \(error.localizedDescription)")
                    completion([])
                }
            }
            task.resume()
        }
    }
extension AllSubjectViewController {
    
    func didTapAddButton(for subjectDetail: SubjectDetail, sectionIndex: Int) {
        print("✅ Delegate Method Called in AllSubjectViewController")
        print("📌 Subject Name: \(subjectDetail.subjectName)")
        print("📌 Section Index: \(sectionIndex)")

        let apiURL = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/get?option=more"
        print("🌍 API URL: \(apiURL)")

        fetchSubjectData(from: apiURL) { [weak self] subjects in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Subject", bundle: nil)
                if let addSubjectVC = storyboard.instantiateViewController(withIdentifier: "AddSubject") as? AddSubject {
                    
                    addSubjectVC.token = self.token
                    addSubjectVC.groupId = self.groupId
                    addSubjectVC.teamId = self.teamId
                    addSubjectVC.subjectDetail = subjectDetail
                    addSubjectVC.sectionIndex = sectionIndex 
                    
                    print("✅ Navigating to AddSubject with \(subjects.count) subjects")
                    
                    self.navigationController?.pushViewController(addSubjectVC, animated: true)
                } else {
                    print("❌ Error: Could not instantiate AddSubject")
                }
            }
        }
    }
}

extension AllSubjectViewController {
    func fetchSubjectData(from urlString: String, completion: @escaping ([SubjectDetail]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Invalid Response")
                completion([])
                return
            }
            
            print("🌍 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No Data Received")
                completion([])
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Raw API Response: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SubjectRegisterResponse.self, from: data)
                let subjects = decodedResponse.data
                
                print("✅ API Response: \(subjects)")
                completion(subjects)
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
                completion([])
            }
        }
        task.resume()
    }
    func didTapStudentSubject(for subjectDetail: SubjectDetail) {
        print("✅ Student Subject Button Tapped for \(subjectDetail.subjectName)")

        guard !groupId.isEmpty, !teamId.isEmpty, !token.isEmpty else {
            print("❌ Missing groupId, teamId, or token")
            return
        }

        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Subject", bundle: nil)
            if let studentSubjectVC = storyboard.instantiateViewController(withIdentifier: "StudentSubjectViewController") as? StudentSubjectViewController {
                
                studentSubjectVC.token = self.token
                studentSubjectVC.groupId = self.groupId
                studentSubjectVC.teamId = self.teamId
                studentSubjectVC.selectedSubject = subjectDetail
                studentSubjectVC.subjectPriority = subjectDetail.subjectPriority
                studentSubjectVC.subjectId = subjectDetail.subjectId
                
                print("✅ Navigating to StudentSubjectViewController with subjectId: \(subjectDetail.subjectId ?? "")")
                self.navigationController?.pushViewController(studentSubjectVC, animated: true)
            } else {
                print("❌ Error: Could not instantiate StudentSubjectViewController")
            }
        }
    }

}
