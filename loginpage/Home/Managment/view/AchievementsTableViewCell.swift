//
//  AchievementsTableViewCell.swift
//  loginpage
//
//  Created by apple on 21/01/26.
//

import UIKit

class AchievementsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Title1: UITextField!
    @IBOutlet weak var Title2: UITextField!
    @IBOutlet weak var Title3: UITextField!
    @IBOutlet weak var Description1: UITextField!
    @IBOutlet weak var Description2: UITextField!
    @IBOutlet weak var Description3: UITextField!
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
    
    func showAadharSelected() {
        print("✅ Aadhar file selected successfully")
        
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        acheivementCertificate1.setImage(tickImage, for: .normal)
        acheivementCertificate1.setTitle("", for: .normal)
        acheivementCertificate1.imageView?.contentMode = .scaleAspectFit
        acheivementCertificate1.backgroundColor = .clear
    }
    func showAadharSelected2() {
        print("✅ Aadhar file selected successfully")
        
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        acheivementCertificate2.setImage(tickImage, for: .normal)
        acheivementCertificate2.setTitle("", for: .normal)
        acheivementCertificate2.imageView?.contentMode = .scaleAspectFit
        acheivementCertificate2.backgroundColor = .clear
    }
    func showAadharSelected3() {
        print("✅ Aadhar file selected successfully")
        
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        acheivementCertificate3.setImage(tickImage, for: .normal)
        acheivementCertificate3.setTitle("", for: .normal)
        acheivementCertificate3.imageView?.contentMode = .scaleAspectFit
        acheivementCertificate3.backgroundColor = .clear
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
