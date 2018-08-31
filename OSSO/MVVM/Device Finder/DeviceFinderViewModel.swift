//
//  DeviceFinderViewModel.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

class DeviceFinderViewModel: NSObject{
    
    var discoveredDevices: Bindable<[OSSODeviceManager.Device]> = Bindable([])
    var currentlyConnectedDevice: Bindable<OSSODeviceManager.Device?> = Bindable(nil)
    var devicePendingConnection: OSSODeviceManager.Device?
    var connected: Bindable<Bool> = Bindable(false)

    override init() {
        super.init()
        ossoDeviceManager.delegate = self
    }
    
    func startSearchingForDevices(){
        ossoDeviceManager.searchForDevices { [weak self] (device) in
            print("Discovered New Device: \(device)")
            //self?.discoveredDevices.value.append(device)
            if device.advData.localName == "BlueNRG"{
                
                print("<====================== FOUND BLUENRG ======================>")
                self?.discoveredDevices.value.append(device)
                //ossoDeviceManager.stopSearchingForDevices()
                //ossoDeviceManager.connectTo(device: device)
            }
        }
    }
    
    func stopSearchingForDevices(){
        ossoDeviceManager.stopSearchingForDevices()
    }
    
    
    func connect(toDevice device: OSSODeviceManager.Device){
        ossoDeviceManager.stopSearchingForDevices()
        devicePendingConnection = device
        ossoDeviceManager.connectTo(device: device)
    }
    
}


extension DeviceFinderViewModel: OSSODeviceManagerDelegate{
    
    func deviceManager(didConnectTo device: CBPeripheral) {
        self.connected.value = true
    }
    
    func deviceManager(didDisconnectFrom device: CBPeripheral) {
        currentlyConnectedDevice.value = nil
        self.connected.value = false
        
    }
}
