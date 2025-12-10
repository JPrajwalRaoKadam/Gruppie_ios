//
//  CommentsVC.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 01/01/25.
//

import UIKit

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var commentTv: UITableView!
    @IBOutlet weak var commentTextFeild: UITextField!
    
    var response: CommentResponse?
    
    var grpID: String?
    
    var postID: String?
    
    let authKey = TokenManager.shared.getToken()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        commentTv.layer.cornerRadius = 10
        holderView.layer.cornerRadius = 5
        if let response = response {
                    print("Total Pages: \(response.totalNumberOfPages)")
                    print("Comments: \(response.data)")
                }
        commentTv.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        fetchComments(groupId: grpID ?? "" , postId: postID ?? "")
        enableKeyboardDismissOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let groupId = grpID, let postId = postID else {
            print("❌ Missing grpID or postID")
            return
        }
        fetchComments(groupId: groupId, postId: postId)

    }
    
    @IBAction func addComment(_ sender: Any) {
        
        // Ensure that the comment text field is not empty before proceeding
        guard let commentText = commentTextFeild.text, !commentText.isEmpty else {
            print("Comment text is empty")
            return
        }
        
        guard let groupId = grpID, let postId = postID else {
            print("❌ Missing group ID or post ID")
            return
        }
        
        // Call the add comment API
        addCommentToPost(groupId: groupId, postId: postId, commentText: commentText) { response, error in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            } else if let response = response, response.success {
                print("Comment added successfully: \(response.message)")
                
                // Create a new Comment object for the added comment and append it to the data
                let newComment = Comment(
                    text: commentText,
                    replies: 0,
                    likes: 0,
                    insertedAt: Date().iso8601, // You may want to use the actual insertion date from the API if available
                    id: UUID().uuidString, // Generate a unique ID for this comment
                    createdByPhone: "YourPhoneNumber", // Update with actual user info if needed
                    createdByName: "Your Name", // Use the actual name
                    createdByImage: nil,
                    createdById: "YourUserID", // Use the actual user ID
                    canEdit: true
                )
                
                // Update the local response data to include the new comment
                self.response?.data.append(newComment)
                
                // Reload the table view to reflect the updated data
                DispatchQueue.main.async {
                    self.commentTv.reloadData()
                }
            }
        }
        
        // Clear the text field after the comment is added
        DispatchQueue.main.async {
            self.commentTextFeild.text = ""
        }
        
        self.fetchComments(groupId: self.grpID!, postId: self.postID!)
        DispatchQueue.main.async {
            self.commentTv.reloadData()
        }
    }

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = commentTv.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell,
           let comment = response?.data[indexPath.row] {
            cell.configure(with: comment)
            return cell
        }
        return UITableViewCell()
    }
    
    func fetchComments(groupId: String, postId: String) {
          // Construct the API endpoint URL
          let urlString = APIManager.shared.baseURL + "groups/\(groupId)/posts/\(postId)/comments/get"
          print("Request URL: \(urlString)") // Print the constructed URL
           
          // Convert string to URL
          guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
          }
           
          // Create URL request
          var request = URLRequest(url: url)
          request.httpMethod = "GET"
           
          // Add Authorization header
          let authKey = authKey
          request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
          print("Authorization header set.") // Print confirmation for header
           
          // Create a URLSession data task
          let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle any network error
            if let error = error {
               print("Error: \(error.localizedDescription)") // Print error
               return
            }
              
            // Handle the response (e.g., HTTP status code)
            if let httpResponse = response as? HTTPURLResponse {
               print("HTTP Status Code: \(httpResponse.statusCode)") // Print HTTP status code
               if httpResponse.statusCode != 200 {
                  let apiError = NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: nil)
                  print("API Error: \(apiError.localizedDescription)")
                  return
               }
            }
              
            // Handle the data (JSON)
            if let data = data {
               print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")") // Print raw response data as string for debugging
               do {
                  // Decode the JSON response into a CommentResponse object
                  let decoder = JSONDecoder()
                  let comments = try decoder.decode(CommentResponse.self, from: data)
                  print("Decoded comments: \(comments)") // Print the decoded response
                  // Call the completion handler with the decoded comments
                  self.response = comments
                  DispatchQueue.main.async {
                    self.commentTv.reloadData()
                  }
               } catch {
                  print("Decoding Error: \(error.localizedDescription)") // Print decoding error
               }
            } else {
               print("No data received.") // Print if no data was received
            }
          }
           
          // Start the task
          task.resume()
       }
    
    func addCommentToPost(groupId: String, postId: String, commentText: String, completion: @escaping (AddCommentResponse?, Error?) -> Void) {
        // Construct the API URL
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/posts/\(postId)/comments/add"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let commentRequest = AddCommentRequest(text: commentText)
        do {
            let requestBody = try JSONEncoder().encode(commentRequest)
            request.httpBody = requestBody
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            // Handle the response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let apiError = NSError(domain: "API Error", code: httpResponse.statusCode, userInfo: nil)
                    completion(nil, apiError)
                    return
                }
            }
            
            // Decode the response data
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(AddCommentResponse.self, from: data)
                    print("Response: \(response)")
                    completion(response, nil)
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(nil, error)
                }
            } else {
                let noDataError = NSError(domain: "No Data", code: 1001, userInfo: nil)
                completion(nil, noDataError)
            }
        }
        
        // Start the task
        task.resume()
    }

}

extension Date {
    var iso8601: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }
}
