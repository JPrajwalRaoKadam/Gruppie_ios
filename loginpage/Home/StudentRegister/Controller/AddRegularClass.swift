import UIKit

class AddRegularClass: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRegularClassLabelCellDelegate {

    @IBOutlet weak var TableView: UITableView!
    
    var classData: [ClassType] = []
    var classTypeId: String = ""
    var className: String = ""
    var groupId: String = ""
    var token: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("📝 Class Type ID: \(classTypeId)")
                print("🏫 Class Name: \(className)")
                print("🆔 Group ID: \(groupId)")
                print("🔑 Token AddRegularClass: \(token)")


        let nib = UINib(nibName: "AddRegularClassCell", bundle: nil)
        TableView.register(nib, forCellReuseIdentifier: "AddRegularClassCell")

        TableView.delegate = self
        TableView.dataSource = self
        enableKeyboardDismissOnTap()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return classData.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddRegularClassCell", for: indexPath) as? AddRegularClassCell else {
            return UITableViewCell()
        }

        cell.parentDelegate = self
        cell.classData = classData[indexPath.section].classList
        cell.TableView.reloadData()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected section: \(classData[indexPath.section].type)")
    }
    
    func didTapIncrementButton(for classItem: ClassItem, at indexPath: IndexPath) {
        let updatedSections = classItem.noOfSections + 1

        let requestBody: [String: Any] = [
            "className": classItem.className,
            "classTypeId": classTypeId,
            "noOfSection": updatedSections
        ]

        guard let url = URL(string: APIManager.shared.baseURL + "groups/\(groupId)/add/classes") else { return }
        
        print("🌍 API URL: \(url)")
        print("🔑 Token: \(token)")
        print("🆔 Group ID: \(groupId)")
        print("📦 Request Body: \(requestBody)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") 
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("📡 API Response Code: \(httpResponse.statusCode)")

            guard let data = data else { return }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                print("✅ API Success Response: \(jsonResponse)")
                
                DispatchQueue.main.async {
                    self.updateSectionsCount(for: indexPath, newCount: updatedSections)
                }
            } catch {
                print("❌ JSON Parsing Error: \(error)")
            }
        }.resume()
    }

    private func updateSectionsCount(for indexPath: IndexPath, newCount: Int) {
        guard indexPath.section < classData.count else { return }

        var updatedClassList = classData[indexPath.section].classList
        updatedClassList[indexPath.row].noOfSections = newCount

        var updatedClassType = classData[indexPath.section]
        updatedClassType.classList = updatedClassList

        classData[indexPath.section] = updatedClassType

        TableView.reloadSections([indexPath.section], with: .automatic)
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
