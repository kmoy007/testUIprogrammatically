//
//  BLEDeviceDiscovered.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEDeviceDiscovered : Equatable
{
    static func == (lhs: BLEDeviceDiscovered, rhs: BLEDeviceDiscovered) -> Bool {
        return ((lhs.deviceName == rhs.deviceName)
                && (lhs.peripheralObj.identifier == rhs.peripheralObj.identifier))
    }
    
    var deviceName = String()
    var lastSuccess = Date(timeIntervalSince1970: 0)
    var rssi = 0
    let peripheralObj : CBPeripheral
   
  
    init(name : String, rssiInt: Int, peripheral: CBPeripheral)
    {
        deviceName = name
        rssi = rssiInt
        peripheralObj = peripheral
        lastSuccess = Date();
    }
}
