//
//  TestCommand.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 24/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

enum CommandSuccessStatus
{
    case NotCalled
    case Success
    case NoSuccess
}
class TestCommand
{
    var commandName = String()
    var lastSuccess = Date(timeIntervalSince1970: 0)
    var lastAttemptSuccessful = CommandSuccessStatus.NotCalled
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
                lastAttemptSuccessful = CommandSuccessStatus.Success
                return true;
            }
        }
         lastAttemptSuccessful = CommandSuccessStatus.NoSuccess
        return false;
    }

}
