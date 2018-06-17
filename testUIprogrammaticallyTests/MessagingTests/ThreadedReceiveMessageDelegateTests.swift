//
//  ThreadedReceiveMessageDelegateTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 10/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class ThreadedReceiveMessageDelegateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStartAndQuitThread()
    {
        let theTestDelegate = TestingUARTTextDelegate()
        let theSubject = ThreadedReceiveMessageDelegate<TestingUARTTextDelegate>(theObject: theTestDelegate)
        XCTAssertTrue(theSubject.blockTillThreadStarted(timeToWait: 3)) //ThreadStarts
        XCTAssertTrue(theSubject.threadIsRunning)
        XCTAssertTrue(theSubject.isExecuting)
        XCTAssertFalse(theSubject.isCancelled)
        theSubject.cancel()
        theSubject.messageReceivedCondition.signal()
        XCTAssertTrue(theSubject.blockTillThreadStopped(timeToWait: 3)) //ThreadStops
        XCTAssertTrue(theSubject.isCancelled)
        XCTAssertFalse(theSubject.threadIsRunning)
    }
   
    
}
