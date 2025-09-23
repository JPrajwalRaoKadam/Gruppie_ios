import UIKit

class OTPViewController: UIViewController {
    
  
    @IBOutlet weak var box1: UITextField!
    @IBOutlet weak var box2: UITextField!
    @IBOutlet weak var box3: UITextField!
    @IBOutlet weak var box4: UITextField!
    @IBOutlet weak var box5: UITextField!
    @IBOutlet weak var box6: UITextField!
    @IBOutlet weak var otpStack: UIStackView!
    @IBOutlet weak var Resend: UIButton!
    @IBOutlet weak var nextOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    var phoneNumber: String?
    var countryCode: String?
    var loadingIndicator: UIActivityIndicatorView!
    
    private lazy var otpBoxes: [UITextField] = [box1, box2, box3, box4, box5, box6]

       /// Convenience var that always returns the combined OTP
       private var currentOTP: String {
           otpBoxes.compactMap { $0.text }.joined()
       }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        butttonStyles()
        [box1, box2, box3, box4, box5, box6].forEach { $0?.applyRoundedStyle2() }
        enableKeyboardDismissOnTap()
        
        otpBoxes.forEach { tf in
                    tf.delegate = self
                    tf.keyboardType = .numberPad
                    tf.textAlignment = .center
                    tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                }
                otpBoxes.first?.becomeFirstResponder()
        
        func butttonStyles(){
            Resend.layer.cornerRadius = 10
            nextOutlet.layer.cornerRadius = 10
            cancelOutlet.layer.cornerRadius = 10
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let underlineAttributedString = NSAttributedString(string: "Resend", attributes: underlineAttribute)
            Resend.setAttributedTitle(underlineAttributedString, for: .normal)

        }
    
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = self.view.center
        self.view.addSubview(loadingIndicator)
    }
    // MARK: - Delegate logic
      @objc private func textFieldDidChange(_ textField: UITextField) {
          guard let text = textField.text else { return }

          // 1. Ensure max 1 character per box
          if text.count > 1 {
              textField.text = String(text.prefix(1))
          }

          // 2. Move forward when a new character is typed
          if !text.isEmpty {
              if let nextBox = nextBox(from: textField) {
                  nextBox.becomeFirstResponder()
              } else {
                  textField.resignFirstResponder() // all filled, close keyboard if you like
              }
          }
      }
    
    @IBAction func resetOTP(_ sender: UIButton) {
        resendOTP()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func next(_ sender: UIButton) {
      
        verifyOTP(otp: currentOTP)
    }
    
    func verifyOTP(otp: String) {
        guard let url = URL(string: APIManager.shared.baseURL + "verify/otp/category/app?category=school&appName=GC2") else {
            showAlert(message: "Invalid API URL.")
            return
        }
        
        let otpData: [String: Any] = [
            "phone": phoneNumber ?? "",
            "countryCode": countryCode ?? "IN",
            "otp": currentOTP
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
extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Handle backspace/delete
        if string.isEmpty {
            // If deleting and current field becomes empty, move to previous field
            if range.length == 1 && textField.text?.count == 1 {
                textField.text = ""
                if let previous = previousBox(from: textField) {
                    previous.becomeFirstResponder()
                }
                return false
            }
            // Allow normal deletion within field
            return true
        }
        
        // Allow only one character input
        guard string.count == 1 else { return false }
        
        // Only allow numeric characters
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }
        
        // Update text field
        textField.text = string
        
        // Move to next field
        DispatchQueue.main.async {
            if let nextBox = self.nextBox(from: textField) {
                nextBox.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
        return false
    }
}

// MARK: - Helpers
private extension OTPViewController {
    func nextBox(from textField: UITextField) -> UITextField? {
        guard let index = otpBoxes.firstIndex(of: textField),
              index + 1 < otpBoxes.count else { return nil }
        return otpBoxes[index + 1]
    }

    func previousBox(from textField: UITextField) -> UITextField? {
        guard let index = otpBoxes.firstIndex(of: textField),
              index > 0 else { return nil }
        return otpBoxes[index - 1]
    }
}

extension UITextField {
    func applyRoundedStyle2(radius: CGFloat = 10) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1        // optional
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.backgroundColor = .white
    }
}
