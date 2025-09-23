import UIKit

class AttenSettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AttenSettingCellDelegate {

    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var settingTableview: UITableView!
    @IBOutlet weak var DoneButton: UIButton!

    var groupId: String?
    var school: School?
    var attendanceSettimngData: [AttendanceModel] = [] // Store API response data
    var updatedAttendanceData: [String: String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // Assign delegates
        settingTableview.delegate = self
        settingTableview.dataSource = self
        
        // Styling the Done button
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        DoneButton.layer.cornerRadius = 10
        settingTableview.layer.cornerRadius = 10
        DoneButton.layer.masksToBounds = true
        DoneButton.clipsToBounds = true
        
        // Register the cell
        settingTableview.register(UINib(nibName: "AttenSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "AttenSettingTableViewCell")
        
        // Fetch API data
        fetchAttendanceSettingData()
        //self.navigationItem.hidesBackButton = true
        enableKeyboardDismissOnTap()
    }
    //new code 30 to 79
    func didUpdateAttendance(teamId: String, newValue: String) {
          updatedAttendanceData[teamId] = newValue
      }
    func updateAttendanceSettings() {
        guard let groupId = groupId else {
            print("Group ID is missing")
            return
        }

        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/add/attendance/settings"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var attendanceSettingsArray: [[String: Any]] = []

        for (teamId, newValue) in updatedAttendanceData {
            let setting: [String: Any] = [
                "numberOfTimeAttendance": newValue,
                "teamIds": [teamId]
            ]
            attendanceSettingsArray.append(setting)
        }

        let body: [String: Any] = [
            "attendanceSettings": attendanceSettingsArray
        ]

        // Print the raw dictionary before encoding
        print("Request Body Dictionary:", body)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Final JSON Body:", jsonString) // Print the JSON string being sent
            }
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating attendance: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.showSuccessPopup()
                }
            }

            if let data = data {
                print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Response Data")
            } else {
                print("No response data received")
            }
        }.resume()
    }

    func showSuccessPopup() {
        let alertController = UIAlertController(title: "Success", message: "Attendance edited successfully", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
     func fetchAttendanceSettingData() {
        guard let groupId = groupId else {
            print("Group ID is missing")
            return
        }

        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        // Corrected URL with the missing slash
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/class/get"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching attendance data: \(error)")
                return
            }

            // Check HTTP Response Status
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response Body: \(responseString)")
                    }
                }
            }

            // Handle non-200 status codes
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected HTTP response")
                return
            }

            // Parse the response data
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let attendanceData = jsonResponse["data"] as? [[String: Any]] {

                    self.attendanceSettimngData = attendanceData.map { student in
                        AttendanceModel(
                            teamId: student["teamId"] as? String ?? "",
                            numberOfTimeAttendance: "\(student["numberOfTimeAttendance"] ?? "0")",
                            name: student["name"] as? String ?? "",
                            image: student["image"] as? String ?? "",
                            enableAttendance: student["enableAttendance"] as? Bool ?? false
                        )
                    }
                    DispatchQueue.main.async {
                        self.settingTableview.reloadData()
                    }
                } else {
                    print("Failed to parse JSON response")
                }
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceSettimngData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
               return 70
           }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttenSettingTableViewCell", for: indexPath) as? AttenSettingTableViewCell else {
           return UITableViewCell()
       }

       let data = attendanceSettimngData[indexPath.row]
       cell.className.text = data.name
       cell.nofPeriod.text = data.numberOfTimeAttendance

       // Decode base64 image and set to UIImageView
       if let imageData = Data(base64Encoded: data.image), let image = UIImage(data: imageData) {
           cell.classimg.backgroundColor = UIColor(patternImage: image) // Set as background
       } else {
           cell.classimg.backgroundColor = .lightGray // Placeholder color
       }

       // Set checkbox based on enableAttendance
       cell.checkButton.isSelected = data.enableAttendance
       cell.contentView.backgroundColor = cell.checkButton.isSelected ? UIColor.lightGray : UIColor.white

       // Corrected code to load the image asynchronously
       if !data.image.isEmpty, // Direct check for non-empty image string
          data.image != "image_url_or_path", // Replace with the actual invalid URL check
          let imageUrl = URL(string: data.image) { // Using the non-optional `data.image`

           // Load image asynchronously
           URLSession.shared.dataTask(with: imageUrl) { imageData, response, error in
               if let imageData = imageData, let image = UIImage(data: imageData) {
                   DispatchQueue.main.async {
                       cell.classimg.image = image
                       cell.fallbackLabel.isHidden = true // Hide fallback label when image is available
                   }
               } else {
                   // Show fallback if the image fails to load
                   DispatchQueue.main.async {
                       cell.showFallbackImage(for: data.name) // Correct usage of `data.name`
                       cell.fallbackLabel.isHidden = false
                   }
               }
           }.resume()
       } else {
           // Show fallback when image is missing or invalid
           DispatchQueue.main.async {
               cell.classimg.image = nil // Ensure no old image is displayed
               cell.showFallbackImage(for: data.name) // Correct usage of `data.name`
               cell.fallbackLabel.isHidden = false
           }
       }
      // new code this is optional
    
             cell.configureCell(with: data)
             cell.delegate = self
       return cell
   }


    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
@IBAction func doneButtonTapped(_ sender: UIButton) {
    updateAttendanceSettings()
    print("done button pressed")
}
}

