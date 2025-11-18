//
//  DashBoard.swift
//  loginpage
//
//  Created by apple on 12/11/25.
//

import UIKit

struct DashboardService {
    let imageName: String
    let title: String
    let description: String
}

class DashBoardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var kidImageView: UIImageView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var kidName: UILabel!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    
    var services: [DashboardService] = []
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           servicesCollectionView.delegate = self
           servicesCollectionView.dataSource = self
           
           // Register cell nib
           let nib = UINib(nibName: "DashboardServiceCollectionViewCell", bundle: nil)
           servicesCollectionView.register(nib, forCellWithReuseIdentifier: "DashboardServiceCollectionViewCell")
           
           setupDummyData()
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                CustomTabManager.addTabBar(self, isRemoveLast: false, selectIndex: 3, bottomConstraint: &self.bottomTableViewConstraint)
    }
    
    func setupDummyData() {
        services = [
            DashboardService(imageName: "single-user-checkmark ser", title: "Attendance", description: "Check daily & monthly records"),
            DashboardService(imageName: "notes-book-pen  ser", title: "Home work", description: "Track pending & submitted work"),
            DashboardService(imageName: "star ser", title: "Performance", description: "Analyze subject-wise scores"),
            DashboardService(imageName: "Money, Coins ser", title: "Fee payment", description: "Check pending & paid fees"),
            DashboardService(imageName: "health-graph-heart ser", title: "Health report", description: "Track height, weight & BMI"),
            DashboardService(imageName: "folderSer", title: "Notes & videos", description: "Quickly revisit important topics"),
            DashboardService(imageName: "single-user-checkmark ser", title: "Attendance", description: "Check daily & monthly records"),
            DashboardService(imageName: "notes-book-pen  ser", title: "Home work", description: "Track pending & submitted work"),
            DashboardService(imageName: "star ser", title: "Performance", description: "Analyze subject-wise scores"),
            DashboardService(imageName: "Money, Coins ser", title: "Fee payment", description: "Check pending & paid fees"),
            DashboardService(imageName: "health-graph-heart ser", title: "Health report", description: "Track height, weight & BMI"),
            DashboardService(imageName: "folderSer", title: "Notes & videos", description: "Quickly revisit important topics")
        ]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardServiceCollectionViewCell", for: indexPath) as? DashboardServiceCollectionViewCell else {
            return UICollectionViewCell()
        }

        let service = services[indexPath.item]
        cell.configure(with: service)
        return cell
    }


    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 160, height: 115)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            // Equal spacing on both sides
            return UIEdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 30 // vertical spacing between rows
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 22 // horizontal spacing between columns
        }

}
