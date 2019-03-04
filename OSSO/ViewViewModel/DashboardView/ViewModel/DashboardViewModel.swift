//
//  DashboardViewModel.swift
//  OSSO
//
//  Created by Joe Bakalor on 12/26/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation


class DashboardViewModel: NSObject{
    
    var temperature: Bindable<Float> = Bindable(0)
    var irTemperature: Bindable<Float> = Bindable(0)
    var humidity: Bindable<Float> = Bindable(0)
    var battery: Bindable<Float> = Bindable(0)
    var uvIndex: Bindable<Int> = Bindable(0)
    var uvExposure: Bindable<Int> = Bindable(0)
    var barks: Bindable<Int> = Bindable(0)
    var steps: Bindable<Int> = Bindable(0)
    var batteryLow: Bindable<Bool> = Bindable(false)
    
    override init() {
        super.init()
        setupBindings()
    }
    
    
    func setupBindings(){
        guard let osso = ossoDeviceManager.connectedOSSO else { return }
        
        osso.ossoUvIndexValue.bind{ (uvIndex) in
            self.uvIndex.value = uvIndex
            //print("DashboardViewModel :: New UV Index \(uvIndex)")
        }
        
        osso.ossoBatteryLow.bind{ (batteryStatus) in
            self.batteryLow.value = batteryStatus
        }
        
        osso.ossoSunExposureTime.bind{ (exposureTime) in
            self.uvExposure.value = exposureTime
            //print("DashboardViewModel :: New Exposure Time \(exposureTime)")
        }
        
        osso.ossoStepsValue.bind{ (steps) in
            self.steps.value = steps
        }
        
        osso.ossoTempValue.bind{ (newTemp) in
            self.temperature.value = newTemp
            //print("DashboardViewModel :: New Temp \(newTemp)")
        }
        
        osso.ossoIrTempValue.bind{ (newIRTemp) in
            self.irTemperature.value = newIRTemp
            //print("DashboardViewModel :: New IR Temp \(newIRTemp)")
        }
        
        osso.ossoUvIndexValue.bind{ (newUVIndex) in
            self.uvIndex.value = newUVIndex
            //print("DashboardViewModel :: New UV index \(newUVIndex)")
        }
        
        osso.ossoHumidity.bind{ (newHumidity) in
            self.humidity.value = newHumidity
            //print("DashboardViewModel :: New Humidity \(newHumidity)")
        }
        
        osso.ossoBarksValue.bind{ (numberOfBarks) in
            self.barks.value = numberOfBarks
            //print("DashboardViewModel :: New barks value \(numberOfBarks)")
        }
        
    }
    
}
