protocol VisitorDetailsDelegate: AnyObject {
    func didUpdateVisitorData()
}

import UIKit
import AVFoundation
class VisitorDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GateListVCDelegate  {
    func didSelectGate(gateId: String, gateNumber: String) {
        self.selectedGateId = gateId
        selectGateButton.setTitle(gateNumber, for: .normal)
    }
    
    weak var delegate: VisitorDetailsDelegate?
    
    @IBOutlet weak var visit: UILabel!
    @IBOutlet weak var idImage: UILabel!
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var vehicleNo: UITextField!
    @IBOutlet weak var whoomToMe: UITextField!
    @IBOutlet weak var roomNo: UITextField!
    @IBOutlet weak var building: UITextField!
    @IBOutlet weak var idCardImage: UIImageView!
    @IBOutlet weak var visitorImage: UIImageView!
    @IBOutlet weak var reason: UITextField!
    @IBOutlet weak var selectGateButton: UIButton!
    @IBOutlet weak var checkout: UIButton!
    
    var visitor: VisitorResponseModel?
    var enteredPhone: String?
    var visitorUIImage: UIImage?
    var idCardUIImage: UIImage?
    var groupId: String?
    var currentRole: String?
    var selectedGateId: String?
    var isFromAddFlow: Bool = true
  
        var currentImageType: ImageType = .visitor // To track which image we're capturing
        
        enum ImageType {
            case visitor
            case idCard
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.layer.cornerRadius = 10
        name.layer.masksToBounds = true
        phone.layer.cornerRadius = 10
        phone.layer.masksToBounds = true
        address.layer.cornerRadius = 10
        address.layer.masksToBounds = true
        vehicleNo.layer.cornerRadius = 10
        vehicleNo.layer.masksToBounds = true
        whoomToMe.layer.cornerRadius = 10
        whoomToMe.layer.masksToBounds = true
        roomNo.layer.cornerRadius = 10
        roomNo.layer.masksToBounds = true
        building.layer.cornerRadius = 10
        building.layer.masksToBounds = true
        reason.layer.cornerRadius = 10
        reason.layer.masksToBounds = true
        
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        visit.layer.cornerRadius = 10
        visit.layer.masksToBounds = true
        idImage.layer.cornerRadius = 10
        idImage.layer.masksToBounds = true
        bcbutton.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStudentInfo(_:)), name: Notification.Name("SelectedStudentNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStaffInfo(_:)), name: Notification.Name("StaffSelected"), object: nil)

        
        checkout.layer.cornerRadius = 10
        selectGateButton.layer.cornerRadius = 10
        print("groupId in visitorvc:\(groupId)")
        
        print("role in visitorvc:\(currentRole)")
           // Disable gate selection for admin
           if currentRole == "admin"  && isFromAddFlow == false{
               selectGateButton.isUserInteractionEnabled = false
               selectGateButton.isEnabled = false  // This is often better than just disabling interaction
               selectGateButton.backgroundColor = .systemGray5  // Correct syntax for system colors
               selectGateButton.setTitleColor(.black, for: .normal)  // Correct way to set button title color
           }

        if let phoneVal = enteredPhone {
            phone.text = phoneVal
        }
        
        if let visitorImg = visitorUIImage {
            visitorImage.image = visitorImg
        }
        
        if let idImg = idCardUIImage {
            idCardImage.image = idImg
        }
 
        if isFromAddFlow {
             configureAddButton()
             setupImageTapGestures()
         } else {
             if currentRole == "admin" {
                 checkout.isHidden = true
             } else if currentRole == "teacher" {
                 configureCheckoutButton()
             }
         }
        
        if let v = visitor {
            name.text = "Name: \(v.visitorName ?? "")"
            phone.text = "Phone No: \(v.visitorMobileNo ?? "")"
            address.text = "Address: \( v.visitorAddress ?? "")"
            vehicleNo.text = "VehicleNo: \(v.visitorVehicleNo ?? "")"
            whoomToMe.text = "Whoom to meet: \(v.personToVisit ?? "")"
            building.text = "Building: \(v.building ?? "")"
            reason.text = "Reason: \(v.reason ?? "")"
            selectGateButton.setTitle(v.gateName.isEmpty ?? true ? "Gate No." : v.gateName, for: .normal)
            
            if let idImages = v.visitorIdCardImage, let firstImage = idImages.first {
                setImage(from: firstImage, in: idCardImage)
            }
            if let visitorImageString = v.visitorImage {
                setImage(from: visitorImageString, in: visitorImage)
            }
        }
    }
    
    @objc func receiveStaffInfo(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let staffName = userInfo["name"] as? String,
              let staffId = userInfo["userId"] as? String else { return }

        whoomToMe.text = "Whoom to meet: \(staffName)"
        print("✅ Received staff name: \(staffName), userId: \(staffId)")
    }
    
   
    @objc func receiveStudentInfo(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let studentName = userInfo["name"] as? String,
              let groupId = userInfo["groupId"] as? String else { return }

        whoomToMe.text = "Whoom to meet: \(studentName)"
        self.groupId = groupId

        print("✅ Received student name: \(studentName), groupId: \(groupId)")
    }

    private func configureAddButton() {
        checkout.isHidden = false
        checkout.setTitle("Add", for: .normal)
        checkout.removeTarget(nil, action: nil, for: .allEvents)
        checkout.addTarget(self, action: #selector(addVisitorFromTeacher), for: .touchUpInside)
    }

    private func configureCheckoutButton() {
        checkout.isHidden = false
        checkout.setTitle("Checkout", for: .normal)
        checkout.removeTarget(nil, action: nil, for: .allEvents)
        checkout.addTarget(self, action: #selector(chekout(_:)), for: .touchUpInside)
    }
    
    private func setupImageTapGestures() {
        let visitorTap = UITapGestureRecognizer(target: self, action: #selector(handleVisitorImageTap))
        visitorImage.isUserInteractionEnabled = true
        visitorImage.addGestureRecognizer(visitorTap)
        
        let idCardTap = UITapGestureRecognizer(target: self, action: #selector(handleIdCardImageTap))
        idCardImage.isUserInteractionEnabled = true
        idCardImage.addGestureRecognizer(idCardTap)
    }
    
    @objc private func handleVisitorImageTap() {
        currentImageType = .visitor
        checkCameraPermissionAndPresentPicker()
    }
    
    @objc private func handleIdCardImageTap() {
        currentImageType = .idCard
        checkCameraPermissionAndPresentPicker()
    }
    
    private func checkCameraPermissionAndPresentPicker() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            presentImagePicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.presentImagePicker()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        default:
            showCameraPermissionAlert()
        }
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please enable camera access in Settings to take photos",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            showAlert(message: "Failed to capture image")
            return
        }
        
        switch currentImageType {
        case .visitor:
            visitorImage.image = image
        case .idCard:
            idCardImage.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    @IBAction func whomToMeet(_ sender: Any) {
        showWhomToMeetOptions()
    }
    func showWhomToMeetOptions() {
        let alert = UIAlertController(title: "Select Whom to Meet", message: nil, preferredStyle: .actionSheet)
        
        let staffAction = UIAlertAction(title: "Select Staff", style: .default) { _ in
            self.navigateToSelectStaff()
        }
        
        let studentAction = UIAlertAction(title: "Select Student", style: .default) { _ in
            self.navigateToSelectStudent()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(staffAction)
        alert.addAction(studentAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToSelectStudent() {
        let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "SelectStuVC") as? SelectStuVC {
            print("VisitorDetailsVC groupId: \(groupId ?? "nil")")
            homeVC.groupId = self.groupId
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    func navigateToSelectStaff() {
        let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "SelectStaffVC") as? SelectStaffVC {
            print("VisitorDetailsVC groupId: \(groupId ?? "nil")")
            homeVC.groupId = self.groupId
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    @IBAction func chekout(_ sender: Any) {
        if checkout.titleLabel?.text == "Checkout" {
        guard let visitorId = visitor?.visitorsId, let groupId = visitor?.groupId else {
            print("❌ Missing visitorId or groupId")
            return
        }
        
        performVisitorCheckout(visitorId: visitorId, groupId: groupId)
        } else {
            addVisitorFromTeacher()
            
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gate(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GateManagement", bundle: nil)
        if let gateListVC = storyboard.instantiateViewController(withIdentifier: "GateListVC") as? GateListVC {
            gateListVC.groupId = self.groupId
            gateListVC.currentRole = self.currentRole
            gateListVC.delegate = self
            gateListVC.modalPresentationStyle = .pageSheet
            
            if let sheet = gateListVC.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.75
                    })
                ]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(gateListVC, animated: true)
        }
    }
    
    func performVisitorCheckout(visitorId: String, groupId: String) {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let visitorImageBase64 = visitorImage.image?.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? ""
        let idCardImageBase64 = idCardImage.image?.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? ""
        let body: [String: Any] = [
            "visitorImage": visitorImageBase64,
            "visitorName": name.text ?? "",
            "gateName": selectGateButton.title(for: .normal) ?? "",
            "visitorMobileNo": phone.text ?? "",
            "visitorAddress": address.text ?? "",
            "visitorVehicleNo": vehicleNo.text ?? "",
            "personToVisit": whoomToMe.text ?? "",
            "roomNo": roomNo.text ?? "",
            "buildingNumber": "",
            "building": building.text ?? "",
            "purposeOfVisit": reason.text ?? "",
            "visitorIdCardImage": [idCardImageBase64],
            "gateId": visitor?.gateId ?? "",
            "reason": reason.text ?? "",
            "personToVisitUserId": visitor?.personToVisitUserId ?? "",
            "personToVisitImage": visitor?.personToVisitImage ?? "",
            "personToVisitTeamId": visitor?.personToVisitTeamId ?? ""
        ]
        
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/visitor/\(visitorId)/checkout") else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to encode JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }
            
            print("✅ Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.delegate?.didUpdateVisitorData()
                    self.navigationController?.popViewController(animated: true)
                }
            
            } else {
                print("❌ Checkout failed with status: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
    }

    func setImage(from encodedString: String, in imageView: UIImageView) {
        let cleanedString = encodedString.cleanedBase64String()
        
        if let imageData = Data(base64Encoded: cleanedString), let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                imageView.image = image
            }
            return
        }
        
        if let urlData = Data(base64Encoded: cleanedString),
           let urlString = String(data: urlData, encoding: .utf8),
           let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    print("❌ Failed to load image from decoded URL")
                    DispatchQueue.main.async {
                        imageView.image = UIImage(systemName: "person.crop.circle.fill")
                    }
                    return
                }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
            return
        }
        
        if let url = URL(string: cleanedString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    print("❌ Failed to load image from direct URL")
                    DispatchQueue.main.async {
                        imageView.image = UIImage(systemName: "person.crop.circle.fill")
                    }
                    return
                }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
            return
        }
        
        print("❌ Could not decode image string: \(encodedString)")
        DispatchQueue.main.async {
            imageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }

     @objc func addVisitorFromTeacher() {
         guard let token = TokenManager.shared.getToken() else {
             print("❌ Token not found")
             showAlert(message: "Authentication required")
             return
         }
         
         guard let groupId = self.groupId else {
             print("❌ GroupId not available")
             showAlert(message: "Group ID missing")
             return
         }
         
         if isFromAddFlow {
             guard visitorImage.image != nil else {
                 showAlert(message: "Please capture visitor image")
                 return
             }
             
             guard idCardImage.image != nil else {
                 showAlert(message: "Please capture ID card image")
                 return
             }
         }
         
         let visitorImageBase64 = visitorImage.image?.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? ""
         let idCardImageBase64 = idCardImage.image?.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? ""
         let body: [String: Any] = [
             "building": building.text ?? "",
             "buildingNumber": "",
             "gateId": selectedGateId ?? "",
             "gateName": selectGateButton.title(for: .normal) ?? "",
             "personToVisit": whoomToMe.text ?? "",
             "personToVisitImage": "",
             "personToVisitUserId": "",
             "purposeOfVisit": reason.text ?? "",
             "reason": reason.text ?? "",
             "roomNo": roomNo.text ?? "",
             "visitorAddress": address.text ?? "",
             "visitorIdCardImage": [idCardImageBase64],
             "visitorImage": visitorImageBase64,
             "visitorMobileNo": phone.text ?? "",
             "visitorName": name.text ?? "",
             "visitorVehicleNo": vehicleNo.text ?? ""
         ]
         
         if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8) {
             print("📦 Request Payload:")
             print(jsonString)
         }
         
         let urlString = APIManager.shared.baseURL + "groups/\(groupId)/visitor/details/add"
         print("🔗 API Endpoint: \(urlString)")
         
         guard let url = URL(string: urlString) else {
             print("❌ Invalid URL")
             showAlert(message: "Invalid API URL")
             return
         }
         
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         
         do {
             request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
         } catch {
             print("❌ JSON encode error: \(error)")
             showAlert(message: "Failed to prepare request")
             return
         }
         
         let loadingIndicator = UIActivityIndicatorView(style: .large)
         loadingIndicator.center = view.center
         loadingIndicator.startAnimating()
         view.addSubview(loadingIndicator)
         
         let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
             DispatchQueue.main.async {
                 loadingIndicator.stopAnimating()
                 loadingIndicator.removeFromSuperview()
             }
             
             if let error = error {
                 print("❌ Error: \(error.localizedDescription)")
                 DispatchQueue.main.async {
                     self?.showAlert(message: "Network error: \(error.localizedDescription)")
                 }
                 return
             }
             
             guard let httpResponse = response as? HTTPURLResponse else {
                 print("❌ Invalid HTTP response")
                 DispatchQueue.main.async {
                     self?.showAlert(message: "Invalid server response")
                 }
                 return
             }
             
             print("📩 Response Status Code: \(httpResponse.statusCode)")
             
             if let data = data, let responseString = String(data: data, encoding: .utf8) {
                 print("📄 Response Body:")
                 print(responseString)
             }
             
             if (200...299).contains(httpResponse.statusCode) {
                 print("✅ Visitor added successfully")
                 DispatchQueue.main.async {
                     self?.delegate!.didUpdateVisitorData()
                     self?.showAlert(message: "Visitor added successfully") {
                         self?.navigationController?.popViewController(animated: true)
                     }
                 }
             } else {
                 print("❌ Add Visitor Failed: Status \(httpResponse.statusCode)")
                 DispatchQueue.main.async {
                     self?.showAlert(message: "Failed to add visitor (Status: \(httpResponse.statusCode))")
                 }
             }
         }
         
         task.resume()
     }
     
     private func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
             completion?()
         })
         present(alert, animated: true)
     }
}
extension String {
    func cleanedBase64String() -> String {
        return self.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
