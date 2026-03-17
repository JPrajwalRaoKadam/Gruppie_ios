
protocol SubDetailsCellDelegate: AnyObject {
    func didTapDownload(at cell: SubDetailsTableViewCell)
    func didTapDelete(at cell: SubDetailsTableViewCell)
}

import UIKit

class SubDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var createdOn: UILabel!
    @IBOutlet weak var datacontainer: UIView!

    weak var delegate: SubDetailsCellDelegate?
    var menuView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        mainContainer.layer.cornerRadius = 12

        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }

    // MARK: - Three dots action

    @IBAction func threeDots(_ sender: UIButton) {

        if menuView != nil {
            hideMenu()
        } else {
            showMenu(from: sender)
        }
    }
    @IBAction func download(_ sender: UIButton) {
        delegate?.didTapDownload(at: self)
    }
    
    @objc func deleteTapped() {
        delegate?.didTapDelete(at: self)
        hideMenu()
    }

    // MARK: - Show menu

    func showMenu(from button: UIButton) {

        guard let parent = self.window else { return }

        let width: CGFloat = 160
        let height: CGFloat = 100

        let buttonFrame = button.convert(button.bounds, to: parent)

        let menu = UIView(frame: CGRect(
            x: parent.frame.width,
            y: buttonFrame.maxY,
            width: width,
            height: height
        ))

        menu.backgroundColor = .white
        menu.layer.cornerRadius = 10
        menu.layer.shadowColor = UIColor.black.cgColor
        menu.layer.shadowOpacity = 0.25
        menu.layer.shadowOffset = CGSize(width: 0, height: 3)
        menu.layer.shadowRadius = 6

        // Edit Button
        let editBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        editBtn.setTitle("✏️   Edit", for: .normal)
        editBtn.setTitleColor(.black, for: .normal)
        editBtn.contentHorizontalAlignment = .left
        editBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        // Delete Button
        let deleteBtn = UIButton(frame: CGRect(x: 0, y: 50, width: width, height: 50))
        deleteBtn.setTitle("🗑   Delete", for: .normal)
        deleteBtn.setTitleColor(.black, for: .normal)
        deleteBtn.contentHorizontalAlignment = .left
        deleteBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // Divider
        let line = UIView(frame: CGRect(x: 0, y: 50, width: width, height: 1))
        line.backgroundColor = UIColor.systemGray5

        menu.addSubview(editBtn)
        menu.addSubview(deleteBtn)
        menu.addSubview(line)

        parent.addSubview(menu)

        self.menuView = menu

        // Slide animation
        UIView.animate(withDuration: 0.25) {
            menu.frame.origin.x = parent.frame.width - width - 20
        }
    }

    // MARK: - Hide menu

    func hideMenu() {

        guard let menu = menuView else { return }

        UIView.animate(withDuration: 0.25, animations: {

            menu.frame.origin.x += 200

        }) { _ in

            menu.removeFromSuperview()
        }

        menuView = nil
    }
}
