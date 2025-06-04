//
//  AddHolidays.swift
//  loginpage
//
//  Created by apple on 05/02/25.
//

import Foundation
import UIKit

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var moreTableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreTableView.register(UINib(nibName: "MoreTableViewCell", bundle: nil), forCellReuseIdentifier: "MoreTableViewCell")
        CustomTabManager.addTabBar(self, isRemoveLast: false, selectIndex: 1, bottomConstraint: &self.moreTableViewBottomConstraint)
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = moreTableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell", for: indexPath) as? MoreTableViewCell {
            cell.moreOptionLabels.text = "Logout"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //            UserDefaults.standard.removeObject(forKey: "loggedInPhone")
        //            let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //        navigationController?.setViewControllers([loginVC], animated: true)
                
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
                    UserDefaults.standard.removeObject(forKey: "loggedInPhone")

                    // Return to login screen
                    if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                        sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: loginVC)
                    }
    }
    
}
