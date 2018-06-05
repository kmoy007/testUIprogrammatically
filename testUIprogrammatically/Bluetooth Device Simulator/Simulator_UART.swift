//
//  Simulator_UARTTextGenerator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

protocol UARTTextDelegate : AnyObject
{
    var theUart : UART? {get set}
    func receiveStringFromUART(receive : String)
}

protocol UART : class
{
    var upstreamDelegate: UARTTextDelegate? {get set}
    var downstreamDelegate: UARTTextDelegate? {get set}
    func sendStringUpstream(stringToSend : Data)
    func sendStringDownstream(stringToSend : Data)
}


class Simulator_UART : UART
{
    var upstreamDelegate: UARTTextDelegate?
    var downstreamDelegate: UARTTextDelegate?
    
    func sendStringDownstream(stringToSend : Data)
    {
        if let theString = String(data: stringToSend, encoding: .utf8)
        {
            downstreamDelegate?.receiveStringFromUART(receive: theString)
            //receiveStringFromUser(fullStringReceived: theString)
        }
        else
        {
            assert(false) //failed to convert, haven't dealt with this yet
        }
        
    }

    let standardMessageLength = 20;
    
    func sendStringUpstream(stringToSend: Data)
    {
        if let theString = String(data: stringToSend, encoding: .utf8)
        {
            let subStrings = splitStringIntoLines(fullStringASCII: theString.utf8, maxChars: standardMessageLength)
            
            for subString in subStrings
            {
                upstreamDelegate?.receiveStringFromUART(receive: subString)
            }
        }
        else
        {
            assert(false) //failed to convert, haven't dealt with this yet
        }
        
        //Do Something here
    }
    
    func splitStringIntoLines(fullStringASCII: String.UTF8View, maxChars : Int) -> [String]
    {
        var workingString : String = String(fullStringASCII)
        var returnStrings : [String] = []
        
        while (workingString.count > 0)
        {
            let lastIndex = workingString.index(workingString.startIndex, offsetBy: min(maxChars, workingString.count) )
            let mySubstring = workingString[..<lastIndex]
            let thisString = String(mySubstring)
            workingString.removeFirst(thisString.count)
            returnStrings.append(thisString)
        }
        
        return returnStrings;
    }
    
 /*   func receiveStringFromUser(fullStringReceived: String) //from user
    {
        if fullStringReceived.hasPrefix("testcommand ")
        {
            let returnString = fullStringReceived.dropFirst(String("testcommand ").count)
            sendStringFromDevice(fullStringToSend: "sure thing, I will do: " + returnString + "\n")
        }
        else
        {
            sendStringFromDevice(fullStringToSend: "unrecognized command" + "\n")
        }
    }
 */
    
    
}
