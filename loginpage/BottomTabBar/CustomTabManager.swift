//
//  CustomTabManager.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 31/12/24.
//

import UIKit

protocol DashboardNavigationDelegate: AnyObject {
    func tapforDashboard()
}

protocol FeedPageNavigationDelegate: AnyObject {
    func tapforFeeds()
}

protocol HomePageNavigationDelegate: AnyObject {
    func getHomedata()
}

protocol MoreNavigationDelegate: AnyObject {
    func tapOnMore()
}

class CustomTabManager: NSObject {
    
    static let shared = CustomTabManager()
    static let viewTag = 999999961
    
    var delegate: FeedPageNavigationDelegate?
    var hDelegate: HomePageNavigationDelegate?
    var mDelegate: MoreNavigationDelegate?
    var dbDelegate: DashboardNavigationDelegate?
    
    private var curVController = UIViewController()
    var customTabbar = CustomTabBarViewController()
    var tabBarOriginY = 0.0

    static func addTabBar(_ controller: UIViewController, isRemoveLast: Bool, selectIndex: Int, bottomConstraint: inout NSLayoutConstraint) {
        
        if let myobject = UIStoryboard(name: "BottomTab", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarViewController") as? CustomTabBarViewController {
            
            if let existingView = controller.view.viewWithTag(CustomTabManager.viewTag) {
                existingView.removeFromSuperview()
            }
            
            CustomTabManager.shared.curVController = controller
            myobject.view.tag = CustomTabManager.viewTag
            
            let viewHeight: CGFloat = 70.0
            
            // Adjust to sit just above safe area
            let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
            let tabBarY = controller.view.frame.height - bottomPadding - viewHeight
            
            myobject.view.frame = CGRect(
                x: 0,
                y: tabBarY,
                width: controller.view.frame.width,
                height: viewHeight
            )
            
            // Remove corner radius to avoid rounded floating bar
            myobject.view.layer.cornerRadius = 0
            myobject.view.clipsToBounds = true
            
            // Button actions
            myobject.buttons[3].addTarget(CustomTabManager.shared, action: #selector(tapforDashboard(_:)), for: .touchUpInside)
            myobject.buttons[0].addTarget(CustomTabManager.shared, action: #selector(tapOnHome(_:)), for: .touchUpInside)
            myobject.buttons[1].addTarget(CustomTabManager.shared, action: #selector(tapOnService(_:)), for: .touchUpInside)
            myobject.buttons[2].addTarget(CustomTabManager.shared, action: #selector(tapOnMore(_:)), for: .touchUpInside)
            
            myobject.tabBarItems[2].isHidden = isRemoveLast
            
            myobject.selectedIndex = selectIndex
            myobject.setSelectedTabBar()
            
            CustomTabManager.shared.customTabbar = myobject
            controller.view.addSubview(myobject.view)
        }
    }
    
    @objc func tapforDashboard(_ sender: UIButton) {
        customTabbar.selectedIndex = 3
        customTabbar.setSelectedTabBar()
        dbDelegate?.tapforDashboard()
    }
    
    @objc func tapOnHome(_ sender: UIButton) {
        customTabbar.selectedIndex = 0
        customTabbar.setSelectedTabBar()
            hDelegate?.getHomedata()
    }

    @objc func tapOnService(_ sender: UIButton) {
        customTabbar.selectedIndex = 1
        customTabbar.setSelectedTabBar()
        delegate?.tapforFeeds()
    }

    @objc func tapOnMore(_ sender: UIButton) {
        customTabbar.selectedIndex = 2
        customTabbar.setSelectedTabBar()
        mDelegate?.tapOnMore()
    }
}
