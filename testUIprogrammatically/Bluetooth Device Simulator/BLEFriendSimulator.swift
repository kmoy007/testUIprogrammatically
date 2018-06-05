//
//  BLEFriendSimulator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

protocol BLEFriendSimulatorDelegate : class
{
    func receiveMessageOverBLE(receivedData : Data)
}

class BLEFriendSimulator : UARTTextDelegate
{
    var theUart: UART?
    
    func receiveStringFromUART(receive: String) {
        //SOMETHING HERE
    }
    
    enum BLEState { case disconnected, connected }
    enum BLEMode { case command, data }
    
    var connectionState = BLEState.disconnected
    var connectionMode = BLEMode.command
    
    var delegate : BLEFriendSimulatorDelegate?
    var uartDevice : UART?
    
    var incomingBuffer = Data()
    
    func getNextStringTokenizedBynewline(dataIn : inout Data) -> Data?
    {
        var returnData : Data? = nil;
       // let char = Character("\n")
        
        if let theIndex = dataIn.index(of: "\n".utf8.map{ UInt8($0) }[0])
        {
            returnData = dataIn.prefix(through: theIndex)
            dataIn.removeSubrange(...theIndex)
        }
        return returnData;
    }
    
    func receiveBTmessage(incomingMessage : Data)
    {
        incomingBuffer = incomingBuffer + incomingMessage;
        while let nextString = getNextStringTokenizedBynewline(dataIn: &incomingBuffer)
        {
            if (specialCaseModeToggle(incomingMessage: nextString))
            {
                //special case of "+++\n" in data mode
                continue;
            }
            
            if (connectionMode == .command)
            {
                ATCommandFilter(incomingMessage: nextString)
            }
            else //(connectionMode == .data)
            {
                uartDevice?.sendStringDownstream(stringToSend: nextString)
            }
        }
    }
    
    
    func specialCaseModeToggle(incomingMessage : Data) -> Bool
    {
        if let incomingString = String(data: incomingMessage, encoding: .utf8)
        {
            if (incomingString == "+++\n")
            {
                return self.toggleMode()
            }
        }
        return false;
    }
    
    func splitNVMCommands(incomingMessage : Data) -> (first: Data, second: Data, third: Data)?
    {
        var returnTuple : (Data,Data,Data)? = nil
        if let theIndex = incomingMessage.index(of: "=".utf8.map{ UInt8($0) }[0])
        {
            var mutableMessage = incomingMessage
            mutableMessage.removeSubrange(...theIndex)
            var components = mutableMessage.split(maxSplits: 2, whereSeparator: { $0 == ",".utf8.map{ UInt8($0) }[0] })
            if (components.count == 3)
            {
                returnTuple = (components[0], components[1], components[2])
            }
        }
        return returnTuple
    }
    
    func ReadNVM(incomingMessage : Data) -> Bool
    {
        if let parameters = splitNVMCommands(incomingMessage: incomingMessage)
        {
            delegate?.receiveMessageOverBLE(receivedData: NVRam)
            return true
        }
        return false
    }
    
    func WriteNVM(incomingMessage : Data) -> Bool
    {
        if let parameters = splitNVMCommands(incomingMessage: incomingMessage)
        {
            if (parameters.third.count <= 256)
            {
                NVRam = parameters.third
                return true
            }
        }
        return false
    }
    
    func ATCommandFilter(incomingMessage : Data)
    {
        let atcommandlist : [(String, (Data) -> Bool)] = [
            ("+++\n", self.toggleMode),
            ("AT+NVMWRITE=",self.WriteNVM),
            ("AT+NVMREAD=",self.ReadNVM),
            ("AT", { (theData: Data)->Bool in return self.connectionMode == BLEMode.command })
        ]
        if let incomingString = String(data: incomingMessage, encoding: .utf8)
        {
            for atcommand in atcommandlist
            {
                if (incomingString.hasPrefix(atcommand.0))
                {
                    if atcommand.1(incomingMessage)
                    {
                        delegate?.receiveMessageOverBLE(receivedData: "OK\r\n".data(using: .utf8)!)
                    }
                    else
                    {
                        delegate?.receiveMessageOverBLE(receivedData: "ERROR\r\n".data(using: .utf8)!)
                    }
                   // delegate?.receiveMessageOverBLE(receivedData: "OK\r\n".data(using: .utf8)!)
                    return;
                }
            }
        }
        delegate?.receiveMessageOverBLE(receivedData: "ERROR\r\n".data(using: .utf8)!)
    }
    
    func toggleMode(redundantString: Data = Data()) -> Bool
    {
        if connectionMode == BLEMode.command
        {
            connectionMode = BLEMode.data
        }
        else
        {
            connectionMode = BLEMode.command
        }
        return true;
    }
    
    
    var NVRam = Data(repeating: 0, count: 256)
    //let cchar = "abc".cString(using: .utf8) returns array of CChar.
    
    
    
}
