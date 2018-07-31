//
//  BLEDeviceDiscovered.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 26/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEDeviceDiscovered : Equatable , CBPeripheralDelegate
{
    static func == (lhs: BLEDeviceDiscovered, rhs: BLEDeviceDiscovered) -> Bool {
        return ((lhs.deviceName == rhs.deviceName)
                && (lhs.peripheralObj.identifier == rhs.peripheralObj.identifier))
    }
    
    var deviceName = String()
    var lastSuccess = Date(timeIntervalSince1970: 0)
    var rssi = 0
    var hasUART = false
    let peripheralObj : CBPeripheral
    var isConnected : Bool{
        get{ return peripheralObj.state == CBPeripheralState.connected }
    }
  
    init(name : String, rssiInt: Int, peripheral: CBPeripheral)
    {
        deviceName = name
        rssi = rssiInt
        peripheralObj = peripheral
        lastSuccess = Date();
    }
    
    func getConnectionStateAsString() -> String
    {
        switch peripheralObj.state{
            
        case CBPeripheralState.disconnected:
            return "disconnected";
    
        case CBPeripheralState.connecting:
            return "connecting";
    
        case CBPeripheralState.connected:
            return "connected";
    
        case CBPeripheralState.disconnecting:
            return "disconnecting";
        }
    }
    
    
    
    //MARK - CBPeripheralDelegate calls
    func peripheral(_ peripheral : CBPeripheral, didDiscoverServices: Error?)
    {//Invoked when you discover the peripheral’s available services.
        if didDiscoverServices != nil
        {
            print(didDiscoverServices!);
            errorStrings.append(didDiscoverServices!.localizedDescription);
        }
    }
    func peripheral(_ peripheral : CBPeripheral, didDiscoverIncludedServicesFor: CBService, error: Error?)
    {//Invoked when you discover the included services of a specified service.
        if error != nil
        {
            print(error!);
            errorStrings.append(error!.localizedDescription);
        }
    }
    
    //Discovering Characteristics and Characteristic Descriptors
    func peripheral(_ peripheral : CBPeripheral, didDiscoverCharacteristicsFor: CBService, error: Error?)
    {//Invoked when you discover the characteristics of a specified service.

    }
    func peripheral(_ peripheral : CBPeripheral, didDiscoverDescriptorsFor: CBCharacteristic, error: Error?)
    {//Invoked when you discover the descriptors of a specified characteristic.
    }
    
    //Retrieving Characteristic and Characteristic Descriptor Values
    func peripheral(_ peripheral : CBPeripheral, didUpdateValueFor: CBCharacteristic, error: Error?)
    {//Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
    }
    
    //Writing Characteristic and Characteristic Descriptor Values
    func peripheral(_ peripheral : CBPeripheral, didWriteValueFor: CBCharacteristic, error: Error?)
    {//Invoked when you write data to a characteristic’s value.
    }
    func peripheral(_ peripheral : CBPeripheral, didWriteValueFor: CBDescriptor, error: Error?)
    {//Invoked when you write data to a characteristic descriptor’s value.
    }
    
    //Managing Notifications for a Characteristic’s Value
    func peripheral(_ peripheral : CBPeripheral, didUpdateNotificationStateFor: CBCharacteristic, error: Error?)
    {//Invoked when the peripheral receives a request to start or stop providing notifications for a specified characteristic’s value.
    }
    
    //Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data
    func peripheral(_ peripheral : CBPeripheral, didReadRSSI: NSNumber, error: Error?)
    {//Invoked after you call readRSSI() to retrieve the value of the peripheral’s current RSSI while it is connected to the central manager.
    }
    
    
    //Monitoring Changes to a Peripheral’s Name or Services
    func peripheralDidUpdateName(_ peripheral : CBPeripheral)
    {//Invoked when a peripheral’s name changes.
    }
    
    func peripheral(_ peripheral : CBPeripheral, didModifyServices: [CBService])
    {//Invoked when a peripheral’s services have changed.
    }
    
    //Instance Methods
    func peripheral(_ peripheral : CBPeripheral, didOpen: CBL2CAPChannel?, error: Error?)
    {}
    func peripheralIsReady(toSendWriteWithoutResponse: CBPeripheral)
    {}
    
    
    
}
