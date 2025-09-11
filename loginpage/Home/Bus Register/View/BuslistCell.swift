//import UIKit
//
//class BuslistCell: UITableViewCell {
//
//    @IBOutlet weak var busnumdot: UIButton!
//    @IBOutlet weak var busRoute: UILabel!
//    @IBOutlet weak var busNumber: UILabel!
//    @IBOutlet weak var statuslabel: UILabel!
//    @IBOutlet weak var activestatus: UIButton!
//    @IBOutlet weak var Busimage: UIImageView!
//    @IBOutlet weak var fallBack: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        activestatus.layer.cornerRadius = activestatus.frame.size.width / 2
//        activestatus.clipsToBounds = true
//        busnumdot.layer.cornerRadius = busnumdot.frame.size.width / 2
//        busnumdot.clipsToBounds = true
//    }
//}
import UIKit

class BuslistCell: UITableViewCell {

    @IBOutlet weak var busnumdot: UIButton!
    @IBOutlet weak var busRoute: UILabel!
    @IBOutlet weak var busNumber: UILabel!
    @IBOutlet weak var statuslabel: UILabel!
    @IBOutlet weak var activestatus: UIButton!
    @IBOutlet weak var Busimage: UIImageView!
    @IBOutlet weak var fallBack: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Circle status buttons
        activestatus.layer.cornerRadius = activestatus.frame.size.width / 2
        activestatus.clipsToBounds = true
        busnumdot.layer.cornerRadius = busnumdot.frame.size.width / 2
        busnumdot.clipsToBounds = true
        
        // Circle Bus image
        Busimage.layer.cornerRadius = Busimage.frame.size.width / 2
        Busimage.clipsToBounds = true
        Busimage.contentMode = .scaleAspectFill
        
        // Circle fallback label
        fallBack.layer.cornerRadius = fallBack.frame.size.width / 2
        fallBack.clipsToBounds = true
        fallBack.textAlignment = .center
        fallBack.font = UIFont.boldSystemFont(ofSize: 20)
        fallBack.textColor = .white
        fallBack.backgroundColor = .link
    }
    
    /// Configure cell with bus data
    func configure(with bus: Bus) {
        busRoute.text = "Route Name: \(bus.routeName)"
        busNumber.text = bus.busNumber
        
        if let imageUrl = bus.busImage, !imageUrl.isEmpty,
           let url = URL(string: imageUrl) {
            // Load image asynchronously
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.Busimage.image = image
                        self.Busimage.isHidden = false
                        self.fallBack.isHidden = true
                    }
                }
            }
        } else {
            // No image → fallback with first letter
            let firstLetter = String(bus.routeName.prefix(1)).uppercased()
            fallBack.text = firstLetter
            fallBack.isHidden = false
            Busimage.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        Busimage.image = nil
        fallBack.text = nil
        fallBack.isHidden = true
        Busimage.isHidden = false
    }
}
