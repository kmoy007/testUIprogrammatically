//
//  BLEDeviceCompleteInfoViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/07/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import RxCocoa
import CoreBluetooth

class BLEDeviceCompleteInfoViewModel : BLEDeviceCompleteInfoDelegate
{
    //MARK - BLEDeviceCompleteInfoDelegate
    func triggerUpdate()
    {
        var theString = String()
        let theStrings = deviceInfoModel.getAsStrings();
        for line in theStrings
        {
            theString.append(String(repeating: " ", count: line.0))
            theString.append(line.1);
            theString.append("\n");
        }
        
        textOfDeviceInfo.accept(theString)
    }
    
    //weak var theDevice : BLEDeviceDiscovered?
    let deviceInfoModel : BLEDeviceCompleteInfo
    let textOfDeviceInfo : BehaviorRelay<String> = BehaviorRelay(value: "NoInfoYet");
    var previousDelegateToRestoreOnClose : CBPeripheralDelegate?
    
    init(theDevice : BLEDeviceDiscovered)
    {
        deviceInfoModel = BLEDeviceCompleteInfo(device: theDevice);
        previousDelegateToRestoreOnClose = theDevice.peripheralObj.delegate;
        deviceInfoModel.delegate = self;
        deviceInfoModel.populateData();
    }
    
    deinit
    {
        deviceInfoModel.bleDevice.peripheralObj.delegate = previousDelegateToRestoreOnClose;
        print("deinit BLEDeviceCompleteInfoViewModel - restored previous CBPeripheralDelegate \(String(describing:previousDelegateToRestoreOnClose))")
    }
}
