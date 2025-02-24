import UIKit

class CreateAccountViewController: UIViewController {
    
    // Property to hold the phone number
    var phoneNumber: String?

    @IBOutlet weak var NextOutlet: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField! // Variable for user name

    override func viewDidLoad() {
        super.viewDidLoad()
        butttonStyles()
        // Display the received phone number
        if let number = phoneNumber {
            phoneNumberTextField.text = number // Set the phone number directly to the text field
            print("Received phone number: \(number)")
        }
    }
    func butttonStyles(){
        NextOutlet.layer.cornerRadius = 10
        nameTextField.layer.cornerRadius = 10
        nameTextField.clipsToBounds = true
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.clipsToBounds = true
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        print("Next button pressed")
        
        // Validate name input
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter your name.")
            return
        }
        
        // Disable the button to prevent multiple taps
        sender.isEnabled = false
        
        // Create the API request
        registerUser(name: name, phoneNumber: phoneNumber ?? "", sender: sender)
    }
    
    func registerUser(name: String, phoneNumber: String, sender: UIButton) {
        guard let url = URL(string: APIManager.shared.baseURL + "register/category/app?category=school&appName=GC2&addSchool=true") else {
            showAlert(message: "Invalid API URL.")
            sender.isEnabled = true
            return
        }

        // Create the request body
        let signinForms: [String: Any] = [
            "countryCode": "IN",
            "phone": phoneNumber,
            "name": name // Using the name variable
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: signinForms, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            showAlert(message: "Failed to prepare request. Please try again.")
            sender.isEnabled = true
            return
        }
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                    sender.isEnabled = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received.")
                    sender.isEnabled = true
                }
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("Parsed JSON Response: \(String(describing: jsonResponse))")
                
                // Handle the response as needed (e.g., check for success)
                DispatchQueue.main.async {
                    // You might want to navigate to the OTPViewController here
                    self.navigateToOTPViewController()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Error processing response. Please try again.")
                    sender.isEnabled = true
                }
            }
        }
        task.resume()
    }
    
    func navigateToOTPViewController() {
        // Instantiate OTPViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let otpVC = storyboard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController else {
            print("ViewController with identifier 'OTPViewController' not found.")
            return
        }
        
        // Pass the phone number to OTPViewController
        otpVC.phoneNumber = phoneNumber
        
        // Navigate to OTPViewController
        self.navigationController?.pushViewController(otpVC, animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

