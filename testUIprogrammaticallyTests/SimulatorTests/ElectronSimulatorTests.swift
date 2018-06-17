//
//  ElectronSimulatorTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 6/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class ElectronSimulatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicClock()
    {
        let clock1 = BasicClock();
        XCTAssertEqual(clock1.getTime(), 0) //one second should not have passed
        sleep(3)
        XCTAssertGreaterThan(clock1.getTime(), 1) //buffer of two because timing is not unit-test-friendly
        XCTAssertLessThan(clock1.getTime(), 5) //buffer of two because timing is not unit-test-friendly
        
        clock1.setTime(unixTime: Int(Date().timeIntervalSince1970))
        
        XCTAssertEqual(Double(clock1.getTime()), Date().timeIntervalSince1970, accuracy: 1.1)
    }
    
    func testErroneousCommand()
    {
        let testMessageDelegate = TestingUARTTextDelegate();
        let theSubject = ElectronSimulator();
        theSubject.upstreamDevice = testMessageDelegate;
        
        //ilformed + unknown
        theSubject.receiveStringFromUART(receive: "junk".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 1)
        XCTAssertEqual(testMessageDelegate.receivedStrings[0],"CommandError,Couldnt decode command")
        
        //formed but unknown
        theSubject.receiveStringFromUART(receive: "junk,stuff".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 2)
        XCTAssertEqual(testMessageDelegate.receivedStrings[1],"CommandError,UnknownCommand[junk]")
        
        //ilformed + known
        theSubject.receiveStringFromUART(receive: "GetUnixTime".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 3)
        XCTAssertEqual(testMessageDelegate.receivedStrings[2],"CommandError,Couldnt decode command")
    }
    
    func testGetTime_ZeroUnixTime()
    {
        let testMessageDelegate = TestingUARTTextDelegate();
        let theSubject = ElectronSimulator();
        theSubject.upstreamDevice = testMessageDelegate;
        
        theSubject.receiveStringFromUART(receive: "GetUnixTime,whatever".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 2)
        XCTAssertTrue(testMessageDelegate.receivedStrings[0].hasPrefix("GetUnixTime,"))
        
        let coder = TwoStringCommaSeparatedEncoderDecoder()
        let result = coder.Decode(toDecode: testMessageDelegate.receivedStrings[0].data(using:.utf8)!)
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!.0, "GetUnixTime") //again, as above
        let theIntValue = Int(result!.1)!
        
        XCTAssertGreaterThanOrEqual(theIntValue, 0)
        XCTAssertLessThan(theIntValue, 2) //buffer of two, should be zero
        
        XCTAssertEqual(testMessageDelegate.receivedStrings[1],"CommandSuccess,")
        
    }
    
    func testGetTime_TwoSecondsUnixTime()
    {
        let testMessageDelegate = TestingUARTTextDelegate();
        let theSubject = ElectronSimulator();
        theSubject.upstreamDevice = testMessageDelegate;
        
        sleep(2);
        
        theSubject.receiveStringFromUART(receive: "GetUnixTime,whatever".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 2)
        XCTAssertTrue(testMessageDelegate.receivedStrings[0].hasPrefix("GetUnixTime,"))
        
        let coder = TwoStringCommaSeparatedEncoderDecoder()
        let result = coder.Decode(toDecode: testMessageDelegate.receivedStrings[0].data(using:.utf8)!)
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!.0, "GetUnixTime") //again, as above
        let theIntValue = Int(result!.1)!
        
        XCTAssertGreaterThanOrEqual(theIntValue, 2)
        XCTAssertLessThan(theIntValue, 4) //buffer of two, should be 2
        
        XCTAssertEqual(testMessageDelegate.receivedStrings[1],"CommandSuccess,")
        
    }
    
    func testSetTime_AndThenCheckTwoSecondsLater()
    {
        let testMessageDelegate = TestingUARTTextDelegate();
        let theSubject = ElectronSimulator();
        theSubject.upstreamDevice = testMessageDelegate;
        
        let currentUnixTime = Int(Date().timeIntervalSince1970)
        let setTimeString = String(format: "SetUnixTime,%d",currentUnixTime)
        
        theSubject.receiveStringFromUART(receive: setTimeString.data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 2)
        XCTAssertEqual(testMessageDelegate.receivedStrings[0], "SetUnixTime,OK")
        XCTAssertEqual(testMessageDelegate.receivedStrings[1], "CommandSuccess,")
        
        sleep(2)
        
        theSubject.receiveStringFromUART(receive: "GetUnixTime,".data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 4)
        let coder = TwoStringCommaSeparatedEncoderDecoder()
        let result = coder.Decode(toDecode: testMessageDelegate.receivedStrings[2].data(using:.utf8)!)
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!.0, "GetUnixTime") //again, as above
        XCTAssertEqual(testMessageDelegate.receivedStrings[3],"CommandSuccess,")
        let theIntValueResult = Int(result!.1)!
        
        XCTAssertGreaterThanOrEqual(theIntValueResult, currentUnixTime + 2)
        XCTAssertLessThan(theIntValueResult, currentUnixTime + 4) //buffer of two, should be 2
        
    }
    
    func testSetTime_junkData()
    {
        let testMessageDelegate = TestingUARTTextDelegate();
        let theSubject = ElectronSimulator();
        theSubject.upstreamDevice = testMessageDelegate;
        
        let setTimeString = "SetUnixTime,abc"
        
        theSubject.receiveStringFromUART(receive: setTimeString.data(using:.utf8)!)
        XCTAssertEqual(testMessageDelegate.receivedCount, 2)
        XCTAssertEqual(testMessageDelegate.receivedStrings[0], "SetUnixTime,FailedToConvertToInt[abc]")
        XCTAssertEqual(testMessageDelegate.receivedStrings[1], "CommandError,")
    }
    
}
