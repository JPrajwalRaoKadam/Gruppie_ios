import UIKit

 class editORdeleteVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var gateLocation: UITextField!
    @IBOutlet weak var gateName: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
     var groupId: String?
     var gateId: String?
     var gateNumber: String?
     var gateLocationText: String?
     var gateImageBase64: String?
     var updatedBase64Image: String?
     var gate: GateData?

    override func viewDidLoad() {
        super.viewDidLoad()
        gateName.layer.cornerRadius = 10
        gateName.layer.masksToBounds = true
        gateLocation.layer.cornerRadius = 10
        gateLocation.layer.masksToBounds = true
        editButton.layer.cornerRadius = 10
        editButton.clipsToBounds = true
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        gateName.text = gate?.gateNumber
        gateLocation.text = gate?.location
        addImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        addImage.addGestureRecognizer(tapGesture)
        print("editgate :\(gate?.image),\(gate?.gateNumber),\(gate?.location)")
    }
     @objc func selectImage() {
         let imagePicker = UIImagePickerController()
         imagePicker.delegate = self
         imagePicker.sourceType = .photoLibrary
         imagePicker.allowsEditing = true
         present(imagePicker, animated: true)
     }

     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let selectedImage = info[.editedImage] as? UIImage {
             addImage.image = selectedImage
         } else if let originalImage = info[.originalImage] as? UIImage {
             addImage.image = originalImage
         }
         picker.dismiss(animated: true)
     }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true)
     }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
  
    
    @IBAction func deleteButton(_ sender: Any) {
        guard let groupId = groupId, let gateId = gate?.gateId else {
            print("Missing groupId or gateId")
            return
        }
        
        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this gate?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performGateDelete(groupId: groupId, gateId: gateId)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func performGateDelete(groupId: String, gateId: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gate/\(gateId)/edit?type=delete"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Delete request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Gate deleted successfully")
                DispatchQueue.main.async {
                    if let nav = self.navigationController {
                        if let gateDetailsVC = nav.viewControllers.first(where: { $0 is GateDetailsVC }) as? GateDetailsVC {
                            gateDetailsVC.didAddNewGate()
                            nav.popToViewController(gateDetailsVC, animated: true)
                        } else {
                            nav.popViewController(animated: true)
                        }
                    }
                }
            } else {
                print("❌ Failed with status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }

   
    @IBAction func editButton(_ sender: Any) {
        guard let groupId = groupId,
              let gateId = gate?.gateId,
              let token = TokenManager.shared.getToken(),
              let gateNumber = gateName.text, !gateNumber.isEmpty else {
            print("Missing required fields")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gate/\(gateId)/edit?type=edit"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var imageBase64: String?
        if let image = addImage.image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            imageBase64 = imageData.base64EncodedString()
        } else if let existingImage = gate?.image?.first {
            imageBase64 = existingImage 
        }

        guard let base64Image = imageBase64 else {
            print("Image conversion failed")
            return
        }

        let requestBody: [String: Any] = [
            "gateNumber": gateNumber,
            "image": [base64Image]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Edit request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Gate edited successfully")
                DispatchQueue.main.async {
                    if let nav = self.navigationController {
                        if let gateDetailsVC = nav.viewControllers.first(where: { $0 is GateDetailsVC }) as? GateDetailsVC {
                            gateDetailsVC.didAddNewGate() // refresh list
                            nav.popToViewController(gateDetailsVC, animated: true)
                        } else {
                            nav.popViewController(animated: true)
                        }
                    }
                }
            } else {
                print("❌ Failed with status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }

    
    private func generateImage(from name: String) -> UIImage? {
        let letter = name.prefix(1).uppercased()
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.link.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 30),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = letter.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        letter.draw(in: textRect, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
