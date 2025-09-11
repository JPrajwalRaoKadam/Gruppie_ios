
protocol AddGateDelegate: AnyObject {
    func didAddNewGate()
}
import UIKit
class AddGateVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var groupId: String?
    weak var delegate: AddGateDelegate?
    var base64ImageString: String?
    
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var gateLocation: UITextField!
    @IBOutlet weak var gateName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        addImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        addImage.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            addImage.image = selectedImage
            if let imageData = selectedImage.jpegData(compressionQuality: 0.7) {
                base64ImageString = imageData.base64EncodedString()
            }
        }
    }

    @IBAction func submitButton(_ sender: Any) {
        guard let groupId = groupId else {
            print("❌ groupId is nil")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        guard let gateNumber = gateName.text, !gateNumber.isEmpty else {
            print("❌ Gate name is empty")
            return
        }

        guard let base64Image = base64ImageString else {
            print("❌ No image selected")
            return
        }

        let body: [String: Any] = [
            "gateNumber": gateNumber,
            "image": [base64Image],
            "latitude": "12.932302621165105", // Replace with dynamic values if needed
            "longitude": "77.58789841085672"
        ]
        
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/add/gates") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("✅ API Response: \(jsonString)")
            }
            
            DispatchQueue.main.async {
                self.delegate?.didAddNewGate() // Notify GateDetailsVC
                self.navigationController?.popViewController(animated: true)
            }

        }.resume()
    }
}

