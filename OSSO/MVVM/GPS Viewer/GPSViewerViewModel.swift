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
        ossoGatt.ossoGpsValue.bind { [weak self] (newCoordinate) in
            self?.cllocation.value = CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longtitude)
        }
    }
    
}
