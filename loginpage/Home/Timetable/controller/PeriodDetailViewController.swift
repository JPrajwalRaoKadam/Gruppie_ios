import UIKit

class PeriodDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var token: String = ""
    var groupId: String = ""
    var day: Int = 0
    var periodData: PeriodData?
    var periodDataList: [PeriodData] = []
    var groupedPeriodData: [String: [PeriodData]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ Received Data in PeriodDetailViewController:")
        print("Token: \(token)")
        print("Group ID: \(groupId)")
        print("Day: \(day)")
        print("Selected Period: \(periodData?.period ?? "N/A")")

        // Register the cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PeriodDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "PeriodDetailTableViewCell")
        fetchPeriodDetails()
    }

    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func fetchPeriodDetails() {
        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/free/staff/get?day=\(day)&period=\(periodData?.period ?? "")") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching period details: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received.")
                return
            }

            do {
                let decoder = JSONDecoder()
                let periodResponse = try decoder.decode(PeriodResponse.self, from: data)
                self.periodDataList = periodResponse.data
                
                // Group the data by teacher name (name field)
                self.groupedPeriodData = Dictionary(grouping: periodResponse.data, by: { $0.name ?? "Unknown" })

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - UITableView Delegate & DataSource
extension PeriodDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedPeriodData.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let teacherName = Array(groupedPeriodData.keys)[section]
        let subjectCount = groupedPeriodData[teacherName]?.flatMap { $0.subjectsHandled ?? [] }.count ?? 0
        return subjectCount + 1 // Adding 1 for "Class Name | Subject" header row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let teacherName = Array(groupedPeriodData.keys)[indexPath.section]
        guard let periods = groupedPeriodData[teacherName] else { return UITableViewCell() }

        let subjects = periods.flatMap { $0.subjectsHandled ?? [] }

        // First row should be the "Class Name | Subject" header
        if indexPath.row == 0 {
            let headerCell = UITableViewCell(style: .default, reuseIdentifier: "HeaderCell")

            // Create labels
            let classLabel = UILabel()
            classLabel.text = "      Class Name"
            classLabel.font = UIFont.boldSystemFont(ofSize: 16)
            classLabel.textAlignment = .left

            let subjectLabel = UILabel()
            subjectLabel.text = "Subject"
            subjectLabel.font = UIFont.boldSystemFont(ofSize: 16)
            subjectLabel.textAlignment = .left  // Change from `.right` to `.left`

            // Create horizontal stack view
            let stackView = UIStackView(arrangedSubviews: [classLabel, subjectLabel])
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 150  // Increase spacing for better alignment
            stackView.alignment = .leading  // Align elements to the left

            // Add stack view to the cell
            headerCell.contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: headerCell.contentView.leadingAnchor, constant: 10),
                stackView.trailingAnchor.constraint(equalTo: headerCell.contentView.trailingAnchor, constant: -10),
                stackView.topAnchor.constraint(equalTo: headerCell.contentView.topAnchor, constant: 8),
                stackView.bottomAnchor.constraint(equalTo: headerCell.contentView.bottomAnchor, constant: -8),
                
                // Ensure Class Name takes a fixed width to push Subject left
                classLabel.widthAnchor.constraint(equalToConstant: 120)
            ])

            // Change background color
            headerCell.backgroundColor = UIColor.systemGray5

            return headerCell
        }

        // Adjust row index to fetch correct subject data
        let subjectIndex = indexPath.row - 1
        guard subjectIndex < subjects.count else { return UITableViewCell() }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodDetailTableViewCell", for: indexPath) as? PeriodDetailTableViewCell else {
            return UITableViewCell()
        }

        let subjectData = subjects[subjectIndex]
        cell.subject.text = subjectData.subjectName ?? ""
        cell.className.text = subjectData.className ?? ""

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let teacherName = Array(groupedPeriodData.keys)[section]

        let headerView = UIView()
        headerView.backgroundColor = UIColor.white

        let label = UILabel()
        label.text = "Teacher Name: \(teacherName)"
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40 // Match section header height
        }
        return UITableView.automaticDimension
    }
}
