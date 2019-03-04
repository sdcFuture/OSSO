//
//  DashboardViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 12/11/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var SensorTableView: UITableView!
    private var viewModel: DashboardViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorTableView.delegate = self
        SensorTableView.dataSource = self
        SensorTableView.separatorStyle = .none
        self.navigationController?.navigationBar.topItem?.title = "Dashboard"
        viewModel = DashboardViewModel()
        setupBindings()
    }
    
    let titles: [String] = ["Temperature/Humidity", "IR Temperature", "Battery", "UV Index", "Barks", "Steps", "Firmware Version"]
    let images: [UIImage] = [
    UIImage(imageLiteralResourceName: "TempHumidity"),
    UIImage(imageLiteralResourceName: "IRTemp"),
    UIImage(imageLiteralResourceName: "Battery"),
    UIImage(imageLiteralResourceName: "UVIndex"),
    UIImage(imageLiteralResourceName: "DogBarking"),
    UIImage(imageLiteralResourceName: "PawPrint")]
    
    var cellData: [[(valueLabel: String, value: String)]] =
        [[(valueLabel: "Temperature", value: "10"), (valueLabel: "Humidity", value: "10")],
         [(valueLabel: "IR Temperature", value: "10")],
         [(valueLabel: "Level", value: "10")],
         [(valueLabel: "UV Index", value: "10"), (valueLabel: "Exposure Time", value: "10")],
         [(valueLabel: "Barks", value: "10")],
         [(valueLabel: "Steps", value: "10")],
         [(valueLabel: "", value: "2.0.1")]]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.navigationController?.navigationBar.topItem?.title = "Dashboard"
        self.SensorTableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    }
    
    func setupBindings(){
        
//        viewModel?.barks.bind{ (barks) in
//            print("Update Barks to  \(barks)")
//            self.cellData[4][0].value = barks
//            self.SensorTableView.reloadData()
//        }
        
    }
}

extension DashboardViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SensorTableViewCell(cellData: cellData[indexPath.row])
        switch indexPath.row {
        case 0:
            viewModel?.temperature.bind{ (newTemp) in
                self.cellData[indexPath.row][0].value = "\(newTemp) C"//Float(newTemp)
                cell.cellData = self.cellData[indexPath.row]
            }
            
            viewModel?.humidity.bind{ (newHumidity) in
                self.cellData[indexPath.row][1].value = "\(newHumidity) %"
                cell.cellData = self.cellData[indexPath.row]
            }
            
        case 1:
            
            viewModel?.irTemperature.bind{ (irTemp) in
                self.cellData[indexPath.row][0].value = "\(irTemp) C"
                cell.cellData = self.cellData[indexPath.row]
            }
            
        case 2:
            
            viewModel?.batteryLow.bind{ (batteryLow) in
                if batteryLow{
                    //self.cellData[indexPath.row]
                    self.cellData[indexPath.row][0].value = "Low"
                    cell.cellData = self.cellData[indexPath.row]
                    cell.valueLabels[0].value.backgroundColor = UIColor.red
                }
                else{
                    self.cellData[indexPath.row][0].value = "Normal"
                    cell.cellData = self.cellData[indexPath.row]
                    cell.valueLabels[0].value.backgroundColor = UIColor.FutureGreen
                }
            }

        case 3:
            
            viewModel?.uvIndex.bind{ (uvIndex)in
                self.cellData[indexPath.row][0].value = "\(uvIndex)"
                cell.cellData = self.cellData[indexPath.row]
                switch uvIndex{
                case let x where x <= 2:
                    cell.valueLabels[0].value.backgroundColor = UIColor.FutureGreen
                case let x where x >= 3 && x <= 5:
                    cell.valueLabels[0].value.backgroundColor = UIColor.yellow
                case let x where x >= 6 && x <= 7:
                    cell.valueLabels[0].value.backgroundColor = UIColor.orange
                case let x where x >= 8 && x <= 10:
                    cell.valueLabels[0].value.backgroundColor = UIColor.red
                case let x where x >= 11:
                    cell.valueLabels[0].value.backgroundColor = UIColor.purple
                default: break
                }
            }
            
            viewModel?.uvExposure.bind{ (newExposure) in
                self.cellData[indexPath.row][1].value = "\(newExposure) M"
                cell.cellData = self.cellData[indexPath.row]
            }
            
        case 4:
            viewModel?.barks.bind{ (barks) in
                print("Barks updated for cell")
                self.cellData[indexPath.row][0].value = "\(barks)"
                cell.cellData = self.cellData[indexPath.row]
            }
        case 5:
            viewModel?.steps.bind{ (steps) in
                print("Barks updated for cell")
                self.cellData[indexPath.row][0].value = "\(steps)"
                cell.cellData = self.cellData[indexPath.row]
            }
        case 6:
            if let osso = ossoDeviceManager.connectedOSSO{
                self.cellData[indexPath.row][0].value = "\(osso.firmwareVersion)"
            }
            
            //self.cellData[indexPath.row][0].valueLabel = "Firmware"
        default: break
        }
        cell.cellTitle.text = titles[indexPath.row]
        if indexPath.row != 6{
            cell.iconImageView.image = images[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return self.view.bounds.height*0.15
    }
    
}

extension DashboardViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
}
