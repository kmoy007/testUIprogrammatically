//
//  BLEFriendSimulator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 30/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

enum BLEState { case disconnected, connected }
enum BLEMode { case command, data }

class BLEFriendSimulator
{
    var downstreamReceiver : ForwardingReceiver?
    var upstreamReceiver : ForwardingReceiver?
    
    init()
    {
        setupReceivers();
    }
    
    func setupReceivers()
    {
        downstreamReceiver = ForwardingReceiver(forwardTo: receiveDownstream)
        upstreamReceiver = ForwardingReceiver(forwardTo: receiveUpstream)
    }
    /*var messageSink = BLEFriend_SendMessageFormattingBuffer()
    init()
    {
        messageSink.messageDestination = delegate;
    }*/
    
//    enum BLEState { case disconnected, connected }
  //  enum BLEMode { case command, data }
    
    var connectionState = BLEState.disconnected
    var connectionMode = BLEMode.command
    
    var upStreamDevice : ReceiveMessageDelegate?
    
    
    var downStreamDevice : SendMessageFormattingBuffer = DoNothingSendMessageFormattingBuffer() //not a let for unit tests
    
    var incomingBuffer = Data()
    
    func receiveUpstream(receive : Data)
    {
         // just forward it on
        upStreamDevice?.receiveStringFromUART(receive: receive)
    }
    
    func receiveDownstream(receive : Data)
    {
        incomingBuffer = incomingBuffer + receive;
        while let nextString = Tokenizer.getNextStringTokenizedBynewline(dataIn: &incomingBuffer)
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
                downStreamDevice.formatAndSendData(stringToSend: nextString)
            }
        }
    }
    
    
    func specialCaseModeToggle(incomingMessage : Data) -> Bool
    {
        if let incomingString = String(data: incomingMessage, encoding: .utf8)
        {
            if (incomingString == "+++\n")
            {
                self.toggleMode()
                upStreamDevice?.receiveStringFromUART(receive: "OK\r\n".data(using: .utf8)!)
                return true
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
            upStreamDevice?.receiveStringFromUART(receive: NVRam)
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
    
    func getInfo(incomingMessage : Data) -> Bool
    {
        if let theConcreteUpStreamDevice = upStreamDevice
        {
            let multiLineString = """
    To be, or not to be - that is the question;
    Whether 'tis nobler in the mind to suffer
    """
            theConcreteUpStreamDevice.receiveStringFromUART(receive: multiLineString.data(using: .utf8)!)
            sleep(1);
            theConcreteUpStreamDevice.receiveStringFromUART(receive: "\nThe slings and arrows of outrageous fortune,\nOr to take arms against a sea of troubles,".data(using: .utf8)!)
            theConcreteUpStreamDevice.receiveStringFromUART(receive: "\n".data(using: .utf8)!)
            //theConcreteDelegate.receiveStringFromUART(receive: "OK\r\n".data(using: .utf8)!)
            return true;
        }
        else
        {
            return false;
        }
        return true;
    }
    
    func ATCommandFilter(incomingMessage : Data)
    {
        let atcommandlist : [(String, (Data) -> Bool)] = [
            ("+++\n", self.toggleMode),
            ("AT+NVMWRITE=",self.WriteNVM),
            ("AT+NVMREAD=",self.ReadNVM),
            ("ATI", self.getInfo),
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
                        upStreamDevice?.receiveStringFromUART(receive: "OK\r\n".data(using: .utf8)!)
                    }
                    else
                    {
                        upStreamDevice?.receiveStringFromUART(receive: "ERROR\r\n".data(using: .utf8)!)
                    }
                   // delegate?.receiveMessageOverBLE(receivedData: "OK\r\n".data(using: .utf8)!)
                    return;
                }
            }
        }
        upStreamDevice?.receiveStringFromUART(receive: "ERROR\r\n".data(using: .utf8)!)
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
