//
//  BLEDeviceViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 4/08/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import UIKit
import Foundation

protocol BLEDeviceTableViewCellViewModel
{
    func getDeviceNameForDisplay() -> String
    func getDeviceMessageForDisplay() -> String
    func getTextColorForDisplay() -> UIColor
    func getShouldShowDeviceInfoButton() -> Bool
    func getConnectionStateAsString() -> String
    func getLastSuccessTime() -> String
}

class BLEDeviceTableViewCellViewModel_BLANK : BLEDeviceTableViewCellViewModel
{
    func getDeviceNameForDisplay() -> String{  return "ERROR - DUMMY DEVICE" }
    func getDeviceMessageForDisplay() -> String{ return "ERROR - DUMMY DEVICE" }
    func getTextColorForDisplay() -> UIColor{ return .red }
    func getShouldShowDeviceInfoButton() -> Bool{ return false }
    func getConnectionStateAsString() -> String { return "ERROR - DUMMY DEVICE" }
    func getLastSuccessTime() -> String { return "ERROR - DUMMY DEVICE" }
}

class BLEDeviceTableViewCellViewModel_PersistentDevice : BLEDeviceTableViewCellViewModel
{
    private let model : PersistentDevice
    
    init(theModel : PersistentDevice)
    {
        model = theModel;
    }
    
    func getDeviceNameForDisplay() -> String{  return model.name }
    func getDeviceMessageForDisplay() -> String{ return "PersistObject" }
    func getTextColorForDisplay() -> UIColor{ return .darkGray }
    func getShouldShowDeviceInfoButton() -> Bool{ return false }
    func getConnectionStateAsString() -> String { return "na" }
    func getLastSuccessTime() -> String { return DateFormatter.localizedString(from: model.lastSeenTime as Date, dateStyle: .short, timeStyle: .short) }
}

class BLEDeviceTableViewCellViewModel_Discovered : BLEDeviceTableViewCellViewModel
{
    private weak var weak_device : BLEDeviceDiscovered?
    init(device: BLEDeviceDiscovered)
    {
        self.weak_device = device
    }
    
    func getDeviceNameForDisplay() -> String{
        guard let device = weak_device else {
            return "ERROR - NO DEVICE"
        }
        return device.deviceName
    }
    
    func getDeviceMessageForDisplay() -> String{
        guard let device = weak_device else {
            return "ERROR - NO DEVICE"
        }
        var uartString = ""
        
        if (device.hasUART)
        {
            //cell.setTextColor(color: .blue)
            uartString = " UART"
        }
        return "RSSI: \(device.rssi) \(uartString)";
    }
    
    func getTextColorForDisplay() -> UIColor{
        guard let device = weak_device else {
            return .red
        }
        if (device.hasUART)
        {
            return .blue
        }
        return .black
    }
    
    func getShouldShowDeviceInfoButton() -> Bool{
        guard let device = weak_device else {
            return false
        }
        return device.isConnected
    }
    
    func getConnectionStateAsString() -> String{
        guard let device = weak_device else {
            return "ERROR - NO DEVICE"
        }
        return device.getConnectionStateAsString()
    }
    
    func getLastSuccessTime() -> String{
        guard let device = weak_device else {
            return "ERROR - NO DEVICE"
        }
        return DateFormatter.localizedString(from: device.lastSuccess as Date, dateStyle: .short, timeStyle: .short)
    }
    
    
    
}
