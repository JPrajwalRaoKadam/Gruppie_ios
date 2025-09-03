//
//  AddGateViewController.swift
//  loginpage
//
//  Created by apple on 03/09/25.
//

import UIKit

class AddGatePassVC: UIViewController {
    
    var groupId: String?
    var currentRole: String?
    
    @IBOutlet weak var searchbox: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbox.layer.cornerRadius = 10
        searchButton.layer.cornerRadius = 10
        addButton.layer.cornerRadius = 10

    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButton(_ sender: Any) {
        
    }
}

