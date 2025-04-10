////
////  AbsentStudentTableViewCell.swift
////  loginpage
////
////  Created by apple on 08/04/25.
////
//
//import UIKit
//
//class AbsentStudentTableViewCell: UITableViewCell,UITableViewDelegate, UITableViewDataSource  {
//   
//    
//    @IBOutlet weak var nameTV: UITableView!
//    @IBOutlet weak var AbsentStudent: UILabel!
//   
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        nameTV.dataSource = self
//        nameTV.delegate = self
//        nameTV.register(UINib(nibName: "A1StudentNameTableViewCell", bundle: nil), forCellReuseIdentifier: "A1StudentNameTableViewCell")
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
// 
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//}
import UIKit
class AbsentStudentTableViewCell: UITableViewCell {

    @IBOutlet weak var absentStudentName: UILabel!
    
    var absentList: [String] = []


    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

}
