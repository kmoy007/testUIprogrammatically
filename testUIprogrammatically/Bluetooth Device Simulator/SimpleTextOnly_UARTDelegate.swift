//
//  SimpleTextOnlySimulator_UART.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

protocol UARTTextGenerator
{
    func pumpString()
}

//CURRENTLY CONVERTING THIS INTO A DELEGATE SO THAT WE CAN THEN MAKE THE DEVICE SIMULATOR AS A MORE COMPLEX VERSION OF THIS
class SimpleTextOnly_UARTDelegate :UARTTextDelegate, UARTTextGenerator
{
    var theUart: UART?
    
    func pumpString()
    {
        let multiLineString = """
            To be, or not to be - that is the question;
            Whether 'tis nobler in the mind to suffer
            The slings and arrows of outrageous fortune,
            Or to take arms against a sea of troubles,
            """
        theUart?.sendStringUpstream(stringToSend : multiLineString.data(using: .utf8)!)
    }
    
    func receiveStringFromUART(receive: String) //from user
    {
        if receive.hasPrefix("testcommand ")
        {
            let returnString = receive.dropFirst(String("testcommand ").count)
            theUart?.sendStringUpstream(stringToSend: String("sure thing, I will do: " + returnString + "\n").data(using: .utf8)!)
        }
        else
        {
            theUart?.sendStringUpstream(stringToSend: String("unrecognized command" + "\n").data(using: .utf8)!)
        }
    }
}
