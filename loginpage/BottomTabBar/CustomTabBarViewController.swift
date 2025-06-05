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
        view.backgroundColor = .white // or any background color you want
        view.layer.cornerRadius = 0   // Make sure it's square bottom
        view.clipsToBounds = true
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
        self.titleLabels[selectedIndex].textColor = .black
    }
}
