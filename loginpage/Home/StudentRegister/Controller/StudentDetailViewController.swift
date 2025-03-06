//import UIKit
//
//class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var TableView: UITableView!
//    @IBOutlet weak var SegmentController: UISegmentedControl!
//    @IBOutlet weak var editButton: UIButton!
//    
//    var student: StudentData?
//    var token: String = ""
//    var groupId: String = ""
//    var teamId: String = ""
//    var userId: String = ""
//    var isEditingEnabled = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        print("StudentDetailViewController Loaded")
//        print("User ID: \(userId), Group ID: \(groupId), Team ID: \(teamId), Token: \(token)")
//        print("Initial Segment Index: \(SegmentController.selectedSegmentIndex)")
//        
//        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
//        TableView.register(UINib(nibName: "OtherInfoCell", bundle: nil), forCellReuseIdentifier: "OtherInfoCell")
//        TableView.register(UINib(nibName: "FamilyInfoCell", bundle: nil), forCellReuseIdentifier: "FamilyInfoCell")
//        
//        TableView.delegate = self
//        TableView.dataSource = self
//        TableView.reloadData()
//    }
//    
//    @IBAction func BackButton(_ sender: UIButton) {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @IBAction func segmentChangeAction(_ sender: Any) {
//        print("Segment Changed to Index: \((sender as AnyObject).selectedSegmentIndex)")
//        TableView.reloadData()
//    }
//    
//    @IBAction func EditButton(_ sender: UIButton) {
//        isEditingEnabled.toggle()
//        sender.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)
//        TableView.reloadData()
//        
//        if !isEditingEnabled {
//            updateStudentProfile()
//        }
//    }
//    
//    func updateStudentProfile() {
//        guard let student = student else {
//            print("Error: No student data available")
//            return
//        }
//        
//        var mergedUpdatedData: [String: Any] = [:]
//
//        // Collect Basic Info
//        if let basicCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BasicInfoCell {
//            let basicInfo = basicCell.collectUpdatedData()
//            let basicData: [String: Any] = [
//                "name": basicInfo.name,
//                "countryCode": basicInfo.country,
//                "phone": basicInfo.phone,
//                "satsNumber": basicInfo.satsNumber,
//                "admissionNumber": basicInfo.admissionNumber,
//                "rollNumber": basicInfo.rollNo,
//                "dob": basicInfo.dob,
//                "doj": basicInfo.doj
//            ]
//            mergedUpdatedData.merge(basicData) { _, new in new }
//        }
//
//        // Collect Other Info
//        if let otherCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherInfoCell {
//            let otherInfo = otherCell.collectUpdatedData()
//            let otherData: [String: Any] = [
//                "nationality": otherInfo.nationality,
//                "bloodGroup": otherInfo.bloodGroup,
//                "religion": otherInfo.religion,
//                "caste": otherInfo.caste,
//                "subCaste": otherInfo.subCaste,
//                "category": otherInfo.category,
//                "address": otherInfo.address,
//                "aadharNumber": otherInfo.aadharNo
//            ]
//            mergedUpdatedData.merge(otherData) { _, new in new }
//        }
//
//        // Collect Family Info
//        if let familyCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FamilyInfoCell {
//            let familyInfo = familyCell.collectUpdatedData()
//            let familyData: [String: Any] = [
//                "fatherName": familyInfo.fatherName,
//                "fatherPhone": familyInfo.fatherPhone,
//                "fatherEducation": familyInfo.fatherEducation,
//                "fatherOccupation": familyInfo.fatherOccupation,
//                "fatherAadhar": familyInfo.fatherAadhar,
//                "motherName": familyInfo.motherName,
//                "motherPhone": familyInfo.motherPhone,
//                "motherOccupation": familyInfo.motherOccupation
//            ]
//            mergedUpdatedData.merge(familyData) { _, new in new }
//        }
//
//        if mergedUpdatedData.isEmpty {
//            print("No changes detected, skipping API request.")
//            return
//        }
//
//        print("Merged Updated Data: \(mergedUpdatedData)")
//
//        // Construct API Request
//        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/edit/profile?user_id=\(userId)"
//
//        guard let url = URL(string: apiUrl) else {
//            print("Invalid API URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let requestBody: [String: Any] = ["studentData": [mergedUpdatedData]]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//        } catch {
//            print("Error encoding request body: \(error.localizedDescription)")
//            return
//        }
//        
//        // Send API Request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error in API Call: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("Invalid response")
//                return
//            }
//            
//            if httpResponse.statusCode == 200 {
//                print("Student data updated successfully!")
//            } else {
//                print("Failed to update student data. Status Code: \(httpResponse.statusCode)")
//            }
//            
//            if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                print("Response: \(responseString)")
//            }
//        }
//        
//        task.resume()
//    }
//
//    // ✅ TableView DataSource Methods
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("Current Segment Index in cellForRowAt: \(SegmentController.selectedSegmentIndex)")
//        
//        guard let student = student else {
//            print("Error: Student data is nil")
//            return UITableViewCell()
//        }
//        
//        switch SegmentController.selectedSegmentIndex {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as! BasicInfoCell
//            let basicInfo = BasicInfoModel(
//                name: student.name ?? "",
//                country: student.countryCode ?? "",
//                phone: student.phone ?? "",
//                satsNumber: student.satsNumber ?? "",
//                admissionNumber: student.admissionNumber ?? "",
//                rollNo: student.rollNumber ?? "",
//                dob: student.dob ?? "",
//                doj: student.doj ?? ""
//            )
//            cell.populate(with: basicInfo, isEditingEnabled: isEditingEnabled)
//            return cell
//            
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherInfoCell", for: indexPath) as! OtherInfoCell
//            let otherInfo = OtherInfoModel(
//                nationality: student.nationality ?? "",
//                bloodGroup: student.bloodGroup ?? "",
//                religion: student.religion ?? "",
//                caste: student.caste ?? "",
//                subCaste: student.subCaste ?? "",
//                category: student.category ?? "",
//                address: student.address ?? "",
//                aadharNo: student.aadharNumber ?? ""
//            )
//            cell.populate(with: otherInfo, isEditingEnabled: isEditingEnabled)
//            return cell
//            
//        case 2:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyInfoCell", for: indexPath) as! FamilyInfoCell
//            let familyInfo = FamilyInfoModel(
//                fatherName: student.fatherName ?? "",
//                fatherPhone: student.fatherPhone ?? "",
//                fatherEducation: student.fatherEducation ?? "",
//                fatherOccupation: student.fatherOccupation ?? "",
//                fatherAadhar: student.fatherAadharNumber ?? "",
//                motherName: student.motherName ?? "",
//                motherPhone: student.motherPhone ?? "",
//                motherOccupation: student.motherOccupation ?? ""
//            )
//            cell.populate(with: familyInfo, isEditingEnabled: isEditingEnabled)
//            return cell
//            
//        default:
//            return UITableViewCell()
//        }
//    }
//}


import UIKit

class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var editButton: UIButton!

    var student: StudentData?
    var token: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var userId: String = ""
    var isEditingEnabled = false

    // Store collected data from different segments
    var basicInfoData: [String: Any] = [:]
    var otherInfoData: [String: Any] = [:]
    var familyInfoData: [String: Any] = [:]

    // Track visited segments
    var visitedSegments: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        print("StudentDetailViewController Loaded")
        print("User ID: \(userId), Group ID: \(groupId), Team ID: \(teamId), Token: \(token)")
        print("Initial Segment Index: \(SegmentController.selectedSegmentIndex)")

        TableView.register(UINib(nibName: "BasicInfoCell", bundle: nil), forCellReuseIdentifier: "BasicInfoCell")
        TableView.register(UINib(nibName: "OtherInfoCell", bundle: nil), forCellReuseIdentifier: "OtherInfoCell")
        TableView.register(UINib(nibName: "FamilyInfoCell", bundle: nil), forCellReuseIdentifier: "FamilyInfoCell")

        TableView.delegate = self
        TableView.dataSource = self
        TableView.reloadData()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func segmentChangeAction(_ sender: UISegmentedControl) {
        print("Segment Changed to Index: \(sender.selectedSegmentIndex)")
        visitedSegments.insert(sender.selectedSegmentIndex) // Mark segment as visited
        TableView.reloadData()
    }

    @IBAction func EditButton(_ sender: UIButton) {
        isEditingEnabled.toggle()
        sender.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)
        TableView.reloadData()

        if !isEditingEnabled {
            collectDataFromAllSegments()
        }
    }

    /// Collect data from all segments before updating the API
    func collectDataFromAllSegments() {
        guard let student = student else {
            print("Error: No student data available")
            return
        }

        // Ensure all segments are visited before saving
        if visitedSegments.count < 3 {
            showAlert(title: "Incomplete Data", message: "Please visit all segments before saving the data.")
            return
        }

        // Collect Basic Info
        if let basicCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BasicInfoCell {
            let basicInfo = basicCell.collectUpdatedData()
            basicInfoData = [
                "name": basicInfo.name,
                "countryCode": basicInfo.countryCode,
                "phone": basicInfo.phone,
                "satsNumber": basicInfo.satsNumber,
                "admissionNumber": basicInfo.admissionNumber,
                "rollNumber": basicInfo.rollNumber,
                "dob": basicInfo.dob,
                "doj": basicInfo.doj
            ]
        }

        // Collect Other Info
        if let otherCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherInfoCell {
            let otherInfo = otherCell.collectUpdatedData()
            otherInfoData = [
                "nationality": otherInfo.nationality,
                "bloodGroup": otherInfo.bloodGroup,
                "religion": otherInfo.religion,
                "caste": otherInfo.caste,
                "subCaste": otherInfo.subCaste,
                "category": otherInfo.category,
                "address": otherInfo.address,
                "aadharNumber": otherInfo.aadharNumber
            ]
        }

        // Collect Family Info
        if let familyCell = TableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FamilyInfoCell {
            let familyInfo = familyCell.collectUpdatedData()
            familyInfoData = [
                "fatherName": familyInfo.fatherName,
                "fatherPhone": familyInfo.fatherPhone,
                "fatherEducation": familyInfo.fatherEducation,
                "fatherOccupation": familyInfo.fatherOccupation,
                "fatherAadhar": familyInfo.fatherAadhar,
                "motherName": familyInfo.motherName,
                "motherPhone": familyInfo.motherPhone,
                "motherOccupation": familyInfo.motherOccupation
            ]
        }

        // Proceed with updating the profile
        updateStudentProfile()
    }

    func updateStudentProfile() {
        var mergedUpdatedData = basicInfoData.merging(otherInfoData) { (_, new) in new }
        mergedUpdatedData.merge(familyInfoData) { (_, new) in new }

        if mergedUpdatedData.isEmpty {
            print("No changes detected, skipping API request.")
            return
        }

        print("Merged Updated Data: \(mergedUpdatedData)")

        // Construct API Request
        let apiUrl = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/student/edit/profile?user_id=\(userId)"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = ["studentData": [mergedUpdatedData]]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }
        
        // Send API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in API Call: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Student data updated successfully!")
            } else {
                print("Failed to update student data. Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        
        task.resume()
    }

    // Helper function to show alerts
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // ✅ TableView DataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Current Segment Index in cellForRowAt: \(SegmentController.selectedSegmentIndex)")

        guard let student = student else {
            print("Error: Student data is nil")
            return UITableViewCell()
        }

        switch SegmentController.selectedSegmentIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as! BasicInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherInfoCell", for: indexPath) as! OtherInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyInfoCell", for: indexPath) as! FamilyInfoCell
            cell.populate(with: student, isEditingEnabled: isEditingEnabled)
            return cell

        default:
            return UITableViewCell()
        }
    }
}
