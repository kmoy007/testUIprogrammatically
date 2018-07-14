//
//  TestCommand.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 24/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class TestCommand
{
    var commandName = String()
    var lastSuccess = Date(timeIntervalSince1970: 0)
    var theCommand : (()->Bool)?
    
    init(name : String, command : (()->Bool)? = nil)
    {
        commandName = name
        theCommand = command
    }
    
    func doSomething() -> Bool
    {
        if let concreteCommand = theCommand
        {
            if concreteCommand()
            {
                lastSuccess = Date()
                return true;
            }
        }
        return false;
    }
}
