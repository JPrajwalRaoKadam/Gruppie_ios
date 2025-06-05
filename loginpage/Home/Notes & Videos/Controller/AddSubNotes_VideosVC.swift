import UIKit
protocol AddSubNotesDelegate: AnyObject {
    func didAddSubject()
}
class AddSubNotes_VideosVC: UIViewController {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var enterSubject: UITextField!
    var isCheckButtonSelected: Bool = false
    var selectedStaffIds: Set<String> = []
    var subjectId: String = ""
    var staffList: [Stafff] = []
    var groupId : String = ""
    var teamId: String = ""
    var className : String = ""
    weak var delegate: AddSubNotesDelegate?
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "teacherNameTableViewCell", bundle: nil), forCellReuseIdentifier: "teacherNameTableViewCell")
        setupCheckButton(initiallySelected: false)
        fetchTeachingStaff(groupId: groupId)
        print("adsbgid: \(groupId) adsbtid: \(teamId)")
        print("selected staffid: \(selectedStaffIds)")
        print("className staffid: \(className)")
        enableKeyboardDismissOnTap()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addpost(_ sender: Any) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let optionalValue = isCheckButtonSelected
        let staffIdsArray = Array(selectedStaffIds)
        guard let enterSubject = enterSubject.text, !enterSubject.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter the subject name.")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/staff/add"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "optional": optionalValue,
            "staffId": staffIdsArray,
            "subjectName": enterSubject
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to serialize JSON body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }

            guard let data = data else {
                print("❗ No data received")
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("✅ API Response of addsub: \(rawResponse)")
            }

            DispatchQueue.main.async {
                self.delegate?.didAddSubject()
                self.showAlert(title: "Success", message: "Subject added successfully!")
            }
        }.resume()
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
            self.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true)
    }

  

    
    @IBAction func chekBttn(_ sender: Any) {
        checkButton.isSelected.toggle()
        isCheckButtonSelected = checkButton.isSelected
        print("✅ checkButton selected: \(isCheckButtonSelected)") // 👈 This line confirms the current state
    }

    private func setupCheckButton(initiallySelected: Bool) {
        checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkButton.isSelected = initiallySelected
        isCheckButtonSelected = initiallySelected // Keep variable in sync
        checkButton.backgroundColor = .white
    }
    
   func fetchTeachingStaff(groupId: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/staff/get?type=teaching"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching staff: \(error)")
                return
            }

            guard let data = data else {
                print("❗ No data received")
                return
            }

            if let rawJSON = String(data: data, encoding: .utf8) {
                print("✅ Raw API Response teacher:\n\(rawJSON)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let dataArray = json?["data"] as? [[String: Any]] {
                    self.staffList = dataArray.map { dict in
                        Stafff(
                            name: dict["name"] as? String ?? "",
                            staffId: dict["staffId"] as? String ?? ""
                        )
                    }
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            } catch {
                print("❌ Error parsing JSON: \(error)")
            }
        }.resume()
    }
}



    extension AddSubNotes_VideosVC: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return staffList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "teacherNameTableViewCell", for: indexPath) as? teacherNameTableViewCell else {
                return UITableViewCell()
            }

            let staff = staffList[indexPath.row]
            let name = staff.name ?? "Unknown"
            let staffId = staff.staffId ?? ""
            let isSelected = selectedStaffIds.contains(staffId)
            cell.configure(with: name, staffId: staffId, isSelected: isSelected)
            cell.delegate = self
            return cell
        }

    }
   
extension AddSubNotes_VideosVC: TeacherCellDelegate {
    func didToggleCheckBox(for staffId: String, isSelected: Bool) {
        if isSelected {
            selectedStaffIds.insert(staffId)
        } else {
            selectedStaffIds.remove(staffId)
        }
        print("✅ Selected Staff IDs: \(selectedStaffIds)")
    }
}
