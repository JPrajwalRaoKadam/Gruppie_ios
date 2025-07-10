//
//  TapProtector.swift
//  loginpage
//
//  Created by apple on 10/07/25.
//

import UIKit
import ObjectiveC

// MARK: - UIButton Tap Protection

extension UIButton {
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

        let original = class_getInstanceMethod(self, #selector(UIButton.sendAction(_:to:for:)))
        let swizzled = class_getInstanceMethod(self, #selector(UIButton.swizzled_sendAction(_:to:for:)))

        if let original = original, let swizzled = swizzled {
            method_exchangeImplementations(original, swizzled)
        }
    }

    @objc private func swizzled_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        guard !isIgnoring else { return }

        isIgnoring = true
        self.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isIgnoring = false
            self.isEnabled = true
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

