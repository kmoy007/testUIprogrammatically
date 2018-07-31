//
//  BLEPeripheralWrapper.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheralWrapper : NSObject, CBPeripheralDelegate
{
    let peripheral : CBPeripheral
    
    init(discoveredPeripheral : CBPeripheral)
    {
        peripheral = discoveredPeripheral;
        super.init()
        peripheral.delegate = self
    }
    
    func something()
    {
        //peripheral
    }
}
