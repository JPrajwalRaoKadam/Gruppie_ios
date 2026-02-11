//
//  AddFeedVC.swift
//  loginpage
//

import UIKit

class AddFeedVC: UIViewController,
                UITableViewDelegate,
                UITableViewDataSource,
                AddFeedInfoCellDelegate {

    // MARK: - Outlets

    @IBOutlet weak var addFeedTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    // MARK: - Properties

    var postName: String = ""
    var postDescription: String?
    var documentURL: URL?

    var selectedIndexPath: IndexPath?

    var groupID: String?

    var currentPage = 1
    var isLoading = false

    public var teamPosts: [GroupClass] = []
    public var pagination: Pagination?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTeams()
    }

    // MARK: - UI Setup

    private func setupUI() {

        addFeedTableView.layer.cornerRadius = 10

        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true

        submitButton.layer.cornerRadius = 10

        addFeedTableView.register(UINib(nibName: "AddFeedInfoTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "AddFeedInfoTableViewCell")

        addFeedTableView.register(UINib(nibName: "ClassTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "ClassTableViewCell")

        addFeedTableView.delegate = self
        addFeedTableView.dataSource = self

        addFeedTableView.rowHeight = UITableView.automaticDimension
        addFeedTableView.estimatedRowHeight = 100

        enableKeyboardDismissOnTap()
    }

    // MARK: - Actions

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitAction(_ sender: Any) {

        guard !postName.isEmpty else {
            showAlert(title: "Error", message: "Enter title")
            return
        }

        guard let body = postDescription, !body.isEmpty else {
            showAlert(title: "Error", message: "Enter description")
            return
        }

        guard let selectedIndexPath else {
            showAlert(title: "Error", message: "Select team")
            return
        }

        guard let token = SessionManager.useRoleToken else {
            showAlert(title: "Error", message: "Token missing")
            return
        }

        showLoading()

        // -------------------------
        // Base params
        // -------------------------
        var params: [String: String] = [

            "postType": "team",
            "classId": "12",
            "fromUserId": "1",
            "toUserId": "40",

            "title": postName,
            "body": body,

            "shareInternal": "true",
            "shareExternal": "false"
        ]

        // -------------------------
        // ✅ FIXED SELECTION LOGIC
        // -------------------------
        let row = selectedIndexPath.row

        if row == 0 {

            print("📌 Posting to NOTICE BOARD")

            params["postType"] = "group"
            params["teamId"] = nil

        } else if row - 1 < teamPosts.count {

            let team = teamPosts[row - 1]

            print("📌 Posting to TEAM:", team.name ?? "")
            print("📌 Team ID:", team.id)

            params["teamId"] = team.id
        }

        var files: [URL] = []

        // -------------------------
        // Handle attachment
        // -------------------------
        if let url = documentURL {

            let urlString = url.absoluteString.lowercased()

            if urlString.contains("youtube.com") ||
               urlString.contains("youtu.be") {

                print("🎥 YouTube URL:", url.absoluteString)

                params["videoUrl"] = url.absoluteString
                params["hasAttachments"] = "false"

            } else {

                let mime = url.mimeType()

                print("📎 File Selected:", url.lastPathComponent)
                print("📎 MIME Type:", mime)

                if mime.contains("video") ||
                   mime.contains("image") ||
                   mime.contains("pdf") ||
                   mime.contains("audio") {

                    files.append(url)
                    params["hasAttachments"] = "true"

                } else {
                    hideLoading()
                    showAlert(title: "Error", message: "Invalid file type")
                    return
                }
            }

        } else {
            params["hasAttachments"] = "false"
        }

        // -------------------------
        // ✅ PRINT FULL PAYLOAD
        // -------------------------
        print("\n==============================")
        print("🚀 FINAL POST PAYLOAD")
        print("==============================")
        print("📄 Params:")
        params.forEach { print("\($0.key): \($0.value)") }

        print("\n📎 Files:")
        if files.isEmpty {
            print("No Attachments")
        } else {
            files.forEach { print($0.lastPathComponent) }
        }
        print("==============================\n")

        // -------------------------
        // Upload
        // -------------------------
        uploadMultipart(token: token,
                        params: params,
                        files: files) { [weak self] (result: Result<String, Error>) in

            guard let self else { return }

            self.hideLoading()

            switch result {

            case .success(let response):

                print("✅ Server Response:", response)
                self.showSuccessAndDismiss()

            case .failure(let error):

                print("❌ Error:", error.localizedDescription)

                self.showAlert(title: "Failed",
                               message: error.localizedDescription)
            }
        }
    }

    // MARK: - Load Teams

    func loadTeams() {

        guard !isLoading else { return }

        isLoading = true

        fetchTeams { [weak self] teams in
            guard let self else { return }
            self.teamPosts = teams
            self.isLoading = false
            self.addFeedTableView.reloadData()
        }
    }

    // MARK: - Fetch Teams

    func fetchTeams(completion: @escaping ([GroupClass]) -> Void) {

        APIManager.shared.getGroupClasses(page: 1, limit: 10) { result in

            switch result {

            case .success(let response):
                DispatchQueue.main.async {
                    completion(response.data)
                }

            case .failure(let error):
                print("❌ API Error:", error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : teamPosts.count + 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddFeedInfoTableViewCell",
                for: indexPath
            ) as! AddFeedInfoTableViewCell

            cell.delegate = self
            cell.parentViewController = self
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ClassTableViewCell",
            for: indexPath
        ) as! ClassTableViewCell

        if indexPath.row == 0 {
            cell.classLabel.text = "Notice Board"
        } else {
            let team = teamPosts[indexPath.row - 1]
            cell.configure(teamPost: team)
        }

        let selected = selectedIndexPath == indexPath

        cell.checkBox.setImage(
            UIImage(systemName: selected
                    ? "checkmark.rectangle.fill"
                    : "rectangle"),
            for: .normal
        )

        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self,
                                action: #selector(checkboxTapped(_:)),
                                for: .touchUpInside)

        return cell
    }

    // MARK: - Checkbox

    @objc func checkboxTapped(_ sender: UIButton) {

        let indexPath = IndexPath(row: sender.tag, section: 1)

        selectedIndexPath = (selectedIndexPath == indexPath)
        ? nil : indexPath

        addFeedTableView.reloadSections(IndexSet(integer: 1),
                                       with: .automatic)
    }

    // MARK: - Delegates

    func assignPostName(postName: String) { self.postName = postName }
    func assignPostDescription(postDescription: String) { self.postDescription = postDescription }
    func assignFinalUrl(finalUrl: URL) { self.documentURL = finalUrl }

    // MARK: - Helpers

    private func showLoading() {

        let alert = UIAlertController(title: nil,
                                      message: "Posting...",
                                      preferredStyle: .alert)

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        alert.view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])

        present(alert, animated: true)
    }

    private func hideLoading() { dismiss(animated: true) }

    private func showSuccessAndDismiss() {

        showAlert(title: "Success", message: "Post created") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(title: String,
                           message: String,
                           completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default) { _ in completion?() })

        present(alert, animated: true)
    }
    
    func uploadMultipart(
        token: String,
        params: [String: String],
        files: [URL],
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "https://dev.gruppie.in/api/v1/posts")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        request.timeoutInterval = 300

        var body = Data()

        for (key, value) in params {

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        for fileURL in files {

            let fileName = fileURL.lastPathComponent
            let mimeType = fileURL.mimeType()

            guard let fileData = try? Data(contentsOf: fileURL) else { continue }

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"attachments\"; filename=\"\(fileName)\"\r\n")
            body.appendString("Content-Type: \(mimeType)\r\n\r\n")

            body.append(fileData)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else { return }

            let result = String(decoding: data, as: UTF8.self)

            print("📩 Server Response:", result)

            DispatchQueue.main.async {
                completion(.success(result))
            }

        }.resume()
    }

}

import MobileCoreServices

extension URL {

    func mimeType() -> String {

        let pathExtension = self.pathExtension as NSString

        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                pathExtension,
                nil
            )?.takeRetainedValue(),

            let mimeType = UTTypeCopyPreferredTagWithClass(
                uti,
                kUTTagClassMIMEType
            )?.takeRetainedValue()
        else {
            return "application/octet-stream"
        }

        return mimeType as String
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension OutputStream {

    func writeString(_ string: String) {

        if let data = string.data(using: .utf8) {

            data.withUnsafeBytes {
                write(
                    $0.bindMemory(to: UInt8.self).baseAddress!,
                    maxLength: data.count
                )
            }
        }
    }
}
