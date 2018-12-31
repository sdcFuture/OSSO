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
    
    let titles: [String] = ["Temperature/Humidity", "IR Temperature", "Battery", "UV Index", "Barks", "Steps"]
    let images: [UIImage] = [
    UIImage(imageLiteralResourceName: "SensorPlaceHolder"),
    UIImage(imageLiteralResourceName: "IRTempSymbol"),
    UIImage(imageLiteralResourceName: "BatterySymbol"),
    UIImage(imageLiteralResourceName: "SensorPlaceHolder"),
    UIImage(imageLiteralResourceName: "BarkSymbol"),
    UIImage(imageLiteralResourceName: "PawPrintSymbol")]
    
    var cellData: [[(valueLabel: String, value: String)]] =
        [[(valueLabel: "Temperature", value: "10"), (valueLabel: "Humidity", value: "10")],
         [(valueLabel: "IR Temperature", value: "10")],
         [(valueLabel: "Level", value: "10")],
         [(valueLabel: "UV Index", value: "10"), (valueLabel: "Exposure Time", value: "10")],
         [(valueLabel: "Barks", value: "10")],
         [(valueLabel: "Steps", value: "10")]]
    
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
                    self.cellData[indexPath.row][0].value = "Low"
                    cell.cellData = self.cellData[indexPath.row]
                }
                else{
                    self.cellData[indexPath.row][0].value = "Normal"
                    cell.cellData = self.cellData[indexPath.row]
                }
            }

        case 3:
            
            viewModel?.uvIndex.bind{ (uvIndex)in
                self.cellData[indexPath.row][0].value = "\(uvIndex)"
                cell.cellData = self.cellData[indexPath.row]
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
        default: break
        }
        cell.cellTitle.text = titles[indexPath.row]
        cell.iconImageView.image = images[indexPath.row]
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
