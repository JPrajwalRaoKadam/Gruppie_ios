//
//  ExamVC.swift
//  loginpage
//
//  Created by apple on 12/03/25.
//

import UIKit

class ExamVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var examListTableView: UITableView!
    
    var examDataResponse: [ExamData] = []
    var token: String = ""
    var groupId: String = ""
    var teamId: String?
    var offlineTestExamId: String?
    var studentMarkExamDataResponse: [StudentMarksData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        examListTableView.delegate = self
        examListTableView.dataSource = self
        
        examListTableView.register(UINib(nibName: "ClassNameMarksCardTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassNameMarksCardTableViewCell")
    
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Call without Manager
    func fetchExamData(offlineTestExamId: String) {
        guard let teamId = teamId else {
            print("❌ Missing teamId ")
            return
        }
        
        let urlString = "https://demo.gruppie.in/api/v1/groups/\(groupId)/team/\(teamId)/offline/testexam/\(offlineTestExamId)/student/markscard/get"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ExamMarkDataResponse.self, from: data)
                DispatchQueue.main.async {
                    if let resData = decodedResponse.data {
                        self?.studentMarkExamDataResponse = resData
                        self?.navigateToMarksCard()
                    }
                }
            } catch {
                print("❌ Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    // MARK: - Table View Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examDataResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassNameMarksCardTableViewCell", for: indexPath) as? ClassNameMarksCardTableViewCell else {
            return UITableViewCell()
        }
        
        let examName = examDataResponse[indexPath.row]
        self.offlineTestExamId = examName.offlineTestExamId
        cell.nameLabel?.text = examName.title
        cell.configureExam(with: examName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offlineTestExamId = examDataResponse[indexPath.row]
        fetchExamData(offlineTestExamId: offlineTestExamId.offlineTestExamId ?? "")
    }
    
    func navigateToMarksCard() {
        let storyboard = UIStoryboard(name: "MarksCard", bundle: nil)
        guard let studentMarksDetailVC = storyboard.instantiateViewController(withIdentifier: "StudentMarksDetailVC") as? StudentMarksDetailVC else {
            print("❌ Failed to instantiate SubjectViewController")
            return
        }
        
        studentMarksDetailVC.studentMarkExamDataResponse = self.studentMarkExamDataResponse
        self.navigationController?.pushViewController(studentMarksDetailVC, animated: true)
    }
}
