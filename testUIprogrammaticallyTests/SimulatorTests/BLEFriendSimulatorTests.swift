//
//  BLEFriendSimulatorTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 30/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class BLEFriendSimulatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitializes() {
        
        let theSubject = BLEFriendSimulator()
        
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
        XCTAssertEqual(theSubject.connectionState, BLEState.disconnected)
        XCTAssert(theSubject.delegate == nil)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testToggleMode() {
        
        let theSubject = BLEFriendSimulator()
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
        theSubject.toggleMode();
        XCTAssertEqual(theSubject.connectionMode, BLEMode.data)
        theSubject.toggleMode();
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
    }
    
    func testfilterForToggleMode_empty() {
        let theSubject = BLEFriendSimulator()
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
        
        theSubject.ATCommandFilter(incomingMessage: "".data(using: .utf8)!)
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)  //no change
//        XCTAssertEqual(result, false)  //no change
    }
    
    func testfilterForToggleMode_NoToggleButOtherStringsPassThrough() {
        let theSubject = BLEFriendSimulator()
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
        
        theSubject.ATCommandFilter(incomingMessage: "+++Hello++".data(using: .utf8)!)
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)  //no change
//        XCTAssertEqual(result1, false)  //no change

        theSubject.ATCommandFilter(incomingMessage: "srt".data(using: .utf8)!) //short
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)  //no change
//        XCTAssertEqual(result2, false)  //no change
    }
    
    func testfilterForToggleMode_withToggle() {
        let theSubject = BLEFriendSimulator()
        let theDelegate = MockBLEFriendSimulatorDelegate();
        theSubject.delegate = theDelegate;
        
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)
        
        theSubject.ATCommandFilter(incomingMessage: "+++\n".data(using: .utf8)!)
        XCTAssertEqual(theSubject.connectionMode, BLEMode.data)  //simple toggle, empty return
        XCTAssertEqual(theDelegate.receivedStrings.count, 1)
        XCTAssertEqual(theDelegate.receivedStrings[0], "OK\r\n")
        
        theSubject.ATCommandFilter(incomingMessage: "+++\n".data(using: .utf8)!)
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)  //simple toggle, empty return
        XCTAssertEqual(theDelegate.receivedStrings.count, 2)
        XCTAssertEqual(theDelegate.receivedStrings[1], "OK\r\n")
        
        
 /*       let result2 = theSubject.filterForToggleMode(incomingMessage: "+++\nblah".utf8CString) //with return
        XCTAssertEqual(theSubject.connectionMode, BLEFriendSimulator.BLEMode.command)
        XCTAssertEqual(result2, "blah".utf8CString)
        
        let result3 = theSubject.filterForToggleMode(incomingMessage: "+++\nblah\n+++\n".utf8CString) //multi
        XCTAssertEqual(theSubject.connectionMode, BLEFriendSimulator.BLEMode.command) //WILL FAIL NOW
        XCTAssertEqual(result2, "blah\n+++\n".utf8CString) //?
 */
    }
    
  
    
    class MockMessageFormattingBuffer : SendMessageFormattingBuffer
    {
        var messageDestination: ReceiveMessageDelegate?
        
        func formatAndSendData(stringToSend: Data) {
            receivedDataAsString.append(stringToSend)
            messageDestination?.receiveStringFromUART(receive: stringToSend)
        }
        
        var receivedDataAsString = [Data]()
    }
    
    func testreceiveBTmessage_compositetest_basic() {
        let mockMessageFormattingBuffer = MockMessageFormattingBuffer()
        let theSubject = BLEFriendSimulator()
        
        XCTAssertNotNil(theSubject.attachedDevice)
        
        theSubject.attachedDevice = mockMessageFormattingBuffer
        
        theSubject.toggleMode()
        XCTAssertEqual(theSubject.connectionMode, BLEMode.data)
       
        theSubject.receiveStringFromUART(receive: "".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 0)
        
        theSubject.receiveStringFromUART(receive: "test".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 0)
        
        theSubject.receiveStringFromUART(receive: "ing\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 1)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[0], "testing\n".data(using: .utf8)!)
        
        theSubject.receiveStringFromUART(receive: "myname\nisken\nhello".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 3)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[0], "testing\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[1], "myname\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[2], "isken\n".data(using: .utf8)!)
        
        theSubject.receiveStringFromUART(receive: "\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 4)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[3], "hello\n".data(using: .utf8)!)
        
        theSubject.receiveStringFromUART(receive: "hello+++\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 5)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[4], "hello+++\n".data(using: .utf8)!)
        
        XCTAssertEqual(theSubject.connectionMode, BLEMode.data)
        theSubject.receiveStringFromUART(receive: "+++\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 5) //NO NEW STRING - Consumed as AT command
        XCTAssertEqual(theSubject.connectionMode, BLEMode.command)

        theSubject.receiveStringFromUART(receive: "helloagain\n".data(using: .utf8)!)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 5) //NO NEW STRING - Consumed as AT command
        
        theSubject.receiveStringFromUART(receive: "+++\n".data(using: .utf8)!)
        theSubject.receiveStringFromUART(receive: "lasttry\n".data(using: .utf8)!)
        XCTAssertEqual(theSubject.connectionMode, BLEMode.data)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString.count, 6)
        XCTAssertEqual(mockMessageFormattingBuffer.receivedDataAsString[5], "lasttry\n".data(using: .utf8)!)
    }
    
    func testsplitNVMCommands()
    {
     //   let mockDelegate = MockBLEFriendSimulatorDelegate()
        let theSubject = BLEFriendSimulator()
     //   theSubject.delegate = mockDelegate
       
        XCTAssertNil(theSubject.splitNVMCommands(incomingMessage: "".data(using: .utf8)!)) //empty String
        XCTAssertNil(theSubject.splitNVMCommands(incomingMessage: "\n".data(using: .utf8)!)) //just a NL character
        XCTAssertNil(theSubject.splitNVMCommands(incomingMessage: "AT,34,45,56".data(using: .utf8)!)) //four with the comma, no equal
        XCTAssertNil(theSubject.splitNVMCommands(incomingMessage: "AT=34,45".data(using: .utf8)!)) //four with the equal and only one comma
        
        var theTuple = theSubject.splitNVMCommands(incomingMessage: "AT=34,45,56".data(using: .utf8)!) //this one should work!
        XCTAssertNotNil(theTuple)
        XCTAssertEqual("34".data(using: .utf8)!, theTuple!.0)
        XCTAssertEqual("45".data(using: .utf8)!, theTuple!.1)
        XCTAssertEqual("56".data(using: .utf8)!, theTuple!.2)
        
        var theTuple2 = theSubject.splitNVMCommands(incomingMessage: "AT=34,45,56,78".data(using: .utf8)!) //this one should work! - extra comma
        XCTAssertNotNil(theTuple2)
        XCTAssertEqual("34".data(using: .utf8)!, theTuple2!.0)
        XCTAssertEqual("45".data(using: .utf8)!, theTuple2!.1)
        XCTAssertEqual("56,78".data(using: .utf8)!, theTuple2!.2)

    }
    
    class MockBLEFriendSimulatorDelegate : ReceiveMessageDelegate
    {
        func receiveStringFromUART(receive: Data)
        {
            receivedStrings.append(String(data: receive, encoding: .utf8)!)
        }
        
        var receivedStrings = [String]()
    }
    
    func testreadNVMCommands()
    {
        let theSubject = BLEFriendSimulator()
        XCTAssertEqual(theSubject.NVRam.count, 256)
        
        theSubject.NVRam = "testing NVRAM string, this should have a total\nof 256 characters. I'm only testing with UTF characters.LetsRepeatIt: To be or not to be, that is the question etc... not that much text done correctly.  Let's see what else we can store in here...  something.".data(using: .utf8)!
        XCTAssertEqual(theSubject.NVRam.count, 256)
        
        let theDelegate = MockBLEFriendSimulatorDelegate();
        theSubject.delegate = theDelegate;
        
        XCTAssertTrue(theSubject.ReadNVM(incomingMessage: "AT+NVMREAD=0, 256, BYTEARRAY".data(using: .utf8)!))
        XCTAssertEqual(theDelegate.receivedStrings.count, 1)
    //    XCTAssertEqual(theSubject.NVRam, theDelegate.receivedStrings[0].data(using: .utf8)!)
     //   XCTAssertEqual(theDelegate.receivedStrings[1], "OK\r\n")
        
        theDelegate.receivedStrings = [String]()
        theSubject.ATCommandFilter(incomingMessage: "AT+NVMREAD=0, 256, BYTEARRAY".data(using: .utf8)!)
        XCTAssertEqual(theDelegate.receivedStrings.count, 2)
        XCTAssertEqual(theSubject.NVRam, theDelegate.receivedStrings[0].data(using: .utf8)!)
        XCTAssertEqual(theDelegate.receivedStrings[1], "OK\r\n")
        
        //BELOW HERE WILL FAIL FOR NOW
        
        //substring
        theSubject.ATCommandFilter(incomingMessage: "AT+NVMREAD=11, 25, BYTEARRAY".data(using: .utf8)!)
        XCTAssertEqual(theDelegate.receivedStrings.count, 4)
        XCTAssertEqual("AM string, this should ha", theDelegate.receivedStrings[2])
        XCTAssertEqual(theDelegate.receivedStrings[3], "OK\r\n")
        
        //nil because asked for too much
        theSubject.ATCommandFilter(incomingMessage: "AT+NVMREAD=11, 25, BYTEARRAY".data(using: .utf8)!)
        XCTAssertEqual(theDelegate.receivedStrings.count, 5)
        XCTAssertEqual(theDelegate.receivedStrings[4], "ERROR\r\n")
    }
    
    func testwriteNVMCommands()
    {
        let theSubject = BLEFriendSimulator()
        XCTAssertEqual(theSubject.NVRam.count, 256)
        let theDelegate = MockBLEFriendSimulatorDelegate();
        theSubject.delegate = theDelegate;
        
        let theString = "AT+NVMWRITE=0, BYTEARRAY,testing NVRAM string, this should have a total\nof 256 characters. I'm only testing with UTF characters.LetsRepeatIt: To be or not to be, that is the question etc... not that much text done correctly.  Let's see what else we can store in here...  something.".data(using: .utf8)!
        
        theSubject.WriteNVM(incomingMessage: theString)
        XCTAssertEqual(theSubject.NVRam.count, 256)
        XCTAssertEqual(theSubject.NVRam, "testing NVRAM string, this should have a total\nof 256 characters. I'm only testing with UTF characters.LetsRepeatIt: To be or not to be, that is the question etc... not that much text done correctly.  Let's see what else we can store in here...  something.".data(using: .utf8)!)
        
        theSubject.NVRam = Data(repeating: 0, count: 256)
        theDelegate.receivedStrings = [String]()
        theSubject.ATCommandFilter(incomingMessage: theString)
        XCTAssertEqual(theSubject.NVRam.count, 256)
        XCTAssertEqual(theSubject.NVRam, "testing NVRAM string, this should have a total\nof 256 characters. I'm only testing with UTF characters.LetsRepeatIt: To be or not to be, that is the question etc... not that much text done correctly.  Let's see what else we can store in here...  something.".data(using: .utf8)!)
        XCTAssertEqual(theDelegate.receivedStrings.count, 1)
        XCTAssertEqual(theDelegate.receivedStrings[0], "OK\r\n")
        
        
        //BELOW HERE WILL FAIL FOR NOW
        
        theSubject.WriteNVM(incomingMessage: "AT+NVMREAD=10, BYTEARRAY,dong".data(using: .utf8)!)
        XCTAssertEqual(theSubject.NVRam.count, 256)
        XCTAssertEqual(theSubject.NVRam, "testing NVdongstring, this should have a total\nof 256 characters. I'm only testing with UTF characters.LetsRepeatIt: To be or not to be, that is the question etc... not that much text done correctly.  Let's see what else we can store in here...  something.".data(using: .utf8)!)
    }
    
    func testgetInfo()
    {
        let theSubject = BLEFriendSimulator()
        let theDelegate = MockBLEFriendSimulatorDelegate();
        theSubject.delegate = theDelegate;
        
        XCTAssertTrue(theSubject.getInfo(incomingMessage: "this is ignored".data(using: .utf8)!))
        XCTAssertEqual(theDelegate.receivedStrings.count, 2)
    }
    
}
