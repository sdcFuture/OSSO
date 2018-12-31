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
    
    var discoveredOssoBoards: Bindable<[OSSO]> = Bindable([])
    var connectedOSSO: OSSO?
    private var onConnection: (()->Void)?
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
    
    private var bleReady = false
    private var _discoveredOssoBoards: [UUID: OSSO] = [:]
    private var pendingConnection: OSSO?

    
    init(){
        
        print("Initializing TeknestThingsManager")
        //teknestPhoneControls = TeknestPhoneControlsAPI()
        /*  Defining GATT profile on instantiation for now, will move gattProfile object creation to
         after connecting to a thing and we have determined what Thing it is
         Update: added setNewGatt method to super class, this is being called now
         */
        super.init(jableDelegate: nil, gattProfile: OSSOGatt().gattProfile, autoGattDiscovery: true)
        super.setJableDelegate(jableDelegate: self)
    }
    
}

//MARK: TeknestThingsAPI Protocol implimentation
extension OSSODeviceManager {
    
    /*  Starting searching for Things */
    func searchForDevices() {
        super.startScanningForPeripherals(withServiceUUIDs: nil)
    }
    
    /*  Stop searching for Things */
    func stopSearchingForDevices(){
        super.stopScanning()
    }
    
    func connect(osso: OSSO, _ withCompletion: (()->Void)?){
        self.onConnection = withCompletion
        guard let peripheral = osso.associatedPeripheral else { return }
        pendingConnection = osso
        setNewGatt(gattProfile: osso.gattProfile?.gattProfile)
        super.connect(toPeripheral: peripheral, withTimeout: 5)
    }
    
    
    /*  diconnect from the specified Thing instance */
    func disconnectOsso() {
        if let connectedOsso = connectedOSSO{
            connectedOsso.willDisconnect()
            self.getCentralManagerInstance().cancelPeripheralConnection(connectedOsso.associatedPeripheral)
        }
    }
}

//MARK: JABLEDelegate
extension OSSODeviceManager: JABLEDelegate
{
    
    internal func jable(isReady: Void) {
        bleReady = true
        super.startScanningForPeripherals(withServiceUUIDs: nil)

    }
    
    /*  Called by JABLE framework when a BLE peripheral is discovered  */
    internal func jable(foundPeripheral peripheral: CBPeripheral, advertisementData: FriendlyAdvdertismentData) {

        guard advertisementData.localName == "BlueNRG" else { return }
        print("FOUND OSSO")
        let newOsso = OSSO(withPeripheral: peripheral)
        if let rssi = advertisementData.rssi{
            newOsso.lastRSSI = rssi
        }

        _discoveredOssoBoards[peripheral.identifier] = newOsso
        discoveredOssoBoards.value = _discoveredOssoBoards.map{
            return $0.value
        }
    }
    
    internal func jable(completedGattDiscovery: Void) {
        onConnection?()
        connectedOSSO = pendingConnection
        pendingConnection?.didConnect()
        pendingConnection = nil
    }
    
    internal func jable(updatedCharacteristicValueFor characteristic: CBCharacteristic, value: Data, onPeripheral peripheral: CBPeripheral) {
        //print("New Value")
        
        /*  Should call function method on OSSGatt*/
        connectedOSSO?.newValue(forCharacteristic: characteristic)
        /*  Send update to Thing instance to process occording to Thing type*/
        //print("PERIPHERAL ENTRY = \(_discoveredThings[peripheral]?.thing.associatedPeripheral)")
    }
    
    internal func jable(connectedTo peripheral: CBPeripheral) {
        
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
