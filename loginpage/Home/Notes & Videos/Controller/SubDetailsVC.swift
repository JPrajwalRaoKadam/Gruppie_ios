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
    
    var subjectId: String = ""
    var subjectName: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var className: String = ""
    var topicsList: [TopicNV] = []
    var currentRole: String?
    var shouldRefreshData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        subTableView.delegate = self
        subTableView.dataSource = self
//        if let role = currentRole?.lowercased(), role == "parent" || role == "teacher" {
//            plusButton.isHidden = true
//        }
        if let role = currentRole?.lowercased(), role == "parent"{
            plusButton.isHidden = true
        }
        classsubjName.text = "\(subjectName)- (\(className))"
        print("adsbgid: \(groupId) adsbtid: \(teamId) subid: \(subjectId)")
        subTableView.register(UINib(nibName: "SubDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubDetailsTableViewCell")
        fetchSubjectDetails()
        enableKeyboardDismissOnTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldRefreshData {
            fetchSubjectDetails()
            shouldRefreshData = false
        }
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
            AddChapterVC.groupId = groupId
            AddChapterVC.teamId = teamId
            AddChapterVC.subjectId = subjectId
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

        // Format date
        let inputFormatter = ISO8601DateFormatter()
        if let date = inputFormatter.date(from: topic.insertedAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            cell.createdOn.text = formatter.string(from: date)
        } else {
            cell.createdOn.text = "-"
        }

        // Clear previous content
        cell.datacontainer.subviews.forEach { $0.removeFromSuperview() }

        // Load file preview
        if let encodedFile = topic.fileName.first,
           let decodedURLString = decodeBase64String(encodedFile),
           let fileURL = URL(string: decodedURLString) {

            print("✅ Decoded URL: \(decodedURLString)")

            let type = topic.fileType.lowercased()

            if let encoded = topic.fileName.first,
               let decoded = decodeBase64String(encoded),
               let url = URL(string: decoded) {

                switch type {
                case "image":
                    let imageView = UIImageView(frame: cell.datacontainer.bounds)
                    imageView.contentMode = .scaleAspectFit
                    imageView.clipsToBounds = true
                    imageView.load(url: encoded)
                    cell.datacontainer.addSubview(imageView)

                case "video":
                    let label = UILabel(frame: cell.datacontainer.bounds)
                    label.text = "🎥 Video: \(url.lastPathComponent)"
                    label.textAlignment = .center
                    label.numberOfLines = 2
                    label.textColor = .systemRed
                    cell.datacontainer.addSubview(label)

                case "audio":
                    let label = UILabel(frame: cell.datacontainer.bounds)
                    label.text = "🎵 Audio: \(url.lastPathComponent)"
                    label.textAlignment = .center
                    label.numberOfLines = 2
                    label.textColor = .systemGreen
                    cell.datacontainer.addSubview(label)

                case "youtube":
                    let label = UILabel(frame: cell.datacontainer.bounds)
                    label.text = "▶️ YouTube: \(url.absoluteString)"
                    label.textAlignment = .center
                    label.numberOfLines = 2
                    label.textColor = .systemOrange
                    cell.datacontainer.addSubview(label)

                case "pdf":
                    let imageView = UIImageView(image: UIImage(named: "defaultpdf"))
                    imageView.frame = cell.datacontainer.bounds
                    imageView.contentMode = .scaleAspectFit
                    cell.datacontainer.addSubview(imageView)

                default:
                    let imageView = UIImageView(image: UIImage(named: "defaultpdf"))
                    imageView.frame = cell.datacontainer.bounds
                    imageView.contentMode = .scaleAspectFit
                    cell.datacontainer.addSubview(imageView)
                }

            } else {
                // Fallback if decoding fails or URL is invalid
                let label = UILabel(frame: cell.datacontainer.bounds)
                label.text = "❌ Invalid or missing file"
                label.textAlignment = .center
                label.textColor = .systemGray
                cell.datacontainer.addSubview(label)
            }


        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 605
    }
    
    func decodeBase64String(_ base64String: String) -> String? {
        guard let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
    
}

extension UIImageView {
    func load(url base64String: String) {
        guard let decodedURLString = decodeBase64String(base64String),
              let url = URL(string: decodedURLString) else {
            DispatchQueue.main.async {
                self.image = nil
            }
            return
        }

        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                print("❌ Failed to load image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.image = nil
                }
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.image = nil
                }
            }
        }.resume()
    }

    private func decodeBase64String(_ base64String: String) -> String? {
        let cleaned = base64String.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let decodedData = Data(base64Encoded: cleaned),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
}
