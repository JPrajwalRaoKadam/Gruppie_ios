//
//  DaysViewController.swift
//  loginpage
//
//  Created by apple on 23/04/25.
//

import Foundation
import UIKit

class DaysViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   

    @IBOutlet weak var curDate: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var currentDatePicker: UIDatePicker?
    var currentDate : String?
    var currentRole: String?
    var groupId: String = ""
        
    var timetableData: TimeTableResponse?

    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        
         print("grpid atten:\(currentDate) ")
        enableKeyboardDismissOnTap()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "daysTableViewCell", bundle: nil), forCellReuseIdentifier: "daysTableViewCell")
        setCurrentDate()
        fetchData()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData() // Optionally refresh data when view appears
    }
    
    func fetchData() {
        guard let token = TokenManager.shared.getToken(),
              let date = currentDate else {
            print("Missing token or date")
            return
        }

        fetchTimeTable(for: date, token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.timetableData = response
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching timetable: \(error)")
                }
            }
        }
    }
    
    @IBAction func leftdateChange(_ sender: Any) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
            
            if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                currentDate = dateFormatter.string(from: previousDay)
                curDate.setTitle(currentDate, for: .normal)
                
                print("Selected Date: \(currentDate ?? "")")
                fetchData() // 🔁 Call API for the new date
            }
        
    }
    
    @IBAction func rightdateChange(_ sender: Any) {
        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd-MM-yyyy"
         
         guard let selectedDate = dateFormatter.date(from: currentDate ?? "") else { return }
         let todayDate = Date()
         
         if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
            nextDay <= todayDate {
             currentDate = dateFormatter.string(from: nextDay)
             curDate.setTitle(currentDate, for: .normal)
             
             print("Selected Date: \(currentDate ?? "")")
             fetchData() // 🔁 Call API for the new date
         } else {
             print("Cannot go beyond today's date")
         }
    }
    
    @IBAction func dateChange(_ sender: Any) {
        showDatePickerPopup(for: sender as! UIButton) // Call the date picker function
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return timetableData?.data.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetableData?.data[section].academicTimeTable.first?.classTimeTable.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "daysTableViewCell", for: indexPath) as? daysTableViewCell else {
            return UITableViewCell()
        }

        let item = timetableData?.data[safe: indexPath.section]?
            .academicTimeTable.first?
            .classTimeTable[safe: indexPath.row]

        cell.periodNo.text = "\(item?.period ?? "")"
        cell.startTime.text = item?.startTime ?? "-"
        cell.endTime.text = item?.endTime ?? "-"
        cell.subjectName.text = item?.subjectName ?? "N/A"
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGray6

        // Main class label
        let classLabel = UILabel()
        classLabel.font = UIFont.boldSystemFont(ofSize: 18)
        classLabel.textColor = .black
        classLabel.translatesAutoresizingMaskIntoConstraints = false
        classLabel.text = timetableData?.data[safe: section]?.academicTimeTable.first?.name ?? "Class: Unknown"
        headerView.addSubview(classLabel)

        // Stack view for Period and Time (first half)
        let firstStackView = UIStackView()
        firstStackView.axis = .horizontal
        firstStackView.distribution = .fillEqually
        firstStackView.spacing = 10
        firstStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let periodLabel = UILabel()
        periodLabel.text = "Period"
        periodLabel.textAlignment = .center
        periodLabel.font = UIFont.systemFont(ofSize: 14)
        firstStackView.addArrangedSubview(periodLabel)

        let timeLabel = UILabel()
        timeLabel.text = "Time"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        firstStackView.addArrangedSubview(timeLabel)

        // Stack view for Subject (second half)
        let secondStackView = UIStackView()
        secondStackView.axis = .horizontal
        secondStackView.distribution = .fillEqually
        secondStackView.spacing = 0
        secondStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let subjectLabel = UILabel()
        subjectLabel.text = "Subject"
        subjectLabel.textAlignment = .center
        subjectLabel.font = UIFont.systemFont(ofSize: 14)
        secondStackView.addArrangedSubview(subjectLabel)

        headerView.addSubview(firstStackView)
        headerView.addSubview(secondStackView)

        NSLayoutConstraint.activate([
            classLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            classLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            classLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),

            firstStackView.topAnchor.constraint(equalTo: classLabel.bottomAnchor, constant: 8),
            firstStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            firstStackView.trailingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: -8),
            firstStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            firstStackView.heightAnchor.constraint(equalToConstant: 20),

            secondStackView.topAnchor.constraint(equalTo: classLabel.bottomAnchor, constant: 8),
            secondStackView.leadingAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 8),
            secondStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            secondStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            secondStackView.heightAnchor.constraint(equalToConstant: 20)
        ])

        return headerView
    }



    
    func setCurrentDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Format: 11-02-2025
        let currentDate = dateFormatter.string(from: Date())
        self.currentDate = currentDate
        curDate.setTitle(self.currentDate, for: .normal) // Set button title
        print("Current Date: \(currentDate)") // Print current date in console
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
        
        if let window = UIApplication.shared.windows.first {
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
        
        // Store the selected button to update its title later
        curDate = button
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70 // You can increase to 80 or 90 if needed
    }

    
    @objc func datePickerDonePressed(_ sender: UIButton) {
        if let datePicker = currentDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            
            curDate.setTitle(selectedDate, for: .normal)
            currentDate = selectedDate
            
            print("Selected Date: \(selectedDate)")
            fetchData() // 🔁 Trigger API for selected date
            
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

    func fetchTimeTable(for date: String, token: String, completion: @escaping (Result<TimeTableResponse, Error>) -> Void) {
        // Construct the URL
        var url: URL?

        if currentRole == "parent" {
            url = URL(string: "\(APIManager.shared.baseURL)groups/\(self.groupId)/time/table/get?date=\(date)")
        } else if currentRole == "teacher" {
            url = URL(string: "\(APIManager.shared.baseURL)groups/\(self.groupId)/staff/timetable/get?date=\(date)")
        }

        guard let finalURL = url else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                completion(.failure(noDataError))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TimeTableResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }


    
}

