//
//  DeviceFinderViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import UIKit


let debug = false

class DeviceFinderViewController: UIViewController {
    
    @IBOutlet weak var discoveredDevicesTableView: UITableView!
    
    var viewModel: DeviceFinderViewModel!
    
    var discoveredDevicesCopy: [OSSODeviceManager.Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DeviceFinderViewModel()
        discoveredDevicesTableView.delegate = self
        discoveredDevicesTableView.dataSource = self
        viewModel.startSearchingForDevices()
        setupBindings()
        
        // Do any additional setup after loading the view.
    }
    
    func setupBindings(){
        
        viewModel.discoveredDevices.bind { [weak self] (devices) in
            print("DISCOVERED DEVICES LIST UPDATED: \(devices)")
            self?.discoveredDevicesCopy = devices
            self?.discoveredDevicesTableView.reloadData()
        }
        
        
        viewModel.connected.bind { [weak self] (isConnected) in
            
            if isConnected{
                //SETUP TRANSISTION TO TAB VIEW CONTROLLER
                let transistion = CATransition()
                transistion.subtype = kCATransitionReveal
                self?.view.window!.layer.add(transistion, forKey: kCATransition)
                let newView = self?.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
                
                //TRANSISTION TO TABVIEW CONTROLLER
                self?.navigationController?.show(newView, sender: self)
            }
        }
    }
    
    
    
}



extension DeviceFinderViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if debug{
            
            //SETUP TRANSISTION TO TAB VIEW CONTROLLER
            let transistion = CATransition()
            transistion.subtype = kCATransitionReveal
            self.view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
            
            //TRANSISTION TO TABVIEW CONTROLLER
            self.navigationController?.show(newView, sender: self)
            
        } else {
            viewModel.connect(toDevice: discoveredDevicesCopy[indexPath.row])
        }
        
    }
    
}

extension DeviceFinderViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if debug{
            return 1
        } else {
            return discoveredDevicesCopy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if debug {
            cell.textLabel?.text = "Test Device"
        } else {
            cell.textLabel?.text = discoveredDevicesCopy[indexPath.row].advData.localName
        }

        return cell
    }

}






