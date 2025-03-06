////
////  LocationVCViewController.swift
////  loginpage
////
////  Created by Apple on 24/01/25.
////
//
//    import UIKit
//    import CoreLocation
//    import GoogleMaps
//    import GooglePlaces
//    import GooglePlacesSearchController
//
//    protocol LocationNameVCDelegate:class {
//        func sendlocationName(_ string: String, _ cordinates: CLLocationCoordinate2D)
//    }
//
//    protocol LocationAddFacilityVCDelegate:class {
//        func sendlocationtoAddFacility(_ string: String, _ cordinates: CLLocationCoordinate2D)
//    }
//
//    protocol LocationBranchAndFacilityVCDelegate:class {
//        func sendlocationAddress(_ string: String, _ cordinates: CLLocationCoordinate2D)
//    }
//
//    class LocationVC: UIViewController {
//
//        @IBOutlet weak var mapView: GMSMapView!
//        @IBOutlet weak var viewCorner: UIView!
//        @IBOutlet weak var txtFieldLocation: UITextField! {
//            didSet {
//            let redPlaceholderText = NSAttributedString(string: "Search Address",
//                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//
//                txtFieldLocation.attributedPlaceholder = redPlaceholderText
//        }
//        }
//        @IBOutlet weak var viewLocationAddress: UIView!
//        @IBOutlet weak var lblAddressLocation: UILabel!
//        @IBOutlet weak var viewClose: UIView!
//        @IBOutlet weak var btnLocationConfirmed: UIButton!
//        @IBOutlet var viewLandmark: UIView!
//        @IBOutlet var txtFieldLandMakr: UITextField!
//        @IBOutlet var viewPincode: UIView!
//        @IBOutlet var txtFieldPincode: UITextField!
//
//        let locationManager = CLLocationManager()
//        var latitude = ""
//        var longitude = ""
//        var currentLocation = CLLocationCoordinate2D()
//
//        var placemark: CLPlacemark?
//        var address = ""
//        var pincode = ""
//        var city = ""
//        var state = ""
//        var country = ""
//        var lat = ""
//        var long = ""
//        var selected_Address = ""
//        var selected_cordinates = CLLocationCoordinate2D()
//        weak var delegate: LocationNameVCDelegate?
//        weak var AddFacility_Delegate : LocationAddFacilityVCDelegate?
//        weak var Add_Branch_Facility_Delegate : LocationBranchAndFacilityVCDelegate?
//
//        struct Address {
//            let name: String
//            let long: CLLocationDegrees
//            let lat: CLLocationDegrees
//        }
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//
//            mapView.delegate = self
//            locationManager.delegate = self
//            self.locationManager.startUpdatingLocation()
//            mapView.isMyLocationEnabled = true
//
//            let geocoder = CLGeocoder()
//            let location = CLLocation(latitude: Double(appDelegate.Lat) ?? 0.0, longitude: Double(appDelegate.Long) ?? 0.0)
//
//            geocoder.reverseGeocodeLocation(location) { placemarks, error in
//                guard let placemark = placemarks?.first else {
//                    print("No placemarks found.")
//                    return
//                }
//
//                // Use the placemark's properties to get the desired address information.
//                let address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
//
//                self.lblAddressLocation.text = address
//                self.txtFieldLandMakr.text = placemark.subLocality
//                self.txtFieldPincode.text = placemark.postalCode
//                self.selected_Address = address
//                self.selected_cordinates = CLLocationCoordinate2D(latitude: Double(appDelegate.Lat) ?? 0.0, longitude: Double(appDelegate.Long) ?? 0.0)
//                self.showCurrentLocationOnMap(lat: Double(appDelegate.Lat) ?? 0.0, long: Double(appDelegate.Long) ?? 0.0)
//
//                print(address)
//            }
//
//
//    //        if CLLocationManager.locationServicesEnabled() {
//    //            locationManager.requestLocation()
//    //            mapView.isMyLocationEnabled = true
//    //            mapView.settings.myLocationButton = true
//    //        } else {
//    //            locationManager.requestWhenInUseAuthorization()
//    //        }
//
//            DispatchQueue.main.async {
//                self.view.layoutIfNeeded()
//                self.viewCorner.layer.cornerRadius = 20
//                self.viewCorner.layer.borderWidth = 1
//                self.viewCorner.layer.borderColor = AppColor.Color_TopHeader.cgColor
//                self.viewCorner.layer.shadowColor = UIColor.lightGray.cgColor
//                self.viewCorner.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.viewCorner.layer.shadowOpacity = 2.0
//                self.viewCorner.layer.shadowRadius = 3.0
//                self.viewCorner.layer.masksToBounds = false
//
//                self.viewLocationAddress.layer.cornerRadius = 20
//                self.viewLocationAddress.layer.borderWidth = 1
//                self.viewLocationAddress.layer.borderColor = AppColor.Color_TopHeader.cgColor
//                self.viewLocationAddress.layer.shadowColor = UIColor.lightGray.cgColor
//                self.viewLocationAddress.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.viewLocationAddress.layer.shadowOpacity = 2.0
//                self.viewLocationAddress.layer.shadowRadius = 3.0
//                self.viewLocationAddress.layer.masksToBounds = false
//
//                self.viewLandmark.layer.cornerRadius = 20
//                self.viewLandmark.layer.borderWidth = 1
//                self.viewLandmark.layer.borderColor = AppColor.Color_TopHeader.cgColor
//                self.viewLandmark.layer.shadowColor = UIColor.lightGray.cgColor
//                self.viewLandmark.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.viewLandmark.layer.shadowOpacity = 2.0
//                self.viewLandmark.layer.shadowRadius = 3.0
//                self.viewLandmark.layer.masksToBounds = false
//
//                self.viewPincode.layer.cornerRadius = 20
//                self.viewPincode.layer.borderWidth = 1
//                self.viewPincode.layer.borderColor = AppColor.Color_TopHeader.cgColor
//                self.viewPincode.layer.shadowColor = UIColor.lightGray.cgColor
//                self.viewPincode.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.viewPincode.layer.shadowOpacity = 2.0
//                self.viewPincode.layer.shadowRadius = 3.0
//                self.viewPincode.layer.masksToBounds = false
//
//                self.viewClose.layer.cornerRadius = self.viewClose.layer.bounds.height / 2
//                self.viewClose.layer.shadowColor = UIColor.lightGray.cgColor
//                self.viewClose.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.viewClose.layer.shadowOpacity = 2.0
//                self.viewClose.layer.shadowRadius = 3.0
//                self.viewClose.layer.masksToBounds = false
//
//                self.btnLocationConfirmed.layer.cornerRadius = 20
//                self.btnLocationConfirmed.layer.shadowColor = UIColor.lightGray.cgColor
//                self.btnLocationConfirmed.layer.shadowOffset = CGSize(width: 5, height: 5)
//                self.btnLocationConfirmed.layer.shadowOpacity = 2.0
//                self.btnLocationConfirmed.layer.shadowRadius = 3.0
//                self.btnLocationConfirmed.layer.masksToBounds = false
//                self.btnLocationConfirmed.layoutIfNeeded()
//            }
//        }
//
//        override func viewWillAppear(_: Bool) {
//            super.viewWillAppear(true)
//
//            //GroupieObject().setStatusBar(view)
//        }
//
//        func reverseGeocode(coordinate: CLLocationCoordinate2D) {
//            let geocoder = GMSGeocoder()
//
//            geocoder.reverseGeocodeCoordinate(coordinate) { response, _ in
//                guard
//                    let address = response?.firstResult(),
//                    let lines = address.lines
//                else {
//                    return
//                }
//
//                self.lblAddressLocation.text = lines.joined(separator: "\n")
//                self.selected_Address = lines.joined(separator: "\n")
//                UIView.animate(withDuration: 0.25) {
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
//
//        func showCurrentLocationOnMap(lat:Double,long:Double) {
//            var bounds = GMSCoordinateBounds()
//
//            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
//            print("location: \(location)")
//
//            let marker = GMSMarker()
//
//            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10)
//            mapView.delegate = self
//
//            var noDataLbl: UILabel?
//            noDataLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 30))
//            noDataLbl?.textAlignment = .center
//            noDataLbl?.font = UIFont(name: "Montserrat", size: 18.0)
//            noDataLbl?.numberOfLines = 0
//            noDataLbl?.textColor = UIColor.white
//            noDataLbl?.lineBreakMode = .byTruncatingTail
//            marker.position = location
//            marker.snippet = lblAddressLocation.text ?? ""
//            marker.map = mapView
//            bounds = bounds.includingCoordinate(marker.position)
//
//    //        mapView.setMinZoom(1, maxZoom: 15) // prevent to over zoom on fit and animate if bounds be too small
//    //        mapView.setMinZoom(1, maxZoom: 20) // allow the user zoom in more than level 15 again
//
//    //        let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
//    //        mapView.animate(with: update)
//        }
//
//        @IBAction func btnLocationAction(_ sender: Any) {
//    //        let autocompleteController = GooglePlacesSearchController(delegate: self, apiKey: "AIzaSyBnPjheD0bIGUtTdZ9SZ4r9oiXBxLWBIMQ", placeType: .all)
//            let autocompleteController = GooglePlacesSearchController(delegate: self, apiKey: "AIzaSyAKGLnCmn2mehjofF4yo7srYwV6xIC-udQ", placeType: .all)
//
//            // Display the autocomplete view controller.
//            present(autocompleteController, animated: true, completion: nil)
//
//        }
//
//        @IBAction func btnLocationConfirmedAction(_ sender: Any) {
//            self.navigationController?.popViewController(animated: true, completion: { [self] in
//                self.delegate?.sendlocationName(selected_Address, selected_cordinates)
//                self.AddFacility_Delegate?.sendlocationtoAddFacility(selected_Address, selected_cordinates)
//                self.Add_Branch_Facility_Delegate?.sendlocationAddress(selected_Address, selected_cordinates)
//                })
//        }
//
//        @IBAction func btnCloseAction(_ sender: Any) {
//
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//
//    // MARK: - CLLocationManagerDelegate
//    extension LocationVC: CLLocationManagerDelegate {
//
//        func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//            guard status == .authorizedWhenInUse else {
//                return
//            }
//
//            locationManager.requestLocation()
//
//            mapView.isMyLocationEnabled = true
//            mapView.settings.myLocationButton = true
//        }
//
//        func locationManager(_: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
//            guard let location = locations.last else {
//                return
//            }
//
//            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17.0)
//
//            self.mapView?.animate(to: camera)
//
//                //Finally stop updating location otherwise it will come again and again in this delegate
//            self.locationManager.stopUpdatingLocation()
//        }
//
//        func locationManager(_: CLLocationManager, didFailWithError error: Error) {
//            print(error)
//        }
//    }
//
//    // MARK: - GMSMapViewDelegate
//
//    extension LocationVC: GMSMapViewDelegate {
//
//        func mapView(_: GMSMapView, idleAt position: GMSCameraPosition) {
//            DispatchQueue.main.async {
//                self.reverseGeocode(coordinate: position.target)
//            }
//        }
//
//        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//            if gesture {
//                mapView.selectedMarker = nil
//            }
//        }
//
//        func mapView(_: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
//            guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
//                return nil
//            }
//
//            let str = marker.snippet ?? ""
//            lblAddressLocation.text = str
//            print(str)
//
//            return infoView
//        }
//
//        func mapView(_: GMSMapView, didTap _: GMSMarker) -> Bool {
//            return false
//        }
//
//        func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//            mapView.selectedMarker = nil
//            return false
//        }
//    }
//
//    extension Double {
//        /// Rounds the double to decimal places value
//        func rounded(toPlaces places: Int) -> Double {
//            let divisor = pow(10.0, Double(places))
//            return (self * divisor).rounded() / divisor
//        }
//    }
//
//
//    extension LocationVC: GooglePlacesAutocompleteViewControllerDelegate {
//        func viewController(didAutocompleteWith place: PlaceDetails) {
//
//            showCurrentLocationOnMap(lat: place.coordinate!.latitude, long: place.coordinate!.longitude)
//
//            print(place)
//            print("Place name: \(place.administrativeArea ?? "")")
//            print("Place: \(place.locality ?? "")")
//            lblAddressLocation.text = place.formattedAddress
//            txtFieldLandMakr.text = place.subLocality
//            txtFieldPincode.text = place.postalCode
//            selected_Address = place.formattedAddress
//            selected_cordinates = place.coordinate!
//
//            self.viewLandmark.layer.cornerRadius = 20
//            self.viewLandmark.layer.borderWidth = 1
//            self.viewLandmark.layer.borderColor = AppColor.Color_TopHeader.cgColor
//            self.viewLandmark.layer.shadowColor = UIColor.lightGray.cgColor
//            self.viewLandmark.layer.shadowOffset = CGSize(width: 5, height: 5)
//            self.viewLandmark.layer.shadowOpacity = 2.0
//            self.viewLandmark.layer.shadowRadius = 3.0
//            self.viewLandmark.layer.masksToBounds = false
//
//            self.viewPincode.layer.cornerRadius = 20
//            self.viewPincode.layer.borderWidth = 1
//            self.viewPincode.layer.borderColor = AppColor.Color_TopHeader.cgColor
//            self.viewPincode.layer.shadowColor = UIColor.lightGray.cgColor
//            self.viewPincode.layer.shadowOffset = CGSize(width: 5, height: 5)
//            self.viewPincode.layer.shadowOpacity = 2.0
//            self.viewPincode.layer.shadowRadius = 3.0
//            self.viewPincode.layer.masksToBounds = false
//            self.dismiss(animated: true, completion: nil)
//        }
//
//        func viewController(didManualCompleteWith text: String) {
//            print("Manual Search Text Address----->",text)
//        }
//    }
//
