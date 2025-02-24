//
//  TeamCollectionCell.swift
//  CollectionViewDemo
//
//  Created by Jailove Mewara on 08/10/18.
//  Copyright © 2018 Jailove. All rights reserved.
//

import UIKit

class TeamCollectionCell: UICollectionViewCell {
    
    @IBOutlet var anImageIcon : UIImageView!
    @IBOutlet var aLabelTeamNameIcon : UILabel!
    @IBOutlet var aLabelBadge : UILabel!
    @IBOutlet var aLabelTeamName : UILabel!
    var colorView: UIColor = .gray
    
    override func prepareForReuse() {
        super.prepareForReuse()
        anImageIcon.image = nil
        colorView = generateRandomColor()
    }
    
    private func generateRandomColor() -> UIColor {
        let redValue = CGFloat.random(in: 100...225)
        let greenValue = CGFloat.random(in: 100...225)
        let blueValue = CGFloat.random(in: 100...225)
        let randomColor = UIColor(red: redValue / 255.0, green: greenValue / 255.0, blue: blueValue / 255.0, alpha: 1.0)
        return randomColor
    }
}
