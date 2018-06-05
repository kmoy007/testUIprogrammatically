//
//  TestingUARTTextDelegate.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation
@testable import testUIprogrammatically

class TestingUARTTextDelegate : UARTTextDelegate
{
    var theUart: UART?
    
    var receivedCount = 0;
    var receivedStrings = [String]()
    
    func receiveStringFromUART(receive: String)
    {
        receivedCount = receivedCount + 1
        receivedStrings.append(String(receive))
    }
    func sendStringFromUser(send: String)
    {
        assert(false) //not implemented yet
    }
    
}
