//
//  DeviceSimulatorTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 3/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically

class DeviceSimulatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample()
    {
        let theDevice = DeviceSimulator();
        XCTAssert(true);
    }
    
   
    
}
