//
//  BusRouteMapVC.swift
//  loginpage
//
//  Created by apple on 09/09/25.
//

import UIKit
//import GoogleMaps
//import GooglePlaces

//var mapView: GMSMapView!

class BusRouteMapVC: UIViewController {
    
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var printMap: UIView!
    
    var groupId: String?
    var currentRole: String?
    var routeNameText: String?   // <-- String to hold route name
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let camera = GMSCameraPosition.camera(withLatitude: 12.9716,
//                                                     longitude: 77.5946,
//                                                     zoom: 10.0)
//               let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
//               self.view.addSubview(mapView)
//               
//               // Add a marker
//               let marker = GMSMarker()
//               marker.position = CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
//               marker.title = "Bengaluru"
//               marker.snippet = "India"
//               marker.map = mapView
        
        // Assign the passed string to the UILabel
        routeName.text = routeNameText
    }
    
    
    @IBAction func segments(_ sender: Any) {
        
    }
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


