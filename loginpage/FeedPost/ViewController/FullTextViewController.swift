//
//  ReadMoreDetail.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 21/07/25.
//

import Foundation
// FullTextViewController.swift
import UIKit

class FullTextViewController: UIViewController {
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var fullText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        textView.text = fullText
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissVC)
        )
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}
