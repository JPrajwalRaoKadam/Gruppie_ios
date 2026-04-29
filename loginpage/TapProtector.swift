//
//  TapProtector.swift
//  loginpage
//
//  Created by apple on 10/07/25.
//

import UIKit
import ObjectiveC

// MARK: - UIButton Tap Protection

extension UIControl {
    private static var hasSwizzled = false
    private struct AssociatedKeys {
        static var isIgnoring = "isIgnoring"
    }

    private var isIgnoring: Bool {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.isIgnoring) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.isIgnoring, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    static func enableGlobalTapProtection() {
        guard !hasSwizzled else { return }
        hasSwizzled = true

        let original = class_getInstanceMethod(UIControl.self, #selector(UIControl.sendAction(_:to:for:)))
        let swizzled = class_getInstanceMethod(UIControl.self, #selector(UIControl.swizzled_sendAction(_:to:for:)))

        if let original = original, let swizzled = swizzled {
            method_exchangeImplementations(original, swizzled)
        }
    }

    @objc private func swizzled_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if let button = self as? UIButton {
            guard !button.isIgnoring else { return }

            button.isIgnoring = true
            button.isEnabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                button.isIgnoring = false
                button.isEnabled = true
            }
        }

        swizzled_sendAction(action, to: target, for: event)
    }
}

// MARK: - Global Tap Lock Controller

final class TableViewTapProtector: NSObject {
    static let shared = TableViewTapProtector()
    private var isLocked: Bool = false

    func lockIfAllowed() -> Bool {
        guard !isLocked else { return false }
        isLocked = true
        return true
    }

    func unlock() {
        isLocked = false
    }
}

// MARK: - Auto Unlock on Push or Present

extension UINavigationController {
    static func swizzlePush() {
        let original = class_getInstanceMethod(self, #selector(pushViewController(_:animated:)))
        let swizzled = class_getInstanceMethod(self, #selector(swizzled_pushViewController(_:animated:)))

        if let original = original, let swizzled = swizzled {
            method_exchangeImplementations(original, swizzled)
        }
    }

    @objc private func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
        swizzled_pushViewController(viewController, animated: animated)
        TableViewTapProtector.shared.unlock()
    }
}

extension UIViewController {
    static func swizzlePresent() {
        let original = class_getInstanceMethod(self, #selector(present(_:animated:completion:)))
        let swizzled = class_getInstanceMethod(self, #selector(swizzled_present(_:animated:completion:)))

        if let original = original, let swizzled = swizzled {
            method_exchangeImplementations(original, swizzled)
        }
    }

    @objc private func swizzled_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        swizzled_present(viewControllerToPresent, animated: animated) {
            TableViewTapProtector.shared.unlock()
            completion?()
        }
    }
}

import UIKit
import ObjectiveC.runtime

extension UITableView {

    static let swizzleReload: Void = {
        let original = class_getInstanceMethod(UITableView.self, #selector(reloadData))
        let swizzled = class_getInstanceMethod(UITableView.self, #selector(swizzled_reloadData))
        method_exchangeImplementations(original!, swizzled!)
    }()

    @objc private func swizzled_reloadData() {
        self.swizzled_reloadData() // original reloadData

        DispatchQueue.main.async {
            self.checkEmpty()
        }
    }

    private func checkEmpty() {
        guard let dataSource = self.dataSource else { return }

        let sections = dataSource.numberOfSections?(in: self) ?? 1
        var isEmpty = true

        for section in 0..<sections {
            let rows = dataSource.tableView(self, numberOfRowsInSection: section)
            if rows > 0 {
                isEmpty = false
                break
            }
        }

        if isEmpty {
            setEmptyMessage()
        } else {
            restore()
        }
    }

    private func setEmptyMessage(_ message: String = "No Data Available") {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        self.backgroundView = label
        self.separatorStyle = .none
    }

    private func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UICollectionView {

    static let swizzleReload: Void = {
        let original = class_getInstanceMethod(UICollectionView.self, #selector(reloadData))
        let swizzled = class_getInstanceMethod(UICollectionView.self, #selector(swizzled_reloadData))
        method_exchangeImplementations(original!, swizzled!)
    }()

    @objc private func swizzled_reloadData() {
        self.swizzled_reloadData()

        DispatchQueue.main.async {
            self.checkEmpty()
        }
    }

    private func checkEmpty() {
        guard let dataSource = self.dataSource else { return }

        let sections = dataSource.numberOfSections?(in: self) ?? 1
        var isEmpty = true

        for section in 0..<sections {
            let items = dataSource.collectionView(self, numberOfItemsInSection: section)
            if items > 0 {
                isEmpty = false
                break
            }
        }

        if isEmpty {
            setEmptyMessage()
        } else {
            restore()
        }
    }

    private func setEmptyMessage(_ message: String = "No Data Available") {
        let label = UILabel(frame: bounds)
        label.text = message
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        self.backgroundView = label
    }

    private func restore() {
        self.backgroundView = nil
    }
}
