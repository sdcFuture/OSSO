//
//  SensorViewViewModel.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation


class SensorViewViewModel: NSObject{
    
    var testHumidity: Bindable<String> = Bindable("")
    var humidity: Bindable<Float?> = Bindable(nil)
    var temperature: Bindable<Float?> = Bindable(nil)
    var uvaUvb: Bindable<Float?> = Bindable(nil)
    var gyroscope: Bindable<Float?> = Bindable(nil)
    var accelerometer: Bindable<TriAxis?> = Bindable(nil)
    var pressure: Bindable<Float?> = Bindable(nil)
    
    override init() {
        super.init()
        ossoGatt.startNotifications()
        ossoGatt.enablePolling()
        beginUpdates()
        
    }
    
    func beginUpdates(){
        
        ossoGatt.ossoTempValue.bind { [weak self] (newTemp) in
            print("New Temp Value ")
            self?.temperature.value = newTemp
        }
        
        ossoGatt.ossoPressureValue.bind { [weak self] (newPressure) in
            self?.pressure.value = newPressure
        }
        
        ossoGatt.ossoAccelValue.bind { [weak self] (newAccel) in
            self?.accelerometer.value = newAccel
        }
        
        ossoGatt.ossoUvIndexValue.bind { [weak self] (newUvValue) in
            self?.uvaUvb.value = newUvValue
        }
        
        ossoGatt.ossoHumidity.bind { [weak self ](newHumidity) in
            self?.humidity.value = newHumidity
        }
        
    }
    
    
    func endUpdates(){
         
        ossoGatt.ossoTempValue.bind(listener: nil)
        ossoGatt.ossoPressureValue.bind(listener: nil)
        ossoGatt.ossoAccelValue.bind(listener: nil)
        ossoGatt.ossoUvIndexValue.bind(listener: nil)
    }
    
    
}







