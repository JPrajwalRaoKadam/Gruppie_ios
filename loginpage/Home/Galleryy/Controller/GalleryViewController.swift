import UIKit
import SDWebImage

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var AlbumName: UITextField!
    @IBOutlet weak var CreateAlbum: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var addDescription: UITextField!
    @IBOutlet weak var backButton: UIButton!

    var currentRole: String = ""
    var groupId: String = ""
    var token: String = ""

    var albums: [AlbumData] = []
    var isLoading = false
    var currentPage = 1
    var totalPages = 1

    let spinner = UIActivityIndicatorView(style: .large)
    private var datePicker: UIDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery Loaded with Group ID: \(groupId) and Token: \(token).....\(currentRole)")

        addButton.isHidden = currentRole.lowercased() != "admin"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(UINib(nibName: "GalleryCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionCell")

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 6
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }

        CreateAlbum.layer.cornerRadius = 10
        view1.isHidden = true
        view2.isHidden = true

        view2.layer.cornerRadius = 10
        view2.layer.shadowColor = UIColor.black.cgColor
        view2.layer.shadowOpacity = 0.3
        view2.layer.shadowOffset = CGSize(width: 0, height: 2)
        view2.layer.shadowRadius = 4
        view2.layer.masksToBounds = false

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)

        setupDatePicker()
        setupLoadingSpinner()
        fetchGalleryData(page: currentPage)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }

    func setupLoadingSpinner() {
        spinner.center = view.center
        view.addSubview(spinner)
    }

    @objc func handleOutsideTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !view2.isHidden && !view2.frame.contains(location) {
            view1.isHidden = true
            view2.isHidden = true
            view.endEditing(true)
        }
    }

    // MARK: - Date Picker Setup
    func setupDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date() // optional: prevents future dates
        picker.locale = Locale(identifier: "en_IN")
        picker.timeZone = .current
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissDatePicker))
        let space = UIBarButtonItem.flexibleSpace()
        toolbar.setItems([space, doneButton], animated: false)

        date.inputView = picker
        date.inputAccessoryView = toolbar
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.timeZone = .current
        date.text = formatter.string(from: sender.date)
    }

    @objc func dismissDatePicker() {
        if let picker = datePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.locale = Locale(identifier: "en_IN")
            formatter.timeZone = .current
            date.text = formatter.string(from: picker.date)
        }
        view.endEditing(true)
    }

    func fetchGalleryData(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        spinner.startAnimating()

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gallery/get?page=\(page)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }

            self.isLoading = false

            if let error = error {
                print("Error fetching gallery data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(AlbumResponse.self, from: data)
                self.totalPages = decodedResponse.totalNumberOfPages

                DispatchQueue.main.async {
                    let newAlbums = decodedResponse.data

                    if self.currentPage == 1 {
                        self.albums = newAlbums
                        self.collectionView.reloadData()
                        return
                    }

                    let startIndex = self.albums.count
                    self.albums += newAlbums

                    let newIndexPaths = (startIndex..<self.albums.count).map {
                        IndexPath(item: $0, section: 0)
                    }

                    if self.collectionView.window != nil && !newIndexPaths.isEmpty {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: newIndexPaths)
                        }, completion: nil)
                    } else {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }


    // MARK: - Delete Album
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                showDeleteConfirmation(album: albums[indexPath.item], indexPath: indexPath)
            }
        }
    }

    func showDeleteConfirmation(album: AlbumData, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Album", message: "Are you sure you want to delete this album?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAlbum(album: album, indexPath: indexPath)
        }))
        present(alert, animated: true)
    }

    func deleteAlbum(album: AlbumData, indexPath: IndexPath) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(album.albumId)/delete"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }

            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Failed to delete album")
                return
            }

            DispatchQueue.main.async {
                self.albums.remove(at: indexPath.item)
                self.collectionView.deleteItems(at: [indexPath])
            }
        }.resume()
    }

    // MARK: - Buttons
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let show = view1.isHidden
        view1.isHidden = !show
        view2.isHidden = !show
        
        // set current date when view2 opens
        if !view2.isHidden {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            date.text = formatter.string(from: Date())
        }
    }

    @IBAction func createAlbumTapped(_ sender: UIButton) {
        guard let name = AlbumName.text, !name.isEmpty,
              let albumDate = date.text, !albumDate.isEmpty,
              let desc = addDescription.text, !desc.isEmpty else {
            print("⚠️ Please fill all fields")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gallery/add"
        guard let url = URL(string: urlString) else { return }

        let body: [String: Any] = [
            "albumName": name,
            "date": albumDate,
            "description": desc
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                print("❌ Failed to create album")
                return
            }

            DispatchQueue.main.async {
                self.AlbumName.text = ""
                self.date.text = ""
                self.addDescription.text = ""
                self.view1.isHidden = true
                self.view2.isHidden = true
                self.albums.removeAll()
                self.currentPage = 1
                self.fetchGalleryData(page: self.currentPage)
            }
        }.resume()
    }
}

// MARK: - Collection View Delegates
extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionCell", for: indexPath) as? GalleryCollectionCell else {
            return UICollectionViewCell()
        }

        let album = albums[indexPath.item]
        cell.albumName.text = album.albumName
        
        let imageCount = album.fileName?.count ?? 0
        cell.imageCountLabel.text = "\(imageCount)"

        if let urlStr = album.fileName?.first, let url = URL(string: urlStr) {
            cell.albumImage.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "placeholder"),
                options: [.scaleDownLargeImages, .continueInBackground, .highPriority]
            )
        } else {
            cell.albumImage.image = UIImage(named: "placeholder")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.item]
        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailGalleryViewController") as? DetailGalleryViewController {
            detailVC.groupId = groupId
            detailVC.token = token
            detailVC.albumId = album.albumId
            detailVC.albumNameString = album.albumName
            detailVC.mediaItemsStrings = album.fileName ?? []
            detailVC.currentRole = currentRole
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.item < albums.count,
               let urlStr = albums[indexPath.item].fileName?.first,
               let url = URL(string: urlStr) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        if position > contentHeight - scrollView.frame.size.height * 1.5 {
            if currentPage < totalPages {
                currentPage += 1
                fetchGalleryData(page: currentPage)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 6 * 3
        let width = (collectionView.frame.width - padding) / 2
        return CGSize(width: width, height: width * 1.05)
    }
}
