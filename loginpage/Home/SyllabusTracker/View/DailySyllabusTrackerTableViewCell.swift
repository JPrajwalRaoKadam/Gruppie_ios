//
//  DailySyllubasTrackerTableViewCell.swift
//  loginpage
//
//  Created by apple on 19/03/25.
//

//import UIKit
//
//class DailySyllubasTrackerTableViewCell: UITableViewCell {
//    @IBOutlet weak var pStart: UIButton!
//    @IBOutlet weak var pEnd: UIButton!
//    @IBOutlet weak var aStart: UIButton!
//    @IBOutlet weak var aEnd: UIButton!
//    @IBOutlet weak var topic: UILabel!
//    
//    @IBOutlet weak var chapter: UILabel!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//}
import UIKit

class DailySyllabusTrackerTableViewCell: UITableViewCell {

    @IBOutlet weak var pStart: UIButton!
    @IBOutlet weak var pEnd: UIButton!
    @IBOutlet weak var aStart: UIButton!
    @IBOutlet weak var aEnd: UIButton!
    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var chapter: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           // ✅ Apply curved corners styling to buttons
           styleButtons()
       }
    // MARK: - Styling Buttons with Curved Corners
     private func styleButtons() {
         let buttons = [pStart, pEnd, aStart, aEnd]

         for button in buttons {
             button?.layer.cornerRadius = 10      // Adjust the corner radius
             button?.layer.masksToBounds = true   // Ensure the corners are clipped
             button?.layer.borderWidth = 1        // Add a border (optional)
             button?.layer.borderColor = UIColor.lightGray.cgColor
         }
     }

    func configure(with syllabus: DailySyllabus) {
        topic.text = "Topic Name - \(syllabus.topicName)"
        chapter.text = syllabus.subjectName
        pStart.setTitle(syllabus.fromDate, for: .normal)
        pEnd.setTitle(syllabus.toDate, for: .normal)
        
        if !syllabus.actualStartDate.isEmpty {
            aStart.setTitle(syllabus.actualStartDate, for: .normal)
        } else {
            aStart.setTitle("", for: .normal)
        }

        if !syllabus.actualEndDate.isEmpty {
            aEnd.setTitle(syllabus.actualEndDate, for: .normal)
        } else {
            aEnd.setTitle("", for: .normal)
        }
    }
}
