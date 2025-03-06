//
//  ClassesTableViewCell.swift
//  loginpage
//
//  Created by Prajwal rao Kadam J on 06/02/25.
//

import UIKit

class ClassesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var className: UILabel!
    
    @IBOutlet weak var classImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moveInsideClassAction(_ sender: Any) {
        
    }
    
    
}

