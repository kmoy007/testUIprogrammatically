//
//  Simulator_UARTTextGenerator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

protocol ReceiveMessageDelegate : AnyObject
{
    //var messageSink : MessageFormattingBuffer? {get set}
    func receiveStringFromUART(receive : Data)
}

protocol SendMessageFormattingBuffer : class
{
    var messageDestination: ReceiveMessageDelegate? {get set}
  //  var downstreamDelegate: UARTTextDelegate? {get set}
    func formatAndSendData(stringToSend : Data)
  //  func sendStringDownstream(stringToSend : Data)
}

class DoNothingSendMessageFormattingBuffer : SendMessageFormattingBuffer
{
    var messageDestination: ReceiveMessageDelegate?
    
    func formatAndSendData(stringToSend : Data)
    {
        messageDestination?.receiveStringFromUART(receive: stringToSend)
    }
}


class BLEFriend_SendMessageFormattingBuffer : SendMessageFormattingBuffer
{
    var messageDestination: ReceiveMessageDelegate?
    let standardMessageLength = 20;
    
    func formatAndSendData(stringToSend: Data)
    {
        if let theString = String(data: stringToSend, encoding: .utf8)
        {
            let subStrings = splitStringIntoLines(fullStringASCII: theString.utf8, maxChars: standardMessageLength)
            
            for subString in subStrings
            {
                messageDestination?.receiveStringFromUART(receive: subString.data(using: .utf8)!)
            }
        }
        else
        {
            assert(false) //failed to convert, haven't dealt with this yet
        }
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
}
