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

class PersistentDevice
{
    let uuid : UUID
    let name : String
    var lastSeenTime: Date

    init(uuid: UUID, name : String)
    {
        self.uuid = uuid
        self.name = name
        lastSeenTime = Date()
    }
    
}

class BLEDeviceSelectionViewModel : NSObject, CBCentralManagerDelegate , BLEDeviceDelegate
{
    func stateChange(device: BLEDeviceDiscovered) {
        triggerUIReload()
    }
    
    override init()
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        CreateTemporaryPersistentDevices()
        
    }
    func CreateTemporaryPersistentDevices()
    {
        persistentDevices.append(PersistentDevice(uuid: UUID(uuidString: "EF090000-12D6-42BA-93B8-9DD7EC090AA4")!, name: "dummyThing1"));
        persistentDevices.append(PersistentDevice(uuid: UUID(uuidString: "9FF1F269-742B-27ED-CD04-7564904E59B7")!, name: "dummyThing2"));
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
    var persistentDevices = [PersistentDevice]()
    
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
    
    func isUUIDinDeviceList(uuid: UUID) -> Bool
    {
        for device in devices.value
        {
            if device.peripheralObj.identifier == uuid
            {
                return true;
            }
        }
        return false;
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
      //  var thePeripheral = BLEPeripheralWrapper(discoveredPeripheral: device.peripheralObj)
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
            var advertStrings = [String]();
            print ("Found: \(devicename).  Advertising:")
            print ("iOS UUID: \(peripheral.identifier.uuidString)")
            for advert in advertisementData
            {
                advertStrings.append(String("Key: \(advert.key) - Data: <\(advert.value)>"))
                print(advertStrings.last!)
            }
            
            let newDevice = BLEDeviceDiscovered(name: devicename, rssiInt: Int(truncating: RSSI), peripheral: peripheral, advertStrings: advertStrings)
            if let serviceUUIDs_Any = advertisementData[CBAdvertisementDataServiceUUIDsKey]
            {
                let serviceUUIDs = serviceUUIDs_Any as! [CBUUID]
                for serviceUUID in serviceUUIDs
                {
                    if serviceUUID == BLEDeviceDiscovered.uartUUID
                    {
                        newDevice.hasUART = true;
                    }
                }
            }
           // print("peripheral: \(peripheral)")
            if let alreadyExistingDevice = devices.value.first(where: {$0 == newDevice})
            {
                alreadyExistingDevice.rssi = Int(truncating: RSSI);
                alreadyExistingDevice.lastSuccess = Date()
                devices.accept(devices.value)//this smells bad
            }
            else
            {
                newDevice.delegate = self
                devices.accept(devices.value + [newDevice])
            }
        }

    }
    
    func centralManager(_ manager: CBCentralManager, didConnect: CBPeripheral)
    {
        //Invoked when a connection is successfully created with a peripheral.
        print("Connection Success: \(String(describing: didConnect.name))")
        didConnect.discoverServices([BLEDeviceDiscovered.uartUUID])
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
