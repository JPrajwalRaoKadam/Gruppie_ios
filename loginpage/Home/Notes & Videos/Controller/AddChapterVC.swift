//
//  AddChapterVC.swift
//  loginpage
//
//  Created by apple on 17/04/25.
//

import UIKit

class AddChapterVC: UIViewController {
    var groupId : String = ""
    var teamId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func addButton(_ sender: Any) {
        print("add button tapped")
        //navigateToAddSubjectVC()
    }
}
