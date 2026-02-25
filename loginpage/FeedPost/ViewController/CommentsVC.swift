//
//  CommentsVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 01/01/25.
//

import UIKit

class CommentsVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var commentTv: UITableView!
    @IBOutlet weak var commentTextFeild: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Properties
    var response: CommentResponse?
    var grpID: String?
    var postID: String?
    let authKey = SessionManager.useRoleToken ?? ""
    var isLoading = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupTextField()
        fetchComments()
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard postID != nil else {
            print("❌ Missing postID")
            return
        }
        fetchComments()
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        commentTv.layer.cornerRadius = 10
    }
    
    private func setupTableView() {
        commentTv.delegate = self
        commentTv.dataSource = self
        commentTv.register(UINib(nibName: "CommentTableViewCell", bundle: nil),
                          forCellReuseIdentifier: "CommentTableViewCell")
        commentTv.rowHeight = UITableView.automaticDimension
        commentTv.estimatedRowHeight = 100
        commentTv.keyboardDismissMode = .interactive
    }
    
    private func setupTextField() {
        commentTextFeild.delegate = self
        commentTextFeild.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        commentTextFeild.placeholder = "Write a comment..."
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        let isTextEmpty = commentTextFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        sendButton.isEnabled = !isTextEmpty
        sendButton.alpha = isTextEmpty ? 0.5 : 1.0
    }
    
    @IBAction func addComment(_ sender: Any) {
        guard let commentText = commentTextFeild.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commentText.isEmpty else {
            print("Comment text is empty")
            return
        }
        
        guard let postId = postID, let postIdInt = Int(postId) else {
            print("❌ Missing or invalid post ID")
            showAlert(message: "Invalid post ID")
            return
        }
        
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        addCommentToPost(postId: postIdInt, commentText: commentText)
    }
    
    // MARK: - API Calls
    private func fetchComments() {
        guard let postId = postID else {
            print("❌ Missing post ID")
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
        
        print("📡 Fetching comments for post: \(postId)")
        
        APIManager.shared.request(
            endpoint: "post/\(postId)/comments",
            method: .get,
            headers: [
                "Authorization": "Bearer \(authKey)",
                "accept": "application/json, text/plain, */*"
            ],
            completion: { [weak self] (result: Result<CommentResponse, APIManager.APIError>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    switch result {
                    case .success(let commentsResponse):
                        print("✅ Successfully fetched \(commentsResponse.data.count) comments")
                        self.response = commentsResponse
                        self.commentTv.reloadData()
                        
                        if !commentsResponse.data.isEmpty {
                            let indexPath = IndexPath(row: commentsResponse.data.count - 1, section: 0)
                            self.commentTv.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to fetch comments: \(error)")
                        // Try one more time with a different approach
                        self.fetchCommentsWithFallback()
                    }
                }
            }
        )
    }
    
    // Fallback method using direct URLSession
    private func fetchCommentsWithFallback() {
        guard let postId = postID else { return }
        
        guard let url = URL(string: "https://dev.gruppie.in/api/v1/post/\(postId)/comments") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data else { return }
            
            do {
                // Try to parse as generic JSON first
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📦 Fallback - Received JSON structure")
                    
                    // Try to extract comments array
                    var comments: [Comment] = []
                    
                    if let dataArray = json["data"] as? [[String: Any]] {
                        // Parse each comment manually
                        for item in dataArray {
                            let comment = self.createCommentFromDictionary(item)
                            comments.append(comment)
                        }
                    } else if let dataDict = json["data"] as? [String: Any],
                              let commentsArray = dataDict["comments"] as? [[String: Any]] {
                        for item in commentsArray {
                            let comment = self.createCommentFromDictionary(item)
                            comments.append(comment)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if !comments.isEmpty {
                            // Create a response object with the comments
                            let fallbackResponse = CommentResponse(
                                data: comments,
                                totalPages: nil,
                                totalRecords: nil,
                                message: nil,
                                success: nil,
                                status: nil,
                                statusCode: nil
                            )
                            self.response = fallbackResponse
                            self.commentTv.reloadData()
                            print("✅ Successfully parsed \(comments.count) comments manually")
                        }
                    }
                }
            } catch {
                print("❌ Fallback parsing failed: \(error)")
            }
        }
        task.resume()
    }
    
    private func createCommentFromDictionary(_ dict: [String: Any]) -> Comment {
        // Safe extraction with defaults
        let text = (dict["text"] as? String) ?? (dict["content"] as? String) ?? (dict["comment"] as? String) ?? ""
        let replies = dict["replies"] as? Int ?? 0
        let likes = dict["likes"] as? Int ?? 0
        let insertedAt = (dict["insertedAt"] as? String) ?? (dict["createdAt"] as? String) ?? (dict["updatedAt"] as? String) ?? ISO8601DateFormatter().string(from: Date())
        let id = (dict["_id"] as? String) ?? (dict["id"] as? String) ?? UUID().uuidString
        let createdByPhone = dict["createdByPhone"] as? String
        let createdByName = (dict["createdByName"] as? String) ?? "Anonymous"
        let createdByImage = dict["createdByImage"] as? String
        let createdById = (dict["createdById"] as? String) ?? ""
        let canEdit = dict["canEdit"] as? Bool
        let userId = dict["userId"] as? String
        let postId = dict["postId"] as? String
        let createdAt = dict["createdAt"] as? String
        let updatedAt = dict["updatedAt"] as? String
        let content = dict["content"] as? String
        let comment = dict["comment"] as? String
        
        return Comment(
            text: text,
            replies: replies,
            likes: likes,
            insertedAt: insertedAt,
            id: id,
            createdByPhone: createdByPhone,
            createdByName: createdByName,
            createdByImage: createdByImage,
            createdById: createdById,
            canEdit: canEdit,
            userId: userId,
            postId: postId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            content: content,
            comment: comment
        )
    }
    
    private func addCommentToPost(postId: Int, commentText: String) {
        let commentRequest = AddCommentRequest(postId: postId, content: commentText)
        
        print("📤 Adding comment to post: \(postId)")
        
        APIManager.shared.request(
            endpoint: "post/comment",
            method: .post,
            body: commentRequest,
            headers: [
                "Authorization": "Bearer \(authKey)",
                "accept": "application/json, text/plain, */*",
                "content-type": "application/json"
            ],
            completion: { [weak self] (result: Result<AddCommentResponse, APIManager.APIError>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("✅ Comment added successfully: \(response.message)")
                        self.commentTextFeild.text = ""
                        self.textFieldDidChange()
                        self.fetchComments()
                        
                    case .failure(let error):
                        print("❌ Error adding comment: \(error)")
                        self.sendButton.isEnabled = true
                        self.sendButton.alpha = 1.0
                        self.showAlert(message: "Failed to add comment. Please try again.")
                    }
                }
            }
        )
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = response?.data.count ?? 0
        if count == 0 {
            let label = UILabel()
            label.text = "No comments yet"
            label.textColor = .gray
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell",
                                                       for: indexPath) as? CommentTableViewCell,
              let comment = response?.data[indexPath.row] else {
            return UITableViewCell()
        }
        cell.configure(with: comment)
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension CommentsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            addComment(textField)
        }
        return true
    }
}
