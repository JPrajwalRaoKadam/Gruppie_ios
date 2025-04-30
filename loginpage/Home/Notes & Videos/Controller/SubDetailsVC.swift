//
//  SubDetailsVC.swift
//  loginpage
//
//  Created by apple on 17/04/25.
//

import UIKit

class SubDetailsVC: UIViewController {

    @IBOutlet weak var classsubjName: UILabel!
    @IBOutlet weak var subTableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var subjectId : String = ""
      var subjectName: String = ""
      var groupId : String = ""
      var teamId: String = ""
      var className : String = ""
      var topicsList: [TopicNV] = []
      var currentRole: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        subTableView.delegate = self
        subTableView.dataSource = self
        if let role = currentRole?.lowercased(), role == "parent" || role == "teacher" {
            plusButton.isHidden = true
        }
        classsubjName.text = "\(className)- (\(subjectName))"
        print("adsbgid: \(groupId) adsbtid: \(teamId) subid: \(subjectId)" )
        subTableView.register(UINib(nibName: "SubDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubDetailsTableViewCell")
        fetchSubjectDetails()
    }
    func fetchSubjectDetails() {
        guard let token = TokenManager.shared.getToken() else {
            print("❌ Token not found")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/posts/get"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error)
                return
            }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(SubDetailsResponse.self, from: data)
                self.topicsList = result.data.flatMap { $0.topics }

                DispatchQueue.main.async {
                    self.subTableView.reloadData()
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }

   
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButton(_ sender: Any) {
        print("add button tapped")
        navigateToAddChapter()
    }
    
    func navigateToAddChapter() {
        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)
        if let AddChapterVC = storyboard.instantiateViewController(withIdentifier: "AddChapterVC") as? AddChapterVC {
            AddChapterVC.groupId = groupId  // Pass groupId
            AddChapterVC.teamId  = teamId   // Pass teamId
            self.navigationController?.pushViewController(AddChapterVC, animated: true)
        }
    }
    
    
}
extension SubDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubDetailsTableViewCell", for: indexPath) as? SubDetailsTableViewCell else {
            return UITableViewCell()
        }

        let topic = topicsList[indexPath.row]
        cell.topicName.text = topic.topicName
        cell.createdBy.text = topic.createdByName

        // Date formatting
        let inputFormatter = ISO8601DateFormatter()
        if let date = inputFormatter.date(from: topic.insertedAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            cell.createdOn.text = formatter.string(from: date)
        } else {
            cell.createdOn.text = "-"
        }

        // Decode base64 fileName and log details
        if let encodedFile = topic.fileName.first,
           let decodedURLString = decodeFileURL(from: encodedFile),
           let fileURL = URL(string: decodedURLString) {

            print("✅ Decoded URL: \(decodedURLString)")

            switch topic.fileType.lowercased() {
            case "image":
                print("🖼️ File is an image")
            case "pdf":
                print("📄 File is a PDF")
            case "video":
                print("🎥 File is a video")
            default:
                print("📁 Unknown file type")
            }
        }

        return cell
    }

    func decodeFileURL(from base64String: String) -> String? {
        let cleanedString = base64String
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let decodedData = Data(base64Encoded: cleanedString),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            print("❌ Failed to decode base64 string")
            return nil
        }
        return decodedString
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 605
    }
}
