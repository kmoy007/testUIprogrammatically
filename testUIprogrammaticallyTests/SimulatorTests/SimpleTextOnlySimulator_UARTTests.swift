//
//  SimpleTextOnlySimulator_UARTTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class SimpleTextOnlySimulator_UARTTests: XCTestCase {
    
    let theSubject = SimpleTextOnly_MessageDelegate() ;
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        theSubject.messageSink = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimulatorReceiveString_empty()
    {
        let forTestDelegate = TestingUARTTextMessageFormattingBuffer();
        theSubject.messageSink = forTestDelegate;
        
        theSubject.receiveStringFromUART(receive: "".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 1)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "unrecognized command\n")
    }
    
    func testSimulatorReceiveString_junk()
    {
        /*let forTestDelegate = TestingUARTTextDelegate();
        theSubject.upstreamDelegate = forTestDelegate;
        */
        let forTestDelegate = TestingUARTTextMessageFormattingBuffer();
        theSubject.messageSink = forTestDelegate;
        
        theSubject.receiveStringFromUART(receive: "abcd".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 1)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "unrecognized command\n")
        
    }
    
    func testSimulatorReceiveString_testCommand()
    {
        /*let forTestDelegate = TestingUARTTextDelegate();
        theSubject.upstreamDelegate = forTestDelegate;
        */
        let forTestDelegate = TestingUARTTextMessageFormattingBuffer();
        theSubject.messageSink = forTestDelegate;
        
        theSubject.receiveStringFromUART(receive: "testcommand".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 1)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "unrecognized command\n") //no space after testCommand
        
        theSubject.receiveStringFromUART(receive: "testcommand ".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 2)
        XCTAssertEqual(forTestDelegate.receivedStrings[1], "sure thing, I will do: \n")
        
        
        theSubject.receiveStringFromUART(receive: "testcommand hello there".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 3)
        XCTAssertEqual(forTestDelegate.receivedStrings[2], "sure thing, I will do: hello there\n")
    }
    /*
    func testSimulatorReceiveString_testCommand()
    {
        let forTestDelegate = TestingUARTTextDelegate();
        theSubject.upstreamDelegate = forTestDelegate;
        
        theSubject.receiveStringFromUART(receive: "testcommand")
        XCTAssertEqual(forTestDelegate.receivedCount, 2)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "unrecognized command") //no space after testCommand
        XCTAssertEqual(forTestDelegate.receivedStrings[1], "\n") //empty as it was just a carriage return
        
        theSubject.receiveStringFromUART(receive: "testcommand ")
        XCTAssertEqual(forTestDelegate.receivedCount, 4)
        XCTAssertEqual(forTestDelegate.receivedStrings[2], "sure thing, I will d")
        XCTAssertEqual(forTestDelegate.receivedStrings[3], "o: \n") //no space after testCommand
        
        
        theSubject.receiveStringFromUART(receive: "testcommand hello there")
        XCTAssertEqual(forTestDelegate.receivedCount, 6)
        XCTAssertEqual(forTestDelegate.receivedStrings[4], "sure thing, I will d")
        XCTAssertEqual(forTestDelegate.receivedStrings[5], "o: hello there\n") //no space after testCommand
    }
    */
    
}
