//
//  SensorViewViewController.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import UIKit

class SensorViewViewController: UIViewController {
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var uvaUvbLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    @IBOutlet weak var accelLabel: UILabel!
    @IBOutlet weak var pressureLable: UILabel!
    
    
    var viewModel: SensorViewViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SensorViewViewModel()
        setupBindings()
        
    }
    
    func setupBindings(){
        
        viewModel.temperature.bind { (newTemp) in
            guard let temp = newTemp else { return }
            self.temperatureLabel.text = "Temperature = \(temp)C"
        }
        
        viewModel.pressure.bind { (newPressure) in
            guard let pressure = newPressure else { return }
            self.uvaUvbLabel.text = "UV Index = \(pressure)"
        }
        
        viewModel.accelerometer.bind { (newAccelValue) in
            guard let accel = newAccelValue else { return }
            self.accelLabel.text = "Accel (x: \(accel.x), y: \(accel.y), z: \(accel.z) mg)"
        }
        
        viewModel.humidity.bind { (newValue) in
            guard let humidity = newValue else { return }
            self.humidityLabel.text = "Humidity: \(humidity) %"
        }
        
    }
}
