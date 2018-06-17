//
//  BasicCommandProcessorTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 7/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class BasicCommandProcessorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicCommandProcessor_emptyCommandList() {
        
        let testDelegate = TestingUARTTextDelegate();
        let theSubject = BasicCommandProcessor();
        
        theSubject.responseDelegate = testDelegate;
        theSubject.coder = TwoStringCommaSeparatedEncoderDecoder();
        
        XCTAssertFalse(theSubject.ProcessCommand(incomingMessage: "".data(using: .utf8)!)); //should fail
        XCTAssertEqual(testDelegate.receivedCount, 1);
        XCTAssertEqual(testDelegate.receivedStrings[0], "Couldnt decode command");
        
        XCTAssertFalse(theSubject.ProcessCommand(incomingMessage: ",".data(using: .utf8)!)); //should fail
        XCTAssertEqual(testDelegate.receivedCount, 2);
        XCTAssertEqual(testDelegate.receivedStrings[1], "UnknownCommand[]");
        
        XCTAssertFalse(theSubject.ProcessCommand(incomingMessage: "junk,here".data(using: .utf8)!)); //should fail
        XCTAssertEqual(testDelegate.receivedCount, 3);
        XCTAssertEqual(testDelegate.receivedStrings[2], "UnknownCommand[junk]");
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testBasicCommandProcessor_SimpleCommandList()
    {
        
        let testDelegate = TestingUARTTextDelegate();
        let theSubject = BasicCommandProcessor();
        
        var commands = [String : (String)->Bool]()
        commands["test1"] = {(message: String)->Bool in testDelegate.receiveStringFromUART(receive: String("Test1WasRun["+message+"]").data(using:.utf8)!); return true; }
        
        commands["test2toFail"] = {(message: String)->Bool in testDelegate.receiveStringFromUART(receive: String("Test2WasRun["+message+"]").data(using:.utf8)!); return false; }
    
        commands["test3"] = {(message: String)->Bool in testDelegate.receiveStringFromUART(receive: String("Test3WasRun["+message+"]").data(using:.utf8)!); return true; }

        theSubject.commands = commands;
        
        theSubject.responseDelegate = testDelegate;
        theSubject.coder = TwoStringCommaSeparatedEncoderDecoder();
        
        XCTAssertTrue(theSubject.ProcessCommand(incomingMessage: "test1,hello".data(using: .utf8)!)); //should pass
        XCTAssertEqual(testDelegate.receivedCount, 1);
        XCTAssertEqual(testDelegate.receivedStrings[0], "Test1WasRun[hello]");
        
        XCTAssertFalse(theSubject.ProcessCommand(incomingMessage: "test2toFail,stuff".data(using: .utf8)!)); //should fail
        XCTAssertEqual(testDelegate.receivedCount, 2);
        XCTAssertEqual(testDelegate.receivedStrings[1], "Test2WasRun[stuff]");
        
        XCTAssertTrue(theSubject.ProcessCommand(incomingMessage: "test3,here".data(using: .utf8)!)); //should pass
        XCTAssertEqual(testDelegate.receivedCount, 3);
        XCTAssertEqual(testDelegate.receivedStrings[2], "Test3WasRun[here]");
        
        XCTAssertFalse(theSubject.ProcessCommand(incomingMessage: "junk,here".data(using: .utf8)!)); //should fail
        XCTAssertEqual(testDelegate.receivedCount, 4);
        XCTAssertEqual(testDelegate.receivedStrings[3], "UnknownCommand[junk]");

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
   
    
}
