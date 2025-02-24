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
    
    var lastContentOffset: CGFloat = 0 // Store the last scroll position
    
    var currentPage = 1
    var isLoading = false
    var response: PostResponse? // Holds the parsed response
    var likeUnlikeStatus : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        feedTableView.register(UINib(nibName: "FeedPostTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedPostTableViewCell")
        // Setup Activity Indicator
           activityIndicator = UIActivityIndicatorView(style: .large)
           activityIndicator.center = view.center
           activityIndicator.hidesWhenStopped = true
           view.addSubview(activityIndicator)

           // Setup Pull to Refresh
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
           feedTableView.refreshControl = refreshControl
        
        setupBottomLeftButton()
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
        
        fetchPostsWithAuth(page: currentPage) { result in
            switch result {
            case .success(let fetchedResponse):
                print("🎉 Successfully fetched data.")
                self.response = fetchedResponse
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
            case .failure(let error):
                print("❌ Failed to fetch data: \(error.localizedDescription)")
            }
        }
    }
    
    
    func setupBottomLeftButton() {
        let downImage = UIImage(named: "edit")
        bottomLeftButton.setImage(downImage, for: .normal)
        
        bottomLeftButton.tintColor = .black
        bottomLeftButton.layer.cornerRadius = 25 // Circular button
        bottomLeftButton.layer.masksToBounds = true
        
    }
    
    
    @IBAction func bottomLeftButtonAction(_ sender: Any) {
        
//        if bottomLeftButton.imageView?.image == UIImage(named: "icon_up") {
//                let indexPath = IndexPath(row: 0, section: 0)  // Scroll to the top of the table
//                feedTableView.scrollToRow(at: indexPath, at: .top, animated: true)
//            } else if bottomLeftButton.imageView?.image == UIImage(named: "edit") {
//                print("Button has 'edit' image")
//            }
        
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
    
    // Detecting Scroll Direction
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == feedTableView else { return }
        
        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset > lastContentOffset {
            // Scrolling Down
            print("Scrolling up")
            updateButtonForScrollingUp()
        } else if currentOffset < lastContentOffset {
            // Scrolling Up
            print("Scrolling down")
            updateButtonForScrollingDown()
        }
        
        if currentOffset <= 0 {
            print("Scrolling down")
            updateButtonForScrollingDown()
        }
        
        lastContentOffset = currentOffset
        
        // Check if the user has scrolled to the bottom
        let contentHeight = scrollView.contentSize.height
        let scrollPosition = scrollView.contentOffset.y + scrollView.frame.size.height
        
        // Only trigger pagination when near the bottom (without interfering with pull-to-refresh)
        if scrollPosition > contentHeight - 100 && !isLoading && feedTableView.refreshControl?.isRefreshing == false {
            loadMorePosts()
        }
    }



    
    // Update button appearance when scrolling down
    func updateButtonForScrollingDown() {
        let downImage = UIImage(named: "edit")
        bottomLeftButton.setImage(downImage, for: .normal)
        
        // Update action for scrolling down
        bottomLeftButton.addTarget(self, action: #selector(scrollDownButtonTapped), for: .touchUpInside)
    }
    
    // Update button appearance when scrolling up
    func updateButtonForScrollingUp() {
        let upImage = UIImage(named: "icon_up")
        bottomLeftButton.setImage(upImage, for: .normal)
        
        // Update action for scrolling up
        bottomLeftButton.addTarget(self, action: #selector(scrollUpButtonTapped), for: .touchUpInside)
    }
    
    @objc func scrollDownButtonTapped() {
        if bottomLeftButton.imageView?.image == UIImage(named: "edit")  {
            print("Scrolling down button tapped!")
            // Action for button when scrolling down
        }
    }
    
    @objc func scrollUpButtonTapped() {
        if bottomLeftButton.imageView?.image == UIImage(named: "icon_up") {
            print("Scrolling up button tapped!")
            // Action for button when scrolling up
        }
        
    }
    
    func loadMorePosts() {
        guard !isLoading else { return }
        
        // Show loader for pagination
        activityIndicator.startAnimating()

        // Set isLoading to true to prevent multiple requests
        isLoading = true
        currentPage += 1 // Increment the page for the next batch of posts
        
        // Fetch posts for the next page
        fetchPostsWithAuth(page: currentPage) { result in
            switch result {
            case .success(let fetchedResponse):
                print("🎉 Successfully fetched more data.")
                
                // Check if fetchedResponse.data is non-empty
                if !fetchedResponse.data.isEmpty {
                    // Append new posts to the existing data
                    self.response?.data.append(contentsOf: fetchedResponse.data)
                    
                    DispatchQueue.main.async {
                        self.feedTableView.reloadData() // Reload the table view to display the new data
                    }
                }
            case .failure(let error):
                print("❌ Failed to fetch more data: \(error.localizedDescription)")
            }
            
            // Hide loader after data is fetched
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            // Set isLoading to false after the request completes
            self.isLoading = false
        }
    }

    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        task.resume()
    }
    
    func didTapLikeButton(cell: FeedPostTableViewCell) {
        guard let indexPath = feedTableView.indexPath(for: cell) else { return }
        let postId = cell.postId
        let grpId = cell.grpId
        let unlikedImage = UIImage(systemName: "hand.thumbsup")
        let likedImage = UIImage(systemName: "hand.thumbsup.fill")
        
        likePost(groupId: grpId!, postId: postId!) { [weak self] response in
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
