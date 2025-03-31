import UIKit

class AddCombineClass: UIViewController {
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var MainView: UIView!
    var token: String = ""  // Add your token here
    var groupIds: String = ""  // Add your group ID here
    var studentTeams: [StudentTeam] = []
    var filteredStudentTeams: [StudentTeam] = []
    var combinedStudentTeams: [CombinedStudentTeam] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set curved corners for MainView
        MainView.layer.cornerRadius = 15
        MainView.layer.masksToBounds = false

        // Add a subtle border for visibility against white background
        MainView.layer.borderWidth = 1
        MainView.layer.borderColor = UIColor.gray.cgColor

        // Add 3D shadow effect to MainView
        MainView.layer.shadowColor = UIColor.black.cgColor
        MainView.layer.shadowOffset = CGSize(width: 0, height: 5)
        MainView.layer.shadowOpacity = 0.5
        MainView.layer.shadowRadius = 10

        // Optionally add a background color to MainView for better contrast (if needed)
        MainView.backgroundColor = UIColor.white

        // Add target for AddButton tap
        AddButton.addTarget(self, action: #selector(addClassTapped), for: .touchUpInside)
    }

    @objc func addClassTapped() {
        // Check if the teamName is not empty
        guard let teamNameText = teamName.text, !teamNameText.isEmpty else {
            print("Team name is empty")
            return
        }

        print("Token: \(token)")  // Log the token being used
        print("Group ID: \(groupIds)")  // Log the groupId being used

        // Prepare API URL and Request Body
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupIds)/class/add/extra"
        let base64Image = "aHR0cHM6Ly9ncnVwcGllbWVkaWEuc2pwMS5kaWdpdGFsb2NlYW5zcGFjZXMuY29tL2ltYWdlcy9nYzJfMTczOTc3Njc0ODM3NC5qcGc="
        let requestBody: [String: Any] = [
            "image": base64Image,
            "name": teamNameText
        ]
        
        // Convert dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Failed to serialize JSON")
            return
        }

        print("Request Body: \(requestBody)")

        // Create request
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform API call using URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to add class. Please try again.")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Response Status Code: \(httpResponse.statusCode)")

                    if httpResponse.statusCode == 201 {
                        self.showAlert(title: "Success", message: "Class '\(teamNameText)' added successfully!") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        self.showAlert(title: "Error", message: "Failed to add class. Please check your details and try again.")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                }
            }
        }
        task.resume()
    }

    // Helper function to show an alert with an optional completion handler
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?() // Execute completion if provided
        })
        present(alert, animated: true, completion: nil)
    }
    @IBAction func BackButton(_ sender: UIButton) {
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
    }

}
