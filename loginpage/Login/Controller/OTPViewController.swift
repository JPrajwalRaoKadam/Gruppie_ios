import UIKit

class OTPViewController: UIViewController {
    
    var phoneNumber: String?
    var countryCode: String?
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var Resend: UIButton!
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        butttonStyles()
        enableKeyboardDismissOnTap()
        if let number = phoneNumber {
            phoneNumberTextField.text = number
            print("Received phone number: \(number)")
        }
        
        
        func butttonStyles(){
            Resend.layer.cornerRadius = 10

            nextOutlet.layer.cornerRadius = 10

            cancelOutlet.layer.cornerRadius = 10
            phoneNumberTextField.layer.cornerRadius = 10
            phoneNumberTextField.clipsToBounds = true
            otpTextField.layer.cornerRadius = 10
            otpTextField.clipsToBounds = true
        }
        
        
        
        // Configure the OTP text field for auto-fill
        otpTextField.textContentType = .oneTimeCode
        otpTextField.keyboardType = .numberPad
        
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = self.view.center
        self.view.addSubview(loadingIndicator)
    }
    
    @IBAction func resetOTP(_ sender: UIButton) {
        resendOTP()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func next(_ sender: UIButton) {
        guard let otp = otpTextField.text, !otp.isEmpty else {
            showAlert(message: "Please enter the OTP.")
            return
        }
        verifyOTP(otp: otp)
    }
    
    func verifyOTP(otp: String) {
        guard let url = URL(string: APIManager.shared.baseURL + "verify/otp/category/app?category=school&appName=GC2") else {
            showAlert(message: "Invalid API URL.")
            return
        }
        
        let otpData: [String: Any] = [
            "phone": phoneNumber ?? "",
            "countryCode": countryCode ?? "IN",
            "otp": otp
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: otpData, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            showAlert(message: "Failed to prepare request. Please try again.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received.")
                }
                return
            }
            
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response data")")
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("Parsed JSON Response: \(jsonResponse ?? [:])")
                
                if let dataResponse = jsonResponse?["data"] as? [String: Any],
                   let otpVerified = dataResponse["otpVerified"] as? Int, otpVerified == 1 {
                    DispatchQueue.main.async {
                        self.navigateToCreatePassword(otp: otp)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Incorrect OTP. Please try again.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Error processing response. Please try again.")
                }
            }
        }
        task.resume()
    }
    
    func resendOTP() {
        guard let url = URL(string: APIManager.shared.baseURL + "forgot/password/category/app?category=school&appName=GC2") else {
            showAlert(message: "Invalid API URL.")
            return
        }
        
        let otpData: [String: Any] = [
            "phone": phoneNumber ?? "",
            "countryCode": countryCode ?? "IN"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: otpData, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            showAlert(message: "Failed to prepare request. Please try again.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received.")
                }
                return
            }
            
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No response data")")
            
            DispatchQueue.main.async {
                self.showAlert(message: "OTP resent successfully.")
            }
        }
        task.resume()
    }
    
    func navigateToCreatePassword(otp: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let createPasswordVC = storyboard.instantiateViewController(withIdentifier: "CreatePasswordViewController") as? CreatePasswordViewController else {
            print("ViewController with identifier 'CreatePasswordViewController' not found.")
            return
        }
        
        createPasswordVC.phoneNumber = phoneNumber
        createPasswordVC.countryCode = countryCode
        createPasswordVC.otp = otp
        
        self.navigationController?.pushViewController(createPasswordVC, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
