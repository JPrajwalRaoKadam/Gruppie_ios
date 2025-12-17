
import UIKit
import AVFoundation

class GateManagementVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var date: UIButton!
    @IBOutlet weak var gatetableview: UITableView!
    @IBOutlet weak var moreButton: UIButton!
    
    var groupId: String?
    var currentRole: String?
    var currentDate: String?
    var currentDatePicker: UIDatePicker?
    var visitorList: [VisitorResponseModel] = []
    var visitor: VisitorResponseModel?
    var capturedVisitorImage: UIImage?
    var capturedIDCardImage: UIImage?
    
    private var dimmedView: UIView!
    private var sideMenuView: UIView!
    private var dateTopConstraint: NSLayoutConstraint!

    var currentDateValue: Date = Date()
    var selectedDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        date.layer.cornerRadius = 10
        gatetableview.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        date.translatesAutoresizingMaskIntoConstraints = false
        dateTopConstraint = date.topAnchor.constraint(equalTo: segments.bottomAnchor, constant: 20)
        NSLayoutConstraint.activate([
            date.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateTopConstraint
        ])

        if currentRole == "admin" {
      
        }
        date.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
              date.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              date.topAnchor.constraint(equalTo: segments.bottomAnchor, constant: 20)
          ])
        gatetableview.delegate = self
        gatetableview.dataSource = self
        gatetableview.register(UINib(nibName: "GateManagementCell", bundle: nil), forCellReuseIdentifier: "GateManagementCell")
        print("currentRole in gatemng::::\(currentRole)")
        segment(segments)
        setCurrentDate()
        fetchVisitorDetails(for: currentDateValue)
    }
    private func getDateForCurrentSegment() -> Date {
        return segments.selectedSegmentIndex == 0 ? Date() : (selectedDate ?? currentDateValue)
    }
    
    func openCamera(for purpose: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.view.tag = (purpose == "visitor") ? 1 : 2
        present(imagePicker, animated: true, completion: nil)
    }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                if picker.view.tag == 1 {
                    self.capturedVisitorImage = image
                    dismiss(animated: true) {
                        self.openCamera(for: "idCard")
                    }
                } else {
                    self.capturedIDCardImage = image
                    dismiss(animated: true) {
                        self.moveToVisitorDetails()
                    }
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        }

        func moveToVisitorDetails() {
            guard let visitorImage = capturedVisitorImage,
                  let idCardImage = capturedIDCardImage else {
                print("Missing visitor or ID card image")
                return
            }

            if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "VisitorDetailsVC") as? VisitorDetailsVC {
                detailsVC.visitorUIImage = visitorImage
                detailsVC.idCardUIImage = idCardImage
                detailsVC.currentRole = currentRole
                navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
  
        func fetchVisitorDetails(for date: Date) {
            guard let groupId = groupId else {
                print("❌ groupId is nil")
                return
            }

            guard let token = TokenManager.shared.getToken() else {
                print("❌ Token not found")
                return
            }

            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)

            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/visitor/details/get?day=\(day)&month=\(month)&year=\(year)"
            print("🔗 Fetching visitor details from: \(urlString)")

            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL")
                return
            }

            var request = URLRequest(url: url, timeoutInterval: 15)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("❌ No data received")
                    return
                }

                if let rawString = String(data: data, encoding: .utf8) {
                    print("✅ Raw Response:\n\(rawString)")
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(VisitorListResponse.self, from: data)
                    self.visitorList = decodedResponse.data
                    print("✅ Total Visitors: \(self.visitorList.count)")

                    DispatchQueue.main.async {
                        self.gatetableview.reloadData()
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }

            }.resume()
        }

    func setCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let currentDateString = formatter.string(from: currentDateValue)
        date.setTitle(currentDateString, for: .normal)
        print("Current Date: \(currentDateString)")
    }


    @IBAction func datepicker(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton)
    }

    func showDatePickerPopup(for button: UIButton) {
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDatePickerPopup(_:)))
        backgroundView.addGestureRecognizer(tapGesture)

        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        currentDatePicker = datePicker

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(datePickerDonePressed(_:)), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(datePickerCancelPressed(_:)), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        containerView.addSubview(cancelButton)
        backgroundView.addSubview(containerView)

        if let window = self.view.window {
            window.addSubview(backgroundView)
        }

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 300),

            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),

            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 40),

            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDateString = formatter.string(from: datePicker.date)
            
            date.setTitle(selectedDateString, for: .normal)
            currentDate = selectedDateString
            selectedDate = datePicker.date
            
            print("Selected Date: \(selectedDateString)")

            if segments.selectedSegmentIndex == 1 {
                fetchVisitorDetails(for: datePicker.date)
            }

            if let backgroundView = sender.superview?.superview {
                backgroundView.removeFromSuperview()
            }
        }
    }

    @objc func datePickerCancelPressed(_ sender: UIButton) {
        if let backgroundView = sender.superview?.superview {
            backgroundView.removeFromSuperview()
        }
    }

    @objc func dismissDatePickerPopup(_ gesture: UITapGestureRecognizer) {
        if let backgroundView = gesture.view {
            backgroundView.removeFromSuperview()
        }
    }

    @IBAction func moreButton(_ sender: Any) {
        showSideMenu()
    }
    func showSideMenu() {
        dimmedView?.removeFromSuperview()
        sideMenuView?.removeFromSuperview()
        
        dimmedView = UIView(frame: self.view.bounds)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSideMenu))
        dimmedView.addGestureRecognizer(tapGesture)
        self.view.addSubview(dimmedView)

        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = 50
        let yPosition: CGFloat = 100

        sideMenuView = UIView(frame: CGRect(x: self.view.frame.width, y: yPosition, width: menuWidth, height: menuHeight))
        sideMenuView.backgroundColor = .white
        sideMenuView.layer.cornerRadius = 8

        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: menuWidth, height: menuHeight))
        
        if currentRole == "teacher" {
            menuButton.setTitle("Add Visitors", for: .normal)
            menuButton.addTarget(self, action: #selector(addVisitorTapped), for: .touchUpInside)
        } else if currentRole == "admin" {
            if segments.selectedSegmentIndex == 0 {
                menuButton.setTitle("Gate", for: .normal)
                menuButton.addTarget(self, action: #selector(gateButtonTapped), for: .touchUpInside)
            } else {
                menuButton.setTitle("Add Visitors", for: .normal)
                menuButton.addTarget(self, action: #selector(addVisitorTapped), for: .touchUpInside)
            }
        }

        menuButton.setTitleColor(.black, for: .normal)
        menuButton.backgroundColor = UIColor.systemGray6

        sideMenuView.addSubview(menuButton)
        self.view.addSubview(sideMenuView)

        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 1
            self.sideMenuView.frame.origin.x = self.view.frame.width - menuWidth - 16
        }
    }
    
    @objc func addVisitorTapped() {
        dismissSideMenu()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let visitorDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "VisitorDetailsVC") as? VisitorDetailsVC {
                visitorDetailsVC.currentRole = self.currentRole
                visitorDetailsVC.isFromAddFlow = true
                visitorDetailsVC.groupId = self.groupId
                visitorDetailsVC.delegate = self
                self.navigationController?.pushViewController(visitorDetailsVC, animated: true)
            }
        }
    }

    @objc func gateButtonTapped() {
        print("Gate option selected")
        dismissSideMenu()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let gateDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "GateDetailsVC") as? GateDetailsVC {
                gateDetailsVC.groupId = self.groupId
                self.navigationController?.pushViewController(gateDetailsVC, animated: true)
            }
        }
    }
    
    @objc func dismissSideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmedView.alpha = 0
            self.sideMenuView.frame.origin.x = self.view.frame.width
        }) { _ in
            self.sideMenuView.removeFromSuperview()
            self.dimmedView.removeFromSuperview()
        }
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            date.isHidden = true
            dateTopConstraint.constant = 0
        } else {
            date.isHidden = false
            dateTopConstraint.constant = 20
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        fetchVisitorDetails(for: getDateForCurrentSegment())
    }

}
extension GateManagementVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visitorList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GateManagementCell", for: indexPath) as! GateManagementCell

        let visitor = visitorList[indexPath.row]
        cell.visitorName.text = visitor.visitorName
        cell.personToVisit.text = visitor.personToVisit ?? "N/A"

        if let imageArr = visitor.visitorIdCardImage, let firstImage = imageArr.first {
            let cleanedImageString = firstImage.cleanedBase64String()
            
            if let imageData = Data(base64Encoded: cleanedImageString), let image = UIImage(data: imageData) {
                cell.iconImageView.image = image
            }
            else if let urlData = Data(base64Encoded: cleanedImageString),
                    let urlString = String(data: urlData, encoding: .utf8),
                    let url = URL(string: urlString) {
                cell.loadImage(from: url)
            }
            else if let url = URL(string: cleanedImageString) {
                cell.loadImage(from: url)
            }
            else {
                cell.iconImageView.image = cell.generateImage(from: visitor.visitorName)
            }
        } else {
            cell.iconImageView.image = cell.generateImage(from: visitor.visitorName)
        }

        cell.fallbackLabel.isHidden = true
        cell.iconImageView.isHidden = false
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVisitor = visitorList[indexPath.row] 
        
        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "VisitorDetailsVC") as? VisitorDetailsVC {
            detailsVC.visitor = selectedVisitor
            detailsVC.currentRole = self.currentRole
            detailsVC.isFromAddFlow = false
            detailsVC.groupId = self.groupId
            detailsVC.delegate = self
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
extension GateManagementVC: VisitorDetailsDelegate {
    func didUpdateVisitorData() {
        fetchVisitorDetails(for: getDateForCurrentSegment())
    }
}
//extension GateManagementVC: VisitorDetailsDelegate {
//    func didUpdateVisitorData() {
//        if segments.selectedSegmentIndex == 0 {
//            // Reload current date data
//            fetchVisitorDetails(for: Date())
//        } else {
//            // Reload selected date data
//            let dateToUse = selectedDate ?? currentDateValue
//            fetchVisitorDetails(for: dateToUse)
//        }
//    }
//}
