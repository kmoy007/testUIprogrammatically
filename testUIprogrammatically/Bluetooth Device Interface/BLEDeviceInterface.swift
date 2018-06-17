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
    func receiveStringFromUART(receive: Data) //From BLE Device
    {
        assert(receivedDataBuffer == nil, "BLEDeviceInterface::receiveStringFromUART buffer overflow!")
        receivedDataBuffer = receive
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "NotifyReceivedBLE_UART_Message"), object: nil)
    }
    
    func isConnected() -> Bool
    {
        return true;
    }
    
    func getBLEMode() -> BLEMode
    {
        theDevice?.receiveStringFromUART(receive: "AT\n".data(using:.utf8)!)
        //Wait for response
        //if response of "OK" after 1 second then it is in command mode, otherwise data mode
        
        return BLEMode.command
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
        theDevice?.receiveStringFromUART(receive: "received a message!".data(using:.utf8)!)
        
        
    }
    
    
    var theDevice : ReceiveMessageDelegate?// = BLEFriendSimulator();
}
