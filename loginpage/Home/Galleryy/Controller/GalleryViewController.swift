import UIKit
import SDWebImage

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var roleName: String?
    var fullAccess: Bool?
    var token: String = ""

    var albums: [AlbumData] = []
    var isLoading = false
    var currentPage = 1
    var totalPages = 1

    let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        print("📂 Gallery VC Loaded")
        print("Current Role in GalleryVC: '\(roleName)'  .....  \(fullAccess)")
        
        // Hide addButton ONLY for student role, show for all other roles
        
        if fullAccess == false {
            addButton.isHidden = true
        }
        
//        let roleToCheck = roleName?.uppercased()
//        addButton.isHidden = ["STUDENT", "TEACHER"].contains(roleToCheck)
        
//        print("Role to check: '\(roleToCheck)'")
        print("Add button is hidden: \(addButton.isHidden)")

        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self

        collectionView.register(
            UINib(nibName: "GalleryCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "GalleryCollectionCell"
        )

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 6
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        collectionView.addGestureRecognizer(longPressGesture)

        setupLoadingSpinner()
        fetchAlbumList(page: currentPage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Double-check button visibility when view appears
        // Hide addButton ONLY for student role, show for all other roles
        
        if fullAccess == false {
            addButton.isHidden = true
        }
        
//        let roleToCheck = roleName?.uppercased()
//        addButton.isHidden = ["STUDENT", "TEACHER"].contains(roleToCheck)
        print("viewWillAppear - Add button is hidden: \(addButton.isHidden)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    func setupLoadingSpinner() {
        spinner.center = view.center
        view.addSubview(spinner)
    }

    func fetchAlbumList(page: Int) {
        guard !isLoading else { return }

        guard let token = SessionManager.useRoleToken else {
            print("Token\(token) ")

            print("❌ Token missing")
            return
        }
        self.token = token

        isLoading = true
        spinner.startAnimating()

        let apiUrlString = APIManager.shared.baseURL + "gallery/albums/list?page=\(page)"
        guard let url = URL(string: apiUrlString) else {
            print("❌ Invalid URL:", apiUrlString)
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
            self.isLoading = false

            if let error = error {
                print("❌ Network Error:", error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }

            print("📡 Status Code:", httpResponse.statusCode)
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ API failed with status:", httpResponse.statusCode)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📥 Raw Album Response:\n", raw)
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AlbumResponse.self, from: data)
                
                self.totalPages = response.meta.totalPages

                DispatchQueue.main.async {
                    if page == 1 {
                        self.albums = response.data
                        self.collectionView.reloadData()
                    } else {
                        let startIndex = self.albums.count
                        self.albums.append(contentsOf: response.data)

                        let indexPaths = (startIndex..<self.albums.count).map {
                            IndexPath(item: $0, section: 0)
                        }

                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: indexPaths)
                        })
                    }
                }

            } catch {
                print("❌ Decoding Error:", error)
            }


        }.resume()
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Only allow long press for non-student roles
        guard roleName != "STUDENT" else {
            print("Students cannot delete albums")
            return
        }
        
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                showDeleteConfirmation(album: albums[indexPath.item], indexPath: indexPath)
            }
        }
    }

    func showDeleteConfirmation(album: AlbumData, indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Album",
            message: "Are you sure you want to delete this album?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive) { _ in
            self.deleteAlbum(album: album, indexPath: indexPath)
        })
        present(alert, animated: true)
    }
    
    func deleteAlbum(album: AlbumData, indexPath: IndexPath) {
        
        let urlString = APIManager.shared.baseURL + "gallery/albums/delete"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // ✅ Request Body
        let body: [String: Any] = [
            "ids": [album.albumId]   // sending selected album id inside array
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Failed to encode delete body:", error)
            return
        }
        
        print("📡 DELETE API:", urlString)
        print("📤 BODY:", body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Network Error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }
            
            print("📡 Status Code:", httpResponse.statusCode)
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Delete failed with status:", httpResponse.statusCode)
                return
            }
            
            DispatchQueue.main.async {
                self.albums.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
            }
            
        }.resume()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
        if let addVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController {
            addVC.token = token
            navigationController?.pushViewController(addVC, animated: true)
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout,
                                 UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {
            if indexPath.item < albums.count,
               let urlStr = albums[indexPath.item].fileName?.first,
               let url = URL(string: urlStr) {

                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GalleryCollectionCell",
            for: indexPath
        ) as! GalleryCollectionCell

        let album = albums[indexPath.item]
        cell.albumName.text = album.albumName
        cell.imageCountLabel.text = "\(album.fileName?.count ?? 0)"

        if let urlStr = album.fileName?.first,
           let url = URL(string: urlStr) {
            cell.albumImage.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "placeholder")
            )
        } else {
            cell.albumImage.image = UIImage(named: "placeholder")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let album = albums[indexPath.item]

        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)

        if let detailVC = storyboard.instantiateViewController(
            withIdentifier: "DetailGalleryViewController"
        ) as? DetailGalleryViewController {

            detailVC.albumId = album.albumId
            detailVC.albumNameString = album.albumName
            detailVC.mediaItemsStrings = album.fileName ?? []
            detailVC.token = self.token
            detailVC.fullAccess = self.fullAccess
            detailVC.currentRole = self.roleName ?? ""  // ✅ Role is passed to detail VC
            
            print("📤 Navigating to DetailGalleryViewController with role: \(self.roleName)")
            print("   Album: \(album.albumName)")

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = collectionView.contentSize.height

        if position > contentHeight - scrollView.frame.height * 1.5 {
            if currentPage < totalPages {
                currentPage += 1
                fetchAlbumList(page: currentPage)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 18
        let width = (collectionView.frame.width - padding) / 2
        return CGSize(width: width, height: width * 1.05)
    }
}
