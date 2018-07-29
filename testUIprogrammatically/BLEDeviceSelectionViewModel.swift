//
//  BLEDeviceSelectionViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

class BLEDeviceSelectionViewModel : NSObject, CBCentralManagerDelegate
{
    override init()
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    let btStateString: Variable<String> = Variable("unset");
    
    private func getBTStateAtString() -> String
    {
        switch centralManager.state
        {
        case CBManagerState.unknown:
            return "Bluetooth state unknown";
        case CBManagerState.resetting:
            return "Bluetooth Resetting";
        case CBManagerState.unsupported:
            return "Bluetooth Unsupported";
        case CBManagerState.unauthorized:
            return "Bluetooth - App not authorized"
        case CBManagerState.poweredOff:
            return "Bluetooth OFF"
        case CBManagerState.poweredOn:
            if centralManager.isScanning
            {
                return "Bluetooth ON - Scanning"
            }
            else
            {
                return "Bluetooth ON - Not Scanning"
            }
        }
        
        return "This shouldnt happen";
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
        
        if (central.state == CBManagerState.poweredOn)
        {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        
        btStateString.value = getBTStateAtString();
        
        viewController?.refresh();
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber)
    {
        if let devicename = peripheral.name
        {
            let newDevice = BLEDeviceDiscovered(name: devicename, rssiInt: Int(truncating: RSSI), peripheral: peripheral)
        
           // print("peripheral: \(peripheral)")
            if let alreadyExistingDevice = devices.first(where: {$0 == newDevice})
            {
                alreadyExistingDevice.rssi = Int(truncating: RSSI);
                alreadyExistingDevice.lastSuccess = Date()
            }
            else
            {
                devices.append(newDevice);
            }
        }
        
        viewController?.refresh();
    }
    
    
    weak var viewController : BLEDeviceSelectionViewController?
    
    var devices = [BLEDeviceDiscovered]()
    
    var centralManager:CBCentralManager!
    var aDevice:CBPeripheral?
    
    func createDevices()
    {
        
        
        //devices.append(BLEDeviceDiscovered(name: "first device"));
        //devices.append(BLEDeviceDiscovered(name: "another device"));
        
    }
}
