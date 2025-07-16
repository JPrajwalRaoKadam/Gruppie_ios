import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Gallery Loaded with Group ID: \(groupId) and Token: \(token).....\(currentRole)")
        
        
        if currentRole.lowercased() == "parent" || currentRole.lowercased() == "teacher" {
            addButton.isHidden = true
        } else if currentRole.lowercased() == "admin" {
            addButton.isHidden = false
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false // Allow table view and button interactions
        view.addGestureRecognizer(tapGesture)


        tableView.delegate = self
        tableView.dataSource = self

        
        CreateAlbum.layer.cornerRadius = 10
            CreateAlbum.layer.masksToBounds = true
        
        view1.isHidden = true
        view2.isHidden = true
        
        view2.layer.cornerRadius = 10
        view2.layer.masksToBounds = true

        view2.layer.shadowColor = UIColor.black.cgColor
        view2.layer.shadowOpacity = 0.3
        view2.layer.shadowOffset = CGSize(width: 0, height: 2)
        view2.layer.shadowRadius = 4
        view2.layer.masksToBounds = false

        tableView.register(UINib(nibName: "GalleryTableViewCell", bundle: nil), forCellReuseIdentifier: "GalleryCell")

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)

        fetchGalleryData()
        setupDatePicker()

    }
    @objc func handleOutsideTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)

        if !view2.isHidden && !view2.frame.contains(location) {
            view2.isHidden = true
            view1.isHidden = true
            self.view.endEditing(true)
        }
    }

    func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissDatePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        
        date.inputView = datePicker
        date.inputAccessoryView = toolbar
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        date.text = formatter.string(from: sender.date)
    }

    @objc func dismissDatePicker() {
        if let datePicker = date.inputView as? UIDatePicker {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            date.text = formatter.string(from: datePicker.date)
        }
        view.endEditing(true)
    }
    func fetchGalleryData() {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gallery/get?page=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

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
                self.albums = decodedResponse.data
                print("API Response GalleryVC: \(decodedResponse)")

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let albumToDelete = albums[indexPath.row]
                showDeleteConfirmation(album: albumToDelete, indexPath: indexPath)
            }
        }
    }

    func showDeleteConfirmation(album: AlbumData, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Album", message: "Are you sure you want to delete this album?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            self.deleteAlbum(album: album, indexPath: indexPath)
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func deleteAlbum(album: AlbumData, indexPath: IndexPath) {
        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/album/\(album.albumId)/delete"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error deleting album: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("✅ Album deleted successfully")

                // ✅ Remove album from the list
                DispatchQueue.main.async {
                    self.albums.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                print("❌ Failed to delete album. Status code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }
}

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count // Use API data count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath) as? GalleryTableViewCell else {
            return UITableViewCell()
        }

        let album = albums[indexPath.row]
        cell.albumName.text = album.albumName
        cell.Date.text = album.updatedAt
        
        let albumCount = albums[indexPath.row]
        print("Album count:\(albumCount.fileName?.count)")
        

        if let imageUrlString = album.fileName?.first, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        cell.ImageUrl.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            cell.ImageUrl.image = UIImage(named: "placeholder")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlbum = albums[indexPath.row] // Get the selected album
        let storyboard = UIStoryboard(name: "Gallery", bundle: nil)

        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailGalleryViewController") as? DetailGalleryViewController {
            detailVC.groupId = groupId
            detailVC.token = token
            detailVC.albumId = selectedAlbum.albumId
            detailVC.albumNameString = selectedAlbum.albumName
            detailVC.mediaItemsStrings = selectedAlbum.fileName ?? []
            detailVC.currentRole = currentRole
            print("Number of images in album: \(selectedAlbum.fileName?.count ?? 0)")

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let shouldShow = view1.isHidden 
        view1.isHidden = !shouldShow
        view2.isHidden = !shouldShow
    }
    @IBAction func createAlbumTapped(_ sender: UIButton) {
        guard let albumName = AlbumName.text, !albumName.isEmpty,
              let albumDate = date.text, !albumDate.isEmpty,
              let albumDescription = addDescription.text, !albumDescription.isEmpty else {
            print("⚠️ Please fill all fields before creating an album")
            return
        }

        let urlString = APIManager.shared.baseURL + "groups/\(groupId)/gallery/add"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let requestBody: [String: Any] = [
            "albumName": albumName,
            "date": albumDate,
            "description": albumDescription
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error encoding request body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error creating album: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }

            if httpResponse.statusCode == 201 {
                print("✅ Album created successfully")

                DispatchQueue.main.async {
                    self.AlbumName.text = ""
                    self.date.text = ""
                    self.addDescription.text = ""
                    
                    self.view1.isHidden = true
                    self.view2.isHidden = true
                    self.fetchGalleryData()
                }
            }
else {
                print("❌ Failed to create album. Status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}
