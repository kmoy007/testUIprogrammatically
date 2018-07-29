//
//  SerialTextViewModel.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class TestingViewModel 
{
    weak var viewController : TestingViewController?
    
    private var bleDeviceInterface : BLEDeviceInterface?
    var commands = [TestCommand]()
    
    func setBLEInterface(bleInterface : BLEDeviceInterface)
    {
        bleDeviceInterface = bleInterface
        createCommands();
    }
    
    func createCommands()
    {
        commands.append(TestCommand(name: "firstCommand"));
        commands.append(TestCommand(name: "another Command"));
        commands.append(TestCommand(name: "ToggleBLEMode", command: { () -> Bool in
            return self.bleDeviceInterface!.toggleBLEMode() } ));
        commands.append(TestCommand(name: "isConnected", command: { () -> Bool in
            return self.bleDeviceInterface!.isConnected() } ));
        
        commands.append(TestCommand(name: "ToggleBLEMode", command: { () -> Bool in
            return self.bleDeviceInterface!.toggleBLEMode() } ));
    
    }
}
