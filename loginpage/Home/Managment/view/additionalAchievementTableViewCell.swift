//
//  additionalAchievementTableViewCell.swift
//  loginpage
//
//  Created by apple on 22/01/26.
//

import UIKit

class additionalAchievementTableViewCell: UITableViewCell {
    
    @IBOutlet weak var attachment1: UITextField!
    @IBOutlet weak var attachment2: UITextField!
    @IBOutlet weak var attachment3: UITextField!
    @IBOutlet weak var acheivementCertificate1: UIButton!
    @IBOutlet weak var acheivementCertificate2: UIButton!
    @IBOutlet weak var acheivementCertificate3: UIButton!
    
    var onUploadCertificate1Tapped: (() -> Void)?
    var onUploadCertificate2Tapped: (() -> Void)?
    var onUploadCertificate3Tapped: (() -> Void)?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func acheivementCertificate1Tapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadCertificate1Tapped?()
    }
    @IBAction func acheivementCertificate2Tapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadCertificate2Tapped?()
    }
    @IBAction func acheivementCertificate3Tapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadCertificate3Tapped?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
