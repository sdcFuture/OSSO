//
//  DeviceFinderViewModel.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2019 SDC Future Electronics. All rights reserved.
//

import Foundation
import CoreBluetooth

class DeviceFinderViewModel: NSObject{
    
    var discoveredOssoBoards: Bindable<[OSSO]> = Bindable([])
    
    override init() {
        super.init()
        setupBindings()
    }
    
    func setupBindings(){
        
        ossoDeviceManager.discoveredOssoBoards.bind{ (boards) in
            self.discoveredOssoBoards.value = boards
            print("Updated discovered osso boards \(boards)")
        }
        
    }
    
    func cancelConnections(){
        ossoDeviceManager.disconnectOsso()
    }
    
    
}
