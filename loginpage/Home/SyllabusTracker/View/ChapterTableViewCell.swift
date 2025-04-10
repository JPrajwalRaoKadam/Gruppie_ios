//////
//////  ChapterTableViewCell.swift
//////  loginpage
//////
//////  Created by apple on 13/03/25.

import UIKit

protocol ChapterTableViewCellDelegate: AnyObject {
    func didDeleteChapter(chapterId: String)
}

class ChapterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var chapter: UILabel!
    
    weak var delegate: ChapterTableViewCellDelegate?
    
    var chapterId: String = ""
    var groupId: String = ""
    var teamId: String = ""
    var subjectId: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with chapterData: ChapterData, groupId: String, teamId: String, subjectId: String) {
        self.chapter.text = "Chapter - \(chapterData.chapterName)"
        self.chapterId = chapterData.chapterId
        self.groupId = groupId
        self.teamId = teamId
        self.subjectId = subjectId
        
        if let firstTopic = chapterData.topicsList.first {
            self.topic.text = "Topic Name - \(firstTopic.topicName)"
        } else {
            self.topic.text = "No Topics Available"
        }
    }

    @IBAction func deleteButton(_ sender: Any) {
        deleteChapter()
    }

    private func deleteChapter() {
        guard let token = TokenManager.shared.getToken() else {
            print("Token not found")
            return
        }

        let urlString = "\(APIProdManager.shared.baseURL)groups/\(groupId)/team/\(teamId)/subject/\(subjectId)/chapter/\(chapterId)/syllabus/delete"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            DispatchQueue.main.async {
                self?.delegate?.didDeleteChapter(chapterId: self?.chapterId ?? "")
            }
        }
        task.resume()
    }
}
