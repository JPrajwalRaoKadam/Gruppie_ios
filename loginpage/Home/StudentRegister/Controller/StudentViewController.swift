import UIKit

class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!

    var groupClasses: [GroupClass] = []
    var groupAcademicYearResponse: GroupAcademicYearResponse?
//    var studentTeams: [StudentTeam] = []
//    var filteredStudentTeams: [StudentTeam] = []
//    var combinedStudentTeams: [CombinedStudentTeam] = []
   // var token: String = ""

    
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
        heightConstraintOfSearchView.constant = 0
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        searchView.isHidden = true
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
       // filteredStudentTeams = studentTeams
        
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        StudentList.layer.cornerRadius = 10
        StudentList.layer.masksToBounds = true
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true

        
        segmentChanged()
        enableKeyboardDismissOnTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
        if shouldShow {
            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
            searchTextField?.placeholder = "Search..."
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchTextField?.backgroundColor = .white
            searchTextField?.layer.cornerRadius = 5
            searchTextField?.layer.borderWidth = 1
            searchTextField?.layer.borderColor = UIColor.gray.cgColor
            if let searchTextField = searchTextField {
                searchView.addSubview(searchTextField)
            }
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func AddButton(_ sender: Any) {
//        let actionSheet = UIAlertController(title: "Add Class", message: "Choose an option", preferredStyle: .actionSheet)
//        
//        let addRegularClassAction = UIAlertAction(title: "Add Regular class", style: .default) { _ in
//            self.fetchClassDataForRegularClass()
//        }
//        
//        let addCombinedClassAction = UIAlertAction(title: "Add Combined class", style: .default) { _ in
//            self.addCombinedClass()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        actionSheet.addAction(addRegularClassAction)
//        actionSheet.addAction(addCombinedClassAction)
//        actionSheet.addAction(cancelAction)
//        
//        self.present(actionSheet, animated: true, completion: nil)
//    }
    
//    func fetchClassDataForRegularClass() {
//        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/get/class/list") else {
//            print("❌ Invalid URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        print("🔍 Requesting: \(url)")
//        print("🔑 Auth Token: \(token)")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ Invalid response from server")
//                return
//            }
//
//            print("📡 Response Status Code: \(httpResponse.statusCode)")
//
//            guard let data = data else {
//                print("❌ No data received")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let response = try decoder.decode(ClassListResponse.self, from: data)
//
//                guard let firstClassData = response.data.first?.classes.first else {
//                    print("❌ No class data found")
//                    return
//                }
//
//                let classData = response.data.first?.classes ?? []
//                let classTypeId = firstClassData.classTypeId
//                let className = firstClassData.classList.first?.className ?? "Unknown"
//                DispatchQueue.main.async {
//                    self.navigateToAddRegularClass(
//                        withClassData: classData,
//                        classTypeId: classTypeId,
//                        className: className
//                    )
//                }
//            } catch {
//                print("❌ Error decoding JSON: \(error)")
//            }
//        }
//
//        task.resume()
//    }
    
    func navigateToAddRegularClass(withClassData classData: [ClassType], classTypeId: String, className: String) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass") as? AddRegularClass else {
            print("❌ Failed to instantiate AddRegularClass from Student.storyboard")
            return
        }

        addRegularClassVC.classData = classData
        addRegularClassVC.classTypeId = classTypeId
        addRegularClassVC.className = className
//        addRegularClassVC.groupId = groupIds
//        addRegularClassVC.token = token

        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
    }
    
    func addCombinedClass() {
//        print("✅ Adding Combined class")
//        
//        let storyboard = UIStoryboard(name: "Student", bundle: nil)
//        guard let addCombineClassVC = storyboard.instantiateViewController(withIdentifier: "AddCombineClass") as? AddCombineClass else {
//            print("❌ Failed to instantiate AddCombineClass from Student.storyboard")
//            return
//        }
//
//        addCombineClassVC.token = self.token
//        addCombineClassVC.groupIds = self.groupIds
//        
//        addCombineClassVC.studentTeams = self.studentTeams
//        addCombineClassVC.filteredStudentTeams = self.filteredStudentTeams
//        addCombineClassVC.combinedStudentTeams = self.combinedStudentTeams
//        
//        self.navigationController?.pushViewController(addCombineClassVC, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedGroupClass = groupClasses[indexPath.row]

        navigateToDetailViewController(
            classId: selectedGroupClass.id,
            groupAcademicYearId: selectedGroupClass.groupAcademicYearId,
            className: selectedGroupClass.name
        )
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupClasses.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RegularTableViewCell",
            for: indexPath
        ) as? RegularTableViewCell else {
            return UITableViewCell()
        }

        let groupClass = groupClasses[indexPath.row]

        cell.configure(
            name: groupClass.name,
            studentCount: groupClass.students.count
        )

        return cell
    }

    @objc func segmentChanged() {
        let selectedIndex = SegmentController.selectedSegmentIndex
        print("Segment changed to index: \(selectedIndex)")

        if selectedIndex == 1 {
           // fetchCombinedStudentTeams()
        }
        
        StudentList.reloadData()
    }

//    func fetchCombinedStudentTeams() {
//        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupIds)/class/get?type=combined") else { return }
//        print("API URL: \(url.absoluteString)")
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error fetching data: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let response = try decoder.decode(CombinedStudentTeamResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.combinedStudentTeams = response.data
//                    self.StudentList.reloadData()
//                }
//            } catch {
//                print("Error decoding data: \(error)")
//            }
//        }
//        
//        task.resume()
//    }

    func navigateToDetailViewController(
        classId: String,
        groupAcademicYearId: String,
        className: String
    ) {

        print("✅ classId passed:", classId)
        print("✅ groupAcademicYearId passed:", groupAcademicYearId)

        guard let detailVC = storyboard?
            .instantiateViewController(withIdentifier: "DetailViewController")
            as? DetailViewController else {
            return
        }

        detailVC.classId = classId
        detailVC.groupAcademicYearId = groupAcademicYearId
        detailVC.className = className

        navigationController?.pushViewController(detailVC, animated: true)
    }


//    func navigateToDetailViewController(
//        classId: String,
//        groupAcademicYearId: String,
//        className: String
//    ) {
//
//        //print("Passing groupIds from StudentViewController:", groupIds)
//
//        guard let detailVC = storyboard?
//            .instantiateViewController(withIdentifier: "DetailViewController")
//                as? DetailViewController else {
//            return
//        }
//
//        //detailVC.groupIds = groupIds
//        detailVC.classId = classId
//        detailVC.groupAcademicYearId = groupAcademicYearId
//        detailVC.className = className
//
//        navigationController?.pushViewController(detailVC, animated: true)
//    }


    
//    func filterMembers(textField: String) {
//        let searchText = textField.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if searchText.isEmpty {
//            filteredStudentTeams = studentTeams
//            StudentList.reloadData()
//            return
//        }
//        
//        if SegmentController.selectedSegmentIndex == 0 {
//            filteredStudentTeams = studentTeams.filter {
//            
//                $0.name.lowercased().contains(searchText.lowercased())
//            }
//        }
//        
//        StudentList.reloadData()
//    }
    func filterMembers(text: String) {
        if text.isEmpty {
            StudentList.reloadData()
            return
        }

        groupClasses = groupClasses.filter {
            $0.name.lowercased().contains(text.lowercased())
        }

        StudentList.reloadData()
    }

    
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    filterMembers(text: searchText)
    return true
}
}
