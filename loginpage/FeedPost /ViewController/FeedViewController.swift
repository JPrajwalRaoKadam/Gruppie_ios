//
//  File.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 30/12/24.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostActivityDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    @IBOutlet weak var bottomLeftButton: UIButton!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    var likeUnlikeResponse: LikeStatus?
    var activityIndicator: UIActivityIndicatorView!
    var schoolId: String = ""

        
    let authKey = TokenManager.shared.getToken()!
    var loadingIndicator: UIActivityIndicatorView!
    var lastContentOffset: CGFloat = 0 // Store the last scroll position
    var currentRole: String?
    var currentPage = 1
    var isLoading = false
    var response: PostResponse? // Holds the parsed response
    var likeUnlikeStatus : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        feedTableView.register(UINib(nibName: "FeedPostTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedPostTableViewCell")
        
        // Setup single loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .black
        view.addSubview(loadingIndicator)
        
        // Role-based UI setup
        if currentRole == "parent" || currentRole == "teacher" {
            bottomLeftButton.isHidden = true
        }
        
        // Pull to Refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        feedTableView.refreshControl = refreshControl
        enableKeyboardDismissOnTap()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshData() {
        currentPage = 1 // Reset to the first page for fresh data
        fetchPostsWithAuth(page: currentPage) { result in
            switch result {
            case .success(let fetchedResponse):
                print("🎉 Successfully refreshed data.")
                self.response = fetchedResponse
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                    self.feedTableView.refreshControl?.endRefreshing() // End refreshing
                }
            case .failure(let error):
                print("❌ Failed to refresh data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.feedTableView.refreshControl?.endRefreshing() // End refreshing even on failure
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CustomTabManager.addTabBar(self, isRemoveLast: false, selectIndex: 1, bottomConstraint: &self.tableViewBottomConstraint)
        
        loadingIndicator.startAnimating()
        fetchPostsWithAuth(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedResponse):
                    self?.response = fetchedResponse
                    self?.feedTableView.reloadData() // Will trigger cell display
                case .failure(let error):
                    print("Failed to fetch data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func bottomLeftButtonAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
                guard let addFeedVC = storyboard.instantiateViewController(withIdentifier: "AddFeedVC") as? AddFeedVC else {
                    print("ViewController with identifier 'AddFeedVC' not found.")
                    return
                }
        addFeedVC.groupID = self.schoolId
        print("old Feed: \(self.response?.data.count ?? 0) posts")
        addFeedVC.response = self.response
        
                self.navigationController?.pushViewController(addFeedVC, animated: true)
    }
 
    
    func loadMorePosts() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        loadingIndicator.startAnimating()
        
        fetchPostsWithAuth(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.isLoading = false
                
                switch result {
                case .success(let fetchedResponse):
                    print("🎉 Successfully fetched more data.")
                    if !fetchedResponse.data.isEmpty {
                        self?.response?.data.append(contentsOf: fetchedResponse.data)
                        self?.feedTableView.reloadData()
                    }
                case .failure(let error):
                    print("❌ Failed to fetch more data: \(error.localizedDescription)")
                }
            }
        }
    }

    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = response?.data.count ?? 0
        if count == 0 {
            // Show a message when no data is available
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            messageLabel.text = "No posts available"
            messageLabel.textColor = .gray
            messageLabel.textAlignment = .center
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Stop loading when first cell is being configured
            if indexPath.row == 0 {
                loadingIndicator.stopAnimating()
            }
        if let cell = feedTableView.dequeueReusableCell(withIdentifier: "FeedPostTableViewCell", for: indexPath) as? FeedPostTableViewCell,
           let post = response?.data[indexPath.row] {
            cell.post = post
            cell.delegate = self
            if post.fileType == "youtube" {
                cell.videoPlayerURL = post.video
            }else {
                if let fileName = post.fileName, !fileName.isEmpty {
                    cell.videoPlayerURL = post.fileName?[0]
                }
            }
            
            cell.configure(with: post)
            print("audio file    \(post.fileType)")
            print("file names::::   \(post.fileName)......\(post.fileType)")
                        
            cell.commentAction = { [weak self] in
                guard let self = self else { return }
                
                let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
                guard let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC else {
                    print("ViewController with identifier 'CommentsVC' not found.")
                    return
                }
                commentsVC.grpID = cell.grpId
                commentsVC.postID = cell.postId
                self.navigationController?.pushViewController(commentsVC, animated: true)
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Fade-in animation
        cell.alpha = 0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
        
        // Ensure loading indicator is stopped when cells are displayed
        if indexPath.row == (response?.data.count ?? 0) - 1 {
            loadingIndicator.stopAnimating()
        }
    }
    
    func taptoNaviagteWithURL(cell: FeedPostTableViewCell, videoURL: String) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let videoViewController = storyboard.instantiateViewController(withIdentifier: "VideoPlayerVC") as? VideoPlayerVC else {
            print("ViewController with identifier 'VideoPlayerVC' not found.")
            return
        }
        videoViewController.videoPlayerURL = videoURL
        self.navigationController?.pushViewController(videoViewController, animated: true)
    }
        
    
    // MARK: - API Call
    func fetchPostsWithAuth(page: Int, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        print("eeegggtgtgt\(schoolId)")
        // Start loading (in case it's not already running)
          DispatchQueue.main.async {
              self.loadingIndicator.startAnimating()
          }
              
        let urlString = APIManager.shared.baseURL + "groups/\(schoolId)/all/post/get?page=\(page)"
        guard let url = URL(string: urlString) else {
            print("🚨 Invalid URL: \(urlString)")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

        print("🌐 Making request to URL: \(urlString)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                if let error = error {
                    print("❌ Error during request: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📩 HTTP Status Code: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("🚨 Invalid Response Status: \(httpResponse.statusCode)")
                        completion(.failure(NSError(domain: "Invalid Response", code: httpResponse.statusCode, userInfo: nil)))
                        return
                    }
                }
                
                guard let data = data else {
                    print("🚨 No data received from server.")
                    completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                    return
                }
                
                print("📦 Data received: \(String(data: data, encoding: .utf8) ?? "Unable to parse data as string")")
                
                do {
                    let decodedResponse = try JSONDecoder().decode(PostResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("❌ JSON Parsing Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func didTapReadMore(text: String, from cell: FeedPostTableViewCell) {
            let fullTextVC = FullTextViewController()
            fullTextVC.fullText = text
            fullTextVC.modalPresentationStyle = .pageSheet
            
            if let sheet = fullTextVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(fullTextVC, animated: true)
        }
    
    func didTapLikeButton(cell: FeedPostTableViewCell) {
        guard let indexPath = feedTableView.indexPath(for: cell) else { return }
        guard let groupId = cell.grpId, let postId = cell.postId else {
            print("🚨 groupId or postId is nil")
            return
        }
        let unlikedImage = UIImage(systemName: "hand.thumbsup")
        let likedImage = UIImage(systemName: "hand.thumbsup.fill")
        
        likePost(groupId: groupId, postId: postId) { [weak self] response in
            guard let self = self else { return }
            
            // Find the post in the response and update its properties
            if let postIndex = self.response?.data.firstIndex(where: { $0.id == postId }) {
                // Create a mutable copy of the post
                var post = self.response!.data[postIndex]
                
                DispatchQueue.main.async {
                    // Update the properties
                    if response?.status.lowercased() == "liked" {
                        post.isLiked = true
                        post.likes += 1 // Increment the likes
                    } else {
                        post.isLiked = false
                        post.likes -= 1 // Decrement the likes
                    }
                    
                    // Assign the modified post back to the array
                    self.response?.data[postIndex] = post
                    
                    // Reload the table view row
                    self.feedTableView.reloadRows(at: [indexPath], with: .none)
                }
            }

        }
    }


    
    func likePost(groupId: String, postId: String, completion: @escaping (LikeStatus?) -> Void) {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/posts/\(postId)/like") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LikeStatus.self, from: data)
                print("Decoded Response: \(response)")
                completion(response)
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }

}
