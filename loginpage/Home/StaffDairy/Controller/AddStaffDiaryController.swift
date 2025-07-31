import UIKit

class AddStaffDiaryController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var token: String?
    var groupId: String? = "" 

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 20
            tableView.clipsToBounds = true

            tableView.layer.shadowColor = UIColor.black.cgColor
            tableView.layer.shadowOffset = CGSize(width: 0, height: 4)
            tableView.layer.shadowOpacity = 0.3
            tableView.layer.shadowRadius = 10
            tableView.layer.masksToBounds = false

            tableView.layer.borderWidth = 1
            tableView.layer.borderColor = UIColor.lightGray.cgColor

            tableView.backgroundColor = UIColor.white

            tableView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        addButton.layer.cornerRadius = 10
        addButton.clipsToBounds = true

        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowRadius = 5
        addButton.layer.masksToBounds = false
        print("Token: \(TokenManager.shared.getToken() ?? "No Token")")
        print("Group ID: \(groupId ?? "No Group ID")")

        guard let tableView = tableView else {
            print("Error: tableView is nil.")
            return
        }

        tableView.register(UINib(nibName: "AddDiaryStaff", bundle: nil), forCellReuseIdentifier: "AddDiaryStaffCell")

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 20
        tableView.clipsToBounds = true
//        addButton.layer.cornerRadius = 10
//        addButton.clipsToBounds = true
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddDiaryStaffCell", for: indexPath) as? AddDiaryStaff else {
            return UITableViewCell()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButton(_ sender: UIButton) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddDiaryStaff else {
            print("Error: Unable to get AddStaff cell.")
            return
        }

        let name = cell.name.text ?? ""
        let country = cell.country.text ?? "IN"
        let phone = cell.phone.text ?? ""
        let designation = cell.designation.text ?? ""
        let isPermanent = cell.permanent.text == "Permanent"

        let staffData = StaffData(
            countryCode: country,
            designation: designation,
            name: name,
            permanent: isPermanent,
            phone: phone
        )
        let requestBody = StaffRequest(staffData: [staffData])

        let type = segmentController.selectedSegmentIndex == 0 ? "teaching" : "nonteaching"
        guard let groupId = groupId else {
            print("Error: groupId is nil")
            return
        }

        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/multiple/staff/register?type=\(type)"
        print("Making API call to: \(apiUrl)")

        postStaffData(to: apiUrl, requestBody: requestBody)
    }


    private func postStaffData(to url: String, requestBody: StaffRequest) {
        guard let requestUrl = URL(string: url) else {
            print("Error: Invalid URL - \(url)")
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Error encoding")")
            request.httpBody = jsonData
        } catch {
            print("Error: Failed to encode request body - \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Network request failed - \(error)")
                return
            }

            guard let data = data else {
                print("Error: No response data received")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("HTTP Status Code: \(response.statusCode)")
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    print("API Response: \(jsonResponse)")

                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        self.showAlert(title: "Success", message: "Staff data has been saved successfully.")
                    } else {
                        self.showAlert(title: "Error", message: "Failed to save staff data.")
                    }
                }
            } catch {
                print("Error: Failed to parse response - \(error)")
            }
        }
        task.resume()
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


