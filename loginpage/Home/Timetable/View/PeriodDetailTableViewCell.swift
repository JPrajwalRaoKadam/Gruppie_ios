

import UIKit

class PeriodDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var subject: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let separator = UIView()
        separator.backgroundColor = .lightGray // Customize color
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.topAnchor.constraint(equalTo: className.topAnchor),
            separator.bottomAnchor.constraint(equalTo: className.bottomAnchor)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
