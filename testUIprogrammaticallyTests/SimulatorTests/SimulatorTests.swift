//
//  SimulatorTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class SimulatorTests: XCTestCase {
    
    let theSubject = Simulator_UART() ;
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        theSubject.upstreamDelegate = nil
        
        super.tearDown()
    }
    
    func testSimulatorSplitStringIntoLines_emptyString()
    {
        let returnStrings : [String] = theSubject.splitStringIntoLines(fullStringASCII : String("").utf8, maxChars : 20);
        
        XCTAssert(returnStrings.count == 0);
        //XCTAssert(returnStrings[0] == "hello\nthere");
    }
    
    func testSimulatorSplitStringIntoLines_basicShortString()
    {
        let returnStrings : [String] = theSubject.splitStringIntoLines(fullStringASCII : String("hello").utf8, maxChars : 20);
        
        XCTAssert(returnStrings.count == 1);
        XCTAssert(returnStrings[0] == "hello");
    }
    
    func testSimulatorSplitStringIntoLines_basicShortStringIncludesNewLine()
    {
        let returnStrings : [String] = theSubject.splitStringIntoLines(fullStringASCII : String("hello\nthere").utf8, maxChars : 20);
        
        XCTAssert(returnStrings.count == 1);
        XCTAssert(returnStrings[0] == "hello\nthere");
    }
    
    func testSimulatorSplitStringIntoLines_veryLongString()
    {
        let multiLineString = """
    To be, or not to be - that is the question;
    Whether 'tis nobler in the mind to suffer
    The slings and arrows of outrageous fortune,
    Or to take arms against a sea of troubles,
    """
        let returnStrings : [String] = theSubject.splitStringIntoLines(fullStringASCII : multiLineString.utf8, maxChars : 20);
        
        XCTAssert(returnStrings.count == 9);
        XCTAssert(returnStrings[0] == "To be, or not to be ")
        XCTAssert(returnStrings[1] == "- that is the questi")
        XCTAssert(returnStrings[2] == "on;\nWhether 'tis nob")
        XCTAssert(returnStrings[3] == "ler in the mind to s")
        XCTAssert(returnStrings[4] == "uffer\nThe slings and")
        XCTAssert(returnStrings[5] == " arrows of outrageou")
        XCTAssert(returnStrings[6] == "s fortune,\nOr to tak")
        XCTAssert(returnStrings[7] == "e arms against a sea")
        XCTAssert(returnStrings[8] == " of troubles,")
    }
    
    func testSimulatorSendString_NoDelegate()
    {
        XCTAssertNil(theSubject.upstreamDelegate)
        theSubject.sendStringUpstream(stringToSend: "hello".data(using: .utf8)!)
        //should crash if optional not handled correctly
        XCTAssertNil(theSubject.upstreamDelegate)
    }
    
   
    
    func testSimulatorSendString_threeLinesToDelegate()
    {
        let forTestDelegate = TestingUARTTextDelegate();
        
        
        XCTAssertNil(theSubject.upstreamDelegate)
        theSubject.upstreamDelegate = forTestDelegate;
        theSubject.sendStringUpstream(stringToSend: "hello".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 1)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "hello")
        
        //larger test - multi line
        theSubject.sendStringUpstream(stringToSend: "000000000011111111112222222".data(using: .utf8)!)
        XCTAssertEqual(forTestDelegate.receivedCount, 3)
        XCTAssertEqual(forTestDelegate.receivedStrings[0], "hello")
        XCTAssertEqual(forTestDelegate.receivedStrings[1], "00000000001111111111")
        XCTAssertEqual(forTestDelegate.receivedStrings[2], "2222222")
    }

  
}
