import UIKit

class AddStudentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    
    var token: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var newStudent: Student?
    var newStudentDetails: [StudentData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("groupId: \(groupId), teamId: \(teamId), token: \(token)")

        TableView.register(UINib(nibName: "AddStudentTableViewCell", bundle: nil), forCellReuseIdentifier: "AddStudentTableViewCell")
        TableView.delegate = self
        TableView.dataSource = self

        // Apply rounded corners, border, and shadow to the table view
        TableView.layer.cornerRadius = 15
        TableView.layer.masksToBounds = true
        TableView.layer.borderWidth = 1
        TableView.layer.borderColor = UIColor.lightGray.cgColor
        TableView.layer.shadowColor = UIColor.black.cgColor
        TableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        TableView.layer.shadowOpacity = 0.3
        TableView.layer.shadowRadius = 4
        TableView.layer.masksToBounds = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddStudentTableViewCell", for: indexPath) as? AddStudentTableViewCell else {
            fatalError("Cell could not be dequeued")
        }
        return cell
    }

    @IBAction func AddButton(_ sender: UIButton) {
        guard let cell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddStudentTableViewCell else { return }
        
        let admissionType = cell.newAdmissionButton.isSelected ? "New Admission" : "Old Admission"
        let fatherName = cell.fatherName.text ?? ""
        let name = cell.name.text ?? ""
        let phone = cell.phone.text ?? ""

        print("User entered data: Admission Type: \(admissionType), Father Name: \(fatherName), Name: \(name), Phone: \(phone)")
        
        let countryCode = "IN"
        let studentData = StudentData(groupId: groupId, name: name, phone: phone, countryCode: countryCode, admissionType: admissionType, fatherName: fatherName.isEmpty ? nil : fatherName)
        let studentRegisterRequest = StudentRegisterRequest(studentData: [studentData])

        showLoadingIndicator()
        sendStudentDataToAPI(requestBody: studentRegisterRequest)
    }

    @IBAction func BackButton(_ sender: UIButton) {
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
    }
    
    func sendStudentDataToAPI(requestBody: StudentRegisterRequest) {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/multiple/student/register") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            if data.isEmpty {
                print("Received empty response.")
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode(StudentDataResponse.self, from: data)
                print("Decoded Response: \(responseModel)")
                
                DispatchQueue.main.async {
                    if !responseModel.data.isEmpty {
                        // Navigate back to previous screen (DetailViewController)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func hideLoadingIndicator() {
        for subview in view.subviews {
            if let activityIndicator = subview as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
