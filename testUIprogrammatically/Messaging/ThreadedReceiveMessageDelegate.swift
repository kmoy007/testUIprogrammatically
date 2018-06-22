//
//  ThreadedReceiveMessageDelegate.swift
//  testUIprogrammatically
//
//  Created by Ken Moynihan on 10/06/18.
//  Copyright © 2018 Ken Moynihan. All rights reserved.
//

import Foundation


class ThreadedReceiveMessageDelegate<T : ReceiveMessageDelegate> : Thread
{
    init(theObject : T)
    {
        m_theObject = theObject
        super.init()
        start();
    }
    
    var receivedDataBuffer : Data?
    
    let m_theObject : T;
    let messageReceivedCondition = NSCondition()
    let threadStartedCondition = NSCondition()
    let threadStoppedCondition = NSCondition()
    var threadIsRunning = false;
    
    func receiveStringFromUART(receive: Data)
    {
        /*if theThread == nil
         {
         theThread = ThreadedReceiveMessageDelegate<ElectronSimulator>(theObject: self)
         theThread?.start();
         }*/
        
        if (receivedDataBuffer != nil)
        {
            receivedDataBuffer!.append(receive)
        }
        else
        {
            receivedDataBuffer = receive
        }
        messageReceivedCondition.signal();
    }
    
    func blockTillThreadStarted(timeToWait: TimeInterval) -> Bool
    {
        threadStartedCondition.lock();
        while (!threadIsRunning)
        {
             threadStartedCondition.wait(until:Date() + timeToWait)
        }
        
        threadStartedCondition.unlock();
        return threadIsRunning
    }
    
    func blockTillThreadStopped(timeToWait: TimeInterval) -> Bool
    {
        threadStoppedCondition.lock();
        if (threadIsRunning)
        {
            threadStoppedCondition.wait(until:Date() + timeToWait)
        }
        threadStoppedCondition.unlock();
        return !threadIsRunning
    }
    
    override func cancel()
    {
        super.cancel()
        messageReceivedCondition.signal()
    }
    
    override func main()
    {
        threadIsRunning = true;
        threadStartedCondition.signal()
        var shouldQuit = false;
        while (!shouldQuit)
        {
            messageReceivedCondition.lock()
            while(receivedDataBuffer == nil) && !isCancelled
            {
                messageReceivedCondition.wait(until: Date() + 1)
            }
            if (isCancelled)
            {
                shouldQuit = true;
                continue;
            }
            
            assert(receivedDataBuffer != nil, "::thread receivedDataBuffer is nil")
            m_theObject.receiveStringFromUART(receive: receivedDataBuffer!)
            receivedDataBuffer = nil;
            messageReceivedCondition.unlock()
        }
        threadIsRunning = false;
        threadStoppedCondition.signal()
    }
}
