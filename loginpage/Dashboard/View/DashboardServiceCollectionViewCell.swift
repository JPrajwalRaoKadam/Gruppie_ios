//
//  DashboardServiceCollectionViewCell.swift
//  loginpage
//
//  Created by apple on 12/11/25.
//

import UIKit

class DashboardServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    
    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make cell rounded
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        // Make container rounded
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        
        // Important: Also mask the cell's layer to avoid rectangular background
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        // Set clear background
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove old gradient when cell is reused
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }

    func configure(with service: DashboardService) {
        serviceName.text = service.title
        serviceDescription.text = service.description
        serviceImageView.image = UIImage(named: service.imageName)
        
        // Remove old gradient if exists
        gradientLayer?.removeFromSuperlayer()
        
        // Get dominant color from image
        if let image = serviceImageView.image, let dominantColor = image.averageColor {
            applyGradient(with: dominantColor)
        } else {
            // Fallback gradient color
            applyGradient(with: .systemBlue)
        }
    }

    private func applyGradient(with color: UIColor) {
        // Ensure container view has proper layout
        containerView.layoutIfNeeded()
        
        let gradient = CAGradientLayer()
        gradient.frame = containerView.bounds
        gradient.colors = [
            color.withAlphaComponent(0.30).cgColor,
            color.withAlphaComponent(0.15).cgColor
        ]
        // Gradient direction: Left Bottom to Right Top
        gradient.startPoint = CGPoint(x: 0, y: 1)  // Left bottom
        gradient.endPoint = CGPoint(x: 1, y: 0)    // Right top
        gradient.cornerRadius = 16
        
        // Remove any existing gradient
        if let existingGradient = gradientLayer {
            existingGradient.removeFromSuperlayer()
        }
        
        containerView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame when layout changes
        gradientLayer?.frame = containerView.bounds
        gradientLayer?.cornerRadius = containerView.layer.cornerRadius
        
        // Ensure all layers have consistent corner radius
        contentView.layer.cornerRadius = 16
        containerView.layer.cornerRadius = 16
        self.layer.cornerRadius = 16
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage,
                                                 kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }
}
