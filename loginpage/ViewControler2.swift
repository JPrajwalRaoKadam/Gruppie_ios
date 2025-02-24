import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo") // Add your logo in Assets
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let countryCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Country Code (e.g., IN)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let termsSwitch: UISwitch = {
        let termsSwitch = UISwitch()
        termsSwitch.translatesAutoresizingMaskIntoConstraints = false
        return termsSwitch
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Agree to Terms and Policy"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isHidden = true // Initially hidden
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    // MARK: - UI Setup
    
    func setupLayout() {
        view.addSubview(logoImageView)
        view.addSubview(countryCodeTextField)
        view.addSubview(phoneNumberTextField)
        view.addSubview(termsSwitch)
        view.addSubview(termsLabel)
        view.addSubview(continueButton)
        view.addSubview(passwordTextField)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Logo ImageView
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Country Code TextField
            countryCodeTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            countryCodeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countryCodeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            countryCodeTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Phone Number TextField
            phoneNumberTextField.topAnchor.constraint(equalTo: countryCodeTextField.bottomAnchor, constant: 15),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Terms Switch and Label
            termsSwitch.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 15),
            termsSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            termsLabel.centerYAnchor.constraint(equalTo: termsSwitch.centerYAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: termsSwitch.trailingAnchor, constant: 10),
            
            // Continue Button
            continueButton.topAnchor.constraint(equalTo: termsSwitch.bottomAnchor, constant: 30),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Password TextField (Initially Hidden)
            passwordTextField.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Button Action
    
    @objc func handleContinue() {
        guard let countryCode = countryCodeTextField.text, !countryCode.isEmpty,
              let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty,
              termsSwitch.isOn else {
            print("Please fill all fields and accept terms.")
            return
        }
        
        // API Call to check user existence
        checkUserExists(countryCode: countryCode, phone: phoneNumber) { [weak self] userExists in
            DispatchQueue.main.async {
                if userExists {
                    self?.passwordTextField.isHidden = false // Show password field if user exists
                } else {
                    print("User does not exist.")
                    // You can handle non-existing user scenario here
                }
            }
        }
    }
    
    // MARK: - API Request
    
    func checkUserExists(countryCode: String, phone: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://api.gruppie.in/api/v1/user/exist/category/app?category=school&appName=GC2") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "userName": [
                "phone": phone,
                "countryCode": countryCode
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Failed to serialize parameters")
            completion(false)
            return
        }
        
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                completion(false)
                return
            }
            
            // Parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let userName = json["userName"] as? [String: Any],
                   let phone = userName["phone"] as? String, phone == "9911111111" {
                    completion(true) // User exists
                } else {
                    completion(false) // User does not exist
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                completion(false)
            }
        }
        
        task.resume()
    }
}
