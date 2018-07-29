//
//  BLEDeviceInterfaceTests.swift
//  testUIprogrammaticallyTests
//
//  Created by Ken Moynihan on 10/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import XCTest
@testable import testUIprogrammatically
@testable import MessagePack

//class SimpleThreadForTesting:
class BLEDeviceInterfaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    class waitingThread : Thread
    {
        var isWaiting = false;
        let bleDeviceInterface : BLEDeviceInterface
        var result : Data?
        
        init(ble: BLEDeviceInterface)
        {
            bleDeviceInterface = ble
        }
        
        override func main()
        {
            isWaiting = true;
            result = bleDeviceInterface.waitForAResponse(timeToWait: 5)
            isWaiting = false;
        }
        
    }
    
    func testwaitForResponse_GetsResponse()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface(dateGenerator: timeTraveller.generateDate)
        
        let threadWaiter = waitingThread(ble: bleDeviceInterface);
        
        threadWaiter.start();
        
        while (!threadWaiter.isWaiting) { //let them start
            sleep(1);
        }
        
        XCTAssertNil(threadWaiter.result)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer)
        bleDeviceInterface.receiveUpstream(receive: "hello".data(using: .utf8)!)
        timeTraveller.travel(by: 4)
        
        while (threadWaiter.isExecuting){ //wait for it to finish
            sleep(1)
        }
        XCTAssertNotNil(threadWaiter.result)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer) //confirm that it is consumed
        
        if let theResult = threadWaiter.result
        {
            XCTAssertEqual(theResult, "hello".data(using: .utf8)!)
        }// Use XCTAssert and related functions to verify your tests produce the correct results.
        else
        {
            XCTAssert(false)
        }
    }
    
    func testwaitForResponse_NoResponse()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface(dateGenerator: timeTraveller.generateDate)
        
        
        let threadWaiter = waitingThread(ble: bleDeviceInterface);
     //   let threadTrigger = waitingThread(ble: bleDeviceInterface);
        
        threadWaiter.start();
      //  threadTrigger.start();
        
        while (!threadWaiter.isWaiting)  { //let them start
            sleep(1);
        }
        
        XCTAssertNil(threadWaiter.result)
        timeTraveller.travel(by: 4)
        XCTAssertNil(threadWaiter.result)
        timeTraveller.travel(by: 2)
        
        while (threadWaiter.isExecuting){ //wait for it to finish
            sleep(1)
        }
        XCTAssertNil(threadWaiter.result)
    }
    
    class waitingforOKThread : waitingThread
    {
        var wasOK = false;
        var leftover = Data();
        override func main()
        {
            isWaiting = true;
            let theResult = bleDeviceInterface.waitForOKResponse(timeToWait: 5)
            result = theResult.anyOtherDataBeforeOKOrError
            wasOK = theResult.gotOK
            leftover = theResult.leftOverData
            isWaiting = false;
        }
        
    }
    
    func testwaitForOKResponse_GetsResponseWithOK()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface(dateGenerator: timeTraveller.generateDate)
        
        let threadWaiter = waitingforOKThread(ble: bleDeviceInterface);
        
        threadWaiter.start();
        
        while (!threadWaiter.isWaiting) { //let them start
            sleep(1);
        }
        
        XCTAssertNil(threadWaiter.result)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer)
        bleDeviceInterface.receiveUpstream(receive: "hello\nOK\n".data(using: .utf8)!)
        timeTraveller.travel(by: 4)
        
        while (threadWaiter.isExecuting){ //wait for it to finish
            sleep(1)
        }
        XCTAssertNotNil(threadWaiter.result)
        XCTAssertTrue(threadWaiter.wasOK)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer) //confirm that it is consumed
        
        if let theResult = threadWaiter.result
        {
            XCTAssertEqual(theResult, "hello\n".data(using: .utf8)!)
        }// Use XCTAssert and related functions to verify your tests produce the correct results.
        else
        {
            XCTAssert(false)
        }
        XCTAssertEqual(threadWaiter.leftover, "".data(using: .utf8)!)
    }
    
    func testwaitForOKResponse_GetsResponseWithoutOK()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface(dateGenerator: timeTraveller.generateDate)
        
        let threadWaiter = waitingforOKThread(ble: bleDeviceInterface);
        
        threadWaiter.start();
        
        while (!threadWaiter.isWaiting) { //let them start
            sleep(1);
        }
        
        XCTAssertNil(threadWaiter.result)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer)
        bleDeviceInterface.receiveUpstream(receive: "hello\nNOTOK\n".data(using: .utf8)!)
        timeTraveller.travel(by: 6)
        
        while (threadWaiter.isExecuting){ //wait for it to finish
            sleep(1)
        }
        XCTAssertNotNil(threadWaiter.result)
        XCTAssertFalse(threadWaiter.wasOK)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer) //confirm that it is consumed
        
        if let theResult = threadWaiter.result
        {
            XCTAssertEqual(theResult, "hello\nNOTOK\n".data(using: .utf8)!)
        }// Use XCTAssert and related functions to verify your tests produce the correct results.
        else
        {
            XCTAssert(false)
        }
        XCTAssertEqual(threadWaiter.leftover, "".data(using: .utf8)!)
    }
    
    func testwaitForOKResponse_GetsResponseOKAndSomeDataAfterwards()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface(dateGenerator: timeTraveller.generateDate)
        
        let threadWaiter = waitingforOKThread(ble: bleDeviceInterface);
        
        threadWaiter.start();
        
        while (!threadWaiter.isWaiting) { //let them start
            sleep(1);
        }
        
        XCTAssertNil(threadWaiter.result)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer)
        bleDeviceInterface.receiveUpstream(receive: "hello\nOK\nwhatIsThis\n".data(using: .utf8)!)
        timeTraveller.travel(by: 6)
        
        while (threadWaiter.isExecuting){ //wait for it to finish
            sleep(1)
        }
        XCTAssertNotNil(threadWaiter.result)
        XCTAssertTrue(threadWaiter.wasOK)
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer) //confirm that it is consumed
        
        if let theResult = threadWaiter.result
        {
            XCTAssertEqual(theResult, "hello\n".data(using: .utf8)!)
        }// Use XCTAssert and related functions to verify your tests produce the correct results.
        else
        {
            XCTAssert(false)
        }
        
        XCTAssertEqual(threadWaiter.leftover, "whatIsThis\n".data(using: .utf8)!)
       // XCTAssert(false) //what are we doing with the rest of the string? "whatIsThis\n"?
    }
    
    class MockDevice : ReceiveMessageDelegate
    {
        init(interface : BLEDeviceInterface)
        {
            theInterface = interface
        }
        var returnOK = true;
        func receiveStringFromUART(receive: Data) {
            if returnOK == true
            {
                theInterface.receiveUpstream(receive: "OK\n".data(using: .utf8)!)
            }
            else
            {
                theInterface.receiveUpstream(receive: "junkData\n".data(using: .utf8)!)
            }
        }
        
        let theInterface : BLEDeviceInterface
    }
    func testgetBLEMode()
    {
    //    let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface()
        
        let mode1 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode1, BLEMode.data); // no response
        
        let mockDevice = MockDevice(interface: bleDeviceInterface);
        bleDeviceInterface.theDevice = mockDevice;
        mockDevice.returnOK = true;
        
        let mode2 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode2, BLEMode.command); // gets a response
        
        XCTAssertNil(bleDeviceInterface.receivedDataBuffer) //confirm that it is consumed
        /*
        mockDevice.returnOK = false;
        
        let mode3 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode2, BLEMode.command); // gets a response
        
        */
    }
    
    func testgetBLEMode_withSimulatorAttached()
    {
        //let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface()
        let bleDeviceSimulator = BLEFriendSimulator();
        
        bleDeviceInterface.theDevice = bleDeviceSimulator.downstreamReceiver!
        bleDeviceSimulator.upStreamDevice = bleDeviceInterface.upstreamReceiver!
        
        bleDeviceSimulator.connectionMode = BLEMode.command; //setup command mode
        
        let mode1 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode1, BLEMode.command); // returns command mode
        
        bleDeviceSimulator.connectionMode = BLEMode.data; //setup data mode
        
        let mode2 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode2, BLEMode.data); // gets a response
        
        /*
         mockDevice.returnOK = false;
         
         let mode3 = bleDeviceInterface.getBLEMode()
         XCTAssertEqual(mode2, BLEMode.command); // gets a response
         
         */
    }
    
    func testtoggleAndGetBLEMode_withSimulatorAttached()
    {
        let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface()
        let bleDeviceSimulator = BLEFriendSimulator();
        
        bleDeviceInterface.theDevice = bleDeviceSimulator.downstreamReceiver!
        bleDeviceSimulator.upStreamDevice = bleDeviceInterface.upstreamReceiver!
        
        bleDeviceSimulator.connectionMode = BLEMode.command; //setup command mode
        
        let mode1 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode1, BLEMode.command); // returns command mode
        
        XCTAssertTrue(bleDeviceInterface.toggleBLEMode())
        let mode2 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode2, BLEMode.data); // gets a response
        
        XCTAssertTrue(bleDeviceInterface.toggleBLEMode())
        let mode3 = bleDeviceInterface.getBLEMode()
        XCTAssertEqual(mode3, BLEMode.command); // gets a response
        
        /*
         mockDevice.returnOK = false;
         
         let mode3 = bleDeviceInterface.getBLEMode()
         XCTAssertEqual(mode2, BLEMode.command); // gets a response
         
         */
    }
    
    func testqueryBLEInfo()
    {
       // let timeTraveller = TimeTraveller();
        let bleDeviceInterface = BLEDeviceInterface()
        let bleDeviceSimulator = BLEFriendSimulator();
        
        bleDeviceInterface.theDevice = bleDeviceSimulator.downstreamReceiver!
        bleDeviceSimulator.upStreamDevice = bleDeviceInterface.upstreamReceiver!
        
        bleDeviceSimulator.connectionMode = BLEMode.command; //setup command mode
        
        let response = bleDeviceInterface.getBLEInfo()
        
        if let concreteResponse = response
        {
            XCTAssertEqual("""
    To be, or not to be - that is the question;
    Whether 'tis nobler in the mind to suffer
    The slings and arrows of outrageous fortune,
    Or to take arms against a sea of troubles,

    """, concreteResponse)
        }
        else
        {
            XCTAssert(false)
        }
        
    }

    func testreadNVMDataDirectCall()
    {
        let inputData : MessagePackValue = ["ver" : 1.0, "deviceName" : "testing"];
        let packedData = pack(inputData);
    
        let bleDeviceInterface = BLEDeviceInterface()
        let bleDeviceSimulator = BLEFriendSimulator();
        
        bleDeviceInterface.theDevice = bleDeviceSimulator.downstreamReceiver!
        bleDeviceSimulator.upStreamDevice = bleDeviceInterface.upstreamReceiver!
        
        bleDeviceSimulator.connectionMode = BLEMode.command; //setup command mode
        
        
        let response = bleDeviceInterface.readNVMData(packedNVMData: packedData)
        XCTAssert(response != nil)
        XCTAssertEqual(response?.count, 2)
        XCTAssertEqual(response?["ver"], 1.0);
        XCTAssertEqual(response?["deviceName"], "testing");
    }
    
   // func readNVMData(packedNVMData: Data) -> MessagePackValue?

    
}
