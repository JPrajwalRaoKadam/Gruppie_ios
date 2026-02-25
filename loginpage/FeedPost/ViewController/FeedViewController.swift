
//
//  FeedViewController.swift
//  YourAppName
//
//  Created by Prajwal Rao Kadam on 30/12/24.
//

enum FeedSource {
    case classroom(teamId: String)
    case normalFeed
    case noticeBoard
}

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostActivityDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerName: UILabel!
    
    // MARK: - Properties
    var loadingIndicator: UIActivityIndicatorView!
    var lastContentOffset: CGFloat = 0
    var currentRole: String?
    var currentPage = 1
    var isLoading = false
    var hasMorePages = true
    var feedResponse: FeedResponse?
    var feedPosts: [FeedPost] = []
    var feedSource: FeedSource = .normalFeed
    var teamId: String?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if case .normalFeed = feedSource {
            setupTabBar()
        }
        loadInitialData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        navigationController?.isNavigationBarHidden = true
        feedTableView.layer.cornerRadius = 10
        bottomLeftButton.isHidden = (currentRole == "parent" || currentRole == "teacher")
        
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        if case .normalFeed = feedSource {
            return
        }
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true
        backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
    }
    
    private func setupTableView() {
        feedTableView.register(
            UINib(nibName: "FeedPostTableViewCell", bundle: nil),
            forCellReuseIdentifier: "FeedPostTableViewCell"
        )
        feedTableView.rowHeight = UITableView.automaticDimension
        feedTableView.estimatedRowHeight = 400
        feedTableView.tableFooterView = UIView()
    }
    
    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        feedTableView.refreshControl = refresh
    }
    
    private func setupTabBar() {
        CustomTabManager.addTabBar(
            self,
            isRemoveLast: false,
            selectIndex: 1,
            bottomConstraint: &viewBottomConstraint
        )
    }
    
    // MARK: - Data Loading
    @objc private func loadInitialData() {
        currentPage = 1
        hasMorePages = true
        feedPosts.removeAll()
        feedTableView.reloadData()
        loadingIndicator.startAnimating()
        fetchFeed(
            source: feedSource,
            page: currentPage
        )
    }
    
    @objc private func refreshData() {
        currentPage = 1
        hasMorePages = true
        fetchFeed(
            source: feedSource,
            page: currentPage,
            isRefresh: true
        )
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if case .normalFeed = feedSource {
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addFeedAction(_ sender: Any) {
        let vc = AddFeedVC.create(feedSource: feedSource)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchFeed(
        source: FeedSource,
        page: Int,
        isRefresh: Bool = false
    ) {
        guard let token = SessionManager.useRoleToken else {
            loadingIndicator.stopAnimating()
            return
        }
        
        isLoading = true
        
        getFeedView(
            source: source,
            page: page,
            limit: 10,
            token: token
        ) { [weak self] (result: Result<FeedResponse, APIManager.APIError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.feedTableView.refreshControl?.endRefreshing()
                self.isLoading = false
                
                switch result {
                    
                case .success(let response):
                    self.feedResponse = response
                    
                    switch source {
                        
                    case .classroom:
                        // Classroom → no pagination
                        self.headerName.text = "Classroom Communication"
                        self.feedPosts = response.data
                        self.hasMorePages = false
                        
                    case .normalFeed:
                        self.headerName.text = "Campus Connect"
                        if page == 1 {
                            self.feedPosts = response.data
                        } else {
                            self.feedPosts.append(contentsOf: response.data)
                        }
                        
                        if let pagination = response.pagination {
                            self.hasMorePages = pagination.currentPage < pagination.totalPages
                        } else {
                            self.hasMorePages = false
                        }
                    case .noticeBoard:
                        self.headerName.text = "Notice Board"
                        // Filter only group posts
                        self.feedPosts = response.data.filter { post in
                            post.postType?.lowercased() == "group"
                        }
                        self.hasMorePages = false
                    }
                    
                    self.feedTableView.reloadData()
                    
                case .failure(let error):
                    print("❌ Feed API Error:", error)
                    self.showErrorState()
                }
            }
        }
    }
    
    func getFeedView(
        source: FeedSource,
        page: Int,
        limit: Int,
        token: String,
        completion: @escaping (Result<FeedResponse, APIManager.APIError>) -> Void
    ) {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        var endpoint = ""
        var queryParams: [String: String]? = nil
        
        switch source {
        case .classroom(let teamId):
            endpoint = "posts"
            queryParams = [
                "teamId": "\(teamId)"
            ]
            
        case .normalFeed:
            endpoint = "posts"
            queryParams = [
                "page": "\(page)",
                "limit": "\(limit)"
            ]
        case .noticeBoard:
            endpoint = "posts"
            queryParams = [
                "page": "\(page)",
                "limit": "\(limit)",
                "postType": "group"
            ]
        }
        
        APIManager.shared.request(
            endpoint: endpoint,
            method: .get,
            queryParams: queryParams,
            headers: headers,
            completion: completion
        )
    }
    
    func loadMorePosts() {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1
        fetchFeed(
            source: feedSource,
            page: currentPage
        )
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let count = feedPosts.count
        tableView.backgroundView = count == 0 ? createEmptyStateView() : nil
        tableView.separatorStyle = count == 0 ? .none : .singleLine
        return count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FeedPostTableViewCell",
            for: indexPath
        ) as? FeedPostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = feedPosts[indexPath.row]
        cell.delegate = self
        cell.configure(with: post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == feedPosts.count - 3 {
            loadMorePosts()
        }
    }
    
    // MARK: - PostActivityDelegate
    func didTapReadMore(text: String, from cell: FeedPostTableViewCell) {
        let vc = FullTextViewController()
        vc.fullText = text
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(vc, animated: true)
    }
    
    func didTapMedia(cell: FeedPostTableViewCell, url: String) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "VideoPlayerVC"
        ) as? VideoPlayerVC else {
            print("❌ VideoPlayerVC not found in storyboard")
            return
        }
        
        vc.mediaURL = url
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Final Working Like Functionality
    func didTapLikeButton(cell: FeedPostTableViewCell) {
        
        guard let indexPath = feedTableView.indexPath(for: cell) else { return }
        
        let post = feedPosts[indexPath.row]
        
        guard let postId = Int(post.postId) else {
            print("Invalid Post ID")
            return
        }
        
        // Store original state for potential rollback
        let originalIsLiked = post.isLiked
        let originalLikeCount = post.likeCount
        
        // Determine action based on current state
        let action = post.isLiked ? "unlike" : "like"
        
        print("🔄 Attempting to \(action) post ID: \(postId)")
        
        // Disable like button to prevent multiple taps
        cell.likeButton.isEnabled = false
        
        // ✅ Optimistic UI Update (immediate feedback)
        var updatedPost = post
        updatedPost.isLiked.toggle()
        
        if updatedPost.isLiked {
            updatedPost.likeCount += 1
        } else {
            updatedPost.likeCount = max(0, updatedPost.likeCount - 1)
        }
        
        self.feedPosts[indexPath.row] = updatedPost
        self.feedTableView.reloadRows(at: [indexPath], with: .none)
        
        // ✅ API Call with toggle endpoint
        toggleLike(postId: postId) { [weak self] (result: Result<ToggleLikeResponse, APIManager.APIError>) in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let response):
                print("✅ Toggle Like Success - Action: \(action)", response)
                print("📊 Server message: \(response.message ?? "No message")")
                
                // Determine the actual server state from the message
                let serverIsLiked: Bool
                if let message = response.message?.lowercased() {
                    if message.contains("liked") && !message.contains("unliked") {
                        serverIsLiked = true
                    } else if message.contains("unliked") {
                        serverIsLiked = false
                    } else {
                        // If message doesn't indicate, use the toggled state
                        serverIsLiked = updatedPost.isLiked
                    }
                } else {
                    // If no message, use the toggled state
                    serverIsLiked = updatedPost.isLiked
                }
                
                print("📊 Determined server state - isLiked: \(serverIsLiked)")
                
                // Show success message
                self.showToast(message: response.message ?? "Success", isSuccess: true)
                
                // ✅ Fetch the updated post to get accurate server counts
                self.fetchUpdatedPost(postId: postId) { fetchedPost in
                    DispatchQueue.main.async {
                        // Re-enable like button
                        if let cell = self.feedTableView.cellForRow(at: indexPath) as? FeedPostTableViewCell {
                            cell.likeButton.isEnabled = true
                        }
                        
                        if let fetchedPost = fetchedPost {
                            // Create a corrected post with the right like status
                            var correctedPost = fetchedPost
                            
                            // If the fetched post has wrong isLiked state, correct it based on server message
                            if fetchedPost.isLiked != serverIsLiked {
                                print("⚠️ Correcting server response - Setting isLiked to \(serverIsLiked)")
                                correctedPost.isLiked = serverIsLiked
                            }
                            
                            // Update with corrected server data
                            self.feedPosts[indexPath.row] = correctedPost
                            self.feedTableView.reloadRows(at: [indexPath], with: .none)
                            print("✅ Updated post with server data - Like count: \(correctedPost.likeCount), isLiked: \(correctedPost.isLiked)")
                            
                        } else {
                            // If fetch fails, use our optimistic update with correction based on message
                            var finalPost = updatedPost
                            
                            // Override isLiked based on server message
                            if finalPost.isLiked != serverIsLiked {
                                print("⚠️ Correcting optimistic update based on server message")
                                finalPost.isLiked = serverIsLiked
                            }
                            
                            self.feedPosts[indexPath.row] = finalPost
                            self.feedTableView.reloadRows(at: [indexPath], with: .none)
                            print("✅ Using corrected optimistic update - Like count: \(finalPost.likeCount), isLiked: \(finalPost.isLiked)")
                        }
                    }
                }
                
            case .failure(let error):
                print("❌ Toggle Like Error - Action: \(action)", error)
                
                // Rollback on failure
                DispatchQueue.main.async {
                    // Re-enable like button
                    if let cell = self.feedTableView.cellForRow(at: indexPath) as? FeedPostTableViewCell {
                        cell.likeButton.isEnabled = true
                    }
                    
                    // Revert to original state
                    self.feedPosts[indexPath.row] = post
                    self.feedTableView.reloadRows(at: [indexPath], with: .none)
                    
                    // Show error message
                    self.showToast(message: "Failed to \(action). Please try again.", isSuccess: false)
                }
            }
        }
    }
    func toggleLike(postId: Int, completion: @escaping (Result<ToggleLikeResponse, APIManager.APIError>) -> Void) {
        
        guard let token = SessionManager.useRoleToken else {
            completion(.failure(APIManager.APIError.invalidURL))
            return
        }
        
        let headers = [
            "Authorization": "Bearer \(token)",
            "accept": "application/json, text/plain, */*",
            "content-type": "application/json"
        ]
        
        let body = ToggleLikeRequest(postId: postId)
        
        APIManager.shared.request(
            endpoint: "posts/toggle-like",
            method: .post,
            body: body,
            headers: headers,
            completion: completion
        )
    }
    // MARK: - Fetch Updated Post

    // MARK: - Fetch Updated Post - Optimized Version
    func fetchUpdatedPost(postId: Int, completion: @escaping (FeedPost?) -> Void) {
        guard let token = SessionManager.useRoleToken else {
            completion(nil)
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let queryParams = ["limit": "50"] // Fetch more posts to ensure we get the updated one
        
        APIManager.shared.request(
            endpoint: "posts",
            method: .get,
            queryParams: queryParams,
            headers: headers,
            completion: { (result: Result<FeedResponse, APIManager.APIError>) in
                switch result {
                case .success(let response):
                    // Find the specific post by ID
                    let updatedPost = response.data.first(where: { $0.postId == String(postId) })
                    
                    if let post = updatedPost {
                        print("✅ Found updated post - ID: \(post.postId), Likes: \(post.likeCount), isLiked: \(post.isLiked)")
                    } else {
                        print("⚠️ Post with ID \(postId) not found in response")
                    }
                    
                    completion(updatedPost)
                    
                case .failure(let error):
                    print("❌ Failed to fetch posts for update: \(error)")
                    completion(nil)
                }
            }
        )
    }

    // Remove the separate fetchAllPostsAndFind method since we've combined it
    
    private func fetchAllPostsAndFind(postId: Int, completion: @escaping (FeedPost?) -> Void) {
        guard let token = SessionManager.useRoleToken else {
            completion(nil)
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let queryParams = ["limit": "50"] // Fetch more posts to find the specific one
        
        APIManager.shared.request(
            endpoint: "posts",
            method: .get,
            queryParams: queryParams,
            headers: headers,
            completion: { (result: Result<FeedResponse, APIManager.APIError>) in
                switch result {
                case .success(let response):
                    let updatedPost = response.data.first(where: { $0.postId == String(postId) })
                    completion(updatedPost)
                case .failure:
                    completion(nil)
                }
            }
        )
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Empty / Error States
    private func createEmptyStateView() -> UIView {
        let view = UIView(frame: feedTableView.bounds)
        let label = UILabel()
        label.text = "No posts available"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    private func showErrorState() {
        let view = UIView(frame: feedTableView.bounds)
        let label = UILabel()
        label.text = "Failed to load posts"
        label.textColor = .red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        feedTableView.backgroundView = view
    }
}

// MARK: - Toast Extension
extension FeedViewController {
    func showToast(message: String, isSuccess: Bool) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = isSuccess ? UIColor.systemGreen.withAlphaComponent(0.8) : UIColor.systemRed.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        let toastWidth: CGFloat = 250
        let toastHeight: CGFloat = 40
        toastLabel.frame = CGRect(
            x: self.view.frame.size.width/2 - toastWidth/2,
            y: self.view.frame.size.height - 100,
            width: toastWidth,
            height: toastHeight
        )
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
