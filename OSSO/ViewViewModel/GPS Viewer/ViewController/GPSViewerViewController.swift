//
//  GPSViewerViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2019 SDC Future Electronics. All rights reserved.
//

import UIKit
import MapKit

class GPSViewerViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gpsTextLog: UITextView!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var coordinateLabelContainer: UIView!
    @IBOutlet weak var centerMapButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.futureelectronics.com/policies/privacy-policy/")! as URL, options: [:], completionHandler:nil)
        self.privacyButton.isHidden = true
    }
    
    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var ossoLocation: CLLocation?
    var locationSet = false
    var ossoLocationSet = false
    let regionRadius: CLLocationDistance = 25000
    let initialLocation = CLLocation(latitude: 40.8205638, longitude: -91.1407439)
    
    let focusButton = UIButton();
    
    var viewModel: GPSViewerViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        privacyButton.layer.cornerRadius = 5
        centerMapButton.layer.cornerRadius = 25
        viewModel = GPSViewerViewModel()
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isZoomEnabled = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        centerMapOnLocation(location: initialLocation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // Do any additional setup after loading the view.
        
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()//requestAlwaysAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        self.navigationController?.navigationBar.topItem?.title = "Location"
        setupBindings()
    }
    
    @IBAction func reCenterButtonPressed(_ sender: UIButton) {
        
        if let location = ossoLocation{
            self.centerMapOnLocation(location: location)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.navigationController?.navigationBar.topItem?.title = "Location"
        locationSet = false
        ossoLocationSet = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupBindings(){
        
        viewModel.cllocation.bind { (newLocation) in
            
            //guard let location = newLocation else { self.gpsTextLog.text = self.gpsTextLog.text + "bad location"; return }
            if let newlat = newLocation?.latitude, let newLon = newLocation?.longitude{
                let validLocation = CLLocation(latitude: newlat, longitude: newLon)
                if !self.ossoLocationSet {
                    self.ossoLocationSet = true
                    self.centerMapOnLocation(location: validLocation)
                }

                self.ossoLocation = validLocation
                self.coordinateLabel.text = "Lon: \(newLon), Lat: \(newlat)"
                self.myAnnotation.coordinate = CLLocationCoordinate2DMake(newlat, newLon);
                self.myAnnotation.title = "Current location"
                self.mapView.addAnnotation(self.myAnnotation)
            }
            else {
                let validLocation = CLLocation(latitude: 0, longitude: 0)
                //self.centerMapOnLocation(location: validLocation)
//                let myAnnotation: MKPointAnnotation = MKPointAnnotation()
//                myAnnotation.coordinate = CLLocationCoordinate2DMake(newLocation.latitude, newLocation.longitude);
//                myAnnotation.title = "Current location"
//                self.mapView.addAnnotation(myAnnotation)
            }
        }
    }


}

extension GPSViewerViewController{
    //FORCE CENTER MAP ON SPECIFIED LOCATION
    func centerMapOnLocation(location: CLLocation)
    {
        if location.coordinate.latitude == 0 && location.coordinate.longitude == 0{
            coordinateLabel.text = "NO GPS"
            return
        }
        
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        let lon = Float(Int(location.coordinate.longitude * 1_000_000))/1_000_000
        let lat = Float(Int(location.coordinate.latitude * 1_000_000))/1_000_000
        
        coordinateLabel.text = "Lon: \(lon), Lat: \(lat)"
        //
        coordinateLabel.textAlignment = .center
        //coordinateLabel.sizeToFit()
    }
}

//MARK: LOCATION RELATED
extension GPSViewerViewController: CLLocationManagerDelegate
{
    //LOCATION MANAGER UPDATED LOCATIONS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if !locationSet{
            locationSet = true
            currentLocation = locationManager.location
            centerMapOnLocation(location: currentLocation!)
            mapView.showsUserLocation = true
        }
    }
    
}

