import UIKit
import SafariServices

class Exam_listVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var examListTableView: UITableView!
    @IBOutlet weak var bcbutton: UIButton!
    
    var groupId: String = ""
    var teamId: String = ""
    var currentRole: String?
    var className: String = ""
    var userId:String = ""
    var exams: [ExamData1] = [] // Store API response
    
    override func viewDidLoad() {
        super.viewDidLoad()
        examListTableView.register(UINib(nibName: "Exam_listVCTableViewCell", bundle: nil), forCellReuseIdentifier: "Exam_listVCTableViewCell")
        examListTableView.delegate = self
        examListTableView.dataSource = self
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        examListTableView.layer.cornerRadius = 10
        print("Extracted teamId in examll: \(teamId)")
        
        fetchExamList()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Call
    func fetchExamList() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }
        
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/get/gruppie/exam/new"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ExamResponse1.self, from: data)
                DispatchQueue.main.async {
                    self?.exams = decodedResponse.scheduleData
                    self?.examListTableView.reloadData()
                }
            } catch {
                print("❌ Decoding Error: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 70
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Exam_listVCTableViewCell", for: indexPath) as? Exam_listVCTableViewCell else {
            return UITableViewCell()
        }
        
        let exam = exams[indexPath.row]
        cell.classLabel.text = exam.testName ?? "N/A"  // Display testName
        
        return cell
    }
    
    func extractTextInsideBrackets(from text: String) -> String {
        if let startRange = text.range(of: "("),
           let endRange = text.range(of: ")", range: startRange.upperBound..<text.endIndex) {
            let insideText = text[startRange.upperBound..<endRange.lowerBound]
            return String(insideText).trimmingCharacters(in: .whitespaces)
        }
        return text
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let exam = exams[indexPath.row]
//        let testId = exam.testId
//        
//        // Extract only text inside brackets
//        let trimmedClassName = extractTextInsideBrackets(from: className)
//        
//        let urlString = "https://campus.gc2.co.in/StudentMTemplate/groupId/\(groupId)/teamId=\(teamId)/userId=\(userId)?testId=\(testId)&className=\(trimmedClassName)"
//        
//        print("web url: \(urlString)")
//        
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exam = exams[indexPath.row]
        let testId = exam.testId
        
        // Extract only the text inside brackets
        let trimmedClassName = extractTextInsideBrackets(from: className)
        
        // ✅ Encode className for URL safety
        let encodedClassName = trimmedClassName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmedClassName
        
        let urlString = "https://campus.gc2.co.in/StudentMTemplate/group/\(groupId)/team/\(teamId)/user/\(userId)?testId=\(testId)&className=\(encodedClassName)"
        
        print("web url: \(urlString)")
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }



}
//https://campus.gc2.co.in/StudentMTemplate/group/686cf36e7864a748c987e875/team/686cf36e7864a748c987e87a/user/689c32457864a74c8de2771d?testId=6694fd7984288b5933b8cbf0&className=Class%205-A
