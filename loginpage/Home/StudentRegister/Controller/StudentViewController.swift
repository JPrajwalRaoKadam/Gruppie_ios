import UIKit

//class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
//    
//    @IBOutlet weak var StudentList: UITableView!
//    @IBOutlet weak var SegmentController: UISegmentedControl!
//    @IBOutlet weak var searchButton: UIButton!
//    @IBOutlet weak var searchView: UIView!
//    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
//    @IBOutlet weak var backButton: UIButton!
//
//    var groupClasses: [GroupClass] = []
//    var filteredGroupClasses: [GroupClass] = []
//    var groupAcademicYearResponse: GroupAcademicYearResponse?
//    var searchTextField: UITextField?
//    var searchButtonTapped = false
//    var isSearching = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        filteredGroupClasses = groupClasses
//        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
//        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
//        heightConstraintOfSearchView.constant = 0
//        
//        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
//        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
//        
//        StudentList.delegate = self
//        StudentList.dataSource = self
//        
//        searchView.isHidden = true
//        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
//       // filteredStudentTeams = studentTeams
//        
//        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
//        
//        StudentList.layer.cornerRadius = 10
//        StudentList.layer.masksToBounds = true
//        
//        backButton.layer.cornerRadius = backButton.frame.size.height / 2
//        backButton.clipsToBounds = true
//        backButton.layer.masksToBounds = true
//
//        
//        segmentChanged()
//        enableKeyboardDismissOnTap()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        backButton.layer.cornerRadius = backButton.frame.size.height / 2
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        filteredGroupClasses = groupClasses
//        StudentList.reloadData()
//    }
//    
//    @objc func searchButtonTappedAction() {
//        let shouldShow = searchView.isHidden
//        searchView.isHidden = !shouldShow
//        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0
//
//        view.layoutIfNeeded()   // 🔥 ADD THIS
//
//        if shouldShow {
//            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
//            searchTextField?.placeholder = "Search..."
//            searchTextField?.delegate = self
//            searchTextField?.borderStyle = .roundedRect
//
//            if let searchTextField = searchTextField {
//                searchView.addSubview(searchTextField)
//            }
//
//            view.bringSubviewToFront(searchView) // 🔥 IMPORTANT
//        } else {
//            searchTextField?.removeFromSuperview()
//            searchTextField = nil
//        }
//    }
//    
//    @IBAction func backButton(_ sender: UIButton) {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    func navigateToAddRegularClass(withClassData classData: [ClassType], classTypeId: String, className: String) {
//        let storyboard = UIStoryboard(name: "Student", bundle: nil)
//        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass") as? AddRegularClass else {
//            print("❌ Failed to instantiate AddRegularClass from Student.storyboard")
//            return
//        }
//
//        addRegularClassVC.classData = classData
//        addRegularClassVC.classTypeId = classTypeId
//        addRegularClassVC.className = className
////        addRegularClassVC.groupId = groupIds
////        addRegularClassVC.token = token
//
//        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
//    }
//    
//    func addCombinedClass() {
////        print("✅ Adding Combined class")
////        
////        let storyboard = UIStoryboard(name: "Student", bundle: nil)
////        guard let addCombineClassVC = storyboard.instantiateViewController(withIdentifier: "AddCombineClass") as? AddCombineClass else {
////            print("❌ Failed to instantiate AddCombineClass from Student.storyboard")
////            return
////        }
////
////        addCombineClassVC.token = self.token
////        addCombineClassVC.groupIds = self.groupIds
////        
////        addCombineClassVC.studentTeams = self.studentTeams
////        addCombineClassVC.filteredStudentTeams = self.filteredStudentTeams
////        addCombineClassVC.combinedStudentTeams = self.combinedStudentTeams
////        
////        self.navigationController?.pushViewController(addCombineClassVC, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Tapped row:", indexPath.row)
//
//        view.endEditing(true) // 🔥 dismiss keyboard
//
//        let selectedGroupClass = filteredGroupClasses[indexPath.row]
//
//        navigateToDetailViewController(
//            classId: selectedGroupClass.id,
//            groupAcademicYearId: selectedGroupClass.groupAcademicYearId,
//            className: selectedGroupClass.name
//        )
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredGroupClasses.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "RegularTableViewCell",
//            for: indexPath
//        ) as? RegularTableViewCell else {
//            return UITableViewCell()
//        }
//
//        let groupClass = filteredGroupClasses[indexPath.row]
//
//        cell.configure(
//            name: groupClass.name,
//            studentCount: groupClass.students.count
//        )
//
//        return cell
//    }
//
//    @objc func segmentChanged() {
//        let selectedIndex = SegmentController.selectedSegmentIndex
//        print("Segment changed to index: \(selectedIndex)")
//
//        if selectedIndex == 1 {
//           // fetchCombinedStudentTeams()
//        }
//        
//        StudentList.reloadData()
//    }
//
//    func navigateToDetailViewController(
//        classId: String,
//        groupAcademicYearId: String,
//        className: String
//    ) {
//
//        print("✅ classId passed:", classId)
//        print("✅ groupAcademicYearId passed:", groupAcademicYearId)
//
//        guard let detailVC = storyboard?
//            .instantiateViewController(withIdentifier: "DetailViewController")
//            as? DetailViewController else {
//            return
//        }
//
//        detailVC.classId = classId
//        detailVC.groupAcademicYearId = groupAcademicYearId
//        detailVC.className = className
//
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//    
//    func filterMembers(text: String) {
//        let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if searchText.isEmpty {
//            filteredGroupClasses = groupClasses   // reset
//        } else {
//            filteredGroupClasses = groupClasses.filter {
//                $0.name.lowercased().contains(searchText.lowercased())
//            }
//        }
//
//        StudentList.reloadData()
//    }
//    
//func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//    filterMembers(text: searchText)
//    return true
//}
//}
class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var StudentList: UITableView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightConstraintOfSearchView: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!

    var groupClasses: [GroupClass] = []
    var filteredGroupClasses: [GroupClass] = []
    var groupAcademicYearResponse: GroupAcademicYearResponse?
    var searchTextField: UITextField?
    var searchButtonTapped = false
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredGroupClasses = groupClasses
        let regularNib = UINib(nibName: "RegularTableViewCell", bundle: nil)
        let combineNib = UINib(nibName: "CombineTableViewCell", bundle: nil)
        heightConstraintOfSearchView.constant = 0
        
        StudentList.register(regularNib, forCellReuseIdentifier: "RegularTableViewCell")
        StudentList.register(combineNib, forCellReuseIdentifier: "CombineTableViewCell")
        
        StudentList.delegate = self
        StudentList.dataSource = self
        
        searchView.isHidden = true
        searchButton.addTarget(self, action: #selector(searchButtonTappedAction), for: .touchUpInside)
       
        SegmentController.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        StudentList.layer.cornerRadius = 10
        StudentList.layer.masksToBounds = true
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        backButton.clipsToBounds = true
        backButton.layer.masksToBounds = true
        
        segmentChanged()
        enableKeyboardDismissOnTap()
        
        // Add tap gesture to dismiss keyboard and handle selection properly
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filteredGroupClasses = groupClasses
        StudentList.reloadData()
    }
    
    @objc func searchButtonTappedAction() {
        let shouldShow = searchView.isHidden
        searchView.isHidden = !shouldShow
        heightConstraintOfSearchView.constant = shouldShow ? 47 : 0

        view.layoutIfNeeded()

        if shouldShow {
            searchTextField = UITextField(frame: CGRect(x: 10, y: 10, width: searchView.frame.width - 20, height: 40))
            searchTextField?.placeholder = "Search..."
            searchTextField?.delegate = self
            searchTextField?.borderStyle = .roundedRect
            searchTextField?.autocorrectionType = .no
            searchTextField?.autocapitalizationType = .none
            searchTextField?.returnKeyType = .done
            
            if let searchTextField = searchTextField {
                searchView.addSubview(searchTextField)
                searchTextField.becomeFirstResponder()
            }

            view.bringSubviewToFront(searchView)
        } else {
            searchTextField?.removeFromSuperview()
            searchTextField = nil
            // Reset search when closing
            filteredGroupClasses = groupClasses
            StudentList.reloadData()
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func navigateToAddRegularClass(withClassData classData: [ClassType], classTypeId: String, className: String) {
        let storyboard = UIStoryboard(name: "Student", bundle: nil)
        guard let addRegularClassVC = storyboard.instantiateViewController(withIdentifier: "AddRegularClass") as? AddRegularClass else {
            print("❌ Failed to instantiate AddRegularClass from Student.storyboard")
            return
        }

        addRegularClassVC.classData = classData
        addRegularClassVC.classTypeId = classTypeId
        addRegularClassVC.className = className

        self.navigationController?.pushViewController(addRegularClassVC, animated: true)
    }
    
    func addCombinedClass() {
        // Your combined class code
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Dismiss keyboard immediately
        view.endEditing(true)
        
        print("Tapped row:", indexPath.row)
        print("Total filtered rows:", filteredGroupClasses.count)
        
        // Make sure the index is valid
        guard indexPath.row < filteredGroupClasses.count else {
            print("❌ Invalid index path")
            return
        }
        
        let selectedGroupClass = filteredGroupClasses[indexPath.row]
        print("Selected class name:", selectedGroupClass.name)
        print("Selected class ID:", selectedGroupClass.id)
        
        // Deselect the row with animation
        tableView.deselectRow(at: indexPath, animated: true)

        navigateToDetailViewController(
            classId: selectedGroupClass.id,
            groupAcademicYearId: selectedGroupClass.groupAcademicYearId,
            className: selectedGroupClass.name
        )
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of filtered rows:", filteredGroupClasses.count)
        return filteredGroupClasses.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RegularTableViewCell",
            for: indexPath
        ) as? RegularTableViewCell else {
            return UITableViewCell()
        }

        guard indexPath.row < filteredGroupClasses.count else {
            return cell
        }
        
        let groupClass = filteredGroupClasses[indexPath.row]

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

    func navigateToDetailViewController(
        classId: String,
        groupAcademicYearId: String,
        className: String
    ) {
        print("✅ Navigating to detail view")
        print("✅ classId passed:", classId)
        print("✅ groupAcademicYearId passed:", groupAcademicYearId)
        print("✅ className passed:", className)

        guard let detailVC = storyboard?
            .instantiateViewController(withIdentifier: "DetailViewController")
            as? DetailViewController else {
            print("❌ Failed to instantiate DetailViewController")
            return
        }

        detailVC.classId = classId
        detailVC.groupAcademicYearId = groupAcademicYearId
        detailVC.className = className

        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func filterMembers(text: String) {
        let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if searchText.isEmpty {
            filteredGroupClasses = groupClasses
        } else {
            filteredGroupClasses = groupClasses.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        print("Filtered results count:", filteredGroupClasses.count)
        StudentList.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        filterMembers(text: searchText)
        return true
    }
    
    // Add this to handle return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
