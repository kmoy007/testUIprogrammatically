//
//  ElectronSimulator.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 6/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class BasicClock
{
    func getTime() -> Int
    {
        let timeSinceStart = Date() - initDateInterval
        //let start = initTimeInterval
        
        return Int(timeSinceStart.timeIntervalSince1970)
    }
    
    func setTime(unixTime: Int)
    {
        initDateInterval = DateInterval(start: Date(timeIntervalSince1970: Double(unixTime)), end: Date()).duration
       // Double(unixTime);
    }
    
    
    var initDateInterval = DateInterval(start: Date(timeIntervalSince1970: 0), end: Date()).duration
    
    //var initTimeInterval = NSTimeIntervalSince1970//(start: Date(), end: Date(timeIntervalSince1970: 0)) //start at unixTime zero
    //var currentUnitTime = Date.init(timeIntervalSince1970: 123) //initialise to nothing
}


class ElectronSimulator : ReceiveMessageDelegate
{
    class BasicCommandProcessorResponseHandler : ReceiveMessageDelegate
    {
        func receiveStringFromUART(receive: Data)
        {
            if responses.count > 0 { responses = responses + "," }
            
            responses = responses + String(data: receive, encoding: .utf8)!
        }
        var responses = String()
    }
    
    
    //MARK: ReceiveMessageDelegate
    func receiveStringFromUART(receive: Data)
    {
       processMessage(receive: receive)
        
 
    }
    
    var upstreamDevice : ReceiveMessageDelegate?
    
    
    //MARK: ElectronSimulator
    let clock = BasicClock();
    let commandProcessor = BasicCommandProcessor();
    var theThread : ThreadedReceiveMessageDelegate<ElectronSimulator>?
    
    enum DeviceState { case deepSleep, waking, talking, transmitting }
    var currentState = DeviceState.deepSleep
    
    init()
    {
        commandProcessor.commands["GetUnixTime"] = self.GetTime;
        commandProcessor.commands["SetUnixTime"] = self.SetTime;
    }
    
    func processMessage(receive: Data)
    {
         let commandResponses = BasicCommandProcessorResponseHandler();
         commandProcessor.responseDelegate = commandResponses;
        
         if (commandProcessor.ProcessCommand(incomingMessage: receive))
         {
            TEMP_sendResponse(key : "CommandSuccess", response : commandResponses.responses)
         }
         else
         {
            TEMP_sendResponse(key : "CommandError", response : commandResponses.responses)
         }
         commandProcessor.responseDelegate = nil;
        
    }
    func TEMP_sendResponse(key : String, response : String)
    {
        let coder = TwoStringCommaSeparatedEncoderDecoder()
        let responseToSend = coder.Encode(key: key, message: response)
        upstreamDevice?.receiveStringFromUART(receive: responseToSend)
    }
    
    //MARK: Real Functions
    func GetTime(message: String) -> Bool
    {
        TEMP_sendResponse(key: "GetUnixTime", response: String(clock.getTime()))
        return true
    }
    
    func SetTime(message: String) -> Bool
    {
        guard let asAValue = Int(message) else
        { TEMP_sendResponse(key: "SetUnixTime", response: "FailedToConvertToInt[" + message + "]"); return false }
        
        clock.setTime(unixTime: asAValue)
        TEMP_sendResponse(key: "SetUnixTime", response: "OK")
        return true
    }
    
    
    
   
}
