import UIKit

class SubDetailsVC: UIViewController, SubDetailsCellDelegate {

    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var classsubjName: UILabel!
    @IBOutlet weak var subTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var classId: String = ""
    var subjectId: String = ""
    var subjectName: String = ""
    var className: String = ""

    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var notesList: [NoteItem] = []

    var shouldRefreshData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        subTableView.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true

        subTableView.delegate = self
        subTableView.dataSource = self

        print("classId:", classId)
        print("subjectId:", subjectId)

        if let groupAcademicYearId = groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId {
            print("groupAcademicYearId:", groupAcademicYearId)
        }

        classsubjName.text = "\(subjectName) - (\(className))"

        subTableView.register(UINib(nibName: "SubDetailsTableViewCell", bundle: nil),
                              forCellReuseIdentifier: "SubDetailsTableViewCell")

        fetchNotes()
        enableKeyboardDismissOnTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldRefreshData {
            fetchNotes()
            shouldRefreshData = false
        }
    }
    
    func didTapDelete(at cell: SubDetailsTableViewCell) {

        guard let indexPath = subTableView.indexPath(for: cell) else { return }

        let note = notesList[indexPath.row]

        guard let noteId = note.noteId else { return }

        showDeleteAlert(noteId: noteId)
    }
    func showDeleteAlert(noteId: String) {

        let alert = UIAlertController(
            title: "Delete Note",
            message: "Are you sure you want to delete this note?",
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteNote(noteId: noteId)
        }

        alert.addAction(cancel)
        alert.addAction(delete)

        present(alert, animated: true)
    }
    func deleteNote(noteId: String) {
        
        guard let token = SessionManager.useRoleToken else {
            print("❌ Token missing")
            return
        }

        let endpoint = "notes/\(noteId)"

        APIManager.shared.request(
            endpoint: endpoint,
            method: .delete,
            headers: ["Authorization": "Bearer \(token)"]
        ) { (result: Result<DeleteNoteResponse, APIManager.APIError>) in

            switch result {

            case .success(let response):

                print("✅ Delete Success:", response)

                self.showMessage(response.message ?? "Note deleted successfully")

                self.fetchNotes()

            case .failure(let error):

                print("❌ Delete Error:", error)
            }
        }
    }
    func showMessage(_ message: String) {

        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
    
    func fetchNotes() {
        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        let queryParams: [String: String] = [
            "classId": classId,
            "subjectId": subjectId
        ]

        print("📤 Query Params:", queryParams)

        APIManager.shared.request(
            endpoint: "notes",
            method: .get,
            queryParams: queryParams,
            headers: ["Authorization": "Bearer \(roleToken)"]
        ) { (result: Result<NotesResponse, APIManager.APIError>) in

            switch result {
            case .success(let response):
                print("API Response:", response)
                
                // Filter notes to show only those matching current classId and subjectId
                let allNotes = response.data ?? []
                self.notesList = allNotes.filter { note in
                    return note.classId == self.classId && note.subjectId == self.subjectId
                }
                
                print("📊 Filtered notes count: \(self.notesList.count) out of \(allNotes.count)")
                
                DispatchQueue.main.async {
                    self.subTableView.reloadData()
                }

            case .failure(let error):
                print("❌ Notes API Error:", error)
            }
        }
    }
    // MARK: - Buttons

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addButton(_ sender: Any) {
        navigateToAddChapter()
    }

    func navigateToAddChapter() {

        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)

        if let vc = storyboard.instantiateViewController(withIdentifier: "AddChapterVC") as? AddChapterVC {

            vc.subjectId = subjectId
            vc.classId = classId
            vc.groupAcademicYearResponse = self.groupAcademicYearResponse
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TableView

extension SubDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func formatDate(_ isoDate: String) -> String {
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: isoDate) {
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy"
            
            return displayFormatter.string(from: date)
        }
        
        return ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubDetailsTableViewCell",
            for: indexPath) as? SubDetailsTableViewCell else {
            return UITableViewCell()
        }

        let topic = notesList[indexPath.row]

        cell.topicName.text = topic.title ?? "-"
        cell.descriptions.text = topic.description ?? "-"
        cell.createdOn.text = formatDate(topic.createdAt ?? "")
        cell.delegate = self
        // Date format
        if let createdAt = topic.createdAt {

            let isoFormatter = ISO8601DateFormatter()

            if let date = isoFormatter.date(from: createdAt) {

                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"

                cell.createdOn.text = formatter.string(from: date)
            }
        }

        // Remove previous views
        cell.datacontainer.subviews.forEach { $0.removeFromSuperview() }

        guard let firstAttachment = topic.attachmentLinks?.first,
              let fileUrl = firstAttachment.fileUrl,
              let url = URL(string: fileUrl) else {

            let label = UILabel(frame: cell.datacontainer.bounds)
            label.text = "No Attachment"
            label.textAlignment = .center
            cell.datacontainer.addSubview(label)
            return cell
        }

        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {

        case "png", "jpg", "jpeg":

            let imageView = UIImageView(frame: cell.datacontainer.bounds)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.load(url: fileUrl)

            cell.datacontainer.addSubview(imageView)

        case "mp4", "mov":

            let label = UILabel(frame: cell.datacontainer.bounds)
            label.text = "🎥 Video: \(url.lastPathComponent)"
            label.textAlignment = .center
            label.textColor = .systemRed

            cell.datacontainer.addSubview(label)

        case "mp3", "wav":

            let label = UILabel(frame: cell.datacontainer.bounds)
            label.text = "🎵 Audio: \(url.lastPathComponent)"
            label.textAlignment = .center
            label.textColor = .systemGreen

            cell.datacontainer.addSubview(label)

        case "pdf":

            let imageView = UIImageView(image: UIImage(named: "defaultpdf"))
            imageView.frame = cell.datacontainer.bounds
            imageView.contentMode = .scaleAspectFit

            cell.datacontainer.addSubview(imageView)

        default:

            let label = UILabel(frame: cell.datacontainer.bounds)
            label.text = "📎 File: \(url.lastPathComponent)"
            label.textAlignment = .center

            cell.datacontainer.addSubview(label)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "VideoPlayerVC"
        ) as? VideoPlayerVC else {
            print("❌ VideoPlayerVC not found in storyboard")
            return
        }
        
        vc.mediaURL = notesList[indexPath.row].attachmentLinks?[indexPath.row].fileUrl
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapDownload(at cell: SubDetailsTableViewCell) {

        guard let indexPath = subTableView.indexPath(for: cell) else { return }

        let note = notesList[indexPath.row]

        guard let fileUrl = note.attachmentLinks?.first?.fileUrl,
              let url = URL(string: fileUrl) else {
            print("❌ Invalid URL")
            return
        }

        print("Opening:", url)

        UIApplication.shared.open(url)
    }
}

// MARK: - Image Loader

extension UIImageView {

    func load(url: String) {

        guard let imageURL = URL(string: url) else { return }

        URLSession.shared.dataTask(with: imageURL) { data, _, _ in

            if let data = data {

                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }

        }.resume()
    }
}
