//
//  SchoolsHeaderView.swift
//  loginpage
//
//  Created by apple on 12/11/25.
//

import UIKit

class SchoolsHeaderView: UICollectionReusableView {
    static let identifier = "SchoolsHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Schools"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
