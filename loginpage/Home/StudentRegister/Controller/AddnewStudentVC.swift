//
//  AddnewStudentVC.swift
//  loginpage
//
//  Created by apple on 24/04/26.
//
protocol PersonalInfocellDelegate: AnyObject {
    func basicInfoDidUpdate(_ data: BasicInfoData)
}

import UIKit

class AddnewStudentVC: UIViewController, PersonalInfocellDelegate {
    func basicInfoDidUpdate(_ data: BasicInfoData) {
        self.basicInfo = data
        updateAddButtonState() 
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var onStudentAdded: (() -> Void)?
    var classId: String = ""
    var newStudent: Student?
    var newStudentDetails: [StudentData] = []
    var basicInfo: BasicInfoData?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "personalInfocell", bundle: nil),
                           forCellReuseIdentifier: "personalInfocell")
        addButton.isEnabled = false
        addButton.alpha = 0.5
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        addButton.layer.cornerRadius = 10
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
    }
    func updateAddButtonState() {
        guard let data = basicInfo else {
            addButton.isEnabled = false
            addButton.alpha = 0.5
            return
        }
        
        let isValid = !data.firstName.isEmpty && !data.mobileNumber.isEmpty
        
        addButton.isEnabled = isValid
        addButton.alpha = isValid ? 1.0 : 0.5
    }
    
    func createPayload() -> [String: Any] {
        guard let data = basicInfo else { return [:] }
        
        var payload: [String: Any] = [
            "classId": classId
        ]
        
        if !data.firstName.isEmpty { payload["firstName"] = data.firstName }
        if !data.middleName.isEmpty { payload["middleName"] = data.middleName }
        if !data.lastName.isEmpty { payload["lastName"] = data.lastName }
        if !data.gender.isEmpty { payload["gender"] = data.gender }
        
        if !data.dateOfBirth.isEmpty {
            payload["dateOfBirth"] = convertDateFormat(data.dateOfBirth)
        }
        
        if !data.mobileNumber.isEmpty {
            payload["studentMobileNumber"] = data.mobileNumber
        }
        
        if !data.nationality.isEmpty { payload["nationality"] = data.nationality }
        if !data.aadharNumber.isEmpty { payload["aadhaarNumber"] = data.aadharNumber }
        if !data.bloodGroup.isEmpty { payload["bloodGroup"] = data.bloodGroup }
        
        // Static values (as per API)
        payload["physicalDisability"] = false
        payload["sportsParticipation"] = false
        payload["eligible"] = true
        payload["transportRequired"] = false
        payload["hostelRequired"] = false
        payload["scholarshipStatus"] = "Not Applied"
        
        return payload
    }
    func convertDateFormat(_ date: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "dd/MM/yyyy"
        
        let output = DateFormatter()
        output.dateFormat = "yyyy-MM-dd"
        
        if let d = input.date(from: date) {
            return output.string(from: d)
        }
        return date
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func registerStudent() {
        
        // ✅ Token check
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            return
        }
        
        // ✅ Payload check
        let payload = createPayload()
        if payload.isEmpty {
            print("❌ Payload is empty")
            return
        }
        
        print("📤 student-registration payload =", payload)
        
        let urlString = "https://dev.gruppie.in/api/v1/student/full-registration"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ JSON Error:", error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // ✅ Network error
            if let error = error {
                print("❌ API Error:", error)
                return
            }
            
            // ✅ Status code
            if let http = response as? HTTPURLResponse {
                print("✅ Status Code:", http.statusCode)
            }
            
            guard let data = data else { return }
            
            // ✅ Raw response (VERY IMPORTANT for debugging)
            if let raw = String(data: data, encoding: .utf8) {
                print("📥 student-registration response:", raw)
            }
            
            // ✅ Decode response
            do {
                let result = try JSONDecoder().decode(CommonSuccessResponse.self, from: data)
                
                if result.success {
                    DispatchQueue.main.async {
                        self.showToast(message: result.message)
                        
                        self.onStudentAdded?()   // ✅ notify previous VC
                        self.navigationController?.popViewController(animated: true) // ✅ go back
                    }
                } else {
                    print("❌ API Failed:", result.message)
                }
                
            } catch {
                print("❌ Decode Error:", error)
            }
            
        }.resume()
    }
    @IBAction func addButtonTapped(_ sender: UIButton) {

        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? personalInfocell else {
            return
        }

        let validation = cell.validateFields()

        if !validation.isValid {
            showToast(message: validation.errorMessage ?? "Invalid data")
            return
        }

        registerStudent()
    }
}

extension AddnewStudentVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "personalInfocell",
            for: indexPath
        ) as! personalInfocell

        cell.delegate = self
        return cell
    }
}
import UIKit

extension UIViewController {

    func showToast(message: String) {

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true

        let width = view.frame.width - 40
        label.frame = CGRect(
            x: 20,
            y: view.frame.height - 120,
            width: width,
            height: 40
        )

        view.addSubview(label)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            label.removeFromSuperview()
        }
    }
}
