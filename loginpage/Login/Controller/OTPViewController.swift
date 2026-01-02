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
    
    var phoneData: PhoneData?
    var phoneNumber: String?
    var countryCode: String?
    var loadingIndicator: UIActivityIndicatorView!
    var shouldAutoResendOTP: Bool = false
    
    private lazy var otpBoxes: [UITextField] = [box1, box2, box3, box4, box5, box6]

       /// Convenience var that always returns the combined OTP
       private var currentOTP: String {
           otpBoxes.compactMap { $0.text }.joined()
       }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("phoneNumber\(phoneNumber)")
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
        nextOutlet.isEnabled = false
        nextOutlet.alpha = 0.5
        
        if shouldAutoResendOTP {
                resendOTP()
            }

    }
    private func updateNextButtonState() {
        if currentOTP.count == 6 {
            nextOutlet.isEnabled = true
            nextOutlet.alpha = 1.0
        } else {
            nextOutlet.isEnabled = false
            nextOutlet.alpha = 0.5
        }
    }

    // MARK: - Delegate logic
    @objc private func textFieldDidChange(_ textField: UITextField) {
          guard let text = textField.text else { return }

          // Ensure max 1 character
          if text.count > 1 {
              textField.text = String(text.prefix(1))
          }

          // Move forward
          if !text.isEmpty {
              if let nextBox = nextBox(from: textField) {
                  nextBox.becomeFirstResponder()
              } else {
                  textField.resignFirstResponder()
              }
          }

          // ✅ Update button state
          updateNextButtonState()
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
       
       guard let phone = phoneNumber else {
           showAlert(message: "Phone number missing")
           return
       }

       let requestBody = VerifyOTPRequest(
           phone: phone,
           otp: otp
       )

       loadingIndicator.startAnimating()

       APIManager.shared.request(
           endpoint: "verify-otp",
           method: .post,
           body: requestBody
       ) { [weak self] (result: Result<VerifyOTPResponse, APIManager.APIError>) in

           guard let self = self else { return }

           self.loadingIndicator.stopAnimating()

           switch result {

           case .success(let response):
               print("📥 Verify OTP API Response:", response)

               if response.isValid {
                   // ✅ OTP Valid → Navigate
                   self.navigateToCreatePassword(otp: otp)
               } else {
                   // ❌ Invalid OTP → API Message
                   self.showAlert(message: response.message)
               }

           case .failure(let error):
               print("❌ Verify OTP API Error:", error)
               self.showAlert(message: "Failed to verify OTP")
           }
       }
   }


   func resendOTP() {
        
        guard let phone = phoneNumber, !phone.isEmpty else {
            showAlert(message: "Phone number missing")
            return
        }

        loadingIndicator.startAnimating()

        APIManager.shared.request(
            endpoint: "resend-otp",
            method: .get,
            queryParams: ["phone": phone],
            completion: { [weak self] (result: Result<ResendOTPResponse, APIManager.APIError>) in

                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()

                switch result {

                case .success(let response):
                    print("📥 Resend OTP Response:", response)

                    if response.success {
                        self.showAlert(message: response.message)
                    } else {
                        self.showAlert(message: "Failed to resend OTP")
                    }

                case .failure(let error):
                    print("❌ Resend OTP Error:", error)
                    self.showAlert(message: "Something went wrong")
                }
            }
        )
    }


    
    func navigateToCreatePassword(otp: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let createPasswordVC = storyboard.instantiateViewController(withIdentifier: "CreatePasswordViewController") as? CreatePasswordViewController else {
            print("ViewController with identifier 'CreatePasswordViewController' not found.")
            return
        }
        
        createPasswordVC.phoneNumber = phoneNumber
       // createPasswordVC.countryCode = countryCode
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

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // Handle delete
        if string.isEmpty {
            if range.length == 1 && textField.text?.count == 1 {
                textField.text = ""
                if let previous = previousBox(from: textField) {
                    previous.becomeFirstResponder()
                }

                // ✅ Update button after delete
                updateNextButtonState()
                return false
            }
            return true
        }

        // Allow only 1 digit
        guard string.count == 1 else { return false }

        // Allow only numbers
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }

        // Set digit
        textField.text = string

        DispatchQueue.main.async {
            if let nextBox = self.nextBox(from: textField) {
                nextBox.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }

            // ✅ Update button after input
            self.updateNextButtonState()
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

