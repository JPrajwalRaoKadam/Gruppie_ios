import UIKit

class SubjectNotes_VideosHWVC: UIViewController {

    func didAddSubject() {
        fetchSubjectRegister()
    }

    @IBOutlet weak var bcbutton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var subTableView: UITableView!

    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var clsName: String = ""
    var classId: String = ""
    var subjectId: String = ""

    // Direct API model
    var subjects: [SubjectRegisterSubjectDetail] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        subTableView.delegate = self
        subTableView.dataSource = self
        subTableView.layer.cornerRadius = 10

        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true
        subTableView.register(
            UINib(nibName: "SubjectNotes_videosHWTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SubjectNotes_videosHWTableViewCell"
        )

        className.text = clsName
        enableKeyboardDismissOnTap()

        fetchSubjectRegister()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addSubjectNV(_ sender: Any) {
        navigateToAddSubjectVC()
    }

    func navigateToAddSubjectVC() {

        let storyboard = UIStoryboard(name: "Notes_VideosVC", bundle: nil)

        if let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddSubNotes_VideosVC"
        ) as? AddSubNotes_VideosVC {

            addVC.className = self.clsName

            self.navigationController?.pushViewController(addVC, animated: true)
        }
    }

    // MARK: - API

    func fetchSubjectRegister() {

        guard let roleToken = SessionManager.useRoleToken else {
            print("❌ Role token missing")
            return
        }

        guard let groupAcademicYearId =
                groupAcademicYearResponse?.data.academicYears.first?.groupAcademicYearId else {
            print("❌ groupAcademicYearId not available")
            return
        }

        if classId.isEmpty {
            print("❌ classId missing")
            return
        }

        let headers = [
            "Authorization": "Bearer \(roleToken)"
        ]

        let queryParams = [
            "groupAcademicYearId": groupAcademicYearId,
            "classId": classId,
            "page": "1",
            "limit": "300"
        ]

        APIManager.shared.request(
            endpoint: "subject-register",
            method: .get,
            queryParams: queryParams,
            headers: headers
        ) { (result: Result<SubjectRegisterAPIResponse, APIManager.APIError>) in

            switch result {

            case .success(let response):

                var allSubjects: [SubjectRegisterSubjectDetail] = []

                for group in response.data.subjectGroups {
                    allSubjects.append(contentsOf: group.subjects)
                }

                DispatchQueue.main.async {
                    self.subjects = allSubjects
                    self.subTableView.reloadData()
                }

            case .failure(let error):
                print("❌ subject-register error :", error)
            }
        }
    }
}

// MARK: - TableView

extension SubjectNotes_VideosHWVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubjectNotes_videosHWTableViewCell",
            for: indexPath
        ) as? SubjectNotes_videosHWTableViewCell else {
            return UITableViewCell()
        }

        let subject = subjects[indexPath.row]
        cell.configure(with: subject)

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let selectedSubject = subjects[indexPath.row]

        let storyboard = UIStoryboard(name: "HomeWork", bundle: nil)

        if let homeworkDetailVC = storyboard.instantiateViewController(
            withIdentifier: "HomeworkDetailVC"
        ) as? HomeworkDetailVC {

            homeworkDetailVC.className = self.clsName
            homeworkDetailVC.classId = classId
            homeworkDetailVC.subjectId = String(selectedSubject.subjectId)
            homeworkDetailVC.subjectName = selectedSubject.subjectName
            homeworkDetailVC.groupAcademicYearResponse = self.groupAcademicYearResponse

            self.navigationController?.pushViewController(homeworkDetailVC, animated: true)
        }
    }
}
