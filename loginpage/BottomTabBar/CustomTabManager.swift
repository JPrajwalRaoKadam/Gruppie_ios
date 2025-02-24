//
//  CustomTabManager.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 31/12/24.
//

import UIKit

protocol FeedPageNavigationDelegate: AnyObject {
    func tapforFeeds()
}

protocol HomePageNavigationDelegate: AnyObject {
    func getHomedata(indexpath: IndexPath)
    var indexPath: IndexPath? { get set }
}

protocol MoreNavigationDelegate: AnyObject {
    func tapOnMore()
}

class CustomTabManager: NSObject {
    // MARK: - Static Properties -
    static let shared = CustomTabManager()
    static let viewTag = 999999961
    
    var delegate: FeedPageNavigationDelegate?
    
    var hDelegate: HomePageNavigationDelegate?
    
    var mDelegate: MoreNavigationDelegate?
    
    // MARK: - Private Properties -
    private var curVController = UIViewController()
    var customTabbar = CustomTabBarViewController()
    var tabBarOriginY = 0.0

    /*
     *  Custom Header for application
     *  Add custom Header to view
     */
    static func addTabBar(_ controller: UIViewController, isRemoveLast: Bool ,selectIndex: Int, bottomConstraint : inout NSLayoutConstraint) {
        if let myobject =  UIStoryboard(name: "BottomTab", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarViewController") as? CustomTabBarViewController {
            if let headerView = controller.view.viewWithTag(CustomTabManager.viewTag) {
                headerView.removeFromSuperview()
            }
            CustomTabManager.shared.curVController = controller
           
            myobject.view.tag = CustomTabManager.viewTag
            let viewHeight = 60.0
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first, window.safeAreaInsets.bottom > 0 {
                bottomConstraint.constant = 0.0
                CustomTabManager.shared.tabBarOriginY = (controller.view.frame.size.height - viewHeight) - window.safeAreaInsets.bottom
            } else {
                bottomConstraint.constant = 0.0
                CustomTabManager.shared.tabBarOriginY = controller.view.frame.size.height - viewHeight - 15.0
            }
           let widttt = controller.view.frame.size.width - (isRemoveLast ? 250.0 : 100.0)
            myobject.view.frame = CGRect(x: (controller.view.frame.width / 2.0 ) - ( widttt / 2.0 ), y: CustomTabManager.shared.tabBarOriginY, width: widttt, height: viewHeight)
           
            myobject.buttons[0].addTarget(CustomTabManager.shared.self, action: #selector(tapOnHome(_:)), for: .touchUpInside)
            myobject.buttons[1].addTarget(CustomTabManager.shared.self, action: #selector(tapOnService(_:)), for: .touchUpInside)
            myobject.buttons[2].addTarget(CustomTabManager.shared.self, action: #selector(tapOnMore(_:)), for: .touchUpInside)
            
            myobject.tabBarItems[2].isHidden = isRemoveLast
            
            myobject.selectedIndex = selectIndex
            myobject.setSelectedTabBar()
            CustomTabManager.shared.customTabbar = myobject
            controller.view.addSubview(myobject.view)
        }
    }
    
    @objc func tapOnHome(_ sender: UIButton) {
        hDelegate?.getHomedata(indexpath: (hDelegate?.indexPath)!)
        CustomTabManager.shared.customTabbar.selectedIndex = 0
        CustomTabManager.shared.curVController.tabBarController?.selectedIndex = 0
        CustomTabManager.shared.customTabbar.setSelectedTabBar()
    }
    
    @objc func tapOnService(_ sender: UIButton) {
        delegate?.tapforFeeds()
        CustomTabManager.shared.customTabbar.selectedIndex = 1
        CustomTabManager.shared.curVController.tabBarController?.selectedIndex = 1
        CustomTabManager.shared.customTabbar.setSelectedTabBar()
    }
    
    @objc func tapOnMore(_ sender: UIButton) {
        mDelegate?.tapOnMore()
        CustomTabManager.shared.customTabbar.selectedIndex = 2
        CustomTabManager.shared.curVController.tabBarController?.selectedIndex = 2
        CustomTabManager.shared.customTabbar.setSelectedTabBar()
    }
}

