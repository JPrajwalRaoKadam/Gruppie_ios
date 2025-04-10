//
//  ThreeFourthPresentationController.swift
//  loginpage
//
//  Created by apple on 07/04/25.
//

import UIKit

class ThreeFourthPresentationController: UIPresentationController {
    
    private let dimmingView = UIView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }

    private func setupDimmingView() {
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dimmingView.addGestureRecognizer(tap)
    }

    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = containerView.bounds.height * 0.75
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 20
        presentedView?.clipsToBounds = true
    }
}
//extension ThreeFourthPresentationController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController,
//                                presenting: UIViewController?,
//                                source: UIViewController) -> UIPresentationController? {
//        return ThreeFourthPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//
//    func presentAbsentStudents() {
//        let vc = AbsentStudentVC()
//        vc.modalPresentationStyle = .custom
//        vc.transitioningDelegate = self
//        present(vc, animated: true, completion: nil)
//    }
//}
