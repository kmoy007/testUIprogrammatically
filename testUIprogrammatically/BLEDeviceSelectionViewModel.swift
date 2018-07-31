//
//  BLEDeviceSelectionViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa

class BLEDeviceSelectionViewModel : NSObject, CBCentralManagerDelegate
{
    override init()
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit
    {
        print("deinit BLEDeviceSelectionViewModel")
    }
    
    var centralManager:CBCentralManager!
    let btStateString: BehaviorRelay<String> = BehaviorRelay(value: "unset");
    let devices : BehaviorRelay<[BLEDeviceDiscovered]> = BehaviorRelay(value: [BLEDeviceDiscovered]())
    let blockUI : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var scanSeconds = 5;
    var timer = Timer()
    var firstScan = true;
    
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
                return "Bluetooth ON - Scanning \(scanSeconds)s"
            }
            else
            {
                return "Bluetooth ON - Not Scanning"
            }
        }
      //  return "This cant happen";
    }
    
    func startScanForDevices()
    {
        if (centralManager.isScanning)
        {
            return;
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        //start the timer
        scanSeconds = 5;
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        
    }
    
    func stopScanForDevices()
    {
        timer.invalidate() //stop the timer
        centralManager.stopScan();
        btStateString.accept(getBTStateAtString());
    }
    
    @objc func updateTimer() {
        if scanSeconds == 0
        {
            stopScanForDevices();
        }
        else
        {
            scanSeconds -= 1     //This will decrement(count down)the seconds.
            btStateString.accept(getBTStateAtString());
        }
        
    }
    
    func connectDevice(device: BLEDeviceDiscovered)
    {
        var thePeripheral = BLEPeripheralWrapper(discoveredPeripheral: device.peripheralObj)
        centralManager.connect(device.peripheralObj);

        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
        
        if (central.state == CBManagerState.poweredOn)
        {
            if (firstScan == true) //trigger a scan when this class is first created
            {
                firstScan = false
                startScanForDevices();
            }
        }
        
        btStateString.accept(getBTStateAtString());
    }
    
    func triggerUIReload()
    {
        devices.accept(devices.value)//this smells bad
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
            if let alreadyExistingDevice = devices.value.first(where: {$0 == newDevice})
            {
                alreadyExistingDevice.rssi = Int(truncating: RSSI);
                alreadyExistingDevice.lastSuccess = Date()
                devices.accept(devices.value)//this smells bad
            }
            else
            {
                devices.accept(devices.value + [newDevice])
            }
        }

    }
    
    func centralManager(_ manager: CBCentralManager, didConnect: CBPeripheral)
    {
        //Invoked when a connection is successfully created with a peripheral.
        print("Connection Success: \(String(describing: didConnect.name))")
        triggerUIReload()
    }
    func centralManager(_ manager: CBCentralManager, didDisconnectPeripheral: CBPeripheral, error: Error?)
    {
        print("Connection Teardown: \(String(describing: didDisconnectPeripheral.name)) Error: \(String(describing: error))")
        //Invoked when an existing connection with a peripheral is torn down.
        triggerUIReload()
    }
    
    func centralManager(_ manager: CBCentralManager, didFailToConnect: CBPeripheral, error: Error?)
    {
        print("Connection Failed: \(String(describing: didFailToConnect.name)) Error: \(String(describing: error))")
        //Invoked when the central manager fails to create a connection with a peripheral.
        triggerUIReload()
    }
}
