//
//  OSSDeviceManager.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation

import Foundation
import JABLE
import CoreBluetooth

protocol OSSODeviceManagerDelegate{
    func deviceManager(didConnectTo device: CBPeripheral)
    func deviceManager(didDisconnectFrom device: CBPeripheral)
}

let ossoDeviceManager = OSSODeviceManager()

/*  Impliment bluetooth api inside TeknestCore but move other apis to their own classes */
class OSSODeviceManager: JABLE{
    
    struct Device{
        var peripheral: CBPeripheral
        var advData: FriendlyAdvdertismentData
    }
    
    /* used for tracking when start scanning is called before BLE radio is ready */
    enum ScanStatus{
        case scanning
        case stopped
        case pendingStart
    }
    
    /* keep track of connection state */
    enum ConnectionState{
        case pendingConnection
        case disconnected
        case connected
        case multipleConnected
        case uknown
    }
    
    /* internal reference variables */
    internal var _discoveredPeripherals: [(peripheral: CBPeripheral, advData: FriendlyAdvdertismentData)] = []
    
    /*  Dictionary for peripheral getting associated Thing for peripheral instance */
    internal var _discoveredDevices: [Device] = []
    internal var lastDeviceConnected: Device?
    internal var _ready: Bool = false
    internal var ossoDelegate: OSSODeviceManagerDelegate?
    
    /* Bindable variable instanced */
    var scanStatus: Bindable<ScanStatus> = Bindable(ScanStatus.stopped)
    var connectionState: Bindable<ConnectionState> = Bindable(ConnectionState.disconnected)
    
    var connectedDevices: [Device] = []
    
    var delegate: OSSODeviceManagerDelegate?
    
    private var deviceDiscoveryHandler: ((Device) -> Void)?
    
    init(){
        
        print("Initializing TeknestThingsManager")
        //teknestPhoneControls = TeknestPhoneControlsAPI()
        /*  Defining GATT profile on instantiation for now, will move gattProfile object creation to
         after connecting to a thing and we have determined what Thing it is
         Update: added setNewGatt method to super class, this is being called now
         */
        super.init(jableDelegate: nil, gattProfile: &ossoGatt.gattProfile, autoGattDiscovery: true)
        super.setJableDelegate(jableDelegate: self)
    }
}

//MARK: TeknestThingsAPI Protocol implimentation
extension OSSODeviceManager {
    
    /* Retrieve a list of the "Things" that are currently connected*/
    func getConnectedDevices() -> [Device] {
        return connectedDevices
    }
    
    
    /*  Starting searching for Things */
    func searchForDevices(deviceHandler: ((Device) -> Void)?) {
        
        if deviceHandler != nil{
            self.deviceDiscoveryHandler = deviceHandler
        }
        
        if !_ready{
            scanStatus.value = .pendingStart
        }else{
            super.startScanningForPeripherals(withServiceUUIDs: nil)
            scanStatus.value = .scanning
        }
    }
    
    /*  Stop searching for Things */
    func stopSearchingForDevices(){
        
        if scanStatus.value == .scanning{
            super.stopScanning()
            scanStatus.value = .stopped
        }
    }
    
    /*  Attempt to connect to the peripheral associated with the Thing specified */
    func connectTo(device: Device) {
        
        super.connect(toPeripheral: device.peripheral, withTimeout: 5)
        
        /* save reference because we want to reference when gatt discovery completes */
        lastDeviceConnected = device
    }
    
    /*  diconnect from the specified Thing instance */
    func disconnectFrom(device: Device) {
        
    }
    
}

//MARK: JABLEDelegate
extension OSSODeviceManager: JABLEDelegate
{
    
    internal func jable(isReady: Void) {
        
        print(": Bluetooth Ready\n")
        
        _ready = true
        
        if scanStatus.value == .pendingStart{
            
            /* start scanning for peripherals without specifying service uuids */
            super.startScanningForPeripherals(withServiceUUIDs: nil)
            
            /* update internal scan status*/
            scanStatus.value = .scanning
        }
    }
    
    /*  Called by JABLE framework when a BLE peripheral is discovered  */
    internal func jable(foundPeripheral peripheral: CBPeripheral, advertisementData: FriendlyAdvdertismentData) {
        
        /* initialize with Thing object when identified */
        //var _discoveredDevice: Device?
        
//        switch peripheral.name{
//        case "Thingy":
//            guard _discoveredThings[peripheral] == nil else{ break }
//            _discoveredThing = NordicThingy(peripheralToAssociate: peripheral)
//        case "BBC micro:bit":
//            _discoveredThing = microbit(peripheralToAssociate: peripheral)
//        default:
//            break
//        }
        
        //guard let discoveredDevice = _discoveredDevice else { return }
        
        /*  Add dictionary entry to associate so we can call correct peripheral later */
        //_discoveredThings[peripheral] = (discoveredThing, advertisementData)
        
        /*  Call delegate method with the found Thing */
        //_teknestThingDiscoveryDelegate?.foundThing(thing: discoveredThing)
        
        let discoveredDevice = Device(peripheral: peripheral, advData: advertisementData)
        
        self.deviceDiscoveryHandler?(discoveredDevice)
        
        //  Check for duplicate, if duplicate then update dat
        var duplicate = false
        
        
        //  Check if the peripheral found matches one in the current list and if so replace its data with the new data
        let new = _discoveredPeripherals.map({ (oldPeripheral, oldAdvDa)  -> (CBPeripheral, FriendlyAdvdertismentData) in
            
            if oldPeripheral == peripheral{// duplicate found
                
                duplicate = true
                var advDataCopy = advertisementData
                advDataCopy.seen = oldAdvDa.seen + 1
                advDataCopy.advIntervalEstimate = (advertisementData.timeStamp!.timeIntervalSince(oldAdvDa.timeStamp!)/Double(advDataCopy.seen)*1000*(1.2))
                advDataCopy.timeStamp = oldAdvDa.timeStamp
                return (peripheral, advDataCopy)
                
            }else{//  not a duplicate
                return (oldPeripheral, oldAdvDa)
            }
        })
        
        //  Use new list if duplicate else append new peripheral
        guard duplicate == false else {
            //print("Duplicate found")
            _discoveredPeripherals = new
            return
        }
    }
    
    internal func jable(completedGattDiscovery: Void) {
        
        
        ossoGatt.gattDiscoveryCompleted()
        guard let lastConnected = lastDeviceConnected else {
            return
        }
        /*  Call delegate method after gatt discovery has completed */
        //_teknestThingDiscoveryDelegate?.connectedToThing(thing: lastConnected)
        
        /* called method on Thing to notify of setup completion */
        //lastConnected.teknestCoreConnectedToThisThing()
        
        connectedDevices.append(lastConnected)
        
        //print("TeknestCore _discoveredThings = \(_discoveredDevices)")
        
    }
    
    internal func jable(updatedCharacteristicValueFor characteristic: CBCharacteristic, value: Data, onPeripheral peripheral: CBPeripheral) {
        
        /*  Should call function method on OSSGatt*/
        ossoGatt.newValue(forCharacteristic: characteristic, value: value)
        
        /*  Send update to Thing instance to process occording to Thing type*/
        //_discoveredThings[peripheral]?.thing.newValueRecievedForCharacteristic(characteristic: characteristic)
        
        //print("PERIPHERAL ENTRY = \(_discoveredThings[peripheral]?.thing.associatedPeripheral)")
    }
    
    internal func jable(connectedTo peripheral: CBPeripheral) {
        
        delegate?.deviceManager(didConnectTo: peripheral)
        //print("TeknestCore _discoveredThings = \(_discoveredThings)")
        //_discoveredThings[peripheral]?.teknestCoreConnectedToThisThing()
    }
    
    internal func jable(disconnectedWithReason reason: Error?, from peripheral: CBPeripheral) {
        
        //_teknestThingDiscoveryDelegate?.disconnectedFromThing(thing: (_discoveredThings[peripheral]?.thing)!, withReason: reason)
        
        /* remove after called delegate */
        //_discoveredThings = _discoveredThings.filter { $0.key != peripheral }
        
        //print("TeknestCore _discoveredThings = \(_discoveredThings)")
    }
    
    internal func jable(updatedRssi rssi: Int, forPeripheral peripheral: CBPeripheral) {
        //_discoveredThings[peripheral]?.thing.updatedRssi(to: rssi)
    }
    
    
    internal func jable(updatedDescriptorValueFor descriptor: CBDescriptor, value: Data) {}
    
    /*  we are utilizing auto JABLE auto gatt discovery so this will not be called */
    internal func jable(foundCharacteristicsFor service: CBService, characteristics: [CBCharacteristic]) {}
    internal func jable(foundServices services: [CBService]) {}
    internal func jable(foundDescriptorsFor characteristic: CBCharacteristic, descriptors: [CBDescriptor]) {}
}
