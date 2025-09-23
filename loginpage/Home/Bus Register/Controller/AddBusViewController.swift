//
//  AddBusViewController.swift
//  loginpage
//
//  Created by apple on 08/09/25.
//

import UIKit

class AddBusViewController: UIViewController {

    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var bcbutton: UIButton!
    
    var groupId: String?
    var currentRole: String?
    
    @IBOutlet weak var busView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        add.layer.cornerRadius = 10
        busView.layer.cornerRadius = 10
        bcbutton.layer.cornerRadius = bcbutton.frame.size.width / 2
        bcbutton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addBusButton(_ sender: Any) {
        navigateToCalendarViewController()
    }

    func navigateToCalendarViewController() {
            let storyboard = UIStoryboard(name: "BusRegister", bundle: nil)
        if let addBusVC = storyboard.instantiateViewController(withIdentifier: "AddBusDetailsVC") as? AddBusDetailsVC {
                addBusVC.currentRole = self.currentRole
                addBusVC.groupId = self.groupId
               
                navigationController?.pushViewController(addBusVC, animated: true)
            }
        }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
