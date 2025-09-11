//
//  AddBusDetailsVC.swift
//  loginpage
//
//  Created by apple on 08/09/25.
//

import UIKit

class AddBusDetailsVC: UIViewController {
    @IBOutlet weak var addButton: UIButton!
    
    var groupId: String?
    var currentRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    

    @IBAction func addButton(_ sender: Any) {
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
