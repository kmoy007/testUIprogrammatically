//
//  SerialTextViewModelTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 27/05/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class SerialTextViewModelTests: XCTestCase {
    
    let theSubject = SerialTextViewModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        theSubject.theStrings = [String]()
        theSubject.theUart = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testaddIncomingString_WithCorrectFormatting_addOneBasicString()
    {
        
        XCTAssert(theSubject.theStrings.count == 0)
        theSubject.addIncomingString_WithCorrectFormatting(receivedString: "hello")
        XCTAssert(theSubject.theStrings.count == 1)
        XCTAssert(theSubject.theStrings[0] == "hello")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testaddIncomingString_WithCorrectFormatting_addTwoBasicStrings()
    {
        XCTAssert(theSubject.theStrings.count == 0)
        theSubject.addIncomingString_WithCorrectFormatting(receivedString: "hello")
        XCTAssert(theSubject.theStrings.count == 1)
        XCTAssert(theSubject.theStrings[0] == "hello")
        theSubject.addIncomingString_WithCorrectFormatting(receivedString: " there")
        XCTAssert(theSubject.theStrings.count == 1)
        XCTAssert(theSubject.theStrings[0] == "hello there")
    }
    
    func testaddIncomingString_WithCorrectFormatting_addStringWithNewLine()
    {
        XCTAssert(theSubject.theStrings.count == 0)
        theSubject.addIncomingString_WithCorrectFormatting(receivedString: "hello\nto you my friend")
        XCTAssert(theSubject.theStrings.count == 2)
        XCTAssert(theSubject.theStrings[0] == "hello")
        XCTAssert(theSubject.theStrings[1] == "to you my friend")
    }
    
    func testaddIncomingString_WithCorrectFormatting_addMultipleStringsWithVariousNewLines()
    {
        let stringsToAdd : [String] = ["this is a ","set of strings that we", " will be adding\n", "first New Line here and \nsecond new line here"]
        XCTAssert(theSubject.theStrings.count == 0)
        
        for aString in stringsToAdd
        {
            theSubject.addIncomingString_WithCorrectFormatting(receivedString: aString)
        }
        XCTAssert(theSubject.theStrings.count == 3)
        XCTAssert(theSubject.theStrings[0] == "this is a set of strings that we will be adding")
        XCTAssert(theSubject.theStrings[1] == "first New Line here and ")
        XCTAssert(theSubject.theStrings[2] == "second new line here")
    }
    
    func testSendAString()
    {
        let stringsToAdd : [String] = ["this is a ","set of strings that we", " will be adding\n", "first New Line here and \nsecond new line here"]
        XCTAssert(theSubject.theStrings.count == 0)
        
        for aString in stringsToAdd
        {
            theSubject.addIncomingString_WithCorrectFormatting(receivedString: aString)
        }
        XCTAssert(theSubject.theStrings.count == 3)
        XCTAssert(theSubject.theStrings[0] == "this is a set of strings that we will be adding")
        XCTAssert(theSubject.theStrings[1] == "first New Line here and ")
        XCTAssert(theSubject.theStrings[2] == "second new line here")
    }
    
    class MockUART : UART
    {
        func sendStringUpstream(stringToSend: Data) {
            assert(false)
        }
        
        var upstreamDelegate: UARTTextDelegate?
        var downstreamDelegate: UARTTextDelegate?
        var theStrings = [String]()
        
        func sendStringDownstream(stringToSend: Data) {
            theStrings.append(String(data: stringToSend, encoding: .utf8)!)
        }
        
    }
    
    func testAttachDelegate()
    {
        XCTAssert(theSubject.theUart == nil)  //no UART attached
        
        let mockUART = MockUART()
        theSubject.theUart = mockUART
        
        XCTAssert(theSubject.theUart === mockUART)  //uncontroversial
        
        XCTAssert(theSubject === mockUART.upstreamDelegate)  //this is the important checl
    }
    
    func testsendStringFromUser_normal()
    {
        theSubject.sendStringFromUser(send: "")
        XCTAssert(theSubject.theStrings.count == 0)  //no UART attached
        
        let mockUART = MockUART()
        theSubject.theUart = mockUART
        
        theSubject.sendStringFromUser(send: "")
        XCTAssertEqual(theSubject.theStrings.count, 0)  //nothing received
        
        XCTAssertEqual(mockUART.theStrings.count, 1)
        XCTAssertEqual(mockUART.theStrings[0], "")
        
        theSubject.sendStringFromUser(send: "abcdefghijklmnopqrstuvwxy\n1234")
        XCTAssertEqual(mockUART.theStrings.count, 2)
        XCTAssertEqual(mockUART.theStrings[1], "abcdefghijklmnopqrstuvwxy\n1234")
        
    }
    
    func testsendStringFromUser_nonUTF8Character()
    {
        theSubject.sendStringFromUser(send: "")
        XCTAssert(theSubject.theStrings.count == 0)  //no UART attached
        
        let mockUART = MockUART()
        theSubject.theUart = mockUART
        
        theSubject.sendStringFromUser(send: "ˆ¶ˍƒ©˚©ððß´ƒ-ºthings")
        // now it pops up a dialogbox, but this isn't testing for it.
        XCTAssert(mockUART.theStrings.count == 1)  //UART attached, empty string sent
        XCTAssertEqual(mockUART.theStrings[0], "ˆ¶ˍƒ©˚©ððß´ƒ-ºthings")
        
        XCTAssert(false) //once we decouple the UI we can test the error message
    }
    
    
    
}
