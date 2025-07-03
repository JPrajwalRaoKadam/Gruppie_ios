import UIKit
import SDWebImage

class GalleryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var AlbumName: UITextField!
    @IBOutlet weak var CreateAlbum: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var addDescription: UITextField!

    var currentRole: String = ""
    var groupId: String = ""
    var token: String = ""

    var albums: [AlbumData] = []
    var isLoading = false
    var currentPage = 1
    var totalPages = 1

    let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery Loaded with Group ID: \(groupId) and Token: \(token).....\(currentRole)")

        addButton.isHidden = currentRole.lowercased() != "admin"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.register(UINib(nibName: "GalleryTableViewCell", bundle: nil), forCellReuseIdentifier: "GalleryCell")

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
        tableView.addGestureRecognizer(longPressGesture)

        setupDatePicker()
        setupLoadingSpinner()
        fetchGalleryData(page: currentPage)
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

    func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.setItems([.flexibleSpace(), UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissDatePicker))], animated: false)

        date.inputView = datePicker
        date.inputAccessoryView = toolbar
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        date.text = formatter.string(from: sender.date)
    }

    @objc func dismissDatePicker() {
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
                    let startIndex = self.albums.count
                    self.albums += decodedResponse.data

                    var indexPaths: [IndexPath] = []
                    for i in 0..<decodedResponse.data.count {
                        indexPaths.append(IndexPath(row: startIndex + i, section: 0))
                    }

                    self.tableView.insertRows(at: indexPaths, with: .fade)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                showDeleteConfirmation(album: albums[indexPath.row], indexPath: indexPath)
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
                self.albums.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }.resume()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let show = view1.isHidden
        view1.isHidden = !show
        view2.isHidden = !show
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

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath) as? GalleryTableViewCell else {
            return UITableViewCell()
        }

        let album = albums[indexPath.row]
        cell.albumName.text = album.albumName
        cell.Date.text = album.updatedAt

        if let urlStr = album.fileName?.first, let url = URL(string: urlStr) {
            cell.ImageUrl.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "placeholder"),
                options: [.scaleDownLargeImages, .continueInBackground, .highPriority]
            )
        } else {
            cell.ImageUrl.image = UIImage(named: "placeholder")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        if position > contentHeight - scrollView.frame.size.height * 1.5 {
            if currentPage < totalPages {
                currentPage += 1
                fetchGalleryData(page: currentPage)
            }
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row < albums.count,
               let urlStr = albums[indexPath.row].fileName?.first,
               let url = URL(string: urlStr) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
    }
}

