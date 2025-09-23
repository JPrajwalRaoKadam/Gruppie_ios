//
//  GatePassViewController.swift
//  loginpage
//
//  Created by apple on 02/09/25.
//

    import UIKit
    import AVFoundation

    class GatePassVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GatePassReloadDelegate{
        @IBOutlet weak var bcbutton: UIButton!
        @IBOutlet weak var segments: UISegmentedControl!
        @IBOutlet weak var date: UIButton!
        @IBOutlet weak var gatetableview: UITableView!
        @IBOutlet weak var addButton: UIButton!
       
        var groupId: String?
        var currentRole: String?
        var currentDate: String?
        var currentDatePicker: UIDatePicker?
        var gatePassList: [GatePassData] = []
        var capturedVisitorImage: UIImage?
        var capturedIDCardImage: UIImage?
        
        private var dimmedView: UIView!
        private var sideMenuView: UIView!

        // MARK: - Date Handling
        var currentDateValue: Date = Date()
        var selectedDate: Date? // if user picks a date

        // MARK: - View Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            date.layer.cornerRadius = 10
            gatetableview.layer.cornerRadius = 10
            bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
            bcbutton.clipsToBounds = true
            if currentRole == "admin" {
          
            }
            gatetableview.delegate = self
            gatetableview.dataSource = self
            gatetableview.register(UINib(nibName: "GatePassCell", bundle: nil), forCellReuseIdentifier: "GatePassCell")
           // print("role:\(currentRole)")
            print("currentRole in gatemng::::\(currentRole)")
            segment(segments)
            setCurrentDate()
            fetchGatePassData()
            fetchGatePassList()
        }
        
        // MARK: - Delegate Method
           func reloadGatePassData() {
               print("🔄 Reloading GatePassVC data")
               fetchGatePassList()
           }
           
           func fetchGatePassList() {
               // 👉 Your existing API call code to refresh the table
               print("📡 Fetching gate pass list...")
               gatetableview.reloadData()
           }
        
        private func getDateForCurrentSegment() -> Date {
            return segments.selectedSegmentIndex == 0 ? Date() : (selectedDate ?? currentDateValue)
        }
        
        func openCamera(for purpose: String) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary  // ✅ Changed from .camera to .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.view.tag = (purpose == "visitor") ? 1 : 2 // Tag to identify purpose
            present(imagePicker, animated: true, completion: nil)
        }
            // Camera result
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    if picker.view.tag == 1 {
                        self.capturedVisitorImage = image
                        dismiss(animated: true) {
                            // Now open for ID card
                            self.openCamera(for: "idCard")
                        }
                    } else {
                        self.capturedIDCardImage = image
                        dismiss(animated: true) {
                            // Now navigate to VisitorDetailsVC
                            //self.moveToVisitorDetails()
                        }
                    }
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }

        
        func showAlert(message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
      
            // MARK: - API Call
        func fetchGatePassData(for date: Date? = nil) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            // If no date provided, use today
            let dateToUse = date != nil ? dateFormatter.string(from: date!) : dateFormatter.string(from: Date())
            
            guard let groupId = groupId else { return }
            
            let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gatepass/management?date=\(dateToUse)"
            
            guard let url = URL(string: urlString) else { return }
            guard let token = TokenManager.shared.getToken() else {
                print("❌ Token not found")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ API Error:", error)
                    return
                }
                
                guard let data = data else { return }
                do {
                    let decoded = try JSONDecoder().decode(GatePassResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.gatePassList = decoded.data
                        self.gatetableview.reloadData()
                    }
                } catch {
                    print("❌ Decoding error:", error)
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

        // MARK: - Segments
        @IBAction func segment(_ sender: UISegmentedControl) {
            if sender.selectedSegmentIndex == 0 {
                date.isHidden = true   // Hide date button
                fetchGatePassData(for: Date()) // ✅ always current date
            } else if sender.selectedSegmentIndex == 1 {
                date.isHidden = false  // Show date button
                let dateToUse = selectedDate ?? currentDateValue
                fetchGatePassData(for: dateToUse) // ✅ user-selected date
            }
        }

        
        // MARK: - Date Picker
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
                selectedDate = datePicker.date // Store the Date object
                
                print("Selected Date: \(selectedDateString)")

                if segments.selectedSegmentIndex == 1 {
                    fetchGatePassData(for: datePicker.date)
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

        // MARK: - Side Menu
        @IBAction func addButton(_ sender: Any) {
            let storyboard = UIStoryboard(name: "GatePass", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AddGatePassVC") as? AddGatePassVC {
                vc.groupId = self.groupId
                vc.delegate = self

                //vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print("❌ Could not instantiate AddGateVC")
            }
        }
    
        @IBAction func backButton(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    extension GatePassVC: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return gatePassList.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let cell = tableView.dequeueReusableCell(withIdentifier: "GatePassCell", for: indexPath) as! GatePassCell
             let item = gatePassList[indexPath.row]
             cell.studentName.text = item.name
             cell.status.text = item.status.capitalized
             return cell
         }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
        }
    }

