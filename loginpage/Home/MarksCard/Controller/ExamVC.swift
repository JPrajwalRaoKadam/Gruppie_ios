////
////  ExamVC.swift
////  loginpage
////
////  Created by apple on 12/03/25.
////
//
//import UIKit
//
//class ExamVC: UIViewController, UITableViewDelegate, UITableViewDataSource, StudentMarksDetailDelegate {
//    
//    @IBOutlet weak var examListTableView: UITableView!
//    @IBOutlet weak var bcbutton: UIButton!
//    
//    var examDataResponse: [ExamData] = []
//    var token: String = ""
//    var groupId: String = ""
//    var teamId: String?
//    var offlineTestExamId: String?
//    var studentMarkExamDataResponse: [StudentMarksData] = []
//    var selectedExamTitle = ""
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
//        bcbutton.clipsToBounds = true
//        examListTableView.layer.cornerRadius = 10
//        examListTableView.delegate = self
//        examListTableView.dataSource = self
//        enableKeyboardDismissOnTap()
//        examListTableView.register(UINib(nibName: "ClassNameMarksCardTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassNameMarksCardTableViewCell")
//    
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let teamId = teamId, let offlineTestExamId = offlineTestExamId, studentMarkExamDataResponse.isEmpty {
//            fetchExamData(offlineTestExamId: offlineTestExamId)
//        }
//    }
//    
//    @IBAction func backButtonAction(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    // MARK: - Table View Setup
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return examDataResponse.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassNameMarksCardTableViewCell", for: indexPath) as? ClassNameMarksCardTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        let examName = examDataResponse[indexPath.row]
//        self.offlineTestExamId = examName.offlineTestExamId
//        cell.nameLabel?.text = examName.title
//        cell.configureExam(with: examName)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let offlineTestExamId = examDataResponse[indexPath.row]
//        self.selectedExamTitle = offlineTestExamId.title ?? ""
//        fetchExamData(offlineTestExamId: offlineTestExamId.offlineTestExamId ?? "")
//    }
//    
//    // MARK: - API Call without Manager
//    func fetchExamData(offlineTestExamId: String) {
//        let loadingIndicator = UIActivityIndicatorView(style: .large)
//        loadingIndicator.center = view.center
//        view.addSubview(loadingIndicator)
//        loadingIndicator.startAnimating()
//        
//        guard let teamId = teamId else { return }
//        
//        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/offline/testexam/\(offlineTestExamId)/student/markscard/get"
//        guard let url = URL(string: urlString) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                loadingIndicator.stopAnimating()
//                loadingIndicator.removeFromSuperview()
//            }
//
//            if let error = error {
//                print("❌ Error fetching data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data else {
//                print("❌ No data received")
//                return
//            }
//
//            do {
//                let decodedResponse = try JSONDecoder().decode(ExamMarkDataResponse.self, from: data)
//                DispatchQueue.main.async {
//                    if let resData = decodedResponse.data {
//                        self?.studentMarkExamDataResponse = resData
//                        self?.navigateToMarksCard()
//                    }
//                }
//            } catch {
//                print("❌ Failed to decode JSON: \(error)")
//            }
//        }.resume()
//    }
//    
//    func didUpdateMarks() {
//            fetchExamData(offlineTestExamId: offlineTestExamId ?? "")
//        }
//
//    func navigateToMarksCard() {
//        let storyboard = UIStoryboard(name: "MarksCard", bundle: nil)
//        guard let studentMarksDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentMarksDetailVC") as? StudentMarksDetailVC else {
//            print("❌ Failed to instantiate StudentMarksDetailVC")
//            return
//        }
////        studentMarksDetailVC.examDataResponse = self.examDataResponse
////        studentMarksDetailVC.studentMarkExamDataResponse = self.studentMarkExamDataResponse
////        studentMarksDetailVC.passedExamTitle = selectedExamTitle
////        studentMarksDetailVC.groupId = self.groupId
////        studentMarksDetailVC.teamId = self.teamId
////        studentMarksDetailVC.offlineTestExamId = self.offlineTestExamId
////        
////        // Set the closure
////        studentMarksDetailVC.onMarksUpdated = { [weak self] in
//           // self?.fetchExamData(offlineTestExamId: self?.offlineTestExamId ?? "")
//        }
//        
//       // self.navigationController?.pushViewController(studentMarksDetailVC, animated: true)
//   // }
//}
//
