//
//  FeedViewController.swift
//  YourAppName
//
//  Created by Prajwal Rao Kadam on 30/12/24.
//

//
//  FeedViewController.swift
//  YourAppName
//
//  Created by Prajwal Rao Kadam on 30/12/24.
//

import UIKit

class FeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PostActivityDelegate {

    // MARK: - Outlets
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var bottomLeftButton: UIButton!
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
    
    let authKey = TokenManager.shared.getToken() ?? ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
//        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
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
    
//    private func setupKeyboardDismiss() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
    
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
    
    // MARK: - Data Loading
    @objc private func loadInitialData() {
        currentPage = 1
        hasMorePages = true
        feedPosts.removeAll()
        feedTableView.reloadData()
        loadingIndicator.startAnimating()
        fetchFeed(page: currentPage)
    }
    
    @objc private func refreshData() {
        currentPage = 1
        hasMorePages = true
        fetchFeed(page: currentPage, isRefresh: true)
    }
    
    
    @IBAction func addFeedAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)

        if let addFeedVC = storyboard.instantiateViewController(withIdentifier: "AddFeedVC") as? AddFeedVC {
            self.navigationController?.pushViewController(addFeedVC, animated: true)
        }
    }
    
    func getFeedView(
        page: Int,
        limit: Int,
        token: String,
        completion: @escaping (Result<FeedResponse, APIManager.APIError>) -> Void
    ) {
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let queryParams = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        
        APIManager.shared.request(
            endpoint: "feed-view",
            method: .get,
            queryParams: queryParams,
            headers: headers,
            completion: completion
        )
    }
    
    private func fetchFeed(page: Int, isRefresh: Bool = false) {
        guard let token = SessionManager.useRoleToken else {
            loadingIndicator.stopAnimating()
            return
        }
        
        isLoading = true
        
        getFeedView(page: page, limit: 10, token: token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.feedTableView.refreshControl?.endRefreshing()
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.feedResponse = response
                    
                    if page == 1 {
                        self.feedPosts = response.data
                    } else {
                        self.feedPosts.append(contentsOf: response.data)
                    }
                    
                    self.hasMorePages =
                    response.pagination.currentPage < response.pagination.totalPages
                    
                    self.feedTableView.reloadData()
                    
                case .failure(let error):
                    print("❌ Feed API Error:", error)
                    self.showErrorState()
                }
            }
        }
    }
    
    func loadMorePosts() {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1
        fetchFeed(page: currentPage)
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
//        guard let indexPath = feedTableView.indexPath(for: cell) else { return }
//
//        let post = feedPosts[indexPath.row]
//
//        likePost(
//            groupId: post.groupId,
//            postId: post.postId
//        ) { [weak self] response in
//
//            guard let self = self,
//                  let response = response else { return }
//
//            DispatchQueue.main.async {
//
//                if response.status.lowercased() == "liked" {
//                    self.feedPosts[indexPath.row].likeCount += 1
//                } else {
//                    self.feedPosts[indexPath.row].likeCount =
//                        max(0, self.feedPosts[indexPath.row].likeCount - 1)
//                }
//
//                self.feedTableView.reloadRows(
//                    at: [indexPath],
//                    with: .none
//                )
//            }
//        }
    }
    
    // MARK: - Like API
    func likePost(groupId: String,
                  postId: String,
                  completion: @escaping (LikeStatus?) -> Void) {
        
        let urlString = APIManager.shared.baseURL +
        "groups/\(groupId)/posts/\(postId)/like"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let response = try? JSONDecoder().decode(LikeStatus.self, from: data)
            completion(response)
        }.resume()
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
