////
////  AddGatePassDetailsVC.swift
////  loginpage
////
////  Created by apple on 04/09/25.
protocol GatePassReloadDelegate: AnyObject {
    func reloadGatePassData()
}
import UIKit

class AddGatePassDetailsVC: UIViewController {
    
    weak var delegate: GatePassReloadDelegate?   // ✅ Delegate reference
    @IBOutlet weak var StudentName: UILabel!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var Description: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var startDate: UIButton!
    @IBOutlet weak var startTime: UIButton!
     
    var groupId: String?
    var currentRole: String?
    var selectedStudent: SearchStudentList?


    override func viewDidLoad() {
        super.viewDidLoad()
        StudentName.layer.cornerRadius = 10
        className.layer.cornerRadius = 10
        Description.layer.cornerRadius = 10
        addButton.layer.cornerRadius = 10
        startDate.layer.cornerRadius = 10
        startTime.layer.cornerRadius = 10
        print("selected student details:\(selectedStudent)")
        StudentName.text = selectedStudent?.name
        className.text = selectedStudent?.className
    }
    
    // MARK: - Date Picker
    @IBAction func addStartDate(_ sender: Any) {
        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 0, y: 0, width: alert.view.bounds.width - 20, height: 200)
        
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            self.startDate.setTitle(selectedDate, for: .normal)
        }))
        
        // Add height for UIDatePicker
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        present(alert, animated: true)
    }

    // MARK: - Time Picker
    @IBAction func addStartTime(_ sender: Any) {
        let alert = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.frame = CGRect(x: 0, y: 0, width: alert.view.bounds.width - 20, height: 200)
        
        alert.view.addSubview(timePicker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let selectedTime = formatter.string(from: timePicker.date)
            self.startTime.setTitle(selectedTime, for: .normal)
        }))
        
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        present(alert, animated: true)
    }
    
    // MARK: - Add Button
    @IBAction func addButton(_ sender: Any) {
        guard let student = selectedStudent else {
            print("❌ No student selected")
            return
        }
        
        guard let groupId = groupId else {
            print("❌ No groupId found")
            return
        }
        
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gatepass/management"
        guard let url = URL(string: urlString) else { return }
        
        // Collect user inputs
        let descriptionText = Description.text ?? ""
        let dateText = startDate.titleLabel?.text ?? ""
        let timeText = startTime.titleLabel?.text ?? ""
        
        // Body parameters
        let body: [String: Any] = [
            "className": student.className,
            "countryCode": "IN",  // hardcoded
            "date": dateText,
            "description": descriptionText,
            "name": student.name,
            "phone": student.phone ?? "",
            "teamId": student.teamId,
            "time": timeText,
            "userId": student.userId
        ]
        
        print("📤 Request Body: \(body)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Error serializing body: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("📥 Response: \(json)")
                    DispatchQueue.main.async {
                               // Notify delegate before dismissing
                               self.delegate?.reloadGatePassData()
                               self.dismiss(animated: true)
                           }

                } catch {
                    print("❌ JSON Parse Error: \(error)")
                }
            }
        }
        
        task.resume()
    }

}
