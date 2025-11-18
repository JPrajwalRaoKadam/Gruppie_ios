//
//  GalleryCollectionCell.swift
//  loginpage
//
//  Created by apple on 12/11/25.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var imageCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // ✅ Rounded corners for the whole cell
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        // ✅ Rounded corners specifically for the image
        albumImage.layer.cornerRadius = 10
        albumImage.layer.masksToBounds = true
        albumImage.clipsToBounds = true
        albumImage.contentMode = .scaleAspectFill  // So image fills properly with rounded edges

        // ✅ Shadow for cell to make it pop
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensures rounded corners apply even after resizing
        albumImage.layer.cornerRadius = 10
    }
}
