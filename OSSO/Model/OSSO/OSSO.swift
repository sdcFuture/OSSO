//
//  OSSO.swift
//  OSSO
//
//  Created by Joe Bakalor on 12/17/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

class OSSO: NSObject{
    
    var lastRSSI: Int = 0
    
    /*  Bindable converted values */
    var ossoFreeFallValue: Bindable<Float>      = Bindable(0)
    var ossoAccelValue: Bindable<TriAxis>       = Bindable(TriAxis(x: 0, y: 0, z: 0))
    var ossoGyroValue: Bindable<TriAxis>        = Bindable(TriAxis(x: 0, y: 0, z: 0))
    var ossoTempValue: Bindable<Float>          = Bindable(0)
    var ossoPressureValue: Bindable<Float>      = Bindable(0)
    var ossoIrTempValue: Bindable<Float>        = Bindable(0)
    var ossoUvIndexValue: Bindable<Int>         = Bindable(0)
    var ossoGpsValue: Bindable<GpsCoordinate>   = Bindable(GpsCoordinate(latitude: 0, longtitude: 0))
    var ossoHumidity: Bindable<Float>           = Bindable(0)
    var rawGps: Bindable<String>                = Bindable("")
    var ossoBarksValue: Bindable<Int>           = Bindable(0)
    var ossoStepsValue: Bindable<Int>           = Bindable(0)
    var ossoSunExposureTime: Bindable<Int>      = Bindable(0)
    var ossoBatteryLow: Bindable<Bool>          = Bindable(false)
    
    var gattProfile: OSSOGatt?
    var associatedPeripheral: CBPeripheral!
    var firmwareVersion: Int = 0
    
    private var updateTimer: Timer?
    
    init(withPeripheral peripheral: CBPeripheral) {
        self.associatedPeripheral = peripheral
        gattProfile = OSSOGatt()
    }
    
    /*  do any setup required after has successfully connected to this thing */
    func didConnect(){
        
        print("OSSO: CONNECTED ")
        guard let gatt = gattProfile else { return }
        
        print("OSSO: Try to enable notifications ")
        
        if let char = gatt.ossoAccelerometerCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoTemperatureCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoPressureCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoPressureCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoHumidityCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoIrTempCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoUvIndexCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoGpsCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        if let char = gatt.ossoAccelerometerCharacteristic{
            associatedPeripheral.setNotifyValue(true, for: char)
        }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            self.readValues()
        }
    }
    
    func willDisconnect(){
        updateTimer?.invalidate()
    }
    
    
    func readValues(){
        
        guard let gatt = gattProfile else { return }
        //print("Read GPS")
        self.associatedPeripheral.readValue(for: gatt.ossoGpsCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoTemperatureCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoUvIndexCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoHumidityCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoBarkCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoIrTempCharacteristic!)
        self.associatedPeripheral.readValue(for: gatt.ossoPressureCharacteristic!)
        
    }
}


extension OSSO{
    
    func newValue(forCharacteristic characteristic: CBCharacteristic){
        
        let dataArray = characteristic.dataBytes()
        
        switch characteristic.uuid{
        case OSSO_FREE_FALL_CHARACTERISTIC_UUID: break//FREE FALL?
            
            
        case OSSO_ACCELERATION_CHARACTERISTIC_UUID://notifications - accel, gyro?
            
            let xValue: Int16 = (Int16(dataArray[5]) << 8) | Int16(dataArray[4])
            let yValue: Int16 = (Int16(dataArray[3]) << 8) | Int16(dataArray[2])
            let zValue: Int16 = (Int16(dataArray[1]) << 8) | Int16(dataArray[0])
            //self.ossoTempValue.value = Float(newTemperature)/10
            self.ossoAccelValue.value = TriAxis(x: Float(xValue), y: Float(yValue), z: Float(zValue))
            
            //guard dataArray.count == 2 else { return }
            
            let steps: Int16 = (Int16(dataArray[1]) << 8) | Int16(dataArray[0])
            self.ossoStepsValue.value = Int(steps)
            //print("New Steps data = \(steps)")
            
        case OSSO_TEMPERATURE_CHARACTERISTIC_UUID://READ ONLY - temp?
            
            let newTemperature: Int16 = Int16((Int16(dataArray[1]) << 8) | Int16(dataArray[0]))
            self.ossoTempValue.value = Float(newTemperature)/10
            //print("New Temperature value = \(ossoTempValue.value)")
            
        case OSSO_PRESSURE_CHARACTERISTIC_UUID://READ ONLY - humidity?
            
            //convert Data to decimal value, this won't make sense in a lot of cases
            let convertedData = Data(bytes: UnsafePointer<UInt8>(dataArray), count: dataArray.count);
            var convertedToDecimal: Int64 = 0;
            
            (convertedData as NSData).getBytes(&convertedToDecimal, length: dataArray.count)
            var decimalValue = convertedToDecimal
            
            self.ossoPressureValue.value = Float(decimalValue)/100
            if dataArray[0] == 0{
                self.ossoBatteryLow.value = false
            }
            else{
                self.ossoBatteryLow.value = true
            }
            
            self.firmwareVersion = Int(dataArray[1])
            print("New Battery value = \(dataArray)")
            
        case OSSO_HUMIDITY_CHARACTERISTIC_UUID:
            guard dataArray.count == 2 else { return }
            
            let newHumidity: UInt16 = (UInt16(dataArray[1]) << 8) | UInt16(dataArray[0])
            self.ossoHumidity.value = Float(newHumidity)/10
            
        case OSSO_IR_TEMP_CHARACTERISTIC_UUID:
            guard dataArray.count == 2 else { return }
            
            let newTemperature: Int16 = Int16((Int16(dataArray[1]) << 8) | Int16(dataArray[0]))
            //let newTemperature: Int16 = Int16((UInt16(dataArray[1]) << 8) | UInt16(dataArray[0]))
            self.ossoIrTempValue.value = Float(newTemperature)/10
            //print("IR Temperature = \(ossoIrTempValue.value)")
            
        case OSSO_UV_INDEX_CHARACTERISTIC_UUID: 
            
        print("New UV Index Data: \(dataArray)")
        let newUvValue: UInt16 = (UInt16(dataArray[1]) << 8) | UInt16(dataArray[0])
        
            let uvIndex = Int(newUvValue & 0b0000000000001111)
            let exposureTime = Int((newUvValue & 0b1111111111110000) >> 4)
            //self.ossoUvIndexValue.value = Float(newUvIndex)/10
            self.ossoUvIndexValue.value = uvIndex
            self.ossoSunExposureTime.value = exposureTime
            
        case OSSO_GPS_CHARACTERISTIC_UUID:
            
            //print("New GPS Data: \(characteristic.getHexString())")
            let dataArray = characteristic.dataBytes()
            self.rawGps.value = characteristic.getHexString()!
            
            let latitude: Int16 = (Int16(dataArray[11]) << 8) | Int16(dataArray[10])
            let latFractional = Double((UInt32(dataArray[9]) << 24) | (UInt32(dataArray[8]) << 16) | (UInt32(dataArray[7]) << 8) | UInt32(dataArray[6]))/10000
            var fullLat: Double
            if latitude < 0{
                fullLat = Double(latitude) - latFractional
            }
            else {
                fullLat = Double(latitude) + latFractional
            }
            
            let longitude: Int16 = (Int16(dataArray[5]) << 8) | Int16(dataArray[4])
            let lonFractional = Double( (UInt32(dataArray[3]) << 24) | (UInt32(dataArray[2]) << 16) | (UInt32(dataArray[1]) << 8) | UInt32(dataArray[0]))/10000
            var fullLon: Double
            if longitude < 0{
                fullLon = Double(longitude) - lonFractional
            }
            else {
                fullLon = Double(longitude) + lonFractional
            }
            
            self.ossoGpsValue.value = GpsCoordinate(latitude: fullLat, longtitude: fullLon)
        
        case OSSO_BARK_CHARACTERISTIC_UUID:
        
            let numberOfBarks: UInt16 = ((UInt16(dataArray[1]) << 8) | UInt16(dataArray[0]))
            self.ossoBarksValue.value = Int(numberOfBarks)
            
        default:
            print("no match")
        }
    }
}
extension CBCharacteristic{
    
    //GET CHARACTERISTIC VALUE AND RETURN AS BYTE ARRAY
    func dataBytes() -> [UInt8]{
        
        var data: Data? = self.value //as? Data
        
        var dataBytes = [UInt8](repeating: 0, count: data!.count)
        (data! as NSData).getBytes(&dataBytes, length: data!.count)
        
        var hexValue = ""
        for value in data!{
            let hex = String(value, radix: 16)
            hexValue = hexValue + "0x\(hex) "
        }
        //print("Raw Hex = \(hexValue)")
        return dataBytes
    }
    
    func getAsciiString() -> String?{
        var data: Data? = self.value //as? Data
        
        var dataBytes = [UInt8](repeating: 0, count: data!.count)
        (data! as NSData).getBytes(&dataBytes, length: data!.count)
        
        var hexValue = ""
        for value in data!{
            let hex = String(value, radix: 16)
            hexValue = hexValue + "0x\(hex) "
        }
        
        return String(bytes: dataBytes, encoding: .utf8)
    }
    
    func getHexString() -> String?{
        var data: Data? = self.value //as? Data
        
        var dataBytes = [UInt8](repeating: 0, count: data!.count)
        (data! as NSData).getBytes(&dataBytes, length: data!.count)
        
        var hexValue = ""
        for value in data!{
            let hex = String(value, radix: 16)
            hexValue = hexValue + "0x\(hex) "
        }
        
        return hexValue
    }
}
