import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // Retrieve the saved phone number from UserDefaults
        guard let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") else {
            showAlert(message: "Phone number not found.")
            return
        }

        // Validate the password input
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter a password.")
            return
        }

        // Call the API to validate the password
        callLoginAPI(with: phoneNumber, password: password)
    }

    func callLoginAPI(with phoneNumber: String, password: String) {
        // Prepare the request body
        let requestBody: [String: Any] = [
            "userName": [
                "phone": phoneNumber,
                "countryCode": "IN"
            ],
            "password": password
        ]

        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Error converting request body to JSON")
            showAlert(message: "Error preparing request. Please try again.")
            return
        }

        // API URL for login
        guard let url = URL(string: "https://api.gruppie.in/api/v1/login/category/app?category=school&appName=GC2&addSchool=true") else {
            print("Invalid URL")
            showAlert(message: "Invalid API URL. Please try again.")
            return
        }

        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors in the API call
            if let error = error {
                print("Error making API call: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription). Please try again.")
                }
                return
            }

            // Check if data was received
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.showAlert(message: "No response from the server. Please try again.")
                }
                return
            }

            do {
                // Parse the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Check if the login was successful
                    if let success = jsonResponse["success"] as? Bool, success {
                        DispatchQueue.main.async {
                            // Navigate to the dashboard on success
                            self.navigateToDashboard()
                        }
                    } else {
                        DispatchQueue.main.async {
                            // Show an alert if login fails
                            if let message = jsonResponse["message"] as? String {
                                self.showAlert(message: message)
                            } else {
                                self.showAlert(message: "Incorrect password. Please try again.")
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing response: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Error processing response. Please try again.")
                }
            }
        }
        task.resume()
    }

    func navigateToDashboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController else {
            print("DashboardViewController not found.")
            return
        }
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
