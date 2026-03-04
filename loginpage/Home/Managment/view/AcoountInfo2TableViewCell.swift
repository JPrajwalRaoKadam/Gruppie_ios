//
//  AcoountInfo2TableViewCell.swift
//  loginpage
//
//  Created by apple on 21/01/26.
//

import UIKit

class AcoountInfo2TableViewCell: UITableViewCell {

    @IBOutlet weak var designation: UITextField!
    @IBOutlet weak var organizationName: UITextField!
    @IBOutlet weak var totalExperience: UITextField!
    @IBOutlet weak var industry: UITextField!
    @IBOutlet weak var workAddress: UITextField!
    @IBOutlet weak var workEmail: UITextField!
    @IBOutlet weak var workPhoneNo: UITextField!
    @IBOutlet weak var uploadExperiance: UIButton!

    var onAccountChange: ((EditableManagement) -> Void)?
    var onUploadExperianceTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        let fields: [UITextField] = [
            designation,
            organizationName,
            totalExperience,
            industry,
            workAddress,
            workEmail,
            workPhoneNo
        ]

        fields.forEach {
            $0.addTarget(self,
                         action: #selector(textFieldDidChange),
                         for: .editingChanged)
        }
    }
    @IBAction func uploadExperianceTapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadExperianceTapped?()
    }
    func showAadharSelected() {
        print("✅ Aadhar file selected successfully")
        
        let tickImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        uploadExperiance.setImage(tickImage, for: .normal)
        uploadExperiance.setTitle("", for: .normal)
        uploadExperiance.imageView?.contentMode = .scaleAspectFit
        uploadExperiance.backgroundColor = .clear
    }

    // MARK: - TextField Change Listener
    @objc private func textFieldDidChange() {
        sendUpdatedData()
    }

    // MARK: - Populate
    func populate(with data: EditableManagement, isEditingEnabled: Bool) {
        designation.text = data.designation
        organizationName.text = data.organizationName
        totalExperience.text = data.totalExperience
        industry.text = data.industry
        workAddress.text = data.workAddress
        workEmail.text = data.workEmail
        workPhoneNo.text = data.workPhoneNo

        let fields: [UITextField] = [
            designation,
            organizationName,
            totalExperience,
            industry,
            workAddress,
            workEmail,
            workPhoneNo
        ]

        fields.forEach { $0.isUserInteractionEnabled = isEditingEnabled }
    }

    // MARK: - Send data
    func sendUpdatedData() {
        var data = EditableManagement()
        data.designation = designation.text ?? ""
        data.organizationName = organizationName.text ?? ""
        data.totalExperience = totalExperience.text ?? ""
        data.industry = industry.text ?? ""
        data.workAddress = workAddress.text ?? ""
        data.workEmail = workEmail.text ?? ""
        data.workPhoneNo = workPhoneNo.text ?? ""

        onAccountChange?(data)
    }
}

