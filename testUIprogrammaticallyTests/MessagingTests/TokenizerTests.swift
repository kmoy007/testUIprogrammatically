//
//  TokenizerTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 22/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class TokenizerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testgetNextStringTokenizedBynewline() {
       // let theSubject = BLEFriendSimulator()
      //  XCTAssertEqual(theSubject.incomingBuffer, "".data(using: .utf8)!)
        var theString = "".data(using: .utf8)!
        let result1 = Tokenizer.getNextStringTokenizedBynewline(dataIn: &theString)
        XCTAssertEqual(result1, nil)
//        XCTAssertEqual(theSubject.incomingBuffer, "".data(using: .utf8)!)
        
        theString = "test".data(using: .utf8)!
        let result2 = Tokenizer.getNextStringTokenizedBynewline(dataIn: &theString )
        XCTAssertEqual(result2, nil)
        XCTAssertEqual(theString, "test".data(using: .utf8)!)
        
        var testDataArray1 = "test\n".data(using: .ascii)!
        let result3 = Tokenizer.getNextStringTokenizedBynewline(dataIn: &testDataArray1)
        XCTAssertEqual(result3, "test\n".data(using: .utf8)!)
        XCTAssertEqual(testDataArray1, "".data(using: .utf8)!)
        
        theString = "test\nmoreStuff".data(using: .utf8)!
        let result4 = Tokenizer.getNextStringTokenizedBynewline(dataIn: &theString)
        XCTAssertEqual(result4, "test\n".data(using: .utf8)!)
        XCTAssertEqual(theString, "moreStuff".data(using: .utf8)!)
        
        theString = "test\nmoreStuff\nAndAgain".data(using: .utf8)!
        let result5 = Tokenizer.getNextStringTokenizedBynewline(dataIn: &theString)
        XCTAssertEqual(result5, "test\n".data(using: .utf8)!)
        XCTAssertEqual(theString, "moreStuff\nAndAgain".data(using: .utf8)!)
    }
   
    
}
