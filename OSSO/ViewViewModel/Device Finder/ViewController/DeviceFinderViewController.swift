//
//  DeviceFinderViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2019 SDC Future Electronics. All rights reserved.
//

import Foundation
import UIKit


let debug = false

class DeviceFinderViewController: UIViewController {
    
    @IBOutlet weak var discoveredDevicesTableView: UITableView!
    
    var viewModel: DeviceFinderViewModel?
    var tableData: [OSSO] = []
    
    var discoveredDevicesCopy: [OSSO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DeviceFinderViewModel()
        discoveredDevicesTableView.delegate = self
        discoveredDevicesTableView.dataSource = self
        setupBindings()
        discoveredDevicesTableView.separatorStyle = .none
        self.navigationController?.navigationBar.topItem?.title = "Device Finder"
        self.view.backgroundColor = UIColor.lightText
        self.discoveredDevicesTableView.backgroundColor = UIColor.lightText
        viewModel = DeviceFinderViewModel()
        setupBindings()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Device Finder"
         viewModel?.cancelConnections()
    }
    
    func setupBindings(){
        viewModel?.discoveredOssoBoards.bind{
            self.tableData = $0
            self.discoveredDevicesTableView.reloadData()
        }
    }
    
}



extension DeviceFinderViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if debug{
            
            //SETUP TRANSISTION TO TAB VIEW CONTROLLER
            let transistion = CATransition()
            transistion.type    = CATransitionType.reveal
            //transistion.subtype = CATransitionSubtype.fromBottom//CATransitionType.reveal
            self.view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
            
            //TRANSISTION TO TABVIEW CONTROLLER
            self.navigationController?.show(newView, sender: self)
            
        } else {
            displayActivityIndicatorAlert(withMessage: "Connecting")
            ossoDeviceManager.connect(osso: tableData[indexPath.row]){
                //SETUP TRANSISTION TO TAB VIEW CONTROLLER
                let transistion = CATransition()
                transistion.type    = CATransitionType.reveal
                //transistion.subtype = CATransitionType.reveal
                self.view.window!.layer.add(transistion, forKey: kCATransition)
                let newView = self.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as! UITabBarController
                
                //TRANSISTION TO TABVIEW CONTROLLER
                self.navigationController?.show(newView, sender: self)
                dismissActivityIndicatorAlert()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension DeviceFinderViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if debug{
            return 5
        } else {
            return tableData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = OssoDeviceTableViewCell()//UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.cellData = (rssi: tableData[indexPath.row].lastRSSI, index: indexPath.row)
        if debug {
            //cell.textLabel?.text = "Test Device"
        } else {
            //cell.textLabel?.text = discoveredDevicesCopy[indexPath.row].advData.localName
        }

        return cell
    }

}






import Foundation
import UIKit

extension UIAlertController {
    
    private struct ActivityIndicatorData {
        static var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    func addActivityIndicator() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 40,height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.blue
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        self.setValue(vc, forKey: "contentViewController")
    }
    
    func dismissActivityIndicator() {
        ActivityIndicatorData.activityIndicator.stopAnimating()
        self.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: false)
    }
}

var activityIndicatorAlert: UIAlertController?

func displayActivityIndicatorAlert(withMessage message: String) {
    
    activityIndicatorAlert = UIAlertController(
        title: message,//NSLocalizedString("Connecting", comment: ""),
        message: "",
        preferredStyle: UIAlertController.Style.alert)
    
    activityIndicatorAlert!.addActivityIndicator()
    var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
    while ((topController.presentedViewController) != nil) {
        topController = topController.presentedViewController!
    }
    topController.present(activityIndicatorAlert!, animated:true, completion:nil)
}

func dismissActivityIndicatorAlert() {
    activityIndicatorAlert?.dismissActivityIndicator()
    activityIndicatorAlert?.dismiss(animated: true, completion: nil) //= nil
}
