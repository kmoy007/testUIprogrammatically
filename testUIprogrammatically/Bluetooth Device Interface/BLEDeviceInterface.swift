//
//  BLEDeviceInterface.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 10/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation

class BLEDeviceInterface : ReceiveMessageDelegate
{
    
    var receivedDataBuffer : Data?
    let messageReceivedCondition = NSCondition()
    private let dateGenerator: () -> Date
    
    var upstream_TEMP : ReceiveMessageDelegate?
    
    init(dateGenerator: @escaping () -> Date = Date.init)
    {
        self.dateGenerator = dateGenerator
    }
    func receiveStringFromUART(receive: Data) //From downstream BLE Device - wait - OR from upstream
    {
        messageReceivedCondition.lock()
        //assert(receivedDataBuffer == nil, "BLEDeviceInterface::receiveStringFromUART buffer overflow!")
        if (receivedDataBuffer != nil)
        {
            receivedDataBuffer!.append(receive)
        }
        else
        {
            receivedDataBuffer = receive
        }
        messageReceivedCondition.unlock()
        messageReceivedCondition.signal()
        
        upstream_TEMP?.receiveStringFromUART(receive: receivedDataBuffer!)//TEMP UNTIL WE MAKE A THREAD FOR THIS

        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "NotifyReceivedBLE_UART_Message"), object: nil)
    }
    
    func isConnected() -> Bool
    {
        return true;
    }
    
    func waitForOKResponse(timeToWait: TimeInterval) -> (gotOK: Bool, anyOtherDataBeforeOKOrError: Data, leftOverData: Data)
    {
        let endWaitTime = dateGenerator().addingTimeInterval(Double(timeToWait))
        var receivedOK = false
        
        var fullLineResponses = Data()
        var leftOverData = Data()
    
        var incomingBuffer = Data()
        while (dateGenerator() < endWaitTime) && !receivedOK
        {
            let response = waitForAResponse(timeToWait: timeToWait);
            
            if var responseConcrete = response
            {
                incomingBuffer.append(responseConcrete);
            }
            
            while let nextString = Tokenizer.getNextStringTokenizedBynewline(dataIn: &incomingBuffer)
            {
                if (nextString == "OK\r\n".data(using: .utf8)!) || (nextString == "OK\n".data(using: .utf8)!)
                {
                    //dont bother appending the OK line, consume and signal it with the boolean
                    
                    leftOverData.append(incomingBuffer) // the Remainder
                    receivedOK = true
                    break;
                }
                else if (nextString == "ERROR\r\n".data(using: .utf8)!) || (nextString == "ERROR\n".data(using: .utf8)!)
                {
                    fullLineResponses.append(nextString)
                    leftOverData.append(incomingBuffer) // the Remainder
                    break;
                }
                else
                {
                    fullLineResponses.append(nextString)
                }
            }
            
        }
        return (receivedOK, fullLineResponses, leftOverData)
    }
    
    func getBLEMode() -> BLEMode
    {
        theDevice?.receiveStringFromUART(receive: "AT\n".data(using:.utf8)!)
        if (waitForOKResponse(timeToWait: 1).gotOK)
        {
            return BLEMode.command
        }
        return BLEMode.data
    }
    
    func getBLEInfo() -> String?
    {
        theDevice?.receiveStringFromUART(receive: "ATI\n".data(using:.utf8)!)
        let result = waitForOKResponse(timeToWait: 2)
        if (result.gotOK)
        {
            return String(data: result.anyOtherDataBeforeOKOrError, encoding: .utf8)!
        }
        return nil
    }
    
    func toggleBLEMode() -> Bool
    {
        theDevice?.receiveStringFromUART(receive: "+++\n".data(using:.utf8)!)
        return waitForOKResponse(timeToWait: 1).gotOK
    }
    
    func waitForAResponse(timeToWait: TimeInterval) -> Data?
    {
        messageReceivedCondition.lock()
        if receivedDataBuffer != nil
        {
            let receivedData = receivedDataBuffer
            receivedDataBuffer = nil;
            messageReceivedCondition.unlock()
            return receivedData
        }
        
        let endWaitTime = dateGenerator().addingTimeInterval(Double(timeToWait))
        var receivedMessage = false;
        
        while(receivedDataBuffer == nil) && (/*self.dateGenerator()*/ Date() < endWaitTime)
        {
            receivedMessage = messageReceivedCondition.wait(until: endWaitTime)
        }
        
        if (!receivedMessage)
        {
            assert(receivedDataBuffer == nil, "::waitForResponse receivedDataBuffer is not nil, but should be")
        }
        else
        {
            assert(receivedDataBuffer != nil, "::waitForResponse receivedDataBuffer is nil")
        }
       
        let receivedData = receivedDataBuffer
        receivedDataBuffer = nil;
        messageReceivedCondition.unlock()
        return receivedData
    }
    
    func setupNotifications()
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "NotifyReceivedBLE_UART_Message"), object: nil , queue: nil) { notification in
            self.processReceivedData();
        }
    }
    
    func processReceivedData()
    {
        //stringBufferToBeChangedLater to format along \n - currently that's in the viewmodel
        
        //receivedDataBuffer
        
        //theDevice?.receiveStringFromUART(receive: "received a message!".data(using:.utf8)!)
        
        print("Got a notification that a message was received" )
    }
    
    
    var theDevice : ReceiveMessageDelegate?// = BLEFriendSimulator();
}
