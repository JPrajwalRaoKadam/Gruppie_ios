//
//  SubDetailsTableViewCell.swift
//  loginpage
//
//  Created by apple on 17/04/25.
//

import UIKit

class SubDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var createdOn: UILabel!
    @IBOutlet weak var datacontainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainContainer.layer.cornerRadius = 12
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let verticalSpacing: CGFloat = 8
        let horizontalSpacing: CGFloat = 1

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(
            top: verticalSpacing / 2,
            left: horizontalSpacing,
            bottom: verticalSpacing / 2,
            right: horizontalSpacing
        ))

        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 3
        layer.masksToBounds = false
        backgroundColor = .clear
        
    }
    
    @IBAction func threeDots(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
