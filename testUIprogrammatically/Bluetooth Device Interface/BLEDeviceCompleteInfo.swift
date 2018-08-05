//
//  BLEDeviceCompleteInfo.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEDeviceCompleteInfoDelegate : AnyObject
{
    func triggerUpdate()
}
class BLEDeviceCompleteInfo : NSObject, CBPeripheralDelegate
{
    weak var delegate : BLEDeviceCompleteInfoDelegate?
    
    let bleDevice : BLEDeviceDiscovered
    
    var errorStrings = [String]()
    
    var descriptorDictionary: [CBDescriptor : String] = [:]
    
    //weak var viewModel_yuck : BLEDeviceCompleteInfoViewModel?
    init (device : BLEDeviceDiscovered)
    {
        bleDevice = device
    }
    
    func getPropertyStrings(properties: CBCharacteristicProperties) -> [String]
    {
        var returnStrings = [String]()
        
        if (properties.contains(.authenticatedSignedWrites)) { returnStrings.append("authenticatedSignedWrites");}
        if (properties.contains(.broadcast)) { returnStrings.append("broadcast");}
        if (properties.contains(.extendedProperties)) { returnStrings.append("extendedProperties");}
        if (properties.contains(.indicate)) { returnStrings.append("indicate");}
        if (properties.contains(.indicateEncryptionRequired)) { returnStrings.append("indicateEncryptionRequired");}
        if (properties.contains(.notify)) { returnStrings.append("notify");}
        if (properties.contains(.notifyEncryptionRequired)) { returnStrings.append("notifyEncryptionRequired");}
        if (properties.contains(.read)) { returnStrings.append("read");}
        if (properties.contains(.write)) { returnStrings.append("write");}
        if (properties.contains(.writeWithoutResponse)) { returnStrings.append("writeWithoutResponse");}
        
        return returnStrings
    }
    
    func getAsStrings() -> [(Int,String)]
    {
        var level = 0;
        var strings = [(Int, String)]()
        
        if (bleDevice.peripheralObj.name != nil)
        {
            strings.append((level, "Name: \(bleDevice.peripheralObj.name!)"));
        }
        else
        {
            strings.append((level, "Name: -none-"));
        }
        
        strings.append((level, "Connection State: \(bleDevice.getConnectionStateAsString())"));
        strings.append((level, "iOS local UUID: (probably valid for this iOS device only) \(bleDevice.peripheralObj.identifier.uuidString) "));
        strings.append((level, "Advertisment Data:"))
        level+=1
        for advert in bleDevice.advertStrings
        {
            strings.append((level, advert));
        }
        level -= 1
        if let concreteServices = bleDevice.peripheralObj.services
        {
            strings.append((level, "Service Count: \(concreteServices.count)"));
            level += 1;
            for service in concreteServices
            {
                strings.append((level, "Service: \(service.uuid.uuidString)"));
                strings.append((level, "Service isPrimary: \(service.isPrimary)"));
                if let concreteIncludedServices = service.includedServices
                {
                    
                    strings.append((level, "Service includedServices count: \(concreteIncludedServices.count)"));
                    level += 1;
                    for includedService in concreteIncludedServices
                    {
                        strings.append((level, "includedService: \(includedService.uuid.uuidString)"));
                    }
                    level -= 1;
                }
                else
                {
                    strings.append((level, "Service includedServices: NONE"));
                }
                
                if let concreteCharacteristics = service.characteristics
                {
                    strings.append((level, "Service characteristics count: \(concreteCharacteristics.count)"));
                    level += 1;
                    for characteristic in concreteCharacteristics
                    {
                        strings.append((level, "characteristic uuid: \(characteristic.uuid.uuidString)"));
                        strings.append((level, "characteristic isNotifying: \(characteristic.isNotifying)"));
                        if let concreteDescriptors = characteristic.descriptors
                        {
                            strings.append((level, "descriptors count: \(concreteDescriptors.count)"));
                            level += 1;
                            for descriptor in concreteDescriptors
                            {
                                strings.append((level, "descriptor uuid: \(descriptor.uuid.uuidString)"));
                                if let text = descriptorDictionary[descriptor]
                                {
                                    strings.append((level, text))
                                }
                                else
                                {
                                    strings.append((level,"descriptor data not read yet"));
                                }
                            }
                            level -= 1;
                        }
                        else
                        {
                            strings.append((level, "characteristic has no descriptors"));
                        }
                        strings.append((level, "characteristic properties:"))
                        level += 1;
                        strings.append((level, getPropertyStrings(properties: characteristic.properties).joined()))
                        level -= 1;
                        
                        if let concreteData = characteristic.value
                        {
                            strings.append((level, "Data as utf8:"));///
                            let utf8String = String(data:concreteData, encoding: .utf8)
                            if let concreteUTF8String = utf8String
                            {
                                strings.append((level, concreteUTF8String));
                            }
                            else
                            {
                                strings.append((level, "<unreadable in utf8>"))
                            }
                            
                            strings.append((level, "Data as hex:"));///
                            let str = concreteData.map { String(format: "%02hhx", $0) }.joined()
                            strings.append((level, str));
                        }
                        else
                        {
                            strings.append((level, "no data"));
                        }
                    }//end for characteristics
                    level -= 1;
                }
                else
                {
                    strings.append((level, "Service includedServices: NONE"));
                }
            } //end for services
            level -= 1;
        }
        else
        {
            strings.append((level, "No Services"));
        }
        
        return strings;
    }
    
    func populateData()
    {
        bleDevice.peripheralObj.delegate = self
        bleDevice.peripheralObj.discoverServices(nil);
       // bleDevice?.peripheralObj.discoverServices([CBUUID]?)
    }
    
    func UpdateDescriptors(forCharacteristic: CBCharacteristic)
    {
        if let concreteDescriptors = forCharacteristic.descriptors
        {
            for descriptor in concreteDescriptors
            {
                bleDevice.peripheralObj.readValue(for: descriptor)
            }
        }
    }
    
    func UpdateCharacteristics(forService: CBService)
    {
        
        if let concreteCharacteristics = forService.characteristics
        {
            for characteristic in concreteCharacteristics
            {
                bleDevice.peripheralObj.readValue(for: characteristic)
                bleDevice.peripheralObj.discoverDescriptors(for: characteristic)
            }
        }
    }
    
    func UpdateServices()
    {
        
        if let concreteServices = bleDevice.peripheralObj.services
        {
            for service in concreteServices
            {
                bleDevice.peripheralObj.discoverIncludedServices(nil, for: service);
                bleDevice.peripheralObj.discoverCharacteristics(nil, for: service);
            }
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
        UpdateServices();
        delegate?.triggerUpdate()
    }
    func peripheral(_ peripheral : CBPeripheral, didDiscoverIncludedServicesFor: CBService, error: Error?)
    {//Invoked when you discover the included services of a specified service.
        if error != nil
        {
            print(error!);
            errorStrings.append(error!.localizedDescription);
        }
        delegate?.triggerUpdate()
    }
    
    //Discovering Characteristics and Characteristic Descriptors
    func peripheral(_ peripheral : CBPeripheral, didDiscoverCharacteristicsFor: CBService, error: Error?)
    {//Invoked when you discover the characteristics of a specified service.
        UpdateCharacteristics(forService: didDiscoverCharacteristicsFor)
        delegate?.triggerUpdate()
    }
    func peripheral(_ peripheral : CBPeripheral, didDiscoverDescriptorsFor: CBCharacteristic, error: Error?)
    {//Invoked when you discover the descriptors of a specified characteristic.
        UpdateDescriptors(forCharacteristic: didDiscoverDescriptorsFor)
        delegate?.triggerUpdate()
    }
    
    //Retrieving Characteristic and Characteristic Descriptor Values
    func peripheral(_ peripheral : CBPeripheral, didUpdateValueFor: CBCharacteristic, error: Error?)
    {//Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
    }
    
    func peripheral(_ peripheral : CBPeripheral, didUpdateValueFor: CBDescriptor, error: Error?)
    {//Invoked when you retrieve a specified characteristic descriptor’s value.
        switch didUpdateValueFor.uuid.uuidString {
        case CBUUIDCharacteristicExtendedPropertiesString:
            guard let properties = didUpdateValueFor.value as? NSNumber else {
                break
            }
            descriptorDictionary[didUpdateValueFor] = "  Extended properties: \(properties)"
        case CBUUIDCharacteristicUserDescriptionString:
            guard let description = didUpdateValueFor.value as? NSString else {
                break
            }
            descriptorDictionary[didUpdateValueFor] = "  User description: \(description)"
        case CBUUIDClientCharacteristicConfigurationString:
            guard let clientConfig = didUpdateValueFor.value as? NSNumber else {
                break
            }
            descriptorDictionary[didUpdateValueFor] = "  Client configuration: \(clientConfig)"
        case CBUUIDServerCharacteristicConfigurationString:
            guard let serverConfig = didUpdateValueFor.value as? NSNumber else {
                break
            }
            descriptorDictionary[didUpdateValueFor] = "  Server configuration: \(serverConfig)"
        case CBUUIDCharacteristicFormatString:
            guard let format = didUpdateValueFor.value as? NSData else {
                break
            }
            descriptorDictionary[didUpdateValueFor] = "  Format: \(format)"
        case CBUUIDCharacteristicAggregateFormatString:
            descriptorDictionary[didUpdateValueFor] = "  Aggregate Format: (is not documented)"
        default:
            break
        }
        delegate?.triggerUpdate()
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
