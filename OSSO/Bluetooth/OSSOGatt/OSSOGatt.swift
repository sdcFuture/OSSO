//
//  BluebirdGatt.swift
//  Teknest
//
//  Created by Joe Bakalor on 4/4/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

//class BluebirdGatt: JABLE_GATT

import Foundation
import CoreBluetooth
import JABLE

let ossoGatt = OSSOGatt()


struct TriAxis{
    var x: Float
    var y: Float
    var z: Float
}

struct GpsCoordinate{
    var latitude: Float
    var longtitude: Float
}

class OSSOGatt: NSObject, GattProfile{
    
    var ossoMotionService: CBService?
    var ossoFreeFallCharacteristic: CBCharacteristic?
    var ossoAccelerometerCharacteristic: CBCharacteristic?//notifications
    
    var ossoEnvironmentalService: CBService?
    var ossoTemperatureCharacteristic: CBCharacteristic?
    var ossoPressureCharacteristic: CBCharacteristic?
    var ossoHumidityCharacteristic: CBCharacteristic?
    var ossoIrTempCharacteristic: CBCharacteristic?
    var ossoUvIndexCharacteristic: CBCharacteristic?
    var ossoGpsCharacteristic: CBCharacteristic?
    
    var timer: Timer?
    
    /*  Bindable converted values */
    var ossoFreeFallValue: Bindable<Float> = Bindable(0)
    var ossoAccelValue: Bindable<TriAxis> = Bindable(TriAxis(x: 0, y: 0, z: 0))
    var ossoGyroValue: Bindable<TriAxis> = Bindable(TriAxis(x: 0, y: 0, z: 0))
    var ossoTempValue: Bindable<Float> = Bindable(0)
    var ossoPressureValue: Bindable<Float> = Bindable(0)
    var ossoIrTempValue: Bindable<Float> = Bindable(0)
    var ossoUvIndexValue: Bindable<Float> = Bindable(0)
    var ossoGpsValue: Bindable<GpsCoordinate> = Bindable(GpsCoordinate(latitude: 0, longtitude: 0))

    var gattProfile: JABLE_GATT.JABLE_GATTProfile!
    
    override init() {
        
        gattProfile = JABLE_GATT.JABLE_GATTProfile(
            services:
            [
                /*  Motion Service  */
                JABLE_GATT.JABLE_Service(
                    serviceUUID: OSSO_MOTION_SERVICE_UUID,
                    whenFound: assignTo(&ossoMotionService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_FREE_FALL_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoFreeFallCharacteristic),
                            descriptors: nil
                        ),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_ACCELERATION_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoAccelerometerCharacteristic),
                            descriptors: nil
                        )
                    ]
                ),
                
                /*  Environmental Service  */
                JABLE_GATT.JABLE_Service(
                    serviceUUID: OSSO_ENVIRONMENTAL_SERVICE_UUID,
                    whenFound: assignTo(&ossoEnvironmentalService),
                    characteristics:
                    [
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_TEMPERATURE_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoTemperatureCharacteristic),
                            descriptors: nil
                        ),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_PRESSURE_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoPressureCharacteristic),
                            descriptors: nil
                        ),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_HUMIDITY_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoHumidityCharacteristic),
                            descriptors: nil
                        ),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_UV_INDEX_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoUvIndexCharacteristic),
                            descriptors: nil
                        ),
                        
                        JABLE_GATT.JABLE_Characteristic(
                            characteristicUUID: OSSO_GPS_CHARACTERISTIC_UUID,
                            whenFound: assignTo(&ossoGpsCharacteristic),
                            descriptors: nil
                        )
                    ]
                )
            ]
        )
    }
}

extension OSSOGatt{
    
    func gattDiscoveryCompleted(){
        
        startNotifications()
    }
    
    func startNotifications(){
        
        if let char = ossoAccelerometerCharacteristic{
            print("Enable Notifications on OSSO Gatt")
            enableNotifications(forCharacteristics: [char])
        }

    }
    
    func enableNotifications(forCharacteristics characteristics: [CBCharacteristic]){
        for char in characteristics{
            ossoDeviceManager.enableNotifications(forCharacteristic: char)
        }
    }
    
    func enablePolling(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readChars), userInfo: nil, repeats: true)
    }
    
    func disablePolling(){
        timer?.invalidate()
    }
    
    @objc func readChars(){
        
        if let char = ossoTemperatureCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }
        
        if let char = ossoPressureCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }
        
        if let char = ossoHumidityCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }

        if let char = ossoUvIndexCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }
        
        if let char = ossoIrTempCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }
        
        if let char = ossoGpsCharacteristic{
            ossoDeviceManager.read(valueFor: char)
        }
        
    }
}


extension OSSOGatt{
    
    func newValue(forCharacteristic characteristic: CBCharacteristic, value: Data){
        
        switch characteristic.uuid{
        case OSSO_FREE_FALL_CHARACTERISTIC_UUID: //FREE FALL?
            
            let dataArray = getDataBytes(characteristic: characteristic)
            print("New Free Fall Data: \(dataArray)")

        case OSSO_ACCELERATION_CHARACTERISTIC_UUID://notifications - accel, gyro?

            let dataArray = getDataBytes(characteristic: characteristic)
            print("New Acceleration Data: \(dataArray)")
            
            let xValue: Int16 = (Int16(dataArray[5]) << 8) | Int16(dataArray[4])
            let yValue: Int16 = (Int16(dataArray[3]) << 8) | Int16(dataArray[2])
            let zValue: Int16 = (Int16(dataArray[1]) << 8) | Int16(dataArray[0])
            //self.ossoTempValue.value = Float(newTemperature)/10
            self.ossoAccelValue.value = TriAxis(x: Float(xValue), y: Float(yValue), z: Float(zValue))
            print("Acceleration = \(ossoAccelValue.value)")

        case OSSO_TEMPERATURE_CHARACTERISTIC_UUID://READ ONLY - temp?

            let dataArray = getDataBytes(characteristic: characteristic)

            let newTemperature: UInt16 = (UInt16(dataArray[1]) << 8) | UInt16(dataArray[0])
            self.ossoTempValue.value = Float(newTemperature)/10
            print("New Temperature value = \(ossoTempValue.value)")
            
        case OSSO_PRESSURE_CHARACTERISTIC_UUID://READ ONLY - humidity?

            let dataArray = getDataBytes(characteristic: characteristic)
            print("New Pressure Data: \(dataArray)")
            
            
            //convert Data to decimal value, this won't make sense in a lot of cases
            let convertedData = Data(bytes: UnsafePointer<UInt8>(dataArray), count: dataArray.count);
            var convertedToDecimal: Int64 = 0;
            
            (convertedData as NSData).getBytes(&convertedToDecimal, length: dataArray.count)
            var decimalValue = convertedToDecimal
            
            self.ossoPressureValue.value = Float(decimalValue)/100
            print("New Pressure value = \(ossoPressureValue.value)")
            
        case OSSO_HUMIDITY_CHARACTERISTIC_UUID:

            let dataArray = getDataBytes(characteristic: characteristic)
            print("New Humidity Data: \(dataArray)")

        case OSSO_IR_TEMP_CHARACTERISTIC_UUID:
            
            let dataArray = getDataBytes(characteristic: characteristic)
            print("New IR Temp Data: \(dataArray)")

        case OSSO_UV_INDEX_CHARACTERISTIC_UUID:
            print("New UV Index Data: \(value)")
            
            
        case OSSO_GPS_CHARACTERISTIC_UUID:
            print("New GPS Data: \(value)")
            
        default:
        print("no match")
        }
    }
}

extension OSSOGatt{
    
    //GET CHARACTERISTIC VALUE AND RETURN AS BYTE ARRAY
    func getDataBytes(characteristic: CBCharacteristic) -> [UInt8]{
        
        var data: Data? = characteristic.value as Data!
        //data = characteristic.value as Data!
        
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
    
}













