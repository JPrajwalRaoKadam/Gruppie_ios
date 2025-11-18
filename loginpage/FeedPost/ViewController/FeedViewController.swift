//
//  FeedViewController.swift
//  YourAppName
//
//  Created by Prajwal Rao Kadam on 30/12/24.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostActivityDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var likeUnlikeResponse: LikeStatus?
    var activityIndicator: UIActivityIndicatorView!
    var schoolId: String = ""
    let authKey = TokenManager.shared.getToken()!
    var loadingIndicator: UIActivityIndicatorView!
    var lastContentOffset: CGFloat = 0
    var currentRole: String?
    var currentPage = 1
    var isLoading = false
    var response: PostResponse?
    var likeUnlikeStatus: String?
    var hasMorePages = true
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
        loadInitialData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.navigationController?.isNavigationBarHidden = true
        feedTableView.layer.cornerRadius = 10
        // Role-based UI setup
        bottomLeftButton.isHidden = (currentRole == "parent" || currentRole == "teacher")
        
        // Loading indicator setup
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .black
        view.addSubview(loadingIndicator)
    }
    
    private func setupTableView() {
        feedTableView.register(UINib(nibName: "FeedPostTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedPostTableViewCell")
        feedTableView.rowHeight = UITableView.automaticDimension
        feedTableView.estimatedRowHeight = 400
        feedTableView.tableFooterView = UIView()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        feedTableView.refreshControl = refreshControl
    }
    
    private func setupTabBar() {
        CustomTabManager.addTabBar(self,
                                 isRemoveLast: false,
                                 selectIndex: 1,
                                 bottomConstraint: &self.viewBottomConstraint)
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardd))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardd() {
        view.endEditing(true)
    }
    
    // MARK: - Data Loading
    @objc private func loadInitialData() {
        currentPage = 1
        hasMorePages = true
        loadingIndicator.startAnimating()
        fetchPostsWithAuth(page: currentPage) { [weak self] result in
            self?.handleDataResponse(result: result)
        }
    }
    
    @objc private func refreshData() {
        currentPage = 1
        hasMorePages = true
        fetchPostsWithAuth(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.feedTableView.refreshControl?.endRefreshing()
            }
            self?.handleDataResponse(result: result)
        }
    }
    
    func loadMorePosts() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        currentPage += 1
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: feedTableView.bounds.width, height: 44)
        feedTableView.tableFooterView = spinner
        
        fetchPostsWithAuth(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.feedTableView.tableFooterView = nil
                
                switch result {
                case .success(let fetchedResponse):
                    self.handleNewPageResponse(fetchedResponse)
                case .failure(let error):
                    print("Failed to load more posts: \(error.localizedDescription)")
                    self.currentPage -= 1
                }
            }
        }
    }
    
    private func handleDataResponse(result: Result<PostResponse, Error>) {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            
            switch result {
            case .success(let fetchedResponse):
                self.response = fetchedResponse
                // Changed from currentPage/totalPages to page number comparison
                self.hasMorePages = self.currentPage < fetchedResponse.totalNumberOfPages
                self.feedTableView.reloadData()
            case .failure(let error):
                print("Failed to fetch data: \(error.localizedDescription)")
                self.showErrorState()
            }
        }
    }
    
    private func handleNewPageResponse(_ fetchedResponse: PostResponse) {
        guard !fetchedResponse.data.isEmpty else {
            hasMorePages = false
            return
        }
        
        response?.data.append(contentsOf: fetchedResponse.data)
        // Removed page number assignments since they're not in the model
        hasMorePages = currentPage < fetchedResponse.totalNumberOfPages
        
        feedTableView.reloadData()
    }
    
    // MARK: - TableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = response?.data.count ?? 0
        tableView.backgroundView = count == 0 ? createEmptyStateView() : nil
        tableView.separatorStyle = count == 0 ? .none : .singleLine
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedPostTableViewCell",
                                                     for: indexPath) as? FeedPostTableViewCell,
              let post = response?.data[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.post = post
        cell.delegate = self
        
        if post.fileType == "youtube" {
            cell.videoPlayerURL = post.video
        } else if let fileName = post.fileName?.first, !fileName.isEmpty {
            cell.videoPlayerURL = fileName
        }
        
        cell.configure(with: post)
        
        cell.commentAction = { [weak self] in
            self?.navigateToComments(groupId: cell.grpId, postId: cell.postId)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 1
        }
        
        guard let response = response else { return }
        if indexPath.row == response.data.count - 3 && hasMorePages && !isLoading {
            loadMorePosts()
        }
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bottomLeftButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let addFeedVC = storyboard.instantiateViewController(withIdentifier: "AddFeedVC") as? AddFeedVC else {
            print("ViewController with identifier 'AddFeedVC' not found.")
            return
        }
        addFeedVC.groupID = self.schoolId
        addFeedVC.response = self.response
        navigationController?.pushViewController(addFeedVC, animated: true)
    }
    
    // MARK: - PostActivityDelegate
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
        guard let indexPath = feedTableView.indexPath(for: cell),
              let groupId = cell.grpId,
              let postId = cell.postId else {
            print("Missing required parameters for like action")
            return
        }
        
        likePost(groupId: groupId, postId: postId) { [weak self] response in
            guard let self = self,
                  let response = response,
                  let postIndex = self.response?.data.firstIndex(where: { $0.id == postId }) else {
                return
            }
            
            DispatchQueue.main.async {
                var post = self.response!.data[postIndex]
                post.isLiked = response.status.lowercased() == "liked"
                post.likes += post.isLiked ? 1 : -1
                self.response?.data[postIndex] = post
                self.feedTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func taptoNaviagteWithURL(cell: FeedPostTableViewCell, videoURL: String) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let videoViewController = storyboard.instantiateViewController(withIdentifier: "VideoPlayerVC") as? VideoPlayerVC else {
            print("ViewController with identifier 'VideoPlayerVC' not found.")
            return
        }
        videoViewController.videoPlayerURL = videoURL
        navigationController?.pushViewController(videoViewController, animated: true)
    }
    
    // MARK: - API Calls
    func fetchPostsWithAuth(page: Int, completion: @escaping (Result<PostResponse, Error>) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(schoolId)/all/post/get?page=\(page)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid Response", code: 401, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(PostResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func likePost(groupId: String, postId: String, completion: @escaping (LikeStatus?) -> Void) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/posts/\(postId)/like"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(LikeStatus.self, from: data)
                completion(response)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    private func navigateToComments(groupId: String?, postId: String?) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        guard let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC,
              let groupId = groupId,
              let postId = postId else {
            return
        }
        commentsVC.grpID = groupId
        commentsVC.postID = postId
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    private func createEmptyStateView() -> UIView {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: feedTableView.bounds.width, height: feedTableView.bounds.height))
        
        let messageLabel = UILabel()
        messageLabel.text = "No posts available"
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
        
        return emptyView
    }
    
    private func showErrorState() {
        let errorView = UIView(frame: CGRect(x: 0, y: 0, width: feedTableView.bounds.width, height: feedTableView.bounds.height))
        
        let errorLabel = UILabel()
        errorLabel.text = "Failed to load posts"
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(loadInitialData), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor)
        ])
        
        feedTableView.backgroundView = errorView
    }
}
