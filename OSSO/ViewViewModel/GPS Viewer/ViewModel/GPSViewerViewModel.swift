//
//  GPSViewerViewModel.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreLocation

class GPSViewerViewModel: NSObject{
    
    var cllocation: Bindable<CLLocationCoordinate2D?> = Bindable(nil)
    
    override init() {
        super.init()
        setupBindings()
    }
    
    func setupBindings(){
        print("Set ViewModelGPS Bindings")
        ossoDeviceManager.connectedOSSO?.ossoGpsValue.bind{ [weak self] (newCoordinate) in
            
            //print("ViewModel updated location")
            self?.cllocation.value = CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longtitude)
        }
    }
    
}
