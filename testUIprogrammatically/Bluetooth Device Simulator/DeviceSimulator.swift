//
//  DeviceSimulator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation


class DeviceSimulator : Simulator_UART
{
    
    
    
    
    enum DeviceState { case deepSleep, waking, talking, transmitting }
    var currentState = DeviceState.deepSleep
    
    
    var currentUnitTime = Date.init(timeIntervalSince1970: 123) //initialise to nothing
    
}
