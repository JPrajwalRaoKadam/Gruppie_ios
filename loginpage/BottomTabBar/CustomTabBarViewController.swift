//
//  CustomTabBarViewController.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 31/12/24.
//

import UIKit

class CustomTabBarViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var images: [UIImageView]!
    @IBOutlet var bottomLines: [UIView]!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet var tabBarItems: [UIView]!

    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSelectedTabBar()
    }
    
    func resetTabBar() {
        for i in 0..<buttons.count {
            images[i].isHighlighted = false
            bottomLines[i].isHidden = true
            titleLabels[i].textColor = .lightGray
        }
    }
    
    func setSelectedTabBar() {
        self.resetTabBar()
        self.images[selectedIndex].isHighlighted = true
        self.bottomLines[selectedIndex].isHidden = false
        self.titleLabels[selectedIndex].textColor = .white
        self.tabBarController?.selectedIndex = self.selectedIndex == 0 ? 1 : (self.selectedIndex == 1 ? 0 : self.selectedIndex)
    }
}
