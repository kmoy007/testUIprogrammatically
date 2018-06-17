//
//  TestingUARTTextDelegate.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
@testable import testUIprogrammatically

class TestingUARTTextDelegate : ReceiveMessageDelegate
{
    var receivedCount = 0;
    var receivedStrings = [String]()
    
    func receiveStringFromUART(receive: Data)
    {
        receivedCount = receivedCount + 1
        receivedStrings.append(String(data: receive, encoding: .utf8)!)
    }
}

class TestingUARTTextMessageFormattingBuffer : SendMessageFormattingBuffer
{
    var messageDestination: ReceiveMessageDelegate?
    
    func formatAndSendData(stringToSend: Data) {
        receivedCount = receivedCount + 1
        receivedStrings.append(String(data: stringToSend, encoding: .utf8)!)
        
        assert(messageDestination == nil) //I assume we dont want this set in tests?
    }
    
    var receivedCount = 0;
    var receivedStrings = [String]()
}

