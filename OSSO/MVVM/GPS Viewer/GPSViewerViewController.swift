//
//  GPSViewerViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import UIKit
import MapKit

class GPSViewerViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latitudeValueLabel: UILabel!
    @IBOutlet weak var longitudeValueLabel: UILabel!
    
    @IBOutlet weak var gpsTextLog: UITextView!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var locationSet = false
    let regionRadius: CLLocationDistance = 25000
    let initialLocation = CLLocation(latitude: 40.8205638, longitude: -91.1407439)
    
    
    var viewModel: GPSViewerViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        setupBindings()
    }
    
    func setupBindings(){
        
        viewModel.cllocation.bind { (newLocation) in
            
            guard let location = newLocation else { self.gpsTextLog.text = self.gpsTextLog.text + "bad location"; return }
            let validLocation = CLLocation(latitude: (newLocation?.latitude)!, longitude: (newLocation?.longitude)!)
            self.centerMapOnLocation(location: validLocation)
            
            self.latitudeValueLabel.text = "\(Double(round(1000*(newLocation?.latitude)!)/1000))"
            self.longitudeValueLabel.text = "\(Double(round(1000*(newLocation?.longitude)!)/1000))"
            
            print("New Location: \(newLocation)")
        }
        
        ossoGatt.rawGps.bind { (newGps) in
            //self.gpsTextLog.text = "\n" + self.gpsTextLog.text + " RAW DATA: " + newGps
        }
        
    }


}

extension GPSViewerViewController{
    //FORCE CENTER MAP ON SPECIFIED LOCATION
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
            
            if let lat = currentLocation?.coordinate.latitude, let lon = currentLocation?.coordinate.longitude{
                self.latitudeValueLabel.text = "\(Double(round(1000*lat)/1000))"
                self.longitudeValueLabel.text = "\(Double(round(1000*lon)/1000))"
            }
        }
    }
    
}

