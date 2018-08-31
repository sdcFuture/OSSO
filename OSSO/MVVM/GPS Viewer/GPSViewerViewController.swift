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
    
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var locationSet = false
    let regionRadius: CLLocationDistance = 25000
    let initialLocation = CLLocation(latitude: 40.8205638, longitude: -91.1407439)
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    /*
    //OVERLAY RENDERER
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("is rendererForOverlay being called???")
        if overlay.isKind(of: MKCircle.self){
            
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            
            switch overlay.title!!{
            case "primaryCircle": print("was able to identify primary circle")
            circleRenderer.fillColor = UIColor.winegardGreen.withAlphaComponent(0.75)
                
            case "secondaryCircle":
                circleRenderer.fillColor = UIColor.winegardYellow.withAlphaComponent(0.125)
                
            case "tertiaryCircle":
                circleRenderer.fillColor = UIColor.winegardRed.withAlphaComponent(0.125)
                
            default:print("Probs wont work")
            }
            print("Added circle overlay")
            
            //.blueColor().colorWithAlphaComponent(0.1)
            
            circleRenderer.lineWidth = 1
            return circleRenderer
            
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    //ADD COLORED CIRCLES AROUND USER LOCTATION TO INDICATE WHICH TOWERS ARE IN RANGE
    func addCircles()
    {
        let primaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 20000)
        primaryCircle.title = "primaryCircle"
        
        let secondaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 30000)
        secondaryCircle.title = "secondaryCircle"
        
        let tertiaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 40000)
        tertiaryCircle.title = "tertiaryCircle"
        
        mapView.addOverlays([tertiaryCircle, secondaryCircle, primaryCircle ])
        //mapView.renderer(for: userCenterCircle)
    }
 */
}

