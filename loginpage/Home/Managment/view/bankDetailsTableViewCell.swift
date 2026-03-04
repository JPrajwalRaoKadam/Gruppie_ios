import UIKit

class bankDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountHolderName: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var branchName: UITextField!
    @IBOutlet weak var accountNumber: UITextField!
    @IBOutlet weak var IFSCCode: UITextField!
    @IBOutlet weak var PANNumber: UITextField!
    @IBOutlet weak var passBook: UIButton!
    @IBOutlet weak var otherDocument: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var onUploadpassBookTapped: (() -> Void)?
    var onUploadotherDocumentTapped: (() -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func passBookTapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadpassBookTapped?()
    }
    @IBAction func otherDocumentTapped(_ sender: UIButton) {
        print("📤 Upload certificate button tapped")
        onUploadotherDocumentTapped?()
    }
    
}
