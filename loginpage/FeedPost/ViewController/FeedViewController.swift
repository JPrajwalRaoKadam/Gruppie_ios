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

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PostActivityDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
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
        ) { [weak self] result in
            
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
                        self.feedPosts = response.data
                        self.hasMorePages = false
                        
                    case .normalFeed:
                        if page == 1 {
                            self.feedPosts = response.data
                        } else {
                            self.feedPosts.append(contentsOf: response.data)
                        }
                        
                        if let pagination = response.pagination {
                            self.hasMorePages =
                            pagination.currentPage < pagination.totalPages
                        } else {
                            self.hasMorePages = false
                        }
                    case .noticeBoard:
                        // ✅ FILTER ONLY GROUP POSTS
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
                // ❌ NO page & limit
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
                    "postType": "group"   // ✅ IMPORTANT
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
            
            //        cell.commentAction = { [weak self] in
            //            self?.navigateToComments(
            //                groupId: post.team?.id,
            //                postId: post.postId
            //            )
            //        }
            
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
        
        // MARK: - PostActivityDelegate
        
        func didTapMedia(cell: FeedPostTableViewCell, url: String) {
            
            let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
            // ⚠️ Use same storyboard where VideoPlayerVC exists
            
            guard let vc = storyboard.instantiateViewController(
                withIdentifier: "VideoPlayerVC"
            ) as? VideoPlayerVC else {
                print("❌ VideoPlayerVC not found in storyboard")
                return
            }
            
            vc.mediaURL = url   // Pass media URL
            
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
        func didTapLikeButton(cell: FeedPostTableViewCell) {
            
            guard let indexPath = feedTableView.indexPath(for: cell) else { return }
            
            var post = feedPosts[indexPath.row]
            
            guard let postId = Int(post.postId) else {
                print("Invalid Post ID")
                return
            }
            
            // ✅ Optimistic UI Update
            post.isLiked.toggle()
            
            if post.isLiked {
                post.likeCount += 1
            } else {
                post.likeCount = max(0, post.likeCount - 1)
            }
            
            feedPosts[indexPath.row] = post
            
            // Update UI immediately
            feedTableView.reloadRows(at: [indexPath], with: .none)
            
            
            // ✅ API Call
            likePost(postId: postId) { result in
                
                switch result {
                    
                case .success(let res):
                    print("✅ Like Response:", res)
                    
                case .failure(let err):
                    print("❌ Like Error:", err)
                }
            }
            
        }
        
        func likePost(postId: Int,completion: @escaping (Result<LikePostResponse, APIManager.APIError>) -> Void) {
            
            guard let token = SessionManager.useRoleToken else {
                completion(.failure(.invalidURL))
                return
            }
            
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            
            let body = LikePostRequest(postId: postId)
            
            APIManager.shared.request(
                endpoint: "posts/like",
                method: .post,
                body: body,
                headers: headers,
                completion: completion
            )
        }
        
        
        // MARK: - Navigation
        //    private func navigateToComments(groupId: String?, postId: String?) {
        //        guard let groupId = groupId,
        //              let postId = postId else { return }
        //
        //        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        //        let vc = storyboard.instantiateViewController(
        //            withIdentifier: "CommentsVC"
        //        ) as! CommentsVC
        //
        //        vc.grpID = groupId
        //        vc.postID = postId
        //        vc.modalPresentationStyle = .pageSheet
        //
        //        if let sheet = vc.sheetPresentationController {
        //            sheet.detents = [.large()]
        //            sheet.prefersGrabberVisible = true
        //        }
        //
        //        present(vc, animated: true)
        //    }
        
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
